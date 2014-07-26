# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "page:load", ->
  $('a[data-toggle="tab"][data-source]').on('shown.bs.tab', (e) ->
      target = $(e.target.hash)

      # Set the data-loaded attribute to prevent double loading
      unless target.data("loaded")
        target.data("loaded", true)
        source_path = $(this).data("source")

        $(document).trigger("page:fetch")

        $.ajax(source_path,
            success: (data) ->
              target.append(data)
              $(document).trigger("page:receive")
          )
    )
