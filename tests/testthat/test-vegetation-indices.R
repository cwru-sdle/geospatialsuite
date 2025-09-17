# Tests for vegetation index calculations
# ===================================================================

test_that("NDVI calculation works correctly", {
  red_raster <- create_test_raster()
  terra::values(red_raster) <- runif(terra::ncell(red_raster), 0.1, 0.3)

  nir_raster <- create_test_raster()
  terra::values(nir_raster) <- runif(terra::ncell(nir_raster), 0.4, 0.8)

  ndvi <- calculate_vegetation_index(
    red = red_raster,
    nir = nir_raster,
    index_type = "NDVI"
  )

  expect_s4_class(ndvi, "SpatRaster")
  expect_equal(names(ndvi), "NDVI")

  values <- terra::values(ndvi, mat = FALSE)
  expect_true(all(values >= -1 & values <= 1, na.rm = TRUE))
})

test_that("EVI calculation works with blue band", {
  red_raster <- create_test_raster()
  terra::values(red_raster) <- runif(terra::ncell(red_raster), 0.1, 0.3)

  nir_raster <- create_test_raster()
  terra::values(nir_raster) <- runif(terra::ncell(nir_raster), 0.4, 0.8)

  blue_raster <- create_test_raster()
  terra::values(blue_raster) <- runif(terra::ncell(blue_raster), 0.05, 0.15)

  evi <- calculate_vegetation_index(
    red = red_raster,
    nir = nir_raster,
    blue = blue_raster,
    index_type = "EVI"
  )

  expect_s4_class(evi, "SpatRaster")
  expect_equal(names(evi), "EVI")
})

test_that("calculate_multiple_indices works", {
  red_raster <- create_test_raster()
  terra::values(red_raster) <- runif(terra::ncell(red_raster), 0.1, 0.3)

  nir_raster <- create_test_raster()
  terra::values(nir_raster) <- runif(terra::ncell(nir_raster), 0.4, 0.8)

  green_raster <- create_test_raster()
  terra::values(green_raster) <- runif(terra::ncell(green_raster), 0.2, 0.4)

  indices <- calculate_multiple_indices(
    red = red_raster,
    nir = nir_raster,
    green = green_raster,
    indices = c("NDVI", "SAVI", "GNDVI"),
    output_stack = TRUE
  )

  expect_s4_class(indices, "SpatRaster")
  expect_true(terra::nlyr(indices) >= 2)
})

test_that("list_vegetation_indices returns valid data", {
  indices_list <- list_vegetation_indices()
  expect_s3_class(indices_list, "data.frame")
  expect_true(nrow(indices_list) > 10)
  expect_true("NDVI" %in% indices_list$Index)
})

test_that("enhanced NDVI calculation works", {
  red_raster <- create_test_raster()
  terra::values(red_raster) <- runif(terra::ncell(red_raster), 0.1, 0.3)

  nir_raster <- create_test_raster()
  terra::values(nir_raster) <- runif(terra::ncell(nir_raster), 0.4, 0.8)

  ndvi_enhanced <- calculate_ndvi_enhanced(
    red_data = red_raster,
    nir_data = nir_raster,
    quality_filter = TRUE
  )

  expect_s4_class(ndvi_enhanced, "SpatRaster")
})
