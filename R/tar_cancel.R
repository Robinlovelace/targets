#' @title Cancel a target mid-build under a custom condition.
#' @export
#' @description Cancel a target while its command is running
#'   if a condition is met.
#' @details Must be invoked by the target itself. `tar_cancel()`
#'   cannot interrupt a target from another process.
#' @param condition Logical of length 1, whether to cancel the target.
#' @examples
#' refresh_data_on_mondays <- function() {
#'   tar_cancel(!is_monday())
#' }
#' x <- tar_target(x, refresh_data_on_mondays())
tar_cancel <- function(condition = TRUE) {
  condition <- force(condition)
  assert_lgl(condition, "condition in tar_cancel() must be logical")
  if (condition) {
    throw_cancel("throw_cancel() is only valid inside a targets pipeline.")
  }
}
