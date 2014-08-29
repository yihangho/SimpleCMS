app = angular.module('ProblemsHelper', [])

app.directive 'problemId', ['$http', 'ProblemDefaultSetter', 'TaskJSONInputParser', ($http, ProblemDefaultSetter, TaskJSONInputParser) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    problemId = attrs['problemId']
    if problemId?
      startSpinner()
      $http.get('/problems/' + problemId + '.json')
      .success (data) ->
        scope.problem = ProblemDefaultSetter(data)
        TaskJSONInputParser(scope.problem.tasks_attributes)
      .finally ->
        stopSpinner()
]

app.service 'ProblemDefaultSetter', ->
  (obj) ->
    defaults =
      contest_only: true
      permalink_attributes: {},
      tasks_attributes: []

    for key, val of defaults
      unless obj[key]?
        obj[key] = val

    obj

app.service 'TaskJSONInputParser', ->
  (tasks) ->
    for _, task of tasks
      try
        task.input_fields = angular.fromJson(task.input)
