$(document).on "page:change", ->
  $("#new_lae_folder").on("ajax:success", (e, data, status, xhr) ->
    #$("#new_lae_folder").append "puppies"
  ).bind "ajax:error", (e, xhr, status, error) ->
    $("#new_lae_folder").append xhr.responseText


