var app = angular.module('ProblemFormApp', []);

app.controller('ProblemFormController', ['$scope', '$http', '$window', function($scope, $http, $window) {
    // Default values for a new problem
    $scope.problem = {
        contest_only: true,
        permalink_attributes: {},
        tasks_attributes: []
    };

    $scope.saveProblem = function($event) {
        $event.preventDefault();

        if (!$scope.problem.permalink_attributes.url || $scope.problem.permalink_attributes.url.trim().length == 0) {
            $scope.problem.permalink_attributes["_destroy"] = true;
        }

        if ($scope.problem.id !== undefined && $scope.problem.id !== null) {
            var endPoint = "/problems/" + $scope.problem.id + ".json";
            var savePromise = $http.put(endPoint, $scope.getSubmissionParams());
        } else {
            var endPoint = "/problems.json";
            var savePromise = $http.post(endPoint, $scope.getSubmissionParams());
        }

        savePromise.success(function(data) {
            $scope.problem = data;

            if (!data.errors || data.errors.length == 0) {
                $window.location.pathname = "/problems/" + data.id;
            }
        });
    };

    $scope.getSubmissionParams = function() {
        return {
            authenticity_token: $scope.authenticity_token,
            problem: $scope.problem
        };
    };

    $scope.addTask = function() {
        $scope.problem.tasks_attributes.push({});
    };

    $scope.removeTask = function(index) {
        $scope.problem.tasks_attributes.splice(index, 1);
    };
}]);

app.directive('problemId', ['$http', function($http) {
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
            var problemId = attrs['problemId'];
            if (problemId !== undefined && problemId !== null) {
                $http.get('/problems/' + problemId + '.json').success(function(data) {
                    scope.problem = data;
                });
            }
        }
    };
}]);

app.directive('authenticityToken', function() {
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
            scope["authenticity_token"] = attrs['authenticityToken'];
        }
    };
})
