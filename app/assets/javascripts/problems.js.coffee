# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "page:load", ->
  $("body").on("click", "[data-clipboard-target]", (e) ->
    e.preventDefault()
    )

  ZCClient = new ZeroClipboard($("[data-clipboard-target"))

  ZCClient.on 'ready', ->
    ZCClient.on('aftercopy', (e) ->
        $(e.target).text("Copied")
        $(e.target).blur()
        setTimeout(->
          $(e.target).text("Copy")
        , 2000)
      )

# https://github.com/zeroclipboard/zeroclipboard-rails/issues/11
$(document).on "page:before-change", ->
  ZeroClipboard.destroy();
