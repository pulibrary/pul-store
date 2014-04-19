// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require jquery-fileupload
//= require jquery.ui.all
//= require jquery.tablesorter
//= require jquery.tablesorter.widgets
//= require hydra-editor/hydra-editor
//= require underscore
//
// Required by Blacklight
//= require blacklight/blacklight
//= require_tree .
//
$(function() {
  $('.datepicker').datepicker({
    dateFormat: 'yy-mm-dd',
    showButtonPanel: true
  });

  $("#date-type-toggle" ).click(function() {
    $( ".date-options").toggle();
    var cur_toggle_text = $(this).text();
    if(cur_toggle_text == "Use Date Range Instead") {
      $(this).text("Use Single Date");
    } else {
      $(this).text("Use Date Range Instead");
    }
  });

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

  $('#new-folder-modal').on('shown', function () {
    $('input:text:visible:first', this).focus();
  });

});

