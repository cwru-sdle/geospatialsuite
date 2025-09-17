# Tests for spatial mapping functions
# ===================================================================

test_that("plot_raster_fast works without error", {
  test_raster <- create_test_raster(vals = "ndvi")

  expect_no_error(
    plot_raster_fast(
      test_raster,
      title = "Test NDVI",
      color_scheme = "ndvi"
    )
  )
})

test_that("quick_map works", {
  test_raster <- create_test_raster()

  expect_no_error(quick_map(test_raster))
})

test_that("create_spatial_map works with points", {
  skip_if_not_installed("ggplot2")

  test_points <- create_test_points()

  # The function might return NULL for terra plots, which is expected
  expect_no_error({
    map_result <- create_spatial_map(
      spatial_data = test_points,
      fill_variable = "value1",
      map_type = "points"
    )
  })
})

test_that("create_spatial_map works with raster", {
  test_raster <- create_test_raster(vals = "ndvi")

  # Should complete without error
  expect_no_error({
    map_result <- create_spatial_map(
      spatial_data = test_raster,
      map_type = "auto",
      title = "Test Raster Map"
    )
  })
})

test_that("plot_rgb_raster works with multi-band data", {
  # Create a simple multi-band raster
  red_band <- create_test_raster()
  green_band <- create_test_raster()
  blue_band <- create_test_raster()

  # Stack them
  rgb_raster <- c(red_band, green_band, blue_band)
  names(rgb_raster) <- c("red", "green", "blue")

  expect_no_error({
    plot_rgb_raster(
      raster_data = rgb_raster,
      r = 1, g = 2, b = 3,
      title = "RGB Test"
    )
  })
})
