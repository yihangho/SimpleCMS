app = angular.module('SimpleCMS.InteractiveTerminal', ['SimpleCMS.jsrepl'])

app.directive 'interactiveTerminal', ['jsrepl', (jsrepl) ->
  restrict: 'E'
  link: (scope, elem, attrs) ->
    elem.css
      width: elem.parent().width()

    jqconsole = elem.jqconsole('Welcome to SimpleCMS!\n', '> ', '..')

    startPrompt = ->
      jqconsole.Prompt true, jsrepl.eval, jsrepl.jsrepl.checkLineEnd, true

    abortPrompt = ->
      jqconsole.AbortPrompt if jqconsole.GetState() == "prompt"

    jsrepl.writer = (text, cls, escape) ->
      jqconsole.Write(text, cls, escape)

    toStringWithNewline = (text) ->
      if "#{text}".slice(-1) is '\n' then "#{text}" else "#{text}\n"

    jsrepl.addDefaultListener "before", abortPrompt
    jsrepl.addDefaultListener "after", startPrompt
    jsrepl.addDefaultListener "output", (data) ->
      jqconsole.Write(toStringWithNewline(data), "jqconsole-output") if data
    jsrepl.addDefaultListener "result", (data) ->
      jqconsole.Write("=> " + toStringWithNewline(data), "text-success") if data
    jsrepl.addDefaultListener "error", (data) ->
      jqconsole.Write(toStringWithNewline(data), "jqconsole-error")

    startPrompt()
]
