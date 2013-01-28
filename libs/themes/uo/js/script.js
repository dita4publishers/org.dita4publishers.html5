/**
 * toolbar
 */
(function (d4p) {

	d4p.ajaxLoader.prototype.rewritetoolBar = function (response) {
		var toolbar = this.html.find("#toolbar");
		$("#toolbar").html(toolbar.html());
	}; 
	
 	var toolbar = new d4p.module('toolbar', {
 	
 		id: 'toolbar',
 		
 	    parent: '#main-content',
 		
 		showOnHomePage: false,
 		
 		add: function() { 		
   			var div = $("<div />").attr('id', this.id).hide();
   			$(this.parent).prepend(div);		 			
 		},
 		
 		hide: function () {
 			$('#'+this.id).hide();
 		},
 		
 		show: function () {
 			var l = d4p.l();
 			if(l.uri == '' && this.showOnHomePage) {
 				$('#'+this.id).show();
 			}else if(l.uri == '' && !this.showOnHomePage) {
 				this.hide();
 			}else if(l.uri == '/home' && !this.showOnHomePage) {
 				this.hide();
 			}else if(l.uri != '') {
 				$('#'+this.id).show();
 			}			
 		},
 		
 		init: function() {
 			d4p.ajax.bind('ready', 'rewritetoolBar');
 			this.add();
 			this.bind('uriChange', 'show');
 			this.show();
 		}	
 	
 	 });
})(d4p);


/**(function (d4p) {**/
/**   var breadcrumb = new d4p.module('breadcrumb', {**/
/**   **/
/**   		require: ['toolbar'],**/
/**   		**/
/**   		id: 'breadcrumbs',**/
/**   		   		**/
/**   		add: function() {**/
/**   			var ul =  $("<ul />").attr("id", this.id);**/
/**   			$('#'+d4p.toolbar.id).append(ul);		**/
/**   		},**/
/**   		**/
/**   		setHome: function () {**/
/**   			var h1 = $('#home h1'), li = $("<li/>").attr('class', 'home'), homeL = $("<a/>").attr("class", "home").attr("href", "#/home").html(h1.html()).click(function(event){**/
/**   		**/
/**   					$("#home").show();**/
/**                    d4p.inav.hideAll();**/
/**   			});**/
/**   			**/
/**   			li.append(homeL);**/
/**   			li.appendTo('#'+this.id);**/
/**   		},**/
/**   		**/
/**   		update: function () {**/
/**   			**/
/**   			var l = d4p.l(),  o = this;**/
/**   			if(d4p.ajax.collection[l.uri] != undefined) {**/
/**   				$('#'+d4p.ajax.collection[l.uri].id).parents().map(function() {**/
/**					if($(this).attr('id') != undefined && $(this).attr('id').indexOf('tab') != -1){	**/
/**						var heading = $(this).find(':header'), li = $("<li />"), a = $("<a/>").attr('href', '#'+$(this).attr('id')).html(heading.html());**/
/**						li.append(a);**/
/**						$('#'+o.id+ " > li.home").nextAll().remove()**/
/**						$('#'+o.id).append(li);**/
/**						return;		**/
/**					}**/
/**				});**/
/**			} else {**/
/**				$('#'+this.id+ " > li.home").nextAll().remove()**/
/**			}**/
/**   		},**/
/**   		**/
/**		init: function () {**/
/**			var l = d4p.l();**/
/**			this.add();**/
/**			this.setHome();**/
/**			this.bind('uriChange', 'update');**/
/**		}**/
/**	**/
/**   	});**/
/**   **/
/**})(d4p);  **/

/**
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
			var o = this;
			this.hideAll();
			var l = d4p.l();
						
			$("#home").hide();	
			
			if(l.uri != '' && l.uri.substring(0,1) != '/')	{	
				this.show(l.id);
			} else if(l.uri != '' && l.uri.substring(0,1) == '/')	{	
				this.show(l.uri.substring(1));
			} else if (l.uri == '') {
				this.show('home');
			}
			
			

		},
		
/**		changeToolbar: function(uri) {**/
/**					**/
/**			if(d4p.ajax.collection[uri] != undefined) {**/
/**				**/
/**				$('#'+d4p.ajax.collection[uri].id).parents().map(function() {**/
/**					if($(this).attr('id') != undefined && $(this).attr('id').indexOf('tab') != -1){	**/
/**						var etoolBar = $(this).find("div.toolbar");	**/
/**						$('#ajax-content div.toolbar').html(etoolBar.html());**/
/**						$('#ajax-content div.toolbar').show();						**/
/**						**/
/**					}**/
/**				});**/
/**				**/
/**			**/
/**			}	**/
/**		},**/

		
        //    
        init: function () {
            d4p.ajax.mode = 'append';
        	this.hideAll();
        	this.setAria();
        	this.bind('uriChange', 'load');
        	d4p.ajax.bind('ready', 'rewriteLangAttrHref');
        	this.load();
        }        
    });
})(d4p);


