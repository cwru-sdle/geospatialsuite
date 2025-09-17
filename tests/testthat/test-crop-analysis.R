
# Tests for crop analysis functions
# ===================================================================

test_that("get_comprehensive_cdl_codes works", {
  corn_codes <- get_comprehensive_cdl_codes("corn")
  expect_equal(corn_codes, 1)

  grain_codes <- get_comprehensive_cdl_codes("grains")
  expect_true(length(grain_codes) > 1)
  expect_true(1 %in% grain_codes)
})

test_that("create_crop_mask works with fixed implementation", {
  # Create test CDL raster with known crop codes
  cdl_raster <- create_test_raster(vals = "cdl")

  # Test with numeric codes
  crop_mask <- create_crop_mask(
    cdl_data = cdl_raster,
    crop_codes = c(1, 5),  # corn and soybeans
    mask_type = "binary"
  )

  expect_s4_class(crop_mask, "SpatRaster")
  expect_equal(names(crop_mask), "crop_mask_binary")

  # Check that values are only 0 or 1
  values <- terra::values(crop_mask, mat = FALSE)
  expect_true(all(values %in% c(0, 1), na.rm = TRUE))
})



test_that("analyze_cdl_crops_dynamic works with area analysis", {
  # Create simple test CDL raster
  cdl_raster <- create_test_raster(nrows = 5, ncols = 5)
  terra::values(cdl_raster) <- rep(c(1, 5, 21), length.out = terra::ncell(cdl_raster))

  # Test area analysis
  area_result <- analyze_cdl_crops_dynamic(
    cdl_data = cdl_raster,
    crop_selection = c(1, 5),  # Use numeric codes directly
    analysis_type = "area"
  )

  expect_type(area_result, "list")
  expect_true("total_area_ha" %in% names(area_result))
  expect_true("crop_areas_ha" %in% names(area_result))
})
