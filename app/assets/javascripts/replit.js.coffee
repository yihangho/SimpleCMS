$(document).on "page:load", ->

  $(".replit-run").each ->
    id = $(this).data("id")

    writeToStdout = (content) ->
      $("ul.replit-output[data-id=#{id}]").append("<li><samp>#{content}</samp></li>")

    jsrepl = new JSREPL(
      input: (fn) -> fn()
      output: writeToStdout
      result: writeToStdout
      error:  writeToStdout
      )

    jsrepl.loadLanguage("python", $.proxy ->
      $(this).removeClass("disabled")
    , this)

    $(this).data("replit", jsrepl)

  $(".replit-run").click ->
    id = $(this).data("id")
    $(this).data("replit").eval($(".replit-input[data-id=#{id}]").val())
