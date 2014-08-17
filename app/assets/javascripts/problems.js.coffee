# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "page:load", ->
  $("body").on("click", "[data-clipboard-target]", (e) ->
    e.preventDefault()
    )

  ZCClient = new ZeroClipboard($("[data-clipboard-target]"))

  ZeroClipboard.on 'error', (e) ->
    if ['flash-disabled', 'flash-outdated', 'flash-unavailable', 'flash-deactivated'].indexOf(e.name) != -1
      $("[data-clipboard-target]").each ->
        level = parseInt($(this).data('remove-level'))
        if level == 0
          $(this).remove()
        else
          $(this).parents().eq(level-1).remove()

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
