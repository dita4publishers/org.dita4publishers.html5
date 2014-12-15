/**
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
d4p.setBodyClassfunction = function (i, width) {
  var cs = '';
  $("html").removeClass (function (index, css) {
    return (css.match (/size-[a-z]+/g) || []).join(' ');
  });

  switch(i)
  {
  case 0:
    cs = 'size-small';
    break;
  case 1:
  case 2:
    cs = 'size-medium';
    break;
  case 3:
  case 4:
    cs = 'size-large';
    break;
  default:
     cs = 'size-x-large';
  }
  $("html").addClass(cs);
}

d4p.getDocumentationRoot = function ()
{
  var loc = window.location.pathname;
  return loc.substring(0, loc.lastIndexOf('/')) + '/' + (d4p.relativePath == null ? '' : d4p.relativePath);
}
