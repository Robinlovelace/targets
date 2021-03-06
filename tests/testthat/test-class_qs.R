tar_test("qs format", {
  skip_if_not_installed("qs")
  x <- target_init(
    name = "abc",
    expr = quote(1L + 1L),
    format = "qs",
    envir = baseenv()
  )
  builder_update_build(x)
  builder_update_path(x)
  builder_update_object(x)
  exp <- 2L
  expect_equal(qs::qread(x$store$file$path), exp)
  expect_equal(target_read_value(x)$object, exp)
  expect_silent(target_validate(x))
})

tar_test("bad compression level throws error", {
  skip_if_not_installed("qs")
  tar_script({
    tar_pipeline(
      tar_target(
        abc,
        1,
        format = "qs",
        resources = list(preset = NA_real_)
      )
    )
  })
  expect_error(tar_make(callr_function = NULL), class = "condition_validate")
})
