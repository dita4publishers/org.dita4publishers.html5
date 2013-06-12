/**
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

})(d4p);