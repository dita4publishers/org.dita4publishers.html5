/**
 *  @file d4p.ajaxLoader
 *
 *  This object is used to perform ajax call on page
 *  Could be instantiated and act uppon context
 *
 *  Copyright 2012 DITA For Publishers  
 * 
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */ (function (window, d4p) {

    /**
     * d4p.ajax constructor
     * multiple instance of this object are possible
     */
    d4p.ajaxLoader = function (opts) {

		this.name = '';
        this.outputSelector = d4p.outputSelector;
        this.title = '';
        this.content = '';
        this.externalContentElement = d4p.externalContentElement;
        this.timeout = d4p.timeout;
        this.modified = true;

        // events    
        this._filter = [];
        this._before = [];
        this._ready = [];
        this._live = [];
        this._failed = [];
        this._postFilter = [];

        // store references
        this.collection = [],

        /**
         * ajax mode
         * - replace
         * - appends
         */
        this.mode = 'replace';

        $.extend(true, this, opts);
        this.setAriaAttr();

    };
	// Set outputSelector
    d4p.ajaxLoader.prototype.focus = function () {
        $(this.id).focus();
    },


    // Set outputSelector
    d4p.ajaxLoader.prototype.setOutputSelector = function (selector) {
        this.outputSelector = selector;
    },

    // allows to set the timeout
    d4p.ajaxLoader.prototype.setTimeout = function (ms) {
        this.timeout = ms;
    };

    // allow to bond event
    // live, ready, failed, filter
    d4p.ajaxLoader.prototype.bind = function (key, fname) {
        this['_' + key].push(fname);
    },

    // add loader (spinner on the page)
    d4p.ajaxLoader.prototype.addLoader = function () {
        var node = $("<div />").attr("id", "d4p-loader");
        $(d4p.loaderParentElement).append(node);
    };

    // set ARIA attributes on the ajax container
    // for accessibility purpose
    d4p.ajaxLoader.prototype.setAriaAttr = function () {
        $(this.outputSelector).attr('role', 'main')
            .attr('aria-atomic', 'true')
            .attr('aria-live', 'polite')
            .attr('aria-relevant', 'all');
    };

    // called before the ajax request is send
    // used to output a 'loader' on the page  
    d4p.ajaxLoader.prototype.contentIsLoading = function () {
        $("#d4p-loader").show();
        $(this.outputSelector).css('opacity', d4p.transition.opacity);
    };

    // called at the end of the ajax call
    d4p.ajaxLoader.prototype.contentIsLoaded = function () {
        $("#d4p-loader").hide();
        $(this.outputSelector).css('opacity', 1);
    };

    // Add entry into the collection
    d4p.ajaxLoader.prototype.collectionSet = function (refpath, uri, id, refid, title) {
        if (this.collection[refpath] == undefined) {
            this.collection[refpath] = {
                'cache': false,
                'uri':  uri,
                'id': id,
                'refid' : refid,
                'title': title
            };
        }
    };

    // Add entry into the collection
    d4p.ajaxLoader.prototype.setCacheStatus = function (refpath) {
        this.collection[refpath].cache = true;
    };

    // tell if id is cached
    d4p.ajaxLoader.prototype.isCached = function (refpath) {
    	var ret = false;
        if(this.inCollection(refpath)){
            ret = this.collection[refpath].cache;
        }
        return ret;
    };
    
    // Add entry into the collection
    d4p.ajaxLoader.prototype.getCollection = function (refpath) {
        return this.collection[refpath];
    };
    
    // Add entry into the collection
    d4p.ajaxLoader.prototype.inCollection = function (refpath) {
        return this.collection[refpath] == undefined ? false : true;
    };

    // Set title of the page
    d4p.ajaxLoader.prototype.setTitle = function () {
        $('title').html(this.title);
        // replace title in collection, may be more accurate
        this.collection[this.refpath]['title'] = this.title;
    },

    // set content of the page
    // this function use the hash value as an ID
    d4p.ajaxLoader.prototype.setMainContent = function () {
        var id = this.refpath.replace(/\//g, '__'),
            div = $("<div />").attr('id', id).attr('class', 'content-chunk').html(this.content),
            fn = {};


        // execute ajaxLive
        // perform all tasks which may require
        // content to be inserted in the DOM
        for (i in this._live) {
            if (this._live.hasOwnProperty(i)) {
                fn = this._live[i];
                this[fn].call(this, d4p.content);
            }
        }

        if (this.mode == 'append') {
            // append new div, but hide it
            $(this.outputSelector).append(div);
            this.setCacheStatus(this.refpath);
        } else {
            $(this.outputSelector).html(div.html());
        }

    },

    // Rewrite each src in the document
    // because there is no real path with AJAX call
    // from http://ejohn.org/blog/search-and-dont-replace/
    d4p.ajaxLoader.prototype.rewriteAttrSrc = function () {
        var l = d4p.l(), uri = "";
        this.responseText = this.responseText.replace(/(src)\s*=\s*"([^<"]*)"/g, function (match, attr, src) {
            var parts = src.split("/"), nhref = '';
            uri = uri.substring(1, uri.length);
            if(d4p.protocols.indexOf(parts[0]) !== -1) {
                nhref = src;
            } else {
                nhref = uri.substring(1, uri.lastIndexOf("/")) + "/" + src;   
            }
            return attr + '="' + nhref + '"';
        });
    },

    // Rewrite each src in the document
    // because there is no real path with AJAX call
    // from http://ejohn.org/blog/search-and-dont-replace/
    d4p.ajaxLoader.prototype.rewriteAttrHref = function () {
        var o = this;
        this.responseText = this.responseText.replace(/(href)\s*=\s*"([^<"]*)"/g, function (match, attr, href) {
			
            var l = d4p.l(),
                newHref = '',
                uri = l.uri.substring(1, l.uri.length),
                list = href.split("/"),
                dir = d4p.basename(uri),
                idx = href.indexOf(uri),
                base = dir.split("/"),
                i = 0,
                parts = '',
                Array = [],
                pathC = [],
                nPath = [],
                pId = '';
                
            base.clean("");

            // rewrite anchors #abc => #/abc
            // do not rewrite external or absolute
            if (href.substring(0, 1) == '#' || d4p.protocols.indexOf(list[0]) != -1 || href.substring(0, 1) == '/') {
            
                newHref = href;

                 
            } else {

                href = href.replace(d4p.ext, '');

                // anchors on the same page
                if (idx == 0) {
                    newHref = '#/' + href;
                } else {

                    parts = href.split('/');
                    nPath = parts;


                    for (i = 0, len = parts.length; i < len; i = i + 1) {
           
                        if (parts[i] === '..' || (parts[i] === '')) {
                            nPath[i] = '';
                            base[base.length - 1] = '';
                        }
                        
                        if (parts[i] === 'index') {
                            nPath[i] = '/home';
                        }
                        
                    }
                    
                    nPath.clean('');
                    base.clean('');

                    pathC = dir != '' ? base.concat(nPath) : Array.concat(nPath);
                    pId = o.collection[l.uri].id;
                    o.collectionSet("/"+pathC.join('/'), pathC.join('/') + d4p.ext, '', o.title);
                    newHref = '#/' + pathC.join('/');
                }
            }
			
            return attr + '="' + newHref + '"';
        });
    },

    /**
     * this is a based from the load function of jquery
     *
     * @param uri: the uri to load
     * @paran hash: the hash to scroll to after the load
     * @todo: see if it is neccessary to implement cache here
     * @todo: implement beforeSend, error callback
     */
    d4p.ajaxLoader.prototype.load = function (uri, hash) {
        var fn = {}, i = 0;      
        this.uri = this.collection[uri].uri;
        this.refpath = uri;
        this.hash = hash;

        // todo: implement cache method
        if (this.isCached(uri)) {
            return true;
        }

        // call ajax before callbacks
        for (i in this._before) {
            if (this._before.hasOwnProperty(i)) {
                fn = this._before[i];
                this[fn].call(this, uri, hash);
            }
        }

        // set aria status
        $(this.outputSelector).attr('aria-busy', 'true');

        $.ajax({

            type: 'GET',

            context: this,

            cache: true,

            ifModified: this.modified,

            timeout: this.timeout,

            url: this.uri,

            dataType: 'html',

            data: {
                ajax: "true"
            },

            beforeSend: function (jqXHR) {
                this.contentIsLoading();
            },

            complete: function (jqXHR, status, responseText) {
			
                // is status is an error, return an error dialog
                if (status === 'error' || status === 'timeout') {

                    this.contentIsLoaded();

                    document.location.hash = d4p.hash.previous;

                    // ajax failed callback
                    for (i in this._failed) {
                        if (this._failed.hasOwnProperty(i)) {
                            fn = this._failed[i];
                            this[fn].call(this, status, responseText);
                        }
                    }

                    return false;
                }

                // Store the response as specified by the jqXHR object
                responseText = jqXHR.responseText;

                // If successful, inject the HTML into all the matched elements
                if (status == "success") {

                    // From jquery: #4825: Get the actual response in case
                    // a dataFilter is present in ajaxSettings
                    jqXHR.done(function (r) {
                        this.responseText = r;
                    });

                    // execute filter on response before adding it to a DOM object
                    for (i in this._filter) {
                        if (this._filter.hasOwnProperty(i)) {
                            fn = this._filter[i];
                            this[fn].call(this, this.responseText);
                        }
                    }

                    // remove scripts from the ajax calls unless they will be loaded
                    this.html = $(this.responseText).not('script');

                    this.content = this.html.find(this.externalContentElement);

                    this.title = this.html.find("title").html();
                    
                    // execute ajaxReady
                    for (i in this._postFilter) {
                        if (this._postFilter.hasOwnProperty(i)) {
                            fn = this._postFilter[i];
                            this[fn].call(this);
                        }
                    }

                    this.setMainContent();

                    // execute ajaxReady
                    for (i in this._ready) {
                        if (this._ready.hasOwnProperty(i)) {
                            fn = this._ready[i];
                            this[fn].call(this);
                        }
                    }

                    this.contentIsLoaded();

                    $(this.outputSelector).attr('aria-busy', 'false');
                    
                    if (this.hash != undefined) {
                      d4p.scrollToHash('#' + this.hash);
                    }

                }
            }
        });
    };

})(window, d4p);