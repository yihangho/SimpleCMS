@startSpinner = ->
  $(".spinner-container").removeClass("hidden")
  $(".spinner-container").spin()

@stopSpinner = ->
  $(".spinner-container").addClass("hidden")
  $(".spinner-container").spin(false)

$(document).ready ->
  $(this).trigger("page:load")
  document.cookie = "timezone=#{jstz.determine_timezone().timezone.olson_tz}; path=/"

  $.get("/contests/ongoing.json", (e) ->
    dispatcher = new WebSocketRails("#{window.location.host}/websocket");
    channel = dispatcher.subscribe("announcements")
    e.forEach( (contest) ->
      channel.bind("#{contest.id}", (message) ->
        alert("Announcement for #{message.contest.title}!")
        )
      )
  )

$(document).on "page:fetch", startSpinner

$(document).on "page:receive", stopSpinner

$(document).on "page:load", ->
  # Ask MathJax to typeset all elements with data-mathjax-source attribute set
  $("[data-mathjax-source]").toArray().forEach (element) ->
    MathJax.Hub.Queue(["Typeset", MathJax.Hub, element]);

  $('[ng-app]').each ->
    try
      angular.bootstrap($(this), [$(this).attr('ng-app')])
