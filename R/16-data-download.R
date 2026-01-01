#' Download or access sample datasets for geospatialsuite
#'
#' @description
#' Access built-in sample datasets for learning and testing geospatialsuite
#' functionality. All datasets are in .rds format (CRAN-preferred) and
#' included with the package (~50-80KB total).
#'
#' @param dataset Name of dataset to download. See \code{list_sample_datasets()}
#'   for available options. Use "all" to list all datasets.
#' @param dest_dir Directory to save downloaded data (default: tempdir())
#' @param overwrite Overwrite existing files? (default: FALSE)
#' @param verbose Print download progress? (default: TRUE)
#'
#' @return Character vector of file paths to sample data
#'
#' @details
#' ## Built-in Sample Data (No Download Required)
#'
#' The package includes small sample datasets in inst/extdata/ using .rds format:
#' - **sample_red.rds**: Red band SpatRaster (10x10 pixels, Ohio region)
#' - **sample_nir.rds**: NIR band SpatRaster (10x10 pixels)
#' - **sample_blue.rds**: Blue band SpatRaster (10x10 pixels)
#' - **sample_green.rds**: Green band SpatRaster (10x10 pixels)
#' - **sample_swir1.rds**: SWIR1 band SpatRaster (10x10 pixels)
#' - **sample_multiband.rds**: Multi-band SpatRaster (5 layers stacked)
#' - **sample_points.rds**: Sample field locations (20 points, sf object)
#' - **sample_boundary.rds**: Sample study area polygon (sf object)
#' - **sample_coordinates.csv**: Sample coordinates with attributes
#'
#' All .rds files contain native R objects (SpatRaster or sf) that load instantly
#' with readRDS() or the load_sample_data() helper function.
#'
#' @examples
#' \donttest{
#' # List available datasets
#' datasets <- list_sample_datasets()
#' print(datasets)
#'
#' # Get path to built-in sample data
#' red_file <- get_sample_data("sample_red.rds")
#' nir_file <- get_sample_data("sample_nir.rds")
#'
#' # Load and use sample data
#' red <- load_sample_data("sample_red.rds")
#' nir <- load_sample_data("sample_nir.rds")
#' ndvi <- calculate_vegetation_index(red = red, nir = nir, index_type = "NDVI")
#'   # Plot (users can run this interactively)
#'   # plot(ndvi, main = "NDVI", col = terrain.colors(100))
#' }
#'
#' @export
download_sample_data <- function(dataset = "all",
                                 dest_dir = tempdir(),
                                 overwrite = FALSE,
                                 verbose = TRUE) {

  # For now, we only have built-in data
  # This function is a placeholder for future online datasets

  if (verbose) {
    message("Note: All sample data is built-in with the package.")
    message("No download necessary. Use load_sample_data() to access files.")
    message("\nSee ?download_sample_data for details on available datasets.")
  }

  # Return paths to built-in data
  extdata_dir <- system.file("extdata", package = "geospatialsuite")

  if (!dir.exists(extdata_dir) || length(list.files(extdata_dir)) == 0) {
    stop("Sample data not found. Please reinstall the package.", call. = FALSE)
  }

  sample_files <- list.files(extdata_dir, full.names = TRUE)

  if (verbose) {
    message(sprintf("\nBuilt-in sample files (%d files):", length(sample_files)))
    for (f in basename(sample_files)) {
      message(sprintf("  - %s", f))
    }
    message("\nAccess with: load_sample_data('filename')")
  }

  return(invisible(sample_files))
}


#' List available sample datasets
#'
#' @description
#' Display information about all sample datasets included with geospatialsuite.
#'
#' @param detailed Return detailed information? (default: TRUE)
#'
#' @return Data frame with dataset information
#'
#' @examples
#' \donttest{
#' # List all sample datasets
#' datasets <- list_sample_datasets()
#' print(datasets)
#'
#' # Quick list
#' datasets_simple <- list_sample_datasets(detailed = FALSE)
#' }
#'
#' @export
list_sample_datasets <- function(detailed = TRUE) {

  # Define built-in datasets
  datasets <- data.frame(
    filename = c(
      "sample_red.rds",
      "sample_nir.rds",
      "sample_blue.rds",
      "sample_green.rds",
      "sample_swir1.rds",
      "sample_multiband.rds",
      "sample_points.rds",
      "sample_boundary.rds",
      "sample_coordinates.csv"
    ),
    type = c(
      "SpatRaster", "SpatRaster", "SpatRaster", "SpatRaster", "SpatRaster",
      "SpatRaster", "sf", "sf", "data.frame"
    ),
    size_kb = c(
      2, 2, 2, 2, 2, 8, 3, 2, 1
    ),
    description = c(
      "Red band reflectance (10x10 pixels, Ohio region)",
      "NIR band reflectance (10x10 pixels, Ohio region)",
      "Blue band reflectance (10x10 pixels, Ohio region)",
      "Green band reflectance (10x10 pixels, Ohio region)",
      "SWIR1 band reflectance (10x10 pixels, Ohio region)",
      "Multi-band raster (Blue, Green, Red, NIR, SWIR1)",
      "Sample field locations (20 points with attributes)",
      "Sample study area boundary polygon",
      "Sample coordinates with elevation and soil data"
    ),
    use_case = c(
      "Vegetation index calculation (NDVI, SAVI, etc.)",
      "Vegetation index calculation (NDVI, SAVI, etc.)",
      "Enhanced vegetation index (EVI) calculation",
      "Water index calculation (NDWI, GNDVI)",
      "Water and moisture indices (NDMI, MNDWI)",
      "Auto band detection, multi-index calculation",
      "Spatial join examples, extraction workflows",
      "Region boundary examples, masking operations",
      "Geocoding, spatial integration examples"
    ),
    stringsAsFactors = FALSE
  )

  # Check which files actually exist
  extdata_dir <- system.file("extdata", package = "geospatialsuite")

  if (dir.exists(extdata_dir)) {
    existing_files <- list.files(extdata_dir)
    datasets$available <- datasets$filename %in% existing_files
  } else {
    datasets$available <- FALSE
  }

  if (!detailed) {
    return(datasets[datasets$available, c("filename", "type", "description")])
  }

  # Add access method
  datasets$access_method <- sprintf("load_sample_data('%s')", datasets$filename)

  return(datasets[datasets$available, ])
}


#' Get path to sample data file
#'
#' @description
#' Helper function to get the full path to a sample data file included with
#' geospatialsuite. This is useful when you want the file path rather than
#' loading the data directly.
#'
#' @param filename Name of sample data file (e.g., "sample_red.rds")
#'
#' @return Character string with full path to file
#'
#' @examples
#' \donttest{
#' # Get path to sample raster
#' red_file <- get_sample_data("sample_red.rds")
#' nir_file <- get_sample_data("sample_nir.rds")
#'
#' # Load manually with terra::rast() for PackedSpatRaster
#' red <- terra::rast(readRDS(red_file))
#' nir <- terra::rast(readRDS(nir_file))
#'
#' # Or use load_sample_data() directly (recommended)
#' red <- load_sample_data("sample_red.rds")
#' nir <- load_sample_data("sample_nir.rds")
#'
#' # Calculate NDVI
#' ndvi <- calculate_vegetation_index(red = red, nir = nir, index_type = "NDVI")
#' # plot(ndvi)
#' }
#'
#' @export
get_sample_data <- function(filename) {

  # Get path to file
  file_path <- system.file("extdata", filename, package = "geospatialsuite")

  # Check if file exists
  if (file_path == "" || !file.exists(file_path)) {

    # List available files for helpful error message
    extdata_dir <- system.file("extdata", package = "geospatialsuite")
    available_files <- if (dir.exists(extdata_dir)) {
      list.files(extdata_dir)
    } else {
      character(0)
    }

    stop(
      sprintf("Sample data file '%s' not found.\n", filename),
      "Available files:\n  ",
      paste(available_files, collapse = "\n  "),
      "\n\nUse list_sample_datasets() to see all available datasets.",
      call. = FALSE
    )
  }

  return(file_path)
}


#' Load sample data directly
#'
#' @description
#' Convenience function to load sample data directly into R objects.
#' Automatically detects file type and uses appropriate loading function.
#' For .rds files containing SpatRaster objects, properly unpacks from
#' PackedSpatRaster format. For .csv files, uses read.csv().
#'
#' @param filename Name of sample data file
#' @param ... Additional arguments passed to loading function
#'
#' @return Loaded data object (SpatRaster, sf, or data.frame)
#'
#' @examples
#' \donttest{
#' # Load raster data (returns SpatRaster)
#' red <- load_sample_data("sample_red.rds")
#' nir <- load_sample_data("sample_nir.rds")
#' blue <- load_sample_data("sample_blue.rds")
#'
#' # Load vector data (returns sf object)
#' points <- load_sample_data("sample_points.rds")
#' boundary <- load_sample_data("sample_boundary.rds")
#'
#' # Load CSV (returns data.frame)
#' coords <- load_sample_data("sample_coordinates.csv")
#'
#' # Use loaded data
#' ndvi <- calculate_vegetation_index(red = red, nir = nir, index_type = "NDVI")
#' evi <- calculate_vegetation_index(red = red, nir = nir, blue = blue, index_type = "EVI")
#' # plot(ndvi, main = "NDVI")
#' # plot(evi, main = "EVI")
#' }
#'
#' @export
load_sample_data <- function(filename, ...) {

  file_path <- get_sample_data(filename)

  # Detect file type and load accordingly
  ext <- tolower(tools::file_ext(filename))

  if (ext == "rds") {
    # RDS format - need to check if it's a PackedSpatRaster
    obj <- readRDS(file_path)

    # If it's a PackedSpatRaster, unpack it to regular SpatRaster
    if (inherits(obj, "PackedSpatRaster")) {
      obj <- terra::rast(obj)
    }

    return(obj)

  } else if (ext == "csv") {
    # CSV data
    return(utils::read.csv(file_path, ...))

  } else {
    stop(sprintf("Unsupported file type: %s. Use .rds or .csv files.", ext),
         call. = FALSE)
  }
}
