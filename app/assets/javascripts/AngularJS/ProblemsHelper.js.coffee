app = angular.module('ProblemsHelper', [])

app.directive 'problemId', ['$http', 'ProblemsHelper', ($http, ProblemsHelper) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    problemId = attrs['problemId']
    ProblemsHelper.defaultId(problemId)
]

app.factory 'ProblemsHelper', ['$q', '$http', ($q, $http) ->
  problems = []
  defaultId = null
  defaultProblem =
    contest_only: true
    permalink_attributes: {}
    tasks_attributes: []

  # Retrieve problem with id
  # Returns a promise which will be resolved with the requested problem if operation
  # is sucessful. The promise is rejected otherwise.
  #
  # This works by first checking the internal cache (problems array). If the cache
  # already have the requested problem, resolve the promise, else, try to load from server
  get: (id, force = false) ->
    dfd = $q.defer()
    if problems[id]? && !force
      dfd.resolve(problems[id])
    else
      $http.get("/problems/#{id}.json")
      .success (data) =>
        this.set(data)
        dfd.resolve(problems[id])
      .error ->
        dfd.reject()

    dfd.promise

  # Put problem into internal cache
  #
  # Please use this method whenever a problem should be added to internal cache (note that
  # the .get method uses this method as well) as this method will perform some
  # initialization-like operations (like updating the default problem)
  set: (problem, def = false) ->
    problems[problem.id] = problem
    if problem.id is defaultId || def
      this.defaultId(defaultId)

  # Save problem to server and perform the following:
  # 1. Set the order for each task
  # 2. Set the ._destroy field for permalink_attributes
  # After saving the problem reference given will be updated.
  # Returns a promise which is resolved with the problem itself if operation
  # was successful, else reject with an array of error messages.
  save: (problem, token) ->
    # 1. Set order
    problem.tasks_attributes ||= []
    task.order = idx for task, idx in problem.tasks_attributes

    # Set permalink destroy status
    problem.permalink_attributes ||= {}
    problem.permalink_attributes["_destroy"] =
      !(problem.permalink_attributes.url && problem.permalink_attributes.url.trim().length)

    # Actually submit the problem to server
    if problem.id?
      request = $http.put("/problems/#{problem.id}.json", problem: problem, authenticity_token: token)
    else
      request = $http.post("/problems.json", problem: problem, authenticity_token: token)

    deferred = $q.defer()
    request.success (data) =>
      # Update the incoming problem object for either case
      angular.copy(data, problem)

      if data.errors && data.errors.length
        deferred.reject(data.errors)
      else
        this.set(data, true)
        deferred.resolve(data)
    .error ->
      deferred.reject()
    return deferred.promise

  # Get or set the ID of default problem
  # If the ID is updated, defaultProblem is updated as well
  defaultId: (id) ->
    if id?
      defaultId = parseInt(id)
      this.get(defaultId).then (problem) ->
        angular.copy(problem, defaultProblem)
    else
      defaultId

  defaultProblem: ->
    defaultProblem
]
