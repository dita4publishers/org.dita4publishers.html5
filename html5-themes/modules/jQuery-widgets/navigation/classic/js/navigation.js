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
var navigation = {
  // navigation object
  o:{},

  // navigation information, ex. selector
  nav: {
    id: '#local-navigation'
  },

  // class
  cs: {
    topichead: 'topichead',
    leaf: 'leaf',
    expand: 'fi fi-arrows-expand ',
    collapse: 'fi fi-arrows-compress ',
    close: 'fi fi-x-circle ',
    active: 'active',
    collapsed: 'collapsed',
    plus: 'fi-plus',
    minus: 'fi-minus'
  },

  // text value
  text: {
    expand: 'Expand All',
    collapse: 'Collapse All',
    close: 'Close Menu'
  },

  // toolbar information
  toolbar: {
    id: 'navToolBar',
    position: 'top',
    o: {}
  },

  // mobile toolbar information
  mobileToolbar: {
    sel: '.toggle-topbar a'
  },

  // buttons information
  buttons: {
    collapse: 'collapseBtn',
    expand: 'expandBtn',
    close: 'closeBtn'
  },

  // tell is the navigation is collapsed in mobile view
  collapsed: true,

  // animation transition speed
  transitionSpeed: 100,

  // traverse the navigation and add required semantic
  traverse: function () {

    var self = this;


    $(this.nav.id).children('ul').attr('role', 'tree');
    $(this.nav.id).find('ul').attr('role', 'group');

    $(this.nav.id).find('li').each(function (index) {
      var span = {}, span2 = {};

      $(this).attr('role', 'treeitem');

      // collapsible
      if ($(this).find('ul').length > 0) {

        // create span for icone
        span = $("<span/>").html(' ');
        span.addClass(self.cs.leaf);

        // add minus to actice and topicheas
        if($(this).hasClass(self.cs.active) || $(this).hasClass(self.cs.topichead))
        {
          span.addClass(self.cs.minus);
        } else {
          span.addClass(self.cs.plus);
        }

        $(this).prepend(span);

        $(this).children('span').on('click', function() {
         self.toggleState($(this).parent());
        });

        //self.toggleState($(this));
      }
    });
  },

  toggleState: function(obj) {
    // if collapsed
    if(obj.toggleClass(this.cs.collapsed).hasClass(this.cs.collapsed) && !obj.hasClass(this.cs.active))
    {
      obj.children('.'+this.cs.leaf).removeClass(this.cs.minus).addClass(this.cs.plus);
    } else {
      obj.children('.'+this.cs.leaf).removeClass(this.cs.plus).addClass(this.cs.minus);
    }
  },

  addToolbar: function () {
    this.toolbar.o = $('<div />').attr('id', this.toolbar.id).attr('class', 'toolbar hide-on-small' + this.toolbar.position)
    $(this.nav.id).prepend(this.toolbar.o);
  },

  addButtons: function () {
    var self = this,

    expandIco = $("<span/>").attr("class", this.cs.expand),
    collapseIco = $("<span/>").attr("class", this.cs.collapse),
    closeIco = $("<span/>").attr("class", this.cs.close),
    expand = $("<span/>").attr("class", "hidden").html(this.text.expand),
    collapse = $("<span/>").attr("class", "hidden").html(this.text.collapse),
    close = $("<span/>").attr("class", "hidden").html(this.text.close),
    btnExpand = $("<button/>").attr('id', this.buttons.expand),
    btnCollapse = $("<button/>").attr('id', this.buttons.collapse).hide(),
    btnClose= $("<button/>").attr('id', this.buttons.close);

    btnExpand.append(expandIco);
    btnExpand.append(expand);
    btnExpand.on('click tap',
     function(){
        $(self.nav.id).addClass('forced');
        $(self.nav.id).find('li').attr('aria-expanded', 'true');
        $('.'+self.cs.leaf).hide();
        $(this).hide();
        $('#'+self.buttons.collapse).show();
      }
    );

    btnCollapse.append(collapse);
    btnCollapse.append(collapseIco);
    btnCollapse.on('click', function(){
      $(self.nav.id).removeClass('forced');
      $(self.nav.id).find('li').removeAttr('aria-expanded');
      $('.'+self.cs.leaf).show();
      $(this).hide();
      $('#'+self.buttons.expand).show();
    });

    btnClose.attr('class', 'show-for-small right').append(closeIco).append(close).on('click tap',
      function(){
        self.menuCollapse();
    });

    $('#'+this.toolbar.id).append(btnExpand);
    $('#'+this.toolbar.id).append(btnCollapse);
    $('#'+this.toolbar.id).append(btnClose);
  },

    setButtonClickEvt: function ()
    {
      var self = this;
      $(this.mobileToolbar.sel).on('click', function(){
        if(self.collapsed)
        {
          $(self.nav.id).animate(
            {
              left: 0
            },
            this.transitionSpeed,
            function()
            {
              self.collapsed = false;
            }
          );
        }
      });
    },

    setCloseEvt: function ()
    {
      var self = this;
      $(document).on('mouseup tap', function (e)
      {
        if (!$(self.nav.id).is(e.target) // if the target of the click isn't the container...
          && $(self.nav.id).has(e.target).length === 0
          && !self.collapsed) // ... nor a descendant of the container
        {
           self.menuCollapse();
           self.collapsed = true;
        }
    });
  },

  menuCollapse: function()
  {
    var self = this;
    $(this.nav.id).animate(
      {
        left: '-100%'
      },
      this.transitionSpeed,
      function() {
        self.collapsed = true;
      }
    );
  },


  init: function () {
    this.traverse();
    this.addToolbar();
    this.addButtons();
    this.setButtonClickEvt();
    this.setCloseEvt();
  }
};
