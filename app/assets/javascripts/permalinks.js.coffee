# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "page:load", ->
  $("input.permalink-field").change ->
    selfId = $(this).attr('id')
    hiddenId = selfId.replace("url", "_destroy")

    $("##{hiddenId}").val(!$(this).val().length)
