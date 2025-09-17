# Helper functions for creating synthetic test data
#' Create a standard test raster with proper extent and CRS
create_test_raster <- function(nrows = 10, ncols = 10, vals = "random",
                               xmin = -84, xmax = -83, ymin = 40, ymax = 41) {
  r <- terra::rast(nrows = nrows, ncols = ncols,
                   xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax)

  if (vals == "random") {
    terra::values(r) <- runif(terra::ncell(r), 0, 1)
  } else if (vals == "ndvi") {
    terra::values(r) <- runif(terra::ncell(r), -0.2, 0.9)
  } else if (vals == "sequence") {
    terra::values(r) <- 1:terra::ncell(r)
  } else if (vals == "cdl") {
    # Create CDL-like data with crop codes
    terra::values(r) <- sample(c(1, 5, 21, 24, 36, 176),
                               terra::ncell(r), replace = TRUE)
  } else if (vals == "red") {
    terra::values(r) <- runif(terra::ncell(r), 0.1, 0.3)
  } else if (vals == "nir") {
    terra::values(r) <- runif(terra::ncell(r), 0.4, 0.8)
  } else if (vals == "green") {
    terra::values(r) <- runif(terra::ncell(r), 0.2, 0.4)
  }

  terra::crs(r) <- "EPSG:4326"
  return(r)
}

#' Create test points with proper structure
create_test_points <- function(n = 10, bbox = c(-84, 40, -83, 41)) {
  coords <- data.frame(
    lon = runif(n, bbox[1], bbox[3]),
    lat = runif(n, bbox[2], bbox[4]),
    value1 = runif(n, 0, 100),
    value2 = rnorm(n, 50, 15),
    station_id = paste0("STATION_", sprintf("%03d", 1:n))
  )

  sf::st_as_sf(coords, coords = c("lon", "lat"), crs = 4326)
}

#' Create test polygon
create_test_polygon <- function(bbox = c(-84, 40, -83, 41)) {
  bbox_sf <- sf::st_bbox(c(xmin = bbox[1], ymin = bbox[2],
                           xmax = bbox[3], ymax = bbox[4]))
  poly <- sf::st_as_sfc(bbox_sf, crs = 4326)
  sf::st_sf(id = 1, geometry = poly)
}

#' Create test files with proper date patterns
create_test_files_with_dates <- function(temp_dir = tempdir()) {
  # Create files with date patterns that extract_dates_universal can recognize
  file_patterns <- c(
    "ndvi_2023-05-15.tif",
    "ndvi_2023-06-15.tif",
    "data_20230315.tif",
    "sentinel_2023_03_15.tif"
  )

  file_paths <- file.path(temp_dir, file_patterns)

  # Create empty files for testing
  for (fp in file_paths) {
    file.create(fp)
  }

  return(file_paths)
}

#' Create matching extent rasters for CRS testing
create_matching_rasters <- function() {
  # Create two rasters with identical extents
  template_ext <- terra::ext(c(-84, -83, 40, 41))

  r1 <- terra::rast(nrows = 10, ncols = 10)
  terra::ext(r1) <- template_ext
  terra::crs(r1) <- "EPSG:4326"
  terra::values(r1) <- runif(100, 0, 1)

  r2 <- terra::rast(nrows = 10, ncols = 10)
  terra::ext(r2) <- template_ext
  terra::crs(r2) <- "EPSG:3857"  # Different CRS but same extent
  terra::values(r2) <- runif(100, 0, 1)

  return(list(r1 = r1, r2 = r2))
}

#' Create synthetic water quality data
create_water_quality_data <- function(n = 50) {
  data.frame(
    longitude = runif(n, -84, -83),
    latitude = runif(n, 40, 41),
    discharge = runif(n, 10, 100),
    temperature = runif(n, 15, 25),
    ph = runif(n, 6.5, 8.5),
    station_id = paste0("WQ", sprintf("%03d", 1:n))
  )
}

# Enhanced test data creation that avoids the terra %in% issue
create_cdl_test_raster <- function(nrows = 10, ncols = 10) {
  r <- terra::rast(nrows = nrows, ncols = ncols,
                   xmin = -84, xmax = -83, ymin = 40, ymax = 41)

  # Create CDL-like values (crop codes)
  possible_codes <- c(1, 5, 21, 24, 36, 176)  # corn, soy, wheat, winter wheat, alfalfa, grassland
  cdl_values <- sample(possible_codes, terra::ncell(r), replace = TRUE)
  terra::values(r) <- cdl_values

  terra::crs(r) <- "EPSG:4326"
  return(r)
}
