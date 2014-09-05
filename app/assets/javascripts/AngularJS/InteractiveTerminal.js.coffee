app = angular.module('SimpleCMS.InteractiveTerminal', ['SimpleCMS.jsrepl'])

app.directive 'interactiveTerminal', ['jsrepl', '$window', (jsrepl, $window) ->
  restrict: 'E'
  scope:
    history: '='
  link: (scope, elem, attrs) ->
    elem.css
      width: elem.parent().width()

    scope.$watch "history", ->
      if angular.isArray scope.history
        jqconsole.SetHistory(scope.history)

    jqconsole = elem.jqconsole('Welcome to the Malaysian Computing Challenging.\nThis system is running
Python 2.7.2.\n', '> ', '..')

    angular.element($window).on 'beforeunload', (e) ->
      scope.$apply ->
        scope.history = jqconsole.GetHistory()
      undefined

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
