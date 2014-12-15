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

/**
 * Create a Lunr index
 */
function searchIdx()
{
  this.idx = lunr(function () {
    this.field('title', { boost: 10 })
    this.field('desc', { boost: 5 })
    this.field('body')
  });
  this.str;
  this.data = {};
  this.searched = {};
}

/**
 * Request data serverside
 */
searchIdx.prototype.getData = function()
{
  var self = this;
  console.log(d4p.getDocumentationRoot() + 'search-index.json');
  $.getJSON(d4p.getDocumentationRoot() + 'search-index.json', function( data ) {
    self.data = data.idx;
    $.each(self.data.topics, function( index, value ) {
      self.idx.add(value);
    })
  });
}

/**
 * Search through the index
 */
searchIdx.prototype.search = function(str)
{
  this.str = str;
  this.searched = this.idx.search(str);
}

/**
 * Add a placeholder
 */
searchIdx.prototype.searchResultPlaceholder = function()
{
   var title = $('<h1/>').html(d4p.l.searchPageHeading),
   container = $('<div/>').attr('id', 'search_container');
   $('#page').append($('<div />').attr('id', 'search_result').attr('class', 'page').append(title).append(container).hide());
}

/**
 * output the search
 */
searchIdx.prototype.highlight = function(e)
{
  var regex = new RegExp('(' + this.str + ')', 'g');
  e.html(function(_, html) {
   return html.replace(regex, '<span class="highlight">$1</span>');
  });
}

/**
 * output the search
 */
searchIdx.prototype.output = function()
{
  var self = this;
  $('#search_container').html('');
  $.each(this.searched, function( index, obj ) {
      var a = $('<a/>').attr('href', d4p.getDocumentationRoot() + self.data.topics[obj.ref].href),
      title = $('<h2 />').html(self.data.topics[obj.ref].title),
      desc = $('<p/>').html(self.data.topics[obj.ref].desc),
      hr = $('<hr />');
      self.highlight(desc);
      a.append(title);
      $('#search_container').append(a).append(desc).append(hr);
  })
}


$(function() {
  var idx = new searchIdx(),
  closeBtn = $('<button />').attr('id', 'searchClose').attr('class', 'float_right').append($('<span />').attr('class', 'fi fi-x')).append($('<span />').html(d4p.l.close).attr('class', 'hidden')).hide();

  idx.getData();
  idx.searchResultPlaceholder();

  $('#search-text').after(closeBtn);

  closeBtn.on('click', function(){
    $('#page').children().show();
    $('#search_result').hide();
    $('#search-text').val('');
    $(this).hide();
   });

  $( "#search" ).submit(function( event ) {
    event.preventDefault();
  });

  $('#search-text').keyup(function( event ) {
    if($(this).val().length > d4p.search.minlength)
    {
      idx.search($(this).val());
      idx.output();
      $('#page').children().hide();
      $('#search_result').show();
      $('#searchClose').show();
    }
  });
});
