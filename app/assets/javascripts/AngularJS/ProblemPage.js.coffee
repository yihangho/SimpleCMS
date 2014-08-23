app = angular.module('ProblemPage', ['ProblemsHelper', 'ui.ace', 'Directives', 'LocalStorageModule'])

app.controller('ProblemPage', ['$scope', '$q', 'localStorageService', ($scope, $q, $storage) ->
    # Set default values
    $scope.code = ""
    $scope.logs = []
    Object.defineProperty $scope.logs, "add",
      value: (type, message) ->
        if message
          this.push
            type: type
            message: message

    $scope.isNumber = (input) ->
      not isNaN(Number(input))

    $scope.$watch 'problem.id', ->
      if $scope.problem && $scope.problem.id
        $storage.bind($scope, 'code', '', "problem-#{$scope.problem.id}-code")

    # Since jsrepl is kind of like a resource that must be shared, use jsreplPromise
    # to implement a locking mechanism.
    # When jsrepl is ready, this promise should be resolved, otherwise, its state shold be
    # pending.
    #
    # Etiquette
    # 1. Resolve the promise as soon as you are done with jsrepl.
    # 2. Detach only the listeners that you have attached.
    #    Hence, never call `jsrepl.off('output')`. Instead, call `jsrepl.off('output', fn)`.
    # 3. Always resolve, never reject.
    jsreplQ = $q.defer()
    jsreplPromise = jsreplQ.promise

    jsrepl = new JSREPL
      input: (fn) -> fn() # In theory this should never be called since we don't have an actual REPL

    jsrepl.loadLanguage("python", -> jsreplQ.resolve())

    $scope.runCode = (code, before, output, result, error, after) ->
      code ||= $scope.code

      jsreplPromise = jsreplPromise.then ->
        innerDfd = $q.defer()

        before() if before

        outputListener = (data) ->
          listener(data, output, "stdout")

        resultListener = (data) ->
          listener(data, result, "result", true)

        errorListener = (data) ->
          listener(data, result, "stderr", true)

        listener = (data, externalListener, label, done = false) ->
          $scope.$apply ->
            externalListener(data) if externalListener
            $scope.logs.add(label, data)

          if done
            detachListeners()
            innerDfd.resolve()

        detachListeners = ->
          jsrepl.off("output", outputListener)
          jsrepl.off("result", resultListener)
          jsrepl.off("error", errorListener)
          after() if after

        jsrepl.on("output", outputListener)
        jsrepl.on("result", resultListener)
        jsrepl.on("error", errorListener)

        jsrepl.eval(code)

        innerDfd.promise;

    $scope.runCodeWithTestCases = ->
      prefix = $scope.problem.prefix_code

      angular.forEach $scope.problem.tasks_attributes, (task, index) ->
        return if task.json

        # TODO We should probably check that task.input itself is a valid Python
        # program before continuing, else, it is likely that the user will see
        # some weird shit error message

        resultantCode = task.input + "\n" + $scope.code

        task.submission = {} unless task.submission
        task.submission.input = "" unless task.submission.input
        task.submission.code  = resultantCode

        stdout = ""

        $scope.runCode resultantCode, ->
          $scope.logs.add("system", "Running with input data for task " + (index + 1))
        , (data) ->
          stdout += data
        , null, null, ->
          task.submission.input = stdout
])
