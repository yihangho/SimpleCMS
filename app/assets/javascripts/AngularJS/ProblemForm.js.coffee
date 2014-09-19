app = angular.module('ProblemForm', ['ui.sortable', 'ui.ace', 'ProblemsHelper', 'Directives'])

app.controller 'ProblemFormController', ['$scope', '$window', 'ProblemsHelper', ($scope, $window, ProblemsHelper) ->

  $scope.problem = ProblemsHelper.defaultProblem()
  $scope.errors = []

  $scope.aceLoad = (editor) ->
    if editor.session.$modeId == "ace/mode/python"
      editor.getSession().setTabSize(4)
    else
      editor.getSession().setTabSize(2)
    editor.getSession().setUseSoftTabs(true)
    editor.getSession().setUseWrapMode(true)

  $scope.saveProblem = ($event) ->
    $event.preventDefault()

    $scope.savingProblem = true
    startSpinner()

    ProblemsHelper.save($scope.problem, $scope.authenticity_token)
    .then ->
      $window.location.pathname = "/problems/#{$scope.problem.id}"
    , (errors) ->
      angular.forEach errors, (error) ->
        $scope.errors.push
          type: "danger"
          message: error
    .finally ->
      $scope.saveProblem = false
      stopSpinner()

  $scope.addTask = ->
    $scope.problem.tasks_attributes.push({})

  $scope.removeTask = (index) ->
    $scope.problem.tasks_attributes.splice(index, 1)
]
