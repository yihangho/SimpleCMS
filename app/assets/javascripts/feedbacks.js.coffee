# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "page:load", ->
  $("#feedback-form-modal").on "show.bs.modal", ->
    # Hide all the alerts
    $("#feedback-form-modal .alert").addClass("hidden")
    $("#send-feedback-btn").removeClass("disabled")

  $("#feedback-form").on "ajax:success", ->
    if $("#feedback_email").val().trim()
      $("#feedback-form-modal .alert.alert-success.with-email").removeClass("hidden")
    else
      $("#feedback-form-modal .alert.alert-success.without-email").removeClass("hidden")

  $("#feedback-form").on "ajax:error", ->
    $("#feedback-form-modal .alert.alert-danger").removeClass("hidden")
    $("#send-feedback-btn").removeClass("disabled")

  $("#send-feedback-btn").click ->
    $(this).addClass("disabled")
    $("#feedback-form").submit()
