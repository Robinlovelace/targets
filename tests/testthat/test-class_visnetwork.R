tar_test("misspell subclass", {
  expect_error(visual_init(subclass = "1234"), class = "condition_validate")
})

tar_test("visnetwork$targets_only", {
  net <- glimpse_init(pipeline_init())
  vis <- visual_init(network = net, targets_only = FALSE)
  expect_equal(vis$targets_only, FALSE)
})

tar_test("visnetwork$allow", {
  net <- glimpse_init(pipeline_init())
  vis <- visual_init(network = net, allow = "x")
  expect_equal(vis$allow, "x")
})

tar_test("visnetwork$exclude", {
  net <- glimpse_init(pipeline_init())
  vis <- visual_init(network = net, exclude = "x")
  expect_equal(vis$exclude, "x")
})

tar_test("visnetwork$update_network()", {
  envir <- new.env(parent = baseenv())
  envir$a <- 1L
  x <- target_init("x", quote(a), envir = envir)
  pipeline <- pipeline_init(list(x))
  local_init(pipeline)$run()
  x <- target_init("x", quote(a), envir = envir)
  pipeline <- pipeline_init(list(x))
  net <- inspection_init(pipeline)
  vis <- visual_init(network = net)
  vis$update_network()
  vertices <- vis$network$vertices
  vertices <- vertices[order(vertices$name), ]
  rownames(vertices) <- NULL
  exp <- data_frame(
    name = c("a", "x"),
    type = c("object", "stem"),
    status = rep("uptodate", 2L)
  )
  exp <- exp[order(exp$name), ]
  rownames(exp) <- NULL
  expect_equal(vertices[, colnames(exp)], exp)
  edges <- vis$network$edges
  exp <- data_frame(from = "a", to = "x")
  rownames(edges) <- NULL
  rownames(exp) <- NULL
  expect_equal(edges, exp)
})

tar_test("visnetwork$update_network() with allow", {
  x <- target_init("x", quote(1))
  y <- target_init("y", quote(x))
  pipeline <- pipeline_init(list(x, y))
  net <- glimpse_init(pipeline)
  vis <- visual_init(network = net, allow = "x")
  vis$update_network()
  vertices <- vis$network$vertices
  exp <- data_frame(
    name = "x",
    type = "stem",
    status = "undefined"
  )
  rownames(vertices) <- NULL
  rownames(exp) <- NULL
  expect_equal(vertices[, colnames(exp)], exp)
  edges <- vis$network$edges
  exp <- data_frame(from = character(0), to = character(0))
  expect_equal(edges, exp)
})

tar_test("visnetwork$update_network() with exclude", {
  x <- target_init("x", quote(1))
  y <- target_init("y", quote(x))
  pipeline <- pipeline_init(list(x, y))
  net <- glimpse_init(pipeline)
  vis <- visual_init(network = net, exclude = "x")
  vis$update_network()
  vertices <- vis$network$vertices
  exp <- data_frame(
    name = "y",
    type = "stem",
    status = "undefined"
  )
  rownames(vertices) <- NULL
  rownames(exp) <- NULL
  expect_equal(vertices[, colnames(exp)], exp)
  edges <- vis$network$edges
  exp <- data_frame(from = character(0), to = character(0))
  expect_equal(edges, exp)
})

tar_test("visnetwork$update_positions()", {
  net <- glimpse_init(pipeline_order())
  vis <- visual_init(network = net, exclude = "x")
  vis$update_network()
  vis$update_positions()
  vertices <- vis$network$vertices
  vertices <- vertices[order(vertices$level), ]
  expect_equal(vertices$level[grepl("data", vertices$name)], c(1L, 1L))
  expect_equal(
    vertices$level[grepl("max[0-9]|min[0-9]", vertices$name)],
    rep(2L, 4L)
  )
  expect_equal(
    vertices$level[grepl("max[0-9]|min[0-9]", vertices$name)],
    rep(2L, 4L)
  )
  expect_equal(
    vertices$level[grepl("maxes|mins", vertices$name)],
    rep(3L, 2L)
  )
  expect_equal(vertices$level[vertices$name == "all"], 4L)
})

tar_test("visnetwork$update_labels()", {
  net <- glimpse_init(pipeline_order())
  vis <- visual_init(network = net)
  vis$update_network()
  vis$update_labels()
  vertices <- vis$network$vertices
  expect_equal(vertices$id, vertices$name)
  expect_true(is.character(vertices$label))
})

tar_test("visnetwork$update_colors()", {
  net <- glimpse_init(pipeline_order())
  vis <- visual_init(network = net)
  vis$update_network()
  vis$update_colors()
  vertices <- vis$network$vertices
  expect_true("color" %in% colnames(vertices))
})

tar_test("visnetwork$update_colors() on cross plan", {
  net <- glimpse_init(pipeline_cross())
  vis <- visual_init(network = net)
  vis$update_network()
  vis$update_shapes()
  vertices <- vis$network$vertices
  expect_true("shape" %in% colnames(vertices))
  expect_equal(vertices$shape[vertices$name == "data1"], "dot")
  expect_equal(vertices$shape[vertices$name == "map1"], "square")
  expect_equal(vertices$shape[vertices$name == "cross1"], "diamond")
})

tar_test("visnetwork$update_legend() on cross plan", {
  net <- glimpse_init(pipeline_cross())
  vis <- visual_init(network = net)
  vis$update_network()
  vis$update_colors()
  vis$update_shapes()
  vis$update_legend()
  expect_silent(vis$validate())
  legend <- vis$legend
  exp <- data_frame(
    label = c("Map", "Stem", "Cross"),
    color = rep("#899DA4", 3L),
    shape = c("square", "dot", "diamond"),
    font.size = rep(20L, 3L)
  )
  cols <- colnames(legend)
  legend <- legend[order(legend$label), cols]
  exp <- exp[order(exp$label), cols]
  expect_equal(legend, exp)
})

tar_test("visnetwork$update() on cross pipeline", {
  skip_if_not_installed("visNetwork")
  net <- glimpse_init(pipeline_cross())
  vis <- visual_init(network = net)
  vis$update()
  expect_silent(vis$validate())
  visnetwork <- vis$visnetwork
  expect_equal(class(visnetwork)[1], "visNetwork")
})

tar_test("visnetwork$update() on empty pipeline", {
  skip_if_not_installed("visNetwork")
  net <- glimpse_init(pipeline_init())
  vis <- visual_init(network = net)
  vis$update()
  expect_silent(vis$validate())
  visnetwork <- vis$visnetwork
  expect_equal(class(visnetwork)[1], "visNetwork")
})

tar_test("visnetwork$update() on edgeless pipeline", {
  skip_if_not_installed("visNetwork")
  net <- glimpse_init(pipeline_init(list(target_init("x", quote(1)))))
  vis <- visual_init(network = net)
  vis$update()
  expect_silent(vis$validate())
  visnetwork <- vis$visnetwork
  expect_equal(class(visnetwork)[1], "visNetwork")
})

tar_test("visnetwork$validate() with no allow or exclude", {
  net <- glimpse_init(pipeline_init())
  vis <- visual_init(network = net)
  expect_silent(vis$validate())
})

tar_test("visnetwork$validate() with allow and exclude", {
  net <- glimpse_init(pipeline_init())
  vis <- visual_init(network = net, allow = "x", exclude = "y")
  expect_silent(vis$validate())
})

tar_test("visnetwork$validate() with label", {
  pipeline <- pipeline_map()
  local_init(pipeline = pipeline, reporter = "silent")$run()
  net <- inspection_init(pipeline_map())
  vis <- visual_init(network = net, label = c("time", "size", "branches"))
  vis$update()
  expect_true(inherits(vis$visnetwork, "visNetwork"))
})
