/**
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


            var event = 'hashchange';
            //var event = 'hashchange';
            // Bind an event to window.onhashchange that, when the history state changes
            // will implament onpopsate event and history if the feature is implemented
            // but now, few browsers support it
            // detect it with Modernizr.history 
            $(window).bind(event, function (e) {
                d4p.uriChanged();
            });

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

})(window);