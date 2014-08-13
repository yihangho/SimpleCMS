# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "page:load", ->
  task_count = 0

  $.Mustache.addFromDom("task-template") if $("#task-template").length

  $("form").submit ->
    unless $(this).find("#problem_permalink_attributes_url").val().length
      $(this).find("#problem_permalink_attributes__destroy").val("true")

  $("form").on "click", '[data-dismiss="task-form"]', ->
    if confirm("Are you sure?")
      $($(this).data("target")).remove()

  $("#add-task-btn").click ->
    task_count++ until($(".task-#{task_count}").length == 0)
    $(".tasks-forms").append($.Mustache.render("task-template", {task_count: task_count}))
    return false
