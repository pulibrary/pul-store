(function( $ ){

  $.fn.laeSubjectForm = function( options ) {  

    // Create some defaults, extending them with any options that were provided
    var settings = $.extend( { }, options);

    function addField() {
      var cloneId = this.id.replace("submit", "clone");
      var newId = this.id.replace("submit", "elements");
      var cloneElem = $('.initial_lae_subject').first().clone(); //$('#'+cloneId).clone();
      // FIXME
      // change the add button to a remove button
      //console.log("a "+this.id);
      var plusbttn = cloneElem.find('#'+this.id);
      //console.log(plusbttn.html());
      plusbttn.html('-<span class="sr-only">remove this '+ this.name.replace("_", " ") +'</span>');
      plusbttn.on('click',removeField);

      // remove the help tag on subsequent added fields
      cloneElem.find('.formHelp').remove();
      cloneElem.find('i').remove();
      cloneElem.find('.modal-div').remove();

      //add offset class for inline forms 
      cloneElem.addClass('col-xs-offset-3');

      //clear out the value for the element being appended
      //so the new element has a blank value
      cloneElem.find('select').val("");
      cloneElem.removeClass('initial_lae_subject');
      var disabled_button = '<input class="form-control lae-subject-placeholder" disabled="disabled" id="lae_folder_subject_" name="lae_folder[subject][]" placeholder="Subject" type="text">';
      cloneElem.find('.lae-subject').first().replaceWith(disabled_button);
      //cloneElem.find('input[type=text]').attr("required", false);

      if (settings.afterAdd) {
        settings.afterAdd(this, cloneElem);
      }
      // this should be json output?
      //var new_category_select = $('.initial_lae_subject').first().clone();
      $('#'+newId).append(cloneElem);
      cloneElem.find('select').last().focus();
      return false;
    }

    function removeField () {
      // get parent and remove it
      //$(this).parents('.form-group').remove();
      $(this).parent().parent().remove();
      return false;
    }

    return this.each(function() {        

      // Tooltip plugin code here
      /*
       * adds additional metadata elements
       */
      $('.lae-subjects > .form-group .adder', this).click(addField);

      $('.lae-subjects > .form-group .remover', this).click(removeField);

      $('.lae-subjects').on
        ('change', 'select.lae-category', function () {
          var selected_id;
          $(this).find("option:selected" ).each(function(index, value) {
            selected_id = $(this).data('category-id');
          });
          var current_category = $(this);
          var category_lookup = $.ajax({
            type: "GET",
            url: "/lae/categories/"+selected_id+"/subjects.json",
            contentType: "application/json",   
            dataType: "json",
            context: current_category,
            error: function(e) {
             console.log(e.message);
           }
         }).done(function(subjects) {
          var subject_labels = _.pluck(subjects, 'label');
          var opt_list = "<option value>Select Subject</a>";
          _.each(subject_labels, function(label) {
            opt_list = opt_list + "<option value='"+label+"'>"+label+"</option>";
          });
          //var add_category_button = '<button class="adder btn" id="additional_subject_submit" name="additional_subject">+<span class="sr-only">add another subject</span></button>';
          var subject_select = "<select class='form-control lae-subject' id='lae_folder_subject_' name='lae_folder[subject][]'>"+opt_list+"</select>";
          var current_initial_select_state = $('.initial_lae_subject select').length;
          if (current_initial_select_state === 1) {
            $(this).next().replaceWith(subject_select); //+add_category_button);
          } else {
            $(this).next().replaceWith(subject_select);
          }
          $(this).next().focus();
        });
       });

    });

  };
})( jQuery );  

