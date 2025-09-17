# Tests for water index calculations
# ===================================================================

test_that("NDWI calculation works correctly", {
  green_raster <- create_test_raster()
  terra::values(green_raster) <- runif(terra::ncell(green_raster), 0.2, 0.4)

  nir_raster <- create_test_raster()
  terra::values(nir_raster) <- runif(terra::ncell(nir_raster), 0.4, 0.8)

  ndwi <- calculate_water_index(
    green = green_raster,
    nir = nir_raster,
    index_type = "NDWI"
  )

  expect_s4_class(ndwi, "SpatRaster")
  expect_equal(names(ndwi), "NDWI")

  values <- terra::values(ndwi, mat = FALSE)
  expect_true(all(values >= -1 & values <= 1, na.rm = TRUE))
})

test_that("MNDWI calculation works with SWIR band", {
  green_raster <- create_test_raster()
  terra::values(green_raster) <- runif(terra::ncell(green_raster), 0.2, 0.4)

  nir_raster <- create_test_raster()
  terra::values(nir_raster) <- runif(terra::ncell(nir_raster), 0.4, 0.8)

  swir1_raster <- create_test_raster()
  terra::values(swir1_raster) <- runif(terra::ncell(swir1_raster), 0.3, 0.6)

  mndwi <- calculate_water_index(
    green = green_raster,
    nir = nir_raster,
    swir1 = swir1_raster,
    index_type = "MNDWI"
  )

  expect_s4_class(mndwi, "SpatRaster")
  expect_equal(names(mndwi), "MNDWI")
})
