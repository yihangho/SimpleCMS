var app = angular.module('ProblemFormApp', ['ui.sortable', 'ProblemsHelper', 'Directives']);

app.controller('ProblemFormController', ['$scope', '$http', '$window', 'ProblemsHelper', function($scope, $http, $window, ProblemsHelper) {

    $scope.problem = ProblemsHelper.defaultProblem();
    $scope.errors = [];

    $scope.saveProblem = function($event) {
        $event.preventDefault();

        ProblemsHelper.save($scope.problem, $scope.authenticity_token).then(function() {
            $window.location.pathname = "/problems/" + $scope.problem.id;
        }, function(errors) {
            angular.forEach(errors, function(error) {
                $scope.errors.push({
                    type: "danger",
                    message: error
                });
            });
        });
    };

    $scope.addTask = function() {
        $scope.problem.tasks_attributes.push({});
    };

    $scope.removeTask = function(index) {
        $scope.problem.tasks_attributes.splice(index, 1);
    };

    $scope.taskAddInputField = function(index) {
        if (!$scope.problem.tasks_attributes[index].input_fields) {
            $scope.problem.tasks_attributes[index].input_fields = [];
        }
        $scope.problem.tasks_attributes[index].input_fields.push({});
    };
}]);


