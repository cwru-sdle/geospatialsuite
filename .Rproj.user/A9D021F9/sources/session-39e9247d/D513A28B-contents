# Tests for spatial join and operations
# ===================================================================

test_that("universal_spatial_join extract method works", {
  test_points <- create_test_points(n = 10)
  test_raster <- create_test_raster()

  result <- universal_spatial_join(
    source_data = test_points,
    target_data = test_raster,
    method = "extract"
  )

  expect_s3_class(result, "sf")
  expect_true(ncol(result) > ncol(test_points))
})

test_that("universal_spatial_join auto method works", {
  test_points <- create_test_points(n = 10)
  test_raster <- create_test_raster()

  result <- universal_spatial_join(
    source_data = test_points,
    target_data = test_raster,
    method = "auto"
  )

  expect_s3_class(result, "sf")
})

test_that("raster_to_raster_ops works", {
  raster1 <- create_test_raster()
  raster2 <- create_test_raster()

  result <- raster_to_raster_ops(
    raster1 = raster1,
    raster2 = raster2,
    operation = "add"
  )

  expect_s4_class(result, "SpatRaster")
})
