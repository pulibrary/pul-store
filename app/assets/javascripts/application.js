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
//= require lae_subjects
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

  // $( ".lae-category" ).change(function() {
  //   $( "select option:selected" ).each(function() {
  //     var option = $( this ).text() + " ";
  //   });
  //   alert( "Handler for .change() called. Option:" + option + " Selected." );
  // }).change(); 
  $( "select.lae-category" )
  .change(function () {
    var str = "";
    $(this).find("option:selected" ).each(function(index, value) {
      str += $( this ).text();
      var cat_id = $(this).attr('data-category-id');
    });
    var option_list = '<option value="Agricultural development projects">Agricultural development projects</option><option value="Agricultural exhibitions">Agricultural exhibitions</option><option value="Agricultural industries">Agricultural industries</option><option value="Agricultural laws and legislation">Agricultural laws and legislation</option><option value="Agricultural technology">Agricultural technology</option><option value="Agriculture">Agriculture</option><option value="Agriculture and politics">Agriculture and politics</option>';

    var subject_select = "<select class='span2 lae-subject' id='lae_folder_subject_' name='lae_folder[subject][]'>"+option_list+"</select>";

    var add_button = '<button class="adder btn" id="additional_subject_submit" name="additional_subject">+<span class="accessible-hidden">add another alternative_title</span></button>'
    var remove_button = '<button class="removeer btn" id="additional_subject_submit" name="additional_subject">+<span class="accessible-hidden">add another alternative_title</span></button>'
   
    // create an underscore template for the select?
    //erb ajax?

    $(this).next().replaceWith(subject_select + add_button);
    alert( "Handler for .change() called. Category:" + cat_id+ " Selected." );
  });
  //.change();

});

