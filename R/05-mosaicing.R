#' Create raster mosaic with intelligent file selection
#'
#' @description
#' Create mosaics from multiple raster files with various methods and
#' intelligent file selection based on region boundaries.
#'
#' @param input_data Character vector of file paths, directory path, or list of rasters
#' @param method Mosaicing method: "merge", "mosaic", "mean", "max", "min"
#' @param region_boundary Optional region boundary for clipping
#' @param output_file Optional output file path
#' @param parallel Use parallel processing
#'
#' @return SpatRaster object
#'
#' @examples
#' \dontrun{
#' # These examples require external data files not included with the package
#' # Basic mosaic
#' mosaic <- create_raster_mosaic("/path/to/rasters", method = "merge")
#'
#' # Mosaic for specific region
#' ohio_mosaic <- create_raster_mosaic("/aster/files", "merge", "Ohio")
#'
#' # Mean composite
#' mean_mosaic <- create_raster_mosaic(raster_list, method = "mean")
#' }
#'
#' @export
create_raster_mosaic <- function(input_data, method = "merge", region_boundary = NULL,
                                 output_file = NULL, parallel = FALSE) {

  message("Starting raster mosaicing process...")

  # Load raster data
  rasters <- load_raster_data(input_data)

  if (length(rasters) < 2) {
    stop("At least 2 rasters are required for mosaicing")
  }

  message(sprintf("Loaded %d rasters for mosaicing", length(rasters)))

  # Check and align CRS
  base_crs <- terra::crs(rasters[[1]])
  for (i in 2:length(rasters)) {
    if (terra::crs(rasters[[i]]) != base_crs) {
      message(sprintf("Reprojecting raster %d to match base CRS", i))
      rasters[[i]] <- terra::project(rasters[[i]], base_crs)
    }
  }

  # Create mosaic based on method
  mosaic_result <- switch(method,
                          "merge" = {
                            message("Using merge method...")
                            do.call(terra::merge, rasters)
                          },
                          "mosaic" = {
                            message("Using mosaic method...")
                            do.call(terra::mosaic, rasters)
                          },
                          "mean" = {
                            message("Using mean method...")
                            raster_stack <- terra::rast(rasters)
                            terra::app(raster_stack, mean, na.rm = TRUE)
                          },
                          "max" = {
                            message("Using max method...")
                            raster_stack <- terra::rast(rasters)
                            terra::app(raster_stack, max, na.rm = TRUE)
                          },
                          "min" = {
                            message("Using min method...")
                            raster_stack <- terra::rast(rasters)
                            terra::app(raster_stack, min, na.rm = TRUE)
                          },
                          stop(paste("Unsupported mosaicing method:", method))
  )

  # Apply region boundary if provided
  if (!is.null(region_boundary)) {
    message("Applying region boundary...")
    boundary <- get_region_boundary(region_boundary)
    boundary_vect <- terra::vect(boundary)
    mosaic_result <- terra::crop(mosaic_result, boundary_vect)
    mosaic_result <- terra::mask(mosaic_result, boundary_vect)
  }

  # Save if output file specified
  if (!is.null(output_file)) {
    message(sprintf("Saving mosaic to: %s", output_file))
    terra::writeRaster(mosaic_result, output_file, overwrite = TRUE)
  }

  message("Mosaicing completed successfully!")
  return(mosaic_result)
}

#' Select rasters for specific region with intelligent filtering
#'
#' @description
#' Intelligently select raster files that overlap with a specified region.
#' For ASTER files (GDEM and WBD), uses filename-based coordinate extraction
#' for fast filtering without loading full rasters.
#'
#' @param input_folder Directory containing raster files
#' @param region_boundary Region boundary or bounding box
#' @param overlap Logical. If TRUE (default), checks for actual overlap with region.
#'   If FALSE, only includes tiles whose centroid falls within region.
#'   Only applies to ASTER files; non-ASTER files always use overlap detection.
#' @param buffer_size Buffer around region (in degrees)
#'
#' @return Character vector of relevant file paths
#'
#' @examples
#' \donttest{
#' # Select ASTER files for Michigan using overlap detection
#' michigan_files <- select_rasters_for_region("/aster/files", "Michigan")
#'
#' # Use centroid-based selection (faster, fewer tiles)
#' michigan_files_centroid <- select_rasters_for_region("/aster/files", "Michigan", 
#'                                                       overlap = FALSE)
#'
#' # Select with custom buffer
#' nevada_files <- select_rasters_for_region("/data", "Nevada", buffer_size = 0.2)
#' }
#'
#' @export
select_rasters_for_region <- function(input_folder, region_boundary, 
                                      overlap = TRUE, buffer_size = 0.1) {

  message("Selecting rasters for specified region...")

  # Get region extent
  if (is.character(region_boundary) && length(region_boundary) == 1) {
    boundary <- get_region_boundary(region_boundary)
    bbox_coords <- as.vector(sf::st_bbox(boundary))
  } else if (is.numeric(region_boundary) && length(region_boundary) == 4) {
    bbox_coords <- region_boundary
  } else {
    boundary <- get_region_boundary(region_boundary)
    bbox_coords <- as.vector(sf::st_bbox(boundary))
  }

  # Add buffer
  bbox_coords[1] <- bbox_coords[1] - buffer_size  # xmin
  bbox_coords[2] <- bbox_coords[2] - buffer_size  # ymin
  bbox_coords[3] <- bbox_coords[3] + buffer_size  # xmax
  bbox_coords[4] <- bbox_coords[4] + buffer_size  # ymax

  # List all raster files
  all_files <- list.files(input_folder, pattern = "\\.(tif|tiff)$",
                          full.names = TRUE, ignore.case = TRUE)

  # Filter files based on overlap with region
  selected_files <- c()

  for (file in all_files) {
    tryCatch({
      # Extract coordinates from ASTER filenames if applicable
      # Supports both GDEM (ASTGTMV) and WBD (ASTWBDV) formats
      if (grepl("AST(GTM|WBD)V", basename(file))) {
        
        if (overlap) {
          # Use bounding box overlap detection
          aster_bbox <- extract_aster_coordinates(basename(file), boundingbox = TRUE)
          if (!is.null(aster_bbox)) {
            lon_overlap <- (aster_bbox$lon_max >= bbox_coords[1]) & 
                          (bbox_coords[3] >= aster_bbox$lon_min)
            lat_overlap <- (aster_bbox$lat_max >= bbox_coords[2]) & 
                          (bbox_coords[4] >= aster_bbox$lat_min)
            
            if (unname(lon_overlap & lat_overlap)) {
              selected_files <- c(selected_files, file)
            }
          }
        } else {
          # Use centroid-based selection (faster, fewer tiles)
          coords <- extract_aster_coordinates(basename(file))
          if (!is.null(coords)) {
            if (coords$lat >= bbox_coords[2] && coords$lat <= bbox_coords[4] &&
                coords$lon >= bbox_coords[1] && coords$lon <= bbox_coords[3]) {
              selected_files <- c(selected_files, file)
            }
          }
        }
      } else {
        # Check actual raster extent for non-ASTER files
        r <- terra::rast(file)
        r_extent <- as.vector(terra::ext(r))

        # Check overlap
        if (!(r_extent[2] < bbox_coords[1] || r_extent[1] > bbox_coords[3] ||
              r_extent[4] < bbox_coords[2] || r_extent[3] > bbox_coords[4])) {
          selected_files <- c(selected_files, file)
        }
      }
    }, error = function(e) {
      warning(sprintf("Could not process file %s: %s", file, e$message))
    })
  }

  message(sprintf("Selected %d files out of %d for the specified region",
                  length(selected_files), length(all_files)))

  return(selected_files)
}

#' Extract coordinates from ASTER filename
#'
#' @description
#' Internal function to extract lat/lon coordinates from ASTER filenames.
#' Supports both ASTER GDEM (ASTGTMV003) and WBD (ASTWBDV001) formats.
#'
#' @param filename ASTER filename (e.g., "ASTGTMV003_N40W084_dem.tif" or "ASTWBDV001_N40W084_dem.tif")
#' @param boundingbox Logical. If TRUE, returns bounding box coordinates instead of centroid
#'
#' @return List with coordinates (lat/lon if boundingbox=FALSE, or lat_min/lat_max/lon_min/lon_max if boundingbox=TRUE),
#'   or NULL if pattern not matched
#'
#' @keywords internal
extract_aster_coordinates <- function(filename, boundingbox = FALSE) {
  # Pattern for ASTER files: ASTGTMV003_N40W084_dem.tif, ASTWBDV001_N40W084_dem.tif
  pattern <- "AST(GTM|WBD)V([0-9]{3})_([NS])([0-9]{2})([EW])([0-9]{3})_"

  if (grepl(pattern, filename)) {
    matches <- regmatches(filename, regexec(pattern, filename))[[1]]

    lat_dir <- matches[4]
    lat_val <- as.numeric(matches[5])
    lon_dir <- matches[6]
    lon_val <- as.numeric(matches[7])

    # Convert to decimal degrees
    lat <- ifelse(lat_dir == "S", -lat_val, lat_val)
    lon <- ifelse(lon_dir == "W", -lon_val, lon_val)
    
    if (boundingbox) {
      # Calculate bounding box (ASTER tiles are 1x1 degree)
      lat_centroid <- lat + 0.5
      lon_centroid <- lon + 0.5
      
      # Use slightly larger than 0.5 to ensure overlap detection
      lat_min <- lat_centroid - 0.5001389
      lat_max <- lat_centroid + 0.5001389
      lon_min <- lon_centroid - 0.5001389
      lon_max <- lon_centroid + 0.5001389
      
      return(list(lat_min = lat_min, lat_max = lat_max, 
                  lon_min = lon_min, lon_max = lon_max))
    } else {
      return(list(lat = lat, lon = lon))
    }
  }

  return(NULL)
}
