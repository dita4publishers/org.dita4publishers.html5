$(function() {
  $('pre').each(function(){

    var language = $(this).attr('data-language');

    if(language != undefined)
    {
      $(this).addClass('brush: ' + language);
    }

  })

  SyntaxHighlighter.all()
});
