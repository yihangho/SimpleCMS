app = angular.module('ProblemsHelper', ['ngResource'])

app.factory 'ProblemsHelper', ['$resource', ($resource) ->
  $resource '/problems/:id/:action.json', undefined,
    edit:
      method: "GET"
      params:
        action: "edit"
    update:
      method: "PATCH"
]
