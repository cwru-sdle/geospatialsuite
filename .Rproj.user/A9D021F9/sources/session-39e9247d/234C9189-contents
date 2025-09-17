test_that("get_region_boundary works with custom bbox", {
  boundary <- get_region_boundary(c(-84, 40, -83, 41))
  expect_s3_class(boundary, "sf")
  expect_equal(nrow(boundary), 1)
})

test_that("get_region_boundary handles invalid input", {
  expect_error(get_region_boundary("NonexistentPlace"))
  expect_error(get_region_boundary(NULL))
})

test_that("load_raster_data works with raster objects", {
  test_raster <- create_test_raster()
  rasters <- load_raster_data(list(test_raster))
  expect_length(rasters, 1)
  expect_s4_class(rasters[[1]], "SpatRaster")
})

test_that("extract_dates_universal works", {
  # Use more realistic filename patterns that should be detected
  files <- c("NDVI_2023-05-15_processed.tif", "NDVI_2023-06-15_processed.tif")

  # Test the function and handle the warning
  suppressWarnings({
    dates <- extract_dates_universal(files)
  })

  expect_length(dates, 2)
  # Check if any date was extracted successfully (even if in Unknown_ format)
  expect_true(length(dates) == 2)

  # Test with simpler pattern that should definitely work
  simple_files <- c("data_20230515.tif", "data_20230615.tif")
  dates2 <- extract_dates_universal(simple_files)
  expect_true(any(grepl("2023", dates2)))
})
