# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $(this).trigger("page:load")

$(document).on "page:load", ->
  task_count = 0

  $("form").on "click", "button.close", ->
    $($(this).data("selector")).remove()


  $("#add-task-btn").click ->
    html = """
           <div class="task-#{task_count}">
             <button type="button" class="close" data-selector=".task-#{task_count}"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
             <div class="form-group">
               <label for="problem_tasks_#{task_count}_input">Input</label>
               <textarea class="form-control" id="problem_tasks_#{task_count}_input" name="problem[tasks][#{task_count}][input]"></textarea>
             </div>
             <div class="form-group">
               <label for="problem_tasks_#{task_count}_output">Output</label>
               <textarea class="form-control" id="problem_tasks_#{task_count}_output" name="problem[tasks][#{task_count}][output]"></textarea>
             </div>
           </div>
           """
    $("form").append(html)
    task_count++
    return false
