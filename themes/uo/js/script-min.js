Array.prototype.clean=function(b){var a=0;for(var a=0;a<this.length;a++){if(this.hasOwnProperty(a)){if(this[a]==b){this.splice(a,1);a=a-1}}}return this};if(!Array.prototype.indexOf){Array.prototype.indexOf=function(c){if(this==null){throw new TypeError()}var d=Object(this);var a=d.length>>>0;if(a===0){return -1}var e=0;if(arguments.length>1){e=Number(arguments[1]);if(e!=e){e=0}else{if(e!=0&&e!=Infinity&&e!=-Infinity){e=(e>0||-1)*Math.floor(Math.abs(e))}}}if(e>=a){return -1}var b=e>=0?e:Math.max(a-Math.abs(e),0);for(;b<a;b++){if(b in d&&d[b]===c){return b}}return -1}}if(!window.console){console={log:function(){}}}(function(a){var b={version:"0.3a",inited:false,loadInitialContent:true,hash:{current:"",previous:""},ext:".html",timeout:30000,outputSelector:"#d4h5-main-content",navigationSelector:"#local-navigation",externalContentElement:"section",loaderParentElement:"body",protocols:["http:","https:","file:","ftp:"],ids:{n:0,prefix:"d4p-page",prefixLink:"d4p-link"},transition:{speed:"slow",opacity:0.5},relativePath:"",mod:[],euriChange:[],scrollElem:{},document:{},scrollDuration:400,indexFilename:"index.html",edocReady:[],tabIndex:10,docIsReady:function(){var c={},d={};for(c in this.edocIsReady){if(this.edocIsReady.hasOwnProperty(c)){d=b.edocIsReady[c];d.call(this,this.uri,this.hash.current)}}},l:function(){var e=document.location.hash.substring(1),d=[],f={},c=false;if(e!==""){d=e.split("#");c=d[0].substring(0,1)==="/"?true:false;f={uri:d[0],hash:d[1]!==undefined?d[1]:"",id:d[0].replace(/\//g,"__"),virtual:c}}else{f={uri:"",hash:"",id:"",virtual:c}}return f},show:function(c){$("#"+c).show()},scrollableElement:function(){var d=0,g=arguments.length,e="",c=false,f={};for(d=0,g;d<g;d=d+1){if(arguments.hasOwnProperty(d)){e=arguments[d];f=$(e);if(f.scrollTop()>0){return e}else{f.scrollTop(1);c=f.scrollTop()>0;f.scrollTop(0);if(c){return e}}}}return[]},scrollToHash:function(c){var d={};if(c!==""&&c!==undefined&&c!==null&&c!=="#"){d=$(c).offset().top;$(b.scrollElem).animate({scrollTop:d},b.scrollDuration)}},setProps:function(d){var e={},c={},g={},f={};for(e in d){if(d.hasOwnProperty(e)){g=d[e];if(typeof g!=="object"){b[e]=g}else{for(c in g){f=g[c];b[e][c]=f}}}}},vlink:function(g){var e=g.attr("id"),f=g.attr("href"),c=f.substring(0,f.length-b.ext.length),d="/"+c,h=d.replace(/\//g,"__");if(e===""||e==undefined){e=b.ids.prefixLink+b.ids.n;b.ids.n++}return{linkID:e,href:f,hrefID:d,id:h}},live:function(c){},getInitialContent:function(){var c=b.l();if(c.uri!==""){b.uriChanged(c.uri,c.hash);return true}if($(b.outputSelector).length==1&&b.loadInitialContent){var d=$(b.navigationSelector+" a:first-child");if(d.attr("href")==undefined){return false}url=$(b.navigationSelector+" a:first-child").attr("href").replace(/^#/,"");document.location.hash=url;b.loadInitialContent=false}},getDocInfos:function(){this.document.title=$("title").html()},uriChanged:function(e,f){var c=b.l();for(i in b.euriChange){if(b.euriChange.hasOwnProperty(i)){var d=b.euriChange[i];b[d.name][d.fn].call(b[d.name],c.uri,c.hash)}}b.hash.previous=f},init:function(d){var c=this.l(),e="",g=false,f={};if(this.inited){return false}this.setProps(d);this.getDocInfos();if(b.relativePath!=""&&c.uri.indexOf(b.indexFilename)!=0){g=b.resolveRoot();document.location=g;return true}this.scrollElem=this.scrollableElement("html","body");for(e in this.mod){if(this.mod.hasOwnProperty(e)){f=this.mod[e];this[f].init.call(this[f])}}if(!("onhashchange" in a)||(document.documentMode==7)){setInterval("d4p.uriChanged()",250)}else{if(a.addEventListener){a.addEventListener("hashchange",b.uriChanged,false);console.log("addEventListene")}else{if(a.attachEvent){a.attachEvent("onhashchange",b.uriChanged);console.log("attachEvent")}}}this.getInitialContent();this.inited=true;return true},filename:function(c){return c.substring(c.lastIndexOf("/")+1)},basename:function(c){return c.substring(0,c.length-this.filename(c).length)},resolveRoot:function(){var f=document.location.toString(),j=b.basename(f),h=j.split("/"),k=b.relativePath.match(/\.\./g),d=h.splice(0,h.length-1-k.length),g=d.join("/"),e=f.substring(g.length+1).replace(b.ext,"");return location.protocol=="file:"?d.join("/")+"/"+b.indexFilename+"#"+e:d.join("/")+"/#"+e}};a.d4p=b})(window);(function(a,b){b.module=function(c,e){var d=0;this.name=c;for(d in e){if(this[d]==undefined){this[d]=e[d]}}if(this.init!=undefined){b.mod.push(c)}b[c]=this};b.module.prototype.hash=function(){return document.location.hash.substring(1)};b.module.prototype.bind=function(c,d){b["e"+c].push({name:this.name,fn:d})}})(window,d4p);(function(a,b){b.ajaxLoader=function(c){this.name="";this.outputSelector=b.outputSelector;this.title="";this.content="";this.externalContentElement=b.externalContentElement;this.timeout=b.timeout;this.modified=true;this._filter=[];this._before=[];this._ready=[];this._live=[];this._failed=[];this._postFilter=[];this.collection=[],this.mode="replace";$.extend(true,this,c);this.setAriaAttr()};b.ajaxLoader.prototype.focus=function(){$(this.id).focus()},b.ajaxLoader.prototype.setOutputSelector=function(c){this.outputSelector=c},b.ajaxLoader.prototype.setTimeout=function(c){this.timeout=c};b.ajaxLoader.prototype.bind=function(c,d){this["_"+c].push(d)},b.ajaxLoader.prototype.addLoader=function(){var c=$("<div />").attr("id","d4p-loader");$(b.loaderParentElement).append(c)};b.ajaxLoader.prototype.setAriaAttr=function(){$(this.outputSelector).attr("role","main").attr("aria-atomic","true").attr("aria-live","polite").attr("aria-relevant","all")};b.ajaxLoader.prototype.contentIsLoading=function(){$("#d4p-loader").show();$(this.outputSelector).css("opacity",b.transition.opacity)};b.ajaxLoader.prototype.contentIsLoaded=function(){$("#d4p-loader").hide();$(this.outputSelector).css("opacity",1)};b.ajaxLoader.prototype.collectionSet=function(e,d,g,c,f){if(this.collection[e]==undefined){this.collection[e]={cache:false,uri:d,id:g,refid:c,title:f}}};b.ajaxLoader.prototype.setCacheStatus=function(c){this.collection[c].cache=true};b.ajaxLoader.prototype.isCached=function(d){var c=false;if(this.inCollection(d)){c=this.collection[d].cache}return c};b.ajaxLoader.prototype.getCollection=function(c){return this.collection[c]};b.ajaxLoader.prototype.inCollection=function(c){return this.collection[c]==undefined?false:true};b.ajaxLoader.prototype.setTitle=function(){$("title").html(this.title);this.collection[this.refpath]["title"]=this.title},b.ajaxLoader.prototype.setMainContent=function(){var e=this.refpath.replace(/\//g,"__"),d=$("<div />").attr("id",e).attr("class","content-chunk").html(this.content),c={};for(i in this._live){if(this._live.hasOwnProperty(i)){c=this._live[i];this[c].call(this,b.content)}}if(this.mode=="append"){$(this.outputSelector).append(d);this.setCacheStatus(this.refpath)}else{$(this.outputSelector).html(d.html())}},b.ajaxLoader.prototype.rewriteAttrSrc=function(){var c=b.l(),d="";this.responseText=this.responseText.replace(/(src)\s*=\s*"([^<"]*)"/g,function(g,e,j){var h=j.split("/"),f="";d=d.substring(1,d.length);if(b.protocols.indexOf(h[0])!==-1){f=j}else{f=d.substring(1,d.lastIndexOf("/"))+"/"+j}return e+'="'+f+'"'})},b.ajaxLoader.prototype.rewriteAttrHref=function(){var c=this;this.responseText=this.responseText.replace(/(href)\s*=\s*"([^<"]*)"/g,function(o,r,e){var j=b.l(),s="",g=j.uri.substring(1,j.uri.length),q=e.split("/"),h=b.basename(g),u=e.indexOf(g),f=h.split("/"),n=0,m="",k=[],d=[],t=[],p="";f.clean("");if(e.substring(0,1)=="#"||b.protocols.indexOf(q[0])!=-1||e.substring(0,1)=="/"){s=e}else{e=e.replace(b.ext,"");if(u==0){s="#/"+e}else{m=e.split("/");t=m;for(n=0,len=m.length;n<len;n=n+1){if(m[n]===".."||(m[n]==="")){t[n]="";f[f.length-1]=""}if(m[n]==="index"){t[n]="/home"}}t.clean("");f.clean("");d=h!=""?f.concat(t):k.concat(t);p=c.collection[j.uri].id;c.collectionSet("/"+d.join("/"),d.join("/")+b.ext,"",c.title);s="#/"+d.join("/")}}return r+'="'+s+'"'})},b.ajaxLoader.prototype.load=function(e,f){var d={},c=0;this.uri=this.collection[e].uri;this.refpath=e;this.hash=f;if(this.isCached(e)){return true}for(c in this._before){if(this._before.hasOwnProperty(c)){d=this._before[c];this[d].call(this,e,f)}}$(this.outputSelector).attr("aria-busy","true");$.ajax({type:"GET",context:this,cache:true,ifModified:this.modified,timeout:this.timeout,url:this.uri,dataType:"html",data:{ajax:"true"},beforeSend:function(g){this.contentIsLoading()},complete:function(h,g,j){if(g==="error"||g==="timeout"){this.contentIsLoaded();document.location.hash=b.hash.previous;for(c in this._failed){if(this._failed.hasOwnProperty(c)){d=this._failed[c];this[d].call(this,g,j)}}return false}j=h.responseText;if(g=="success"){h.done(function(k){this.responseText=k});for(c in this._filter){if(this._filter.hasOwnProperty(c)){d=this._filter[c];this[d].call(this,this.responseText)}}this.html=$(this.responseText).not("script");this.content=this.html.find(this.externalContentElement);this.title=this.html.find("title").html();for(c in this._postFilter){if(this._postFilter.hasOwnProperty(c)){d=this._postFilter[c];this[d].call(this)}}this.setMainContent();for(c in this._ready){if(this._ready.hasOwnProperty(c)){d=this._ready[c];this[d].call(this)}}this.contentIsLoaded();$(this.outputSelector).attr("aria-busy","false");if(this.hash!=undefined){b.scrollToHash("#"+this.hash)}}}})}})(window,d4p);(function(b,c){var a=new c.module("ajaxnav",{traverse:function(){$(c.navigationSelector+" a").each(function(f){var e=$(this).attr("href"),h=e.split("/"),g=$(this).hasClass("d4p-no-ajax"),d=c.vlink($(this));$(this).attr("id",d.linkID);if(e.substring(0,1)!="#"&&c.protocols.indexOf(h[0])==-1&&g==false){c.ajax.collectionSet(d.hrefID,d.href,d.id,d.linkID,$(this).html());$(this).attr("href","#"+d.hrefID)}c.live($(this))});$(c.navigationSelector).find("li").each(function(e){var d="";if($(this).children("a").length===0){d=$(this).find("ul li a:first");if(d.length==1){$(this).children("span.navtitle").click(function(){c.ajax.load(d.attr("href").replace(/^#/,""))})}}})},load:function(){var d=c.l(),e=c.ajax.getCollection(d.uri);if(e!=undefined&&e.cache==false){c.ajax.load(d.uri,d.hash)}},init:function(){c.ajax=new c.ajaxLoader();c.ajax.name="main";c.ajax.addLoader();c.ajax.bind("filter","rewriteAttrHref");c.ajax.bind("filter","rewriteAttrSrc");c.ajax.bind("ready","setTitle");c.ajax.bind("ready","focus");this.bind("uriChange","load");this.traverse()}})})(window,d4p);(function(b){b.ajaxLoader.prototype.setErrorMsg=function(d,c){var e=c==="timeout"?"Sorry, the content could not be loaded":"Sorry, the server does not respond.";b.msg.alert(e,"error")};var a=new b.module("msg",{id:"d4p-message",timeout:3000,create:function(){var c=$("<div />").attr("id",this.id).attr("role","alertdialog").attr("aria-hidden","true").attr("aria-label","Message").addClass("rounded").hide(),d=c.append($("<div />"));$("body").append(c)},init:function(){this.create();b.ajax.bind("failed","setErrorMsg");$(document).mouseup(function(d){var c=$(this.id);if(c.has(d.target).length===0){c.hide()}})},show:function(){$("#"+this.id).show().attr("aria-hidden","false").delay(this.timeout).fadeOut().attr("aria-hidden","true")},alert:function(e,c){var d={};c=c==undefined?"":c;d=$("<p />").addClass(c).text(e);$("#"+this.id+" > div").html(d);this.show()}})})(d4p);(function(a){a.ajaxLoader.prototype.addWidgets=function(){this.content.find("*[class]").each(function(e){var g=$(this).attr("class").split(" ");for(var f=0,c=g.length;f<c;f++){var h=g[f];var b=h.indexOf(a.ui.prefix);var d=a.ui.prefix.length;if(b>=0){var j=h.substring(d);if(a.ui[j]==undefined){return true}if(a.ui[j]["init"]!=undefined){a.ui[j]["init"].call(a.ui[j],$(this))}}}})}})(d4p);(function(b){var a=new b.module("ui",{prefix:"d4p-ui-",dialogMinWidth:600,processed:[],init:function(){b.ajax.bind("ready","addWidgets")}})})(d4p);(function(b,a){b.ui.accordion={init:function(d){var c="";if(d.hasClass("concept")){c="> div.topic > h2"}else{c="> div.section > h2"}d.accordion({header:c,heightStyle:"content",active:false,collapsible:true})}}})(d4p);(function(a){a.ajaxLoader.prototype.removeLinks=function(){var b=a.hash.current;this.content.find("a").each(function(c){$(this).replaceWith(this.childNodes)})};a.ui.dialog={ids:0,done:{},init:function(d){var c="",e="",b="";if(d[0].tagName.toUpperCase()==="DFN"){d=d.parent()}b=d.attr("href");b=b.substring(0,1)=="#"?b.substring(1):b;c=a.ajax.collection[b].uri;e=this.getId();if(this.done[c]==undefined){this.done[c]={id:e,uri:c,done:false}}if(this.checkDialog(d,c)){this.dialog(d,c)}},getId:function(){this.ids++;return this.ids},checkDialog:function(c,b){if(this.done[b].done==true){if(b!=""){c.attr("href","#");c.click(function(d){d.preventDefault();$("#dialog-"+a.ui.dialog.done[b].id).dialog("open")})}return false}else{return true}},dialog:function(e,c){var d=new a.ajaxLoader(),f=this.done[c].id,b=$("<div />").attr("id","dialog-"+f);d.name="dialog";d.collectionSet(c,c,f,f,"");d.bind("ready","rewriteAttrSrc");d.bind("postFilter","removeLinks");$(a.ajax.loaderParentElement).append(b);d.setOutputSelector("#dialog-"+f);d.load(c);b.dialog({autoOpen:false,minWidth:a.ui.dialogMinWidth});b.dialog("close");e.attr("href","#");e.click(function(g){g.preventDefault();$("#dialog-"+f).dialog("open")});this.done[c].done=true}}})(d4p);(function(b){b.ajaxLoader.prototype.rewriteLangAttrHref=function(c){var d=this.html.find("#ch-lang-url").attr("href");$("#ch-lang-url").attr("href",d)};var a=new b.module("inav",{hideAll:function(c){$(".content-chunk").hide()},show:function(c){$("#"+c).show()},setAria:function(){$(".box-ico a").attr("aria-role","button")},load:function(){var e=this,c=b.l(),d=b.ajax.inCollection(c.uri),f="";this.hideAll();if(d){$("#home").addClass("state-active");f=b.ajax.collection[c.uri].id;this.show(f)}else{if(c.uri!=""&&!d){$("#home").addClass("state-active");this.show(c.uri.substring(1))}else{if(c.uri==""){$("#home").removeClass("state-active")}}}return true},goToHash:function(){var d=b.l(),c=0;$("#"+d.id).find(".ui-accordion-header").each(function(e,f){c=$(this).parent().attr("id")==d.hash?e:c});$(".d4p-ui-accordion").accordion("option","active",c);b.scrollToHash("#"+d.hash)},init:function(){b.ajax.mode="append";$("#home").find(".box-ico a").each(function(){var c=$(this).attr("href").substring(1,$(this).attr("href").length);$(this).attr("role","button");$(this).attr("href","#/"+c);$(this).click(function(){$(this).parent().siblings().removeClass("active");$(this).parent().addClass("active");$("#content-container").attr("tabindex",-1).focus()})});this.hideAll();this.setAria();this.bind("uriChange","load");this.bind("uriChange","goToHash");b.ajax.bind("ready","rewriteLangAttrHref");this.load()}})})(d4p);(function(b){var a=new b.module("audience",{onClick:function(){$("#audienceBtn").click(function(c){if($("#audience-widget").hasClass("active")){$("#audience-widget").toggleClass("active");$("#audience-list").slideUp();$("#home").attr("tabindex",-1).focus()}else{$("#audience-widget").toggleClass("active");$("#audience-list").slideDown().attr("tabindex",-1).focus()}})},init:function(){window.group.init();this.onClick();$("#audience-widget").addClass("no-select");$("html").click(function(c){if($(c.target).parent().attr("id")=="audience-widget"){return}if($("#audience-widget").hasClass("active")){$("#audience-widget").toggleClass("active")}})}})})(d4p);