// Disable searching and ordering by default for datatable
$.extend( $.fn.dataTable.defaults, {
    searching: false,
    ordering:  false
});

$(document).ready(function() {


  if(!$('body').hasClass('homepage'))
  {
    navigation.init();
  }

  $('table').each(function( index ) {
    var opts = jQuery.parseJSON($(this).attr('data-options'))
    if(opts.d4p_datatable.activate == '1')
    {
       $(this).DataTable(opts.d4p_datatable.options);
    }
  });


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
