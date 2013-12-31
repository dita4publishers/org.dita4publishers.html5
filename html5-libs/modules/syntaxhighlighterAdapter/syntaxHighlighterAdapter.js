$(function() {
  $('pre').each(function(){
    var language = $(this).attr('data-language');
    $(this).addClass('brush: ' + language);
  })

  SyntaxHighlighter.all()
});
