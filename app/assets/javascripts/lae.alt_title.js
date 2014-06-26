(function( $ ){

  $.fn.laeAltTitleFilter = function( options ) {  

    // Create some defaults, extending them with any options that were provided
    var settings = $.extend( { }, options);


    function generateAltTitle(normalized_title, articles) {
      // for some reason the join method would not allow pass in a custom
      // arguement for the sperator: tried the following
      //var art_list = articles.join("|");
      //var art_list = $.makeArray(articles).join("|");
      // hence the next line of ugliness ugliness
      var pattern_match = "^(" + articles.replace(/,/g, "|") + ")\\s";
      //
      var articles_strip = new RegExp(pattern_match);
      return normalized_title.replace(articles_strip, '');
    }

    return this.each(function() { 
      $('#lae_folder_title').on
        ('change', function () {
          var first_language = $('.lae-language').first().val();
          var normalized_title = $('#lae_folder_title').val().toLowerCase();
          var current_sort_title = $('#lae_folder_sort_title').val();
          if(!current_sort_title) {
            if (first_language === "English" || first_language === "Spanish" || first_language === "Portuguese") {
              var articles_to_strip = _.find(settings.sortTitleFilters, function(mapping){
                if(mapping.lang === first_language) {
                  return mapping.articles;
                }
              });
              var articles = _.values(articles_to_strip);
              var article_string = articles.join("|");
              $('#lae_folder_sort_title').val(generateAltTitle(normalized_title, article_string));
            }
          }
        });

    });

  };
})( jQuery );  




