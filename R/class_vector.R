vector_new <- function(object = NULL) {
  enclass(environment(), c("tar_vector", "tar_value"))
}

#' @export
value_count_slices.tar_vector <- function(value) {
  vctrs::vec_size(value$object)
}

#' @export
value_produce_slice.tar_vector <- function(value, index) { # nolint
  vctrs::vec_slice(x = value$object, i = index)
}

#' @export
value_produce_aggregate.tar_vector <- function(value, objects) { # nolint
  do.call(vctrs::vec_c, objects)
}
