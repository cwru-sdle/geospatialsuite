# Integration tests to verify end-to-end workflows
# ===================================================================

test_that("end-to-end vegetation analysis works", {
  # Create test data
  red <- create_test_raster()
  terra::values(red) <- runif(terra::ncell(red), 0.1, 0.3)

  nir <- create_test_raster()
  terra::values(nir) <- runif(terra::ncell(nir), 0.4, 0.8)

  green <- create_test_raster()
  terra::values(green) <- runif(terra::ncell(green), 0.2, 0.4)

  # Calculate multiple indices
  indices <- calculate_multiple_indices(
    red = red, nir = nir, green = green,
    indices = c("NDVI", "SAVI", "GNDVI"),
    output_stack = TRUE
  )

  expect_s4_class(indices, "SpatRaster")
  expect_true(terra::nlyr(indices) >= 2)

  # Extract to points
  test_points <- create_test_points(n = 5)
  extracted <- universal_spatial_join(
    source_data = test_points,
    target_data = indices[[1]],  # Use first layer
    method = "extract"
  )

  expect_s3_class(extracted, "sf")
  expect_true(ncol(extracted) > ncol(test_points))
})

test_that("workflow integration works", {
  # Test a simplified workflow
  red_raster <- create_test_raster()
  terra::values(red_raster) <- runif(terra::ncell(red_raster), 0.1, 0.3)

  nir_raster <- create_test_raster()
  terra::values(nir_raster) <- runif(terra::ncell(nir_raster), 0.4, 0.8)

  # Test that NDVI calculation works in workflow context
  config <- list(
    analysis_type = "ndvi_crop_analysis",
    input_data = list(red = red_raster, nir = nir_raster),
    region_boundary = c(-84, 40, -83, 41),
    output_folder = tempdir()
  )

  expect_no_error({
    suppressMessages({
      workflow_result <- run_comprehensive_geospatial_workflow(config)
    })
  })

  expect_type(workflow_result, "list")
})
