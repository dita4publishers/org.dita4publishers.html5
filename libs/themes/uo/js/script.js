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
			
		},
		goToHash: function () {
			var l = d4p.l(), 
			idx=0;
			
			$('#'+l.id).find(".ui-accordion-header").each(function(index, value){
				idx = $(this).parent().attr('id') == l.hash ? index : idx;
			});
			
			$(".d4p-ui-accordion").accordion( "option", "active", idx );
			d4p.scrollToHash('#'+l.hash);

		},
		
        //    
        init: function () {
            d4p.ajax.mode = 'append';
            $('#home').find('.box-ico a').each(function(){
            	var hash = $(this).attr('href').substring(1, $(this).attr('href').length);
            	$(this).attr('href', '#/' + hash);
            	$(this).click(function(){
            	    $(this).parent().siblings().removeClass('active');
            	    $(this).parent().addClass('active');
        
            		$('#'+hash).focus();
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
 		
		$("#audience-widget").click(function(e){
			$("#audience-widget").toggleClass('active');
		});

 		},
 		
 		init: function() {
 			
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

