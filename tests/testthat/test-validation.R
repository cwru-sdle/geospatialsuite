# Tests for validation helper functions
# ===================================================================

test_that("validate_method works correctly", {
  expect_true(validate_method("extract", c("extract", "overlay", "resample")))
  expect_error(validate_method("invalid", c("extract", "overlay")))
})

test_that("validate_numeric_range works correctly", {
  expect_true(validate_numeric_range(5, min_val = 0, max_val = 10))
  expect_error(validate_numeric_range(-1, min_val = 0, max_val = 10))
})

test_that("check_raster_compatibility works", {
  raster1 <- create_test_raster(nrows = 10, ncols = 10)
  raster2 <- create_test_raster(nrows = 8, ncols = 8)

  aligned <- check_raster_compatibility(raster1, raster2, auto_align = TRUE)
  expect_s4_class(aligned, "SpatRaster")
  expect_true(terra::compareGeom(raster1, aligned))
})
