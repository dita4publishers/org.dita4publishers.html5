 /**
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
      if (l.hash != undefined) {
         d4p.scrollToHash('#' + l.hash);
      }
    },

    init: function () {

      d4p.ajax = new d4p.ajaxLoader();
      d4p.ajax.name = 'main';
      
      d4p.ajax.addLoader();
      d4p.ajax.bind('filter', 'rewriteAttrHref');
      d4p.ajax.bind('filter', 'rewriteAttrSrc');
      d4p.ajax.bind('ready', 'setTitle');
      
      this.bind('uriChange', 'load');
      this.traverse();
      
    }
  });

})(window, d4p);