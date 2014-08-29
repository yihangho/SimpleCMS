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
