/**
 *  @file <filename>
 *
 *  <description>
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
 */
Array.prototype.clean = function (s) {
    var i = 0;
    for (var i = 0; i < this.length; i++) {
        if (this.hasOwnProperty(i)) {
            if (this[i] == s) {
                this.splice(i, 1);
                i = i-1;
            }
        }
    }
    return this;
};

// @see https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Global_Objects/Array/IndexOf
if (!Array.prototype.indexOf) {
    Array.prototype.indexOf = function (searchElement /*, fromIndex */ ) {
        "use strict";
        if (this == null) {
            throw new TypeError();
        }
        var t = Object(this);
        var len = t.length >>> 0;
        if (len === 0) {
            return -1;
        }
        var n = 0;
        if (arguments.length > 1) {
            n = Number(arguments[1]);
            if (n != n) { // shortcut for verifying if it's NaN
                n = 0;
            } else if (n != 0 && n != Infinity && n != -Infinity) {
                n = (n > 0 || -1) * Math.floor(Math.abs(n));
            }
        }
        if (n >= len) {
            return -1;
        }
        var k = n >= 0 ? n : Math.max(len - Math.abs(n), 0);
        for (; k < len; k++) {
            if (k in t && t[k] === searchElement) {
                return k;
            }
        }
        return -1;
    }
}/**
 *  @file d4p
 *
 *  Allow to set global properties and methods for the d4p project
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
 */
 if ( ! window.console ) console = { log: function(){} };
 
(function (window) {

    var d4p = {

        'version': '0.3a',

        'inited': false,

        // is initial content should be loaded after init()
        'loadInitialContent': true,

        // hash
        'hash': {
            'current': '',
            'previous': ''
        },

        'ext': '.html',

        'timeout': 30000,

        // main output selectors
        'outputSelector': '#d4h5-main-content',

        // local navigation selector
        'navigationSelector': '#local-navigation',

        // external content element
        'externalContentElement': 'section',

        //
        'loaderParentElement': 'body',

        'protocols': ['http:', 'https:', 'file:', 'ftp:'],


        // used to attribute and id to the navigation tree
        // if none are specified, this should make jQuery selection faster
        'ids': {
            'n': 0,
            'prefix': 'd4p-page',
            'prefixLink': 'd4p-link'
        },

        // default values for transitions
        'transition': {
            'speed': 'slow',
            'opacity': 0.5
        },

        'relativePath': '',

        // registered modules
        'mod': [],

        // uri change functions
        'euriChange': [],

        // scrollElement
        'scrollElem': {},
        
        // document information
        'document': {},

        //scroll duration in ms
        'scrollDuration': 400,

        // index filename
        'indexFilename': 'index.html',

        // register a module init function will be called
        // once document is loaded.
        // I added this feature to allow user to set options
        // before their module are called.
        'edocReady': [],
        
        'tabIndex': 10,

        docIsReady: function () {
            var i = {}, fn = {};
            for (i in this.edocIsReady) {
                if (this.edocIsReady.hasOwnProperty(i)) {
                    fn = d4p.edocIsReady[i];
                    fn.call(this, this.uri, this.hash.current);
                }
            }
        },

        // l current hash and return the uri + the hash
        l: function () {
            var r = document.location.hash.substring(1), s = [], o = {}, v = false;
            if (r !== '') {
                s = r.split('#');
                v = s[0].substring(0, 1) === "/" ? true : false; 
                o = {
                    'uri': s[0],
                    'hash': s[1] !== undefined ? s[1] : '',
                    'id': s[0].replace(/\//g, '__'),
                    'virtual': v
                };
            } else {
                o = {
                    'uri': '',
                    'hash': '',
                    'id': '',
                    'virtual': v
                };
            }
            return o;
        },

        show: function (id) {
            $("#" + id).show();
        },

        // find if an element is scrollable
        // from http://css-tricks.com/snippets/jquery/smooth-scrolling/
        scrollableElement: function () {
            var i = 0, argLength = arguments.length, el = '', isScrollable = false, scrollElement = {};
            for (i = 0, argLength; i < argLength; i = i + 1) {
                if (arguments.hasOwnProperty(i)) {
                    el = arguments[i];
                    scrollElement = $(el);

                    if (scrollElement.scrollTop() > 0) {
                        return el;
                    } else {
                        scrollElement.scrollTop(1);
                        isScrollable = scrollElement.scrollTop() > 0;
                        scrollElement.scrollTop(0);

                        if (isScrollable) {
                            return el;
                        }
                    }
                }
            }
            return [];
        },

        // scroll to hash
        scrollToHash: function (hash) {
            var targetOffset = {};
            if (hash !== "" && hash !== undefined && hash !== null && hash !== '#') {
                targetOffset = $(hash)
                    .offset()
                    .top;
                $(d4p.scrollElem)
                    .animate({ scrollTop: targetOffset }, d4p.scrollDuration);
            }
        },

        // extend the d4p objects
        // need to rewrite
        setProps: function (options) {
            var key = {}, kl2 = {}, val = {}, val2 = {};
            for (key in options) {
                if (options.hasOwnProperty(key)) {
                    val = options[key];
                    if (typeof val !== 'object') {
                        d4p[key] = val;
                    } else {
                        for (kl2 in val) {
                            val2 = val[kl2];
                            d4p[key][kl2] = val2;
                        }
                    }
                }
            }
        },

        // check if a jQuery object has an id or create one
        vlink: function (obj) {
            var objId = obj.attr('id'),
            objHref = obj.attr('href'),
            href = objHref.substring(0, objHref.length - d4p.ext.length),
            hrefID = "/"+ href,
            id = hrefID.replace(/\//g, '__');

            // create an ID for future reference if not set
            if (objId === '' || objId == undefined) {
                objId = d4p.ids.prefixLink + d4p.ids.n;
                d4p.ids.n++;
            };

            return {
                'linkID': objId,
                'href': objHref,
                'hrefID': hrefID,
                'id': id
            };

        },

        // set AJAX callback on the specified link obj.
        live: function (obj) {

            /*  obj.live('click', function (e) {
				
				e.preventDefault();
				console.log("uri %s", obj.attr('href'));
				
               // And finally, prevent the default link click behavior by returning false.
               return false;
           });*/
        },

        // load initial content to avoid a blank page
        getInitialContent: function () {
            var l = d4p.l();
           
            if (l.uri !== '') {
              d4p.uriChanged(l.uri, l.hash);
              return true;
            }
            
            if ($(d4p.outputSelector).length == 1 && d4p.loadInitialContent) {
               
				var el = $(d4p.navigationSelector + ' a:first-child');
                if (el.attr('href') == undefined) {
                    return false;
                }
                url = $(d4p.navigationSelector + ' a:first-child')                         
                	.attr('href')
					.replace(/^#/, '');
                    document.location.hash = url;
                
               	d4p.loadInitialContent = false;
            }
            
          
        },
        
        getDocInfos: function () {
        	this.document['title'] = $('title').html();
        },
        
        // execute callbacks function on uri changed
        uriChanged: function (uri, hash) {
            var l = d4p.l();
            for (i in d4p.euriChange) {
                if (d4p.euriChange.hasOwnProperty(i)) {
                   var fn = d4p.euriChange[i];
                   d4p[fn.name][fn.fn].call(d4p[fn.name], l.uri, l.hash);
                }
            }
            d4p.hash.previous = hash;
        },

        // init d4p objects and all modules
        init: function (options) {

            var l = this.l(),
                i = '',
                redirect = false,
                fn = {};
            
            //prevent double initialization
            if (this.inited) {
                return false;
            }

            // extend options
            this.setProps(options);

			// get document information
			 this.getDocInfos();

			
            // redirect if not on the index page
            if (d4p.relativePath != "" && l.uri.indexOf(d4p.indexFilename) != 0) {
                redirect = d4p.resolveRoot();
                document.location = redirect;
                return true;
            }

            //
            this.scrollElem = this.scrollableElement('html', 'body');

            // initialize
            for (i in this.mod) {
                if (this.mod.hasOwnProperty(i)) {
                    fn = this.mod[i];
                    this[fn].init.call(this[fn]);
                }
            }
           
            //var event = 'hashchange';
            // Bind an event to window.onhashchange that, when the history state changes
            // will implament onpopsate event and history if the feature is implemented
            // but now, few browsers support it
            // detect it with Modernizr.history           
            if (!("onhashchange" in window) || (document.documentMode == 7 )) {
    			setInterval("d4p.uriChanged()", 250);
			} else if (window.addEventListener) {
    			window.addEventListener("hashchange", d4p.uriChanged, false);    			   
			} else if (window.attachEvent) {
    			window.attachEvent("onhashchange", d4p.uriChanged);       				   
			}

            this.getInitialContent();
            
            this.inited = true;

            return true;

        },

        filename: function (uri) {
            return uri.substring(uri.lastIndexOf('/') + 1);
        },

        basename: function (uri) {
            return uri.substring(0, uri.length - this.filename(uri).length);
        },

        resolveRoot: function () {

            var url = document.location.toString(), basename = d4p.basename(url), s = basename.split("/"), c = d4p.relativePath.match(/\.\./g), a = s.splice(0, s.length - 1 - c.length), furl = a.join("/"), filename = url.substring(furl.length + 1).replace(d4p.ext, '');
            return location.protocol == 'file:' ? a.join("/") + "/" + d4p.indexFilename + "#" + filename : a.join("/") + "/" + "#" + filename;

        }

    };


    window.d4p = d4p;

})(window);/**
 *  @file module
 *
 *  Allow to instantiate a module to work with the d4p Object
 *  The d4p object will automatically initialize the module.
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
 */ 
(function (window, d4p) {

  d4p.module = function (name, obj) {
    
    var i = 0;
    this.name = name;

    // set option
    for (i in obj) {
      if (this[i] == undefined) {
        this[i] = obj[i];
      }
    }

    // register component in d4p	
    if (this.init != undefined) {
      d4p.mod.push(name);
    }

    d4p[name] = this;

  };

  // deprecated
  d4p.module.prototype.hash = function () {
    return document.location.hash.substring(1);
  };

  // register document ready function
  // possible key: uriChange, docChange
  d4p.module.prototype.bind = function (key, fname) {
    d4p['e'+key].push({
      name: this.name,  // module name
      fn: fname         // function name to call
    });
  };

})(window, d4p);/**
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

})(window, d4p); /**
 *  @file ajax.navigation
 *
 *  Starting in an element, grab all links and trigger ajax call
 *  The links are kept as a collection in the AJAX object
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
 */ 
(function (window, d4p) {

  /**
   * This is the core of the main ajax navigation
   */
  var ajaxnav = new d4p.module('ajaxnav', {

    traverse: function () {
      
      // navigation: prefix all href with #
      $(d4p.navigationSelector + ' a').each(function (index) {

        var href = $(this).attr('href'), 
        list = href.split("/"),
        except = $(this).hasClass('d4p-no-ajax'),
        
        // ids.linkID;
        // ids.hrefID;
      
        v = d4p.vlink($(this));

        // attribute an ID for future reference if not set
        $(this).attr('id', v.linkID);
          

        // do not rewrite anchors and absolute uri
        // @todo check for absolute uri
        if (href.substring(0, 1) != '#' && d4p.protocols.indexOf(list[0]) == -1 && except==false) {
          // add it in the collection
          d4p.ajax.collectionSet(v.hrefID, v.href, v.id, v.linkID, $(this).html());
          $(this).attr('href', '#' + v.hrefID);

        }

        d4p.live($(this));

      });


      //span.navtitle 
      // note sure that theses lines belongs to this modules

      $(d4p.navigationSelector).find('li').each(function (index) {
          var l = '';
        if ($(this).children('a').length === 0) {
          l = $(this).find('ul li a:first');
          if (l.length == 1) {
            $(this).children('span.navtitle').click(function () {
              d4p.ajax.load(l.attr('href').replace(/^#/, ''));
            });
          }
        }
      });
    },

    load: function () {
      var l = d4p.l(),
      o = d4p.ajax.getCollection(l.uri);
      if (o != undefined && o.cache == false) {
        d4p.ajax.load(l.uri, l.hash);
      }
     
    },

    init: function () {

      d4p.ajax = new d4p.ajaxLoader();
      d4p.ajax.name = 'main';
      
      d4p.ajax.addLoader();
      
      d4p.ajax.bind('filter', 'rewriteAttrHref');
      d4p.ajax.bind('filter', 'rewriteAttrSrc');
      d4p.ajax.bind('ready', 'setTitle');
      
      d4p.ajax.bind('ready', 'focus');
      this.bind('uriChange', 'load');

      this.traverse();
      
    }
  });

})(window, d4p);/**
 *  @file message
 *
 *  Allow to send quick message to the user
 *  Might have an alternate version to work with UI dialog
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
 */ 
(function (d4p) {

    // Set outputSelector
    d4p.ajaxLoader.prototype.setErrorMsg = function (responseText, status) {
        var msg = status === 'timeout' ? 'Sorry, the content could not be loaded' : 'Sorry, the server does not respond.';
        d4p.msg.alert(msg, 'error');
    };
                    
  // use ui-dialog instead ?

  var message = new d4p.module('msg', {
    // id of the div element to be created
    'id': 'd4p-message',

    'timeout': 3000,

    // message type
    create: function () {
      var msgBox = $("<div />")
        .attr('id', this.id)
        .attr('role', 'alertdialog')
        .attr('aria-hidden', 'true')
        .attr('aria-label', 'Message')
        .addClass('rounded')
        .hide(), 
      div = msgBox.append($("<div />"));
      $('body')
        .append(msgBox);
    },

    // create message container    
    init: function () {
    
      this.create();
	  d4p.ajax.bind('failed', 'setErrorMsg');
	  
      $(document).mouseup(function (e) {
        var container = $(this.id);

        if (container.has(e.target).length === 0) {
          container.hide();
        }
      });
    },

    show: function () {
      $("#" + this.id)
        .show()
        .attr('aria-hidden', 'false')
        .delay(this.timeout)
        .fadeOut()
        .attr('aria-hidden', 'true');
    },

    alert: function (msg, type) {
      var p = {};
      type = type == undefined ? '' : type;
      p = $("<p />")
        .addClass(type)
        .text(msg);
      $("#" + this.id + " > div")
        .html(p);
      this.show();
    }
  });

})(d4p);/**
 *  @file jQuery UI adapter
 *
 *  Allows to interact with the DITA <-> jQuery UI library
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
 */ 
(function (d4p) {

  // new prototype
  // register a hashChange callback
  d4p.ajaxLoader.prototype.addWidgets = function () {
    this.content.find("*[class]").each(function (index) {
      var classes = $(this)
        .attr('class')
        .split(" ");

      for (var i = 0, len = classes.length; i < len; i++) {

        var cs = classes[i];
        var idx = cs.indexOf(d4p.ui.prefix);
        var l = d4p.ui.prefix.length;

        if (idx >= 0) {

          var ui = cs.substring(l);

          if (d4p.ui[ui] == undefined) {
            return true;
          }

          if (d4p.ui[ui]['init'] != undefined) {
            d4p.ui[ui]['init'].call(d4p.ui[ui], $(this));
          }
        }
      }
    });
  };
  
})(d4p);

/**
 * interface with ui
 */ 
(function (d4p) {

  var ui = new d4p.module('ui', {

    // prefix
    prefix: "d4p-ui-",

    dialogMinWidth: 600,

    processed: [],

    //    
    init: function () {
      d4p.ajax.bind('ready', 'addWidgets');
    }
  });
})(d4p);/**
 *  @file accordion.js
 *
 *  adapter for jquery UI accordion
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
 */ 
(function (d4p, document) {

  d4p.ui.accordion = {

    init: function (obj) {
      var cs = '';
      if (obj.hasClass('concept')) {
        cs = '> div.topic > h2';
      } else {
        cs = '> div.section > h2';
      }
      obj.accordion({
        header: cs,
        heightStyle: 'content',
        active: false,
        collapsible: true
        //,
        //change: function( event, ui ) {
        //	var l = d4p.l(), hash = l.uri;
        //	if(l.hash != '') {
        //		window.location.hash = hash;
        //	}
       // } 
      });
    }
  };

})(d4p);/**
 *  @file dialog
 *
 *  dialog adapter for jQuery UI
 *  As its own instance of the d4p.ajaxLoader
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
 */ 
(function (d4p) {

    // Remove links on dialogs
    d4p.ajaxLoader.prototype.removeLinks = function () {
        var uri = d4p.hash.current;
        this.content.find("a").each(function(index) {
      		$(this).replaceWith(this.childNodes);
    	});
    };

    d4p.ui.dialog = {

        ids: 0,
        
        done: {},

        init: function (obj) {
        
        	var uri = '', id = '', href='';

            if (obj[0].tagName.toUpperCase() === "DFN") {
                obj = obj.parent();
            }
		
			href = obj.attr('href');
			href = href.substring(0,1) == '#' ? href.substring(1) : href;
            uri = d4p.ajax.collection[href].uri;
                      
            id = this.getId();

            // keep track of every external dialog loaded
            if (this.done[uri] == undefined) {
                this.done[uri] = {
                    'id': id,
                    'uri': uri,
                    'done': false
                };
            }

            if (this.checkDialog(obj, uri)) {
                this.dialog(obj, uri);
            }

        },

        getId: function () {
            this.ids++;
            return this.ids;
        },

        checkDialog: function (obj, uri) {
			
            // avoid processing url twice
            if (this.done[uri].done == true) {

                if (uri != "") {
                    obj.attr('href', "#");

                    // add click handler
                    obj.click(function (event) {
                     	event.preventDefault();
                        $("#dialog-" + d4p.ui.dialog.done[uri].id).dialog('open');
                    });
                }
                return false;
            } else {
                return true;
            }
        },

        dialog: function (obj, uri) {
            // add dialog
            var ajax = new d4p.ajaxLoader(),
            id = this.done[uri].id, 
			dialog = $("<div />").attr("id", "dialog-" + id);
			
			ajax.name = 'dialog';
			ajax.collectionSet(uri, uri, id, id, "");
            
            ajax.bind('ready', 'rewriteAttrSrc');
            ajax.bind('postFilter', 'removeLinks');

            $(d4p.ajax.loaderParentElement).append(dialog);

            ajax.setOutputSelector("#dialog-" + id);
            ajax.load(uri);

            dialog.dialog({
                autoOpen: false,
                minWidth: d4p.ui.dialogMinWidth
            });

            dialog.dialog('close');

            // remove href
            obj.attr('href', "#");

            // add click handler
            obj.click(function (event) {
            	event.preventDefault();
                $("#dialog-" + id).dialog('open');
            });

            this.done[uri].done = true;
        }
    };


})(d4p);/**
 * 
 */
(function (d4p) {

	d4p.ajaxLoader.prototype.rewriteLangAttrHref = function (response) {
		var langHref = this.html.find("#ch-lang-url").attr('href');
		$("#ch-lang-url").attr('href', langHref);
	}; 

    var inav = new d4p.module('inav', {
   
		hideAll: function (id) {
			$('.content-chunk').hide();
		},
				
		show: function (id) {
			$("#"+id).show();
		},
		
		setAria: function () {
			$('.box-ico a').attr('aria-role', 'button');
		},
		
		load: function () {
			var o = this,
			l = d4p.l(),
			ret = d4p.ajax.inCollection(l.uri),
			id = '';
			
			this.hideAll();
									
			if(ret)	{
				$("#home").addClass('state-active');
				id = d4p.ajax.collection[l.uri].id;
				this.show(id);
			} else if(l.uri != '' && !ret)	{	
				$("#home").addClass('state-active');
				this.show(l.uri.substring(1));
			} else if (l.uri == '') {
				$("#home").removeClass('state-active');
			}
			
			return true;
			
		},
		goToHash: function () {
			var l = d4p.l(), 
			idx=0;
			
			$('#'+l.id).find(".ui-accordion-header").each(function(index, value){
				idx = $(this).parent().attr('id') == l.hash ? index : idx;
			});
			
			$(".d4p-ui-accordion").accordion( "option", "active", idx );
			$('#content-container-anchor').attr('tabindex', -1).focus();  

		},
		
        //    
        init: function () {
            d4p.ajax.mode = 'append';
             $('#ajax-content').prepend($('<a />').attr('id', 'ajax-content-anchor').attr('class', 'named-anchor').attr('name', 'ajax-content-anchor'));
             $('#content-container').prepend($('<a />').attr('id', 'content-container-anchor').attr('class', 'named-anchor').attr('name', 'content-container-anchor'));
             
            $('#home').find('.box-ico a').each(function(){
            	var hash = $(this).attr('href').substring(1, $(this).attr('href').length);
            	$(this).attr('role', 'button');
            	$(this).attr('href', '#/' + hash);
            	$(this).click(function(){
            	    var lang = $('html').attr('lang') == 'fr' ? 'en/my-info/' : 'fr/mon-info/';
            	                	    
            	    $(this).parent().siblings().removeClass('active');
            	    $(this).parent().addClass('active');
            	    $("#ch-lang-url").attr('href', "/"+lang+document.location.hash);  
            	});
            });
            
            
        	this.hideAll();
        	this.setAria();
        	this.bind('uriChange', 'load');
        	this.bind('uriChange', 'goToHash');
        	d4p.ajax.bind('ready', 'rewriteLangAttrHref');
        	this.load();
        }        
    });
})(d4p);

(function (d4p) {

	
 	var audience = new d4p.module('audience', {
 	
 		onClick: function() {
 		//  add on click event on header
 		//$("#audienceBtn").unbind('click');
 		
		$("#audienceBtn").click(function(e){
		    if($("#audience-widget").hasClass('active')) {
		    	$("#audience-widget").toggleClass('active');
		    	$("#audience-list").slideUp();
		    	$("#home").attr("tabindex",-1).focus();
		    } else {
				$("#audience-widget").toggleClass('active');
				$("#audience-list").slideDown().attr("tabindex",-1).focus();
			}
		});

 		},
 	
 	
 		
 		init: function() {
 		
 		window.group.init();
 		this.onClick();

 		$("#audience-widget").addClass('no-select');
 		
 		
		$('html').click(function(e){
			
			if($(e.target).parent().attr("id") == "audience-widget") { return; }
			
			if($("#audience-widget").hasClass('active')) { 
				$("#audience-widget").toggleClass('active');
			}
		});
	
 	 }
 	 });
})(d4p);


(function (d4p) {
 
 d4p.ui.analytic = {

    init: function (obj) {
      var l = d4p.l();
	     $(".ui-accordion-header").click(
			function(){
				var value = jQuery.trim(String($(this).text()));
				_gaq.push(['_trackEvent', 'my-info', l.uri, value, 1]);
		  }
		);
    }
  };
	
 	var analytic = new d4p.module('analytics', {
	
 	    load: function () {
			var l = d4p.l();
			_gaq.push(['_trackPageview', l.uri]);
		},
			
 		init: function() {
	       this.bind('uriChange', 'load');
 	    }
 	 });
})(d4p);
