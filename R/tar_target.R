#' @title Declare a target.
#' @export
#' @description A target is a single step of computation in a pipeline.
#'   It runs an R command and returns a value.
#'   This value gets treated as an R object that can be used
#'   by the commands of targets downstream. Targets that
#'   are already up to date are skipped. See the user manual
#'   for more details.
#' @return A target object. Users should not modify these directly,
#'   just feed them to [tar_pipeline()] in your `_targets.R` file.
#' @param name Symbol, name of the target.
#' @param command R code to run the target.
#' @param pattern Language to define branching for a target.
#'   For example, in a pipeline with numeric vector targets `x` and `y`,
#'   `tar_target(z, x + y, pattern = map(x, y))` implicitly defines
#'   branches of `z` that each compute `x[1] + y[1]`, `x[2] + y[2]`,
#'   and so on. See the user manual for details.
#' @param tidy_eval Logical, whether to enable tidy evaluation
#'   when interpreting `command` and `pattern`. If `TRUE`, you can use the
#'   "bang-bang" operator `!!` to programmatically insert
#'   the values of global objects.
#' @param packages Character vector of packages to load right before
#'   the target builds. Use `tar_option_set()` to set packages
#'   globally for all subsequent targets you define.
#' @param library Character vector of library paths to try
#'   when loading `packages`.
#' @param format Optional storage format for the target's return value.
#'   With the exception of `format = "file"`, each target
#'   gets a file in `_targets/objects`, and each format is a different
#'   way to save and load this file.
#'   Possible formats:
#'   * `"rds"`: Default, uses `saveRDS()` and `readRDS()`. Should work for
#'     most objects, but slow.
#'   * `"qs"`: Uses `qs::qsave()` and `qs::qread()`. Should work for
#'     most objects, much faster than `"rds"`. Optionally set the
#'     preset for `qsave()` through the `resources` argument, e.g.
#'     `tar_target(..., resources = list(preset = "archive"))`.
#'   * `"fst"`: Uses `fst::write_fst()` and `fst::read_fst()`.
#'     Much faster than `"rds"`, but the value must be
#'     a data frame. Optionally set the compression level for
#'     `fst::write_fst()` through the `resources` argument, e.g.
#'     `tar_target(..., resources = list(compress = 100))`.
#'   * `"fst_dt"`: Same as `"fst"`, but the value is a `data.table`.
#'     Optionally set the compression level the same way as for `"fst"`.
#'   * `"fst_tbl"`: Same as `"fst"`, but the value is a `tibble`.
#'     Optionally set the compression level the same way as for `"fst"`.
#'   * `"keras"`: Uses `keras::save_model_hdf5()` and
#'     `keras::load_model_hdf5()`. The value must be a Keras model.
#'   * `"file"`: A dynamic file. To use this format,
#'     the target needs to manually identify or save some data
#'     and return a character vector of paths
#'     to the data. Those paths must point to files or directories,
#'     and they must not contain characters `|` or `*`.
#'     Then, `targets` automatically checks those files and cues the
#'     appropriate build decisions if those files are out of date.
#'   * `"url"`: A dynamic input URL. It works like `format = "file"`
#'     except the return value of the target is a URL that already exists
#'     and serves as input data for downstream targets. Optionally
#'     supply a custom `curl` handle through the `resources` argument, e.g.
#'     `tar_target(..., resources = list(handle = curl::new_handle()))`.
#'     The data file at the URL needs to have an ETag or a Last-Modified
#'     time stamp, or else the target will throw an error because
#'     it cannot track the data. Also, use extreme caution when
#'     trying to use `format = "url"` to track uploads. You must be absolutely
#'     certain the ETag and Last-Modified time stamp are fully updated
#'     and available by the time the target's command finishes running.
#'     `targets` makes no attempt to wait for the web server.
#' @param iteration Character of length 1, name of the iteration mode
#'   of the target. Choices:
#'   * `"vector"`: branching happens with `vectors::vec_slice()` and
#'     aggregation happens with `vctrs::vec_c()`.
#'   * `"list"`, branching happens with `[[]]` and aggregation happens with
#'     `list()`.
#'   * `"group"`: `dplyr::group_by()`-like functionality to branch over
#'     subsets of a data frame. The target's return value must be a data
#'     frame with a special `tar_group` column of consecutive integers
#'     from 1 through the number of groups. Each integer designates a group,
#'     and a branch is created for each collection of rows in a group.
#'     See the [tar_group()] function to see how you can
#'     create the special `tar_group` column with `dplyr::group_by()`.
#' @param error Character of length 1, what to do if the target
#'   runs into an error. If `"stop"`, the whole pipeline stops
#'   and throws an error. If `"continue"`, the error is recorded,
#'   but the pipeline keeps going.
#' @param memory Character of length 1, memory strategy.
#'   If `"persistent"`, the target stays in memory
#'   until the end of the pipeline.
#'   If `"transient"`, the target gets unloaded
#'   after every new target completes.
#'   Either way, the target gets automatically loaded into memory
#'   whenever another target needs the value.
#' @param deployment Character of length 1, only relevant to
#'   [tar_make_clustermq()] and [tar_make_future()]. If `"remote"`,
#'   the target builds on a remote parallel worker. If `"local"`,
#'   the target builds on the host machine / process managing the pipeline.
#' @param priority Numeric of length 1 between 0 and 1. Controls which
#'   targets get deployed first when multiple competing targets are ready
#'   simultaneously. Targets with priorities closer to 1 get built earlier.
#' @param resources A named list of computing resources. Uses:
#'   * Template file wildcards for `future::future()` in [tar_make_future()].
#'   * Template file wildcards `clustermq::workers()` in [tar_make_clustermq()].
#'   * Custom `curl` handle if `format = "url"`,
#'     e.g. `resources = list(handle = curl::new_handle())`.
#'   * Custom preset for `qs::qsave()` if `format = "qs"`, e.g.
#'     `resources = list(handle = "archive")`.
#'   * Custom compression level for `fst::write_fst()` if
#'     `format` is `"fst"`, `"fst_dt"`, or `"fst_tbl"`, e.g.
#'     `resources = list(compress = 100)`.
#' @param storage Character of length 1, only relevant to
#'   [tar_make_clustermq()] and [tar_make_future()].
#'   If `"local"`, the target's return value is sent back to the
#'   host machine and saved locally. If `"remote"`, the remote worker
#'   saves the value.
#' @param retrieval Character of length 1, only relevant to
#'   [tar_make_clustermq()] and [tar_make_future()].
#'   If `"local"`, the target's dependencies are loaded on the host machine
#'   and sent to the remote worker before the target builds.
#'   If `"remote"`, the remote worker loads the targets dependencies.
#' @param cue An optional object from `tar_cue()` to customize the
#'   rules that decide whether the target is up to date.
#' @examples
#' # Defining targets does not run them.
#' data <- tar_target(target_name, get_data(), packages = "tidyverse")
#' analysis <- tar_target(analysis, analyze(x), pattern = map(x))
#' # Pipelines accept targets.
#' pipeline <- tar_pipeline(data, analysis)
#' # Tidy evaluation
#' tar_option_set(envir = environment())
#' n_rows <- 30L
#' data <- tar_target(target_name, get_data(!!n_rows))
#' print(data)
#' # Disable tidy evaluation:
#' data <- tar_target(target_name, get_data(!!n_rows), tidy_eval = FALSE)
#' print(data)
#' tar_option_reset()
tar_target <- function(
  name,
  command,
  pattern = NULL,
  tidy_eval = targets::tar_option_get("tidy_eval"),
  packages = targets::tar_option_get("packages"),
  library = targets::tar_option_get("library"),
  format = targets::tar_option_get("format"),
  iteration = targets::tar_option_get("iteration"),
  error = targets::tar_option_get("error"),
  memory = targets::tar_option_get("memory"),
  deployment = targets::tar_option_get("deployment"),
  priority = targets::tar_option_get("priority"),
  resources = targets::tar_option_get("resources"),
  storage = targets::tar_option_get("storage"),
  retrieval = targets::tar_option_get("retrieval"),
  cue = targets::tar_option_get("cue")
) {
  name <- deparse_language(substitute(name))
  assert_chr(name, "name arg of tar_target() must be a symbol")
  assert_lgl(tidy_eval, "tidy_eval in tar_target() must be logical.")
  assert_chr(packages, "packages in tar_target() must be character.")
  assert_chr(
    library %||% character(0),
    "library in tar_target() must be NULL or character."
  )
  assert_format(format)
  iteration <- match.arg(iteration, c("vector", "list", "group"))
  error <- match.arg(error, c("stop", "continue", "save"))
  memory <- match.arg(memory, c("persistent", "transient"))
  deployment <- match.arg(deployment, c("remote", "local"))
  assert_dbl(priority)
  assert_scalar(priority)
  assert_ge(priority, 0)
  assert_le(priority, 1)
  assert_list(resources, "resources in tar_target() must be a named list.")
  storage <- match.arg(storage, c("local", "remote"))
  retrieval <- match.arg(retrieval, c("local", "remote"))
  if (!is.null(cue)) {
    cue_validate(cue)
  }
  envir <- tar_option_get("envir")
  expr <- as.expression(substitute(command))
  pattern <- as.expression(substitute(pattern))
  target_init(
    name = name,
    expr = tidy_eval(expr, envir, tidy_eval),
    pattern = tidy_eval(pattern, envir, tidy_eval),
    packages = packages,
    library = library,
    envir = envir,
    format = format,
    iteration = iteration,
    error = error,
    memory = memory,
    deployment = deployment,
    priority = priority,
    resources = resources,
    storage = storage,
    retrieval = retrieval,
    cue = cue
  )
}
