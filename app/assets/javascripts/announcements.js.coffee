# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "page:load", ->
  $(".preview-markdown").click ->
    $.post("/preview/markdown", input: $("#announcement_message").val(), (data) ->
      $(".markdown-previewer").removeClass("hidden")
      $(".markdown-previewer .panel-body").html(data)
      MathJax.Hub.Queue(["Typeset", MathJax.Hub, $(".markdown-previewer .panel-body").get()])
      )
    false
