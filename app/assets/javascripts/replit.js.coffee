$(document).on "page:load", ->
  if $(".replit-run").length
    jsrepl = new JSREPL(
      input: (fn) -> fn()
      output: (content) -> $("ul.replit-output").append("<li><samp>#{content}</samp></li>")
      result: (content) -> $("ul.replit-output").append("<li><samp>=> #{content}</samp></li>")
      error:  (content) -> $("ul.replit-output").append("<li class=\"text-danger\"><samp>#{content}</samp></li>")
    )

    jsrepl.loadLanguage "python", ->
      $(".replit-run").removeClass("disabled")

    $(".replit-run").click ->
      $(".code-input").each ->
        $(this).val($(".replit-input").val())
      jsrepl.eval($(".replit-input").val())
