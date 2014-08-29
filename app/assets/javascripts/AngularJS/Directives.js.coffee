app = angular.module('Directives', [])

app.directive 'zeroClipboard', ['$timeout', ($timeout) ->
  restrict: 'A'
  scope:
    data: '=zeroClipboard'
  link: (scope, elem, attrs) ->
    client = new ZeroClipboard(elem.get()[0])

    client.on "copy", (event) ->
      event.clipboardData.setData('text/plain', scope.data)

    client.on "aftercopy", (event) ->
      if (success for type, success of event.success when success).length
        elem.text("Copied")
        $timeout ->
          elem.text("Copy")
        , 2000

    client.on "error", (event) ->
      if ["flash-disabled", "flash-outdated", "flash-unavailable"].indexOf(event.name) + 1
        elem.addClass("disabled")
]

app.directive 'authenticityToken', ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    scope["authenticity_token"] = attrs['authenticityToken']

app.directive 'alerts', ->
  restrict: 'E'
  scope:
    alerts: '='
  template: """
            <div class="alert alert-dismissible" role="alert"
                 ng-class="getAlertClass(alert)"
                 ng-repeat="alert in alerts">
              <button type="button" class="close" ng-click="dismiss($index)"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
              {{ alert.message }}
            </div>
            """
  controller: ["$scope", ($scope) ->
    $scope.getAlertClass = (alert) ->
      "alert-#{alert.type}" if alert.type in ["warning", "danger", "success", "info"]

    $scope.dismiss = (index) ->
      $scope.alerts.splice(index, 1)
  ]
