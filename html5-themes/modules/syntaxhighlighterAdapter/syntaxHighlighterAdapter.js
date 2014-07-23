$(function() {
  $('pre').each(function(){

    var language = $(this).attr('data-language'),
    opts =  '';

    opts += $(this).attr('data-gutter') != undefined ? ' gutter: ' + $(this).attr('data-gutter') + ';' : '';
    opts += $(this).attr('data-auto-links') != undefined ? ' auto-links: ' + $(this).attr('data-auto-links') + ';' : '';
    opts += $(this).attr('data-collapse') != undefined ? ' collapse: ' + $(this).attr('data-collapse') + ';' : '';
    opts += $(this).attr('data-first-line') != undefined ? ' first-line: ' + $(this).attr('data-first-line') + ';' : '';
    opts += $(this).attr('data-html-script') != undefined ? ' html-script: ' + $(this).attr('data-html-script') + ';' : '';
    opts += $(this).attr('data-smart-tabs') != undefined ? ' smart-tabs: ' + $(this).attr('data-smart-tabs') + ';' : '';
    opts += $(this).attr('data-toolbar') != undefined ? ' toolbar: ' + $(this).attr('data-toolbar') + ';' : '';

    if(language != undefined)
    {
      $(this).addClass('brush: ' + language + opts);
    }

  })

  SyntaxHighlighter.all()
});
