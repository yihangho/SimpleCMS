app = angular.module('ProblemForm', ['ui.sortable', 'ProblemsHelper', 'Directives'])

app.controller 'ProblemFormController', ['$scope', '$window', 'ProblemsHelper', ($scope, $window, ProblemsHelper) ->

  $scope.problem = ProblemsHelper.defaultProblem()
  $scope.errors = []

  $scope.saveProblem = ($event) ->
    $event.preventDefault()

    ProblemsHelper.save($scope.problem, $scope.authenticity_token)
    .then ->
      $window.location.pathname = "/problems/#{$scope.problem.id}"
    , (errors) ->
      angular.forEach errors, (error) ->
        $scope.errors.push
          type: "danger"
          message: error

  $scope.addTask = ->
    $scope.problem.tasks_attributes.push({})

  $scope.removeTask = (index) ->
    $scope.problem.tasks_attributes.splice(index, 1)

  $scope.taskAddInputField = (index) ->
    $scope.problem.tasks_attributes[index].input_fields ||= []
    $scope.problem.tasks_attributes[index].input_fields.push({})
]
