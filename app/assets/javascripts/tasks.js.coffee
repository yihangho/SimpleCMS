# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "page:load", ->
  task_count = 0

  $.Mustache.addFromDom("task-template")

  $("form").on "click", "button.close", ->
    if confirm("Are you sure?")
      $($(this).data("selector")).remove()

  $("#add-task-btn").click ->
    task_count++ until($(".task-#{task_count}").length == 0)
    $("form").append($.Mustache.render("task-template", {task_count: task_count}))
    return false
