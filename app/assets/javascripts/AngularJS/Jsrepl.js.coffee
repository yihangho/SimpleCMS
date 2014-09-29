app = angular.module('SimpleCMS.jsrepl', [])

app.factory 'jsrepl', ['$q', ($q) ->
  _dfd = $q.defer()
  promise = _dfd.promise
  dfd = null

  jsrepl = new JSREPL
    timeout:
      time: 10000
      callback: ->
        if kill = confirm("Your program is taking too long to finish. Do you want to stop it?")
          dfd.reject()
          _dfd = $q.defer()
          promise = _dfd.promise
          jsrepl.loadLanguage "python", -> _dfd.resolve()
        kill

  jsrepl.loadLanguage "python", -> _dfd.resolve()
  jsreplEvents = ["input", "output", "result", "error"]

  defaultListeners = {}

  writer: (text, cls, escape) ->
  addDefaultListener: (type, listener) ->
    if type in jsreplEvents
      jsrepl.on(type, listener)
    else
      (defaultListeners[type] ||= []).push(listener)
  eval: (code = "", listeners = {}) ->
    for key, val of listeners
      listeners[key] = [val] unless angular.isArray(val)

    promise = promise.then ->
      dfd = $q.defer()

      doneListener = ->
        for key, arr of listeners when key in jsreplEvents
          jsrepl.off(key, fn) for fn in arr

        jsrepl.off("result", doneListener)
        jsrepl.off("error", doneListener)

        fn() for fn in (defaultListeners["after"] || [])
        fn() for fn in (listeners["after"] || [])

        dfd.resolve()

      for key, arr of listeners when key in jsreplEvents
        jsrepl.on(key, fn) for fn in arr

      jsrepl.on("result", doneListener)
      jsrepl.on("error", doneListener)

      fn() for fn in (defaultListeners["before"] || [])
      fn() for fn in (listeners["before"] || [])

      jsrepl.eval(code)

      dfd.promise
  jsrepl:
    checkLineEnd: jsrepl.checkLineEnd
]
