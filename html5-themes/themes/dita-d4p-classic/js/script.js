// Disable searching and ordering by default for datatable
$.extend( $.fn.dataTable.defaults, {
    searching: false,
    ordering:  false
});

$(document).ready(function() {

  $('table').each(function( index ) {
    var opts = jQuery.parseJSON($(this).attr('data-options'))
    if(opts.d4p_datatable.activate == '1')
    {
       $(this).DataTable(opts.d4p_datatable.options);
    }
  });
  }
);
