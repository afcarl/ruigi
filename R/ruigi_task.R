`ruigi_task&initialize` <- function(name, requires, runner, target) {
  if (!missing(name)) self$name <- name
  if (!missing(requires)) {
    if (length(requires) > 0) {
      if (!all(sapply(requires, is.ruigi_target)))
        stop("Invalid ", sQuote("requires"), " for a ruigi task")
    }
    self$requires <- requires
  }
  ## A runner is the computation that the node must produce
  ## In code, a runner is a function that has two arguments:
  ## *requires*, that is a list of ruigi_tasks, and *produces*, which is a ruigi_target
  ## In practise, this function will be called with the appropriate values by
  ## the scheduler.
  if (missing(runner)) stop("Every task must have a ", sQuote("runner"))
  if (!is.function(runner) | length(runner) != 1)
    stop("A ", sQuote("runner"), " must be a function")
  if (! all(names(formals(runner)) %in% c("requires", "target")))
    stop("A ", sQuote("runner"), " must take ", sQuote("requires"), "and ",
    sQuote("target"), " as inputs")
  self$runner <- runner
  if (missing(target)) stop("Every task must have a ", sQuote("target"))
  if (!is.ruigi_target(target)) {
    stop("A task must have one and only one target that is a ", sQuote("ruigi_target"))
  }
  self$target <- target
}

#' Minimal unit of computation in Ruigi. A task is a bundle that contains dependencies,
#' a target (every node should produce one and only one target), and a function that maps the
#' dependencies to this target. Ruigi will organize and determine the right order of computation
#' of multiple nodes formed together into one pipeline.
#'
#' @export
ruigi_task <- R6::R6Class("ruigi_task",
  public = list(
    ## Defaults
    name = "ruigi processing task",
    requires = list(),
    runner = NULL,
    target = NULL,
    ## This initialize ensures that all the inputs are valid in a very verbose way
    ## since this is the primary interface with the user.
    ## It is important to check early because execution of the node may happen
    ## on another machine, or it will start late and cause errors in a huge batch job.
    initialize = `ruigi_task&initialize`
  )
)

is.ruigi_task <- function(obj) inherits(obj, "ruigi_task")
