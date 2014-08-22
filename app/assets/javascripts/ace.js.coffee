$(document).on "page:load", ->
  $("[data-ace-editor]").each ->
    $(this).css(
      # 0.3 is just a guess lol. It looks good on my machine.
      height: 0.3 * $(this).parent().width()
      width:  $(this).parent().width()
      )

    editor = ace.edit(this)
    editor.setTheme("ace/theme/monokai")

    session = editor.getSession()
    session.setMode("ace/mode/python")
    session.setTabSize(2)
    session.setUseSoftTabs(true)
    session.setUseWrapMode(true)

    $(this).data("ace-editor", editor)
