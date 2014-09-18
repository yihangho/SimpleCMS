app = angular.module('ProblemForm', ['ui.sortable', 'ui.ace', 'ProblemsHelper', 'Directives', 'ProblemId', 'AuthenticityToken'])

app.controller 'ProblemFormController', ['$scope', '$window', 'ProblemsHelper', 'ProblemId', 'AuthenticityToken', ($scope, $window, ProblemsHelper, ProblemId, AuthenticityToken) ->
  # $scope.problem = ProblemsHelper.defaultProblem()
  if ProblemId?
    $scope.problem = ProblemsHelper.edit(id: ProblemId)
  else
    $scope.problem = new ProblemsHelper
      contest_only: true
      tasks_attributes: []

  $scope.errors = []

  $scope.aceLoad = (editor) ->
    editor.getSession().setTabSize(2)
    editor.getSession().setUseSoftTabs(true)
    editor.getSession().setUseWrapMode(true)

  $scope.saveProblem = ($event) ->
    $event.preventDefault()

    $scope.savingProblem = true
    startSpinner()

    # If permalink is empty, mark it to be deleted
    $scope.problem.permalink_attributes ||= {}
    $scope.problem.permalink_attributes["_destroy"] =
      !($scope.problem.permalink_attributes.url && $scope.problem.permalink_attributes.url.trim().length)

    # Set the order of each task
    $scope.problem.tasks_attributes ||= []
    t.order = idx for t, idx in $scope.problem.tasks_attributes

    $scope.problem = (if $scope.problem.id then ProblemsHelper.update else ProblemsHelper.save)
      id: $scope.problem.id
      authenticity_token: AuthenticityToken,
      {problem: $scope.problem},
      ->
        if $scope.problem.errors? && $scope.problem.errors.length
          $scope.errors = $scope.errors.concat(type: "danger", message: e for e in $scope.problem.errors)
        else
          $window.location.pathname = "/problems/#{$scope.problem.id}"
      , (e) ->
        $scope.errors.push
          type: "danger"
          message: "Something went wrong: #{e.statusText}"

    $scope.problem.$promise.finally ->
      $scope.savingProblem = false
      stopSpinner()

  $scope.addTask = ->
    $scope.problem.tasks_attributes.push({})

  $scope.removeTask = (index) ->
    $scope.problem.tasks_attributes.splice(index, 1)
]
