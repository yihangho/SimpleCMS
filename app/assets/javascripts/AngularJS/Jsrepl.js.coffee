app = angular.module('SimpleCMS.jsrepl', [])

app.factory 'jsrepl', ['$q', ($q) ->
  _dfd = $q.defer()
  promise = _dfd.promise

  jsrepl = new JSREPL
  jsrepl.loadLanguage "python", -> _dfd.resolve()
  jsreplEvents = ["input", "output", "result", "error"]

  defaultListeners = {}

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
]
