$(document).on "page:load", ->

  $(".replit-run").each ->
    id = $(this).data("id")

    jsrepl = new JSREPL(
      input: (fn) -> fn()
      output: (content) -> $("ul.replit-output[data-id=#{id}]").append("<li><samp>#{content}</samp></li>")
      result: (content) -> $("ul.replit-output[data-id=#{id}]").append("<li><samp>=> #{content}</samp></li>")
      error:  (content) -> $("ul.replit-output[data-id=#{id}]").append("<li class=\"text-danger\"><samp>#{content}</samp></li>")
      )

    jsrepl.loadLanguage("python", $.proxy ->
      $(this).removeClass("disabled")
    , this)

    $(this).data("replit", jsrepl)

  $(".replit-run").click ->
    id = $(this).data("id")
    $(this).data("replit").eval($(".replit-input[data-id=#{id}]").val())
