// lae.boxes.js
(function( $ ){

  $.fn.laeBoxFolderSort = function( options ) { 

     $("#folders-table").tablesorter({
      theme     : 'bootstrap',
      headerTemplate : '{content} {icon}',
      widgets : [ "uitheme", "zebra" ],
      widgetOptions : {
      zebra : ["even", "odd"],
      widthFixed: true,
      filter_reset : ".reset"

      }
    });

  };
})( jQuery ); 
