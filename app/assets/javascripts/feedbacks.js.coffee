# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "page:load", ->
  $("#feedback-form-modal").on "show.bs.modal", ->
    # Hide all the alerts
    $("#feedback-form-modal .alert").addClass("hidden")
    $("#send-feedback-btn").removeClass("disabled")
    # Fill in email address
    emailAddress = $.cookie("feedback_email")
    $("#feedback_email").val(emailAddress.trim()) if emailAddress? && emailAddress.trim()

  $("#feedback-form").on "ajax:success", ->
    $("#feedback-form-modal .alert.alert-success").removeClass("hidden")

  $("#feedback-form").on "ajax:error", ->
    $("#feedback-form-modal .alert.alert-danger").removeClass("hidden")
    $("#send-feedback-btn").removeClass("disabled")

  $("#send-feedback-btn").click ->
    $(this).addClass("disabled")
    $("#feedback-form").submit()
    emailAddress = $("#feedback_email").val()
    $.cookie("feedback_email", emailAddress.trim()) if emailAddress.trim()
