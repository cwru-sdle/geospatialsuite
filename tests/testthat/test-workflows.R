# Tests for comprehensive workflows
# ===================================================================

test_that("NDVI workflow completes successfully", {
  red_raster <- create_test_raster()
  terra::values(red_raster) <- runif(terra::ncell(red_raster), 0.1, 0.3)

  nir_raster <- create_test_raster()
  terra::values(nir_raster) <- runif(terra::ncell(nir_raster), 0.4, 0.8)

  blue_raster <- create_test_raster()
  terra::values(blue_raster) <- runif(terra::ncell(blue_raster), 0.05, 0.15)

  config <- list(
    analysis_type = "ndvi_crop_analysis",
    input_data = list(red = red_raster, nir = nir_raster, blue = blue_raster),
    region_boundary = c(-84, 40, -83, 41),
    output_folder = tempdir()
  )

  expect_no_error(
    workflow_result <- run_comprehensive_geospatial_workflow(config)
  )
})
