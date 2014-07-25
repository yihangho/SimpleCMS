$(document).on "page:fetch", ->
  $(".spinner-container").removeClass("hidden")
  $(".spinner-container").spin()

$(document).on "page:receive", ->
  $(".spinner-container").addClass("hidden")
  $(".spinner-container").spin(false)
