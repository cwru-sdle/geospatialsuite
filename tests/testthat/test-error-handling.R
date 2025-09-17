# Tests for error handling and edge cases
# ===================================================================

test_that("functions handle NULL inputs appropriately", {
  expect_error(calculate_vegetation_index(red = NULL, nir = NULL, index_type = "NDVI"))
  expect_error(get_region_boundary(NULL))
})

test_that("functions handle mismatched CRS", {
  # Create rasters with same extent but different CRS
  raster1 <- create_test_raster(nrows = 10, ncols = 10)
  terra::crs(raster1) <- "EPSG:4326"

  raster2 <- create_test_raster(nrows = 10, ncols = 10)
  # Use the same extent to avoid extent mismatch
  terra::ext(raster2) <- terra::ext(raster1)
  terra::crs(raster2) <- "EPSG:4326"  # Start with same CRS, then change

  # Now change CRS without changing extent
  terra::crs(raster2) <- "+proj=utm +zone=17 +datum=WGS84"

  # The function should handle this gracefully with project method
  result <- raster_to_raster_ops(
    raster1 = raster1,
    raster2 = raster2,
    operation = "add",
    align_method = "project"
  )

  expect_s4_class(result, "SpatRaster")
})

test_that("functions handle all NA rasters", {
  na_raster <- create_test_raster()
  terra::values(na_raster) <- NA

  red_raster <- create_test_raster()
  terra::values(red_raster) <- runif(terra::ncell(red_raster), 0.1, 0.3)

  # Suppress the expected warning about all NA values
  suppressWarnings({
    ndvi <- calculate_vegetation_index(
      red = red_raster,
      nir = na_raster,
      index_type = "NDVI"
    )
  })

  expect_s4_class(ndvi, "SpatRaster")
  expect_true(all(is.na(terra::values(ndvi, mat = FALSE))))
})

test_that("functions handle extreme coordinate values", {
  # Test with valid but extreme coordinates
  extreme_points <- data.frame(
    lon = c(-179, 179, 0, 0),
    lat = c(89, -89, 0, 45),
    value = 1:4
  )
  extreme_sf <- sf::st_as_sf(extreme_points, coords = c("lon", "lat"), crs = 4326)

  expect_s3_class(extreme_sf, "sf")
  expect_equal(nrow(extreme_sf), 4)
})
