var app = angular.module('ProblemsHelper', []);

app.directive('problemId', ['$http', 'ProblemDefaultSetter', 'TaskJSONInputParser', function($http, ProblemDefaultSetter, TaskJSONInputParser) {
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
            var problemId = attrs['problemId'];
            if (problemId !== undefined && problemId !== null) {
                startSpinner();
                $http.get('/problems/' + problemId + '.json').success(function(data) {
                    scope.problem = ProblemDefaultSetter(data);
                    TaskJSONInputParser(scope.problem.tasks_attributes);
                }).finally(function() {
                    stopSpinner();
                });
            }
        }
    };
}]);

app.service('ProblemDefaultSetter', function() {
    return function(obj) {
        var defaults = {
            contest_only: true,
            permalink_attributes: {},
            tasks_attributes: []
        };

        for (var key in defaults) {
            if (obj[key] === undefined || obj[key] === null) {
                obj[key] = defaults[key]
            }
        }
        return obj;
    }
});

app.service('TaskJSONInputParser', function(){
    return function(tasks) {
        for (var i in tasks) {
            try {
                tasks[i].input_fields = angular.fromJson(tasks[i].input)
            } catch(_) {}
        }
        return tasks;
    }
});
