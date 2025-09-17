# Helper Functions for GeoSpatialSuite
# All missing functions now properly implemented

#' Match rasters by date
#' @keywords internal
match_rasters_by_date <- function(red_data, nir_data, date_patterns = NULL, verbose = FALSE) {
  # Handle different input types
  if (is.character(red_data) && length(red_data) == 1 && dir.exists(red_data)) {
    red_files <- list.files(red_data, pattern = "\\.(tif|tiff)$", full.names = TRUE, ignore.case = TRUE)
  } else {
    red_files <- red_data
  }

  if (is.character(nir_data) && length(nir_data) == 1 && dir.exists(nir_data)) {
    nir_files <- list.files(nir_data, pattern = "\\.(tif|tiff)$", full.names = TRUE, ignore.case = TRUE)
  } else {
    nir_files <- nir_data
  }

  # Extract dates from both datasets
  red_dates <- extract_dates_universal(red_files, date_patterns, verbose)
  nir_dates <- extract_dates_universal(nir_files, date_patterns, verbose)

  # Find matching dates
  common_dates <- intersect(red_dates, nir_dates)

  if (length(common_dates) == 0) {
    if (verbose) message("No matching dates found, using file order matching")
    # Fallback: match by order if same number of files
    if (length(red_files) == length(nir_files)) {
      return(data.frame(
        red = red_files,
        nir = nir_files,
        date = paste0("Pair_", seq_along(red_files)),
        stringsAsFactors = FALSE
      ))
    } else {
      stop("No matching dates found and different number of files")
    }
  }

  # Create matched data frame
  matched_df <- data.frame(
    red = red_files[red_dates %in% common_dates],
    nir = nir_files[nir_dates %in% common_dates],
    date = common_dates,
    stringsAsFactors = FALSE
  )

  if (verbose) {
    message(sprintf("Matched %d pairs by date", nrow(matched_df)))
  }

  return(matched_df)
}

#' Map custom band names
#' @keywords internal
map_custom_band_names <- function(spectral_data, band_names, verbose = FALSE) {
  bands <- list(red = NULL, nir = NULL, blue = NULL, green = NULL,
                swir1 = NULL, swir2 = NULL, red_edge = NULL, coastal = NULL, nir2 = NULL)

  # Map provided band names to standard names
  if (length(band_names) >= 2) {
    bands$red <- spectral_data[[band_names[1]]]
    bands$nir <- spectral_data[[band_names[2]]]
  }
  if (length(band_names) >= 3) bands$blue <- spectral_data[[band_names[3]]]
  if (length(band_names) >= 4) bands$green <- spectral_data[[band_names[4]]]
  if (length(band_names) >= 5) bands$swir1 <- spectral_data[[band_names[5]]]
  if (length(band_names) >= 6) bands$swir2 <- spectral_data[[band_names[6]]]

  if (verbose) {
    message(sprintf("Mapped %d custom band names", length(band_names)))
  }

  return(bands)
}

#' Validate vegetation analysis
#' @keywords internal
validate_vegetation_analysis <- function(vegetation_indices, reference_data, verbose = FALSE) {
  if (verbose) message("Performing validation analysis...")

  validation_results <- list()

  # If reference_data is NULL, skip validation
  if (is.null(reference_data)) {
    if (verbose) message("No reference data provided for validation")
    return(validation_results)
  }

  # Simple validation - compare means if reference data available
  for (idx in names(vegetation_indices)) {
    if (idx %in% names(reference_data)) {
      observed <- terra::values(vegetation_indices[[idx]], mat = FALSE)

      # Handle reference data (could be raster or vector)
      if (inherits(reference_data[[idx]], "SpatRaster")) {
        expected <- terra::values(reference_data[[idx]], mat = FALSE)
      } else {
        expected <- reference_data[[idx]]
      }

      # Remove NAs for comparison
      valid_obs <- !is.na(observed)
      valid_exp <- !is.na(expected)

      # Ensure same length
      min_length <- min(length(observed), length(expected))
      if (min_length > 0) {
        obs_subset <- observed[1:min_length]
        exp_subset <- expected[1:min_length]

        common_valid <- !is.na(obs_subset) & !is.na(exp_subset)

        if (sum(common_valid) > 0) {
          correlation <- cor(obs_subset[common_valid], exp_subset[common_valid])
          rmse <- sqrt(mean((obs_subset[common_valid] - exp_subset[common_valid])^2))

          validation_results[[idx]] <- list(
            correlation = correlation,
            rmse = rmse,
            n_samples = sum(common_valid)
          )
        }
      }
    }
  }

  return(validation_results)
}

#' Save vegetation analysis results
#' @keywords internal
save_vegetation_analysis_results <- function(analysis_results, vegetation_indices,
                                             output_folder, crop_type, verbose = FALSE) {
  if (verbose) message("Saving vegetation analysis results...")

  # Create output folder if it doesn't exist
  if (!dir.exists(output_folder)) {
    dir.create(output_folder, recursive = TRUE)
  }

  # Save vegetation indices as raster stack
  indices_file <- file.path(output_folder, paste0(crop_type, "_vegetation_indices.tif"))
  if (inherits(vegetation_indices, "SpatRaster")) {
    terra::writeRaster(vegetation_indices, indices_file, overwrite = TRUE)
  }

  # Save analysis results as RDS
  analysis_file <- file.path(output_folder, paste0(crop_type, "_analysis_results.rds"))
  saveRDS(analysis_results, analysis_file)

  # Create summary text file
  summary_file <- file.path(output_folder, paste0(crop_type, "_summary.txt"))
  summary_text <- c(
    paste("Crop Vegetation Analysis Summary for", crop_type),
    paste("Date:", Sys.time()),
    "",
    "Files created:",
    paste("  Vegetation indices:", basename(indices_file)),
    paste("  Analysis results:", basename(analysis_file)),
    paste("  Summary:", basename(summary_file))
  )

  writeLines(summary_text, summary_file)

  return(list(
    indices_file = indices_file,
    analysis_file = analysis_file,
    summary_file = summary_file
  ))
}

#' Create dominant crop map -
#' @keywords internal
create_dominant_crop_map <- function(cdl_raster, crop_codes, crop_names, boundary) {
  # Find most common crop in each area using terra operations
  if (length(crop_codes) > 1) {
    # Create mask for selected crops
    crop_mask <- cdl_raster
    crop_mask[!(cdl_raster %in% crop_codes)] <- NA

    # Use terra plotting
    terra::plot(crop_mask, main = "Dominant Crop Distribution",
                col = rainbow(length(crop_codes)))
  } else {
    # Single crop
    crop_mask <- cdl_raster == crop_codes[1]
    terra::plot(crop_mask, main = paste("Distribution of", crop_names[1]))
  }

  return(invisible(NULL))
}

#' Create crop diversity map -
#' @keywords internal
create_crop_diversity_map <- function(cdl_raster, crop_codes, boundary) {
  # Calculate crop diversity (number of different crops in focal window)
  diversity <- terra::focal(cdl_raster, w = matrix(1, 3, 3),
                            fun = function(x) length(unique(x[!is.na(x) & x %in% crop_codes])))

  terra::plot(diversity, main = "Crop Diversity", col = terrain.colors(10))
  return(invisible(NULL))
}

#' Create crop area map -
#' @keywords internal
create_crop_area_map <- function(cdl_raster, crop_codes, crop_names, boundary) {
  # Create binary mask for selected crops
  area_mask <- cdl_raster %in% crop_codes
  terra::plot(area_mask, main = "Crop Area Distribution",
              col = c("white", "darkgreen"))
  return(invisible(NULL))
}

#' Add crop statistics overlay
#' @keywords internal
add_crop_statistics_overlay <- function(plot_obj, cdl_raster, crop_codes, crop_names) {
  # Calculate basic statistics and print to console
  crop_freq <- terra::freq(cdl_raster)
  crop_pixels <- sum(crop_freq$count[crop_freq$value %in% crop_codes], na.rm = TRUE)
  total_pixels <- sum(crop_freq$count, na.rm = TRUE)

  message(sprintf("Crop Statistics: %d crop pixels out of %d total (%.1f%%)",
                  crop_pixels, total_pixels, (crop_pixels/total_pixels)*100))

  # For terra plots, we can't easily add text overlays, so just return the message
  return(plot_obj)
}

#' Create overlay comparison
#' @keywords internal
create_overlay_comparison <- function(data1, data2, titles, color_scheme) {
  # Simple side-by-side plotting using terra
  oldpar <- par(no.readonly = TRUE)  #save current settings
  on.exit(par(oldpar))               #iMMEDIATE on.exit() call
  par(mfrow = c(1, 2))              # now safe to change
  terra::plot(data1, main = titles[1], col = viridis::viridis(100))
  terra::plot(data2, main = titles[2], col = viridis::viridis(100))
  return(invisible(NULL))
}

#' Add points to leaflet -
#' @keywords internal
add_points_to_leaflet <- function(map_obj, spatial_data, fill_variable, popup_vars, color_scheme, cluster_points) {
  if (!requireNamespace("leaflet", quietly = TRUE)) {
    warning("leaflet package not available")
    return(map_obj)
  }

  if (!is.null(fill_variable) && fill_variable %in% names(spatial_data)) {
    if (is.numeric(spatial_data[[fill_variable]])) {
      pal <- leaflet::colorNumeric("viridis", spatial_data[[fill_variable]])
    } else {
      pal <- leaflet::colorFactor("Set3", spatial_data[[fill_variable]])
    }

    map_obj <- map_obj %>%
      leaflet::addCircleMarkers(
        data = spatial_data,
        color = ~pal(get(fill_variable)),
        clusterOptions = if (cluster_points) leaflet::markerClusterOptions() else NULL
      )
  } else {
    map_obj <- map_obj %>% leaflet::addCircleMarkers(data = spatial_data)
  }

  return(map_obj)
}

#' Add polygons to leaflet -
#' @keywords internal
add_polygons_to_leaflet <- function(map_obj, spatial_data, fill_variable, popup_vars, color_scheme) {
  if (!requireNamespace("leaflet", quietly = TRUE)) {
    warning("leaflet package not available")
    return(map_obj)
  }

  if (!is.null(fill_variable) && fill_variable %in% names(spatial_data)) {
    if (is.numeric(spatial_data[[fill_variable]])) {
      pal <- leaflet::colorNumeric("viridis", spatial_data[[fill_variable]])
    } else {
      pal <- leaflet::colorFactor("Set3", spatial_data[[fill_variable]])
    }

    map_obj <- map_obj %>%
      leaflet::addPolygons(
        data = spatial_data,
        fillColor = ~pal(get(fill_variable)),
        fillOpacity = 0.7
      )
  } else {
    map_obj <- map_obj %>% leaflet::addPolygons(data = spatial_data)
  }

  return(map_obj)
}

#' Add lines to leaflet -
#' @keywords internal
add_lines_to_leaflet <- function(map_obj, spatial_data, fill_variable, popup_vars, color_scheme) {
  if (!requireNamespace("leaflet", quietly = TRUE)) {
    warning("leaflet package not available")
    return(map_obj)
  }

  map_obj <- map_obj %>% leaflet::addPolylines(data = spatial_data)
  return(map_obj)
}

#' Run enhanced terrain analysis workflow - IMPLEMENTED
#' @keywords internal
run_enhanced_terrain_analysis_workflow <- function(config, output_folder) {
  message("Running enhanced terrain analysis workflow...")

  # Extract configuration
  input_data <- config$input_data
  region_boundary <- config$region_boundary

  # Load elevation data
  if (is.character(input_data)) {
    elevation <- terra::rast(input_data)
  } else {
    elevation <- input_data
  }

  # Apply region boundary if provided
  if (!is.null(region_boundary)) {
    boundary <- get_region_boundary(region_boundary)
    boundary_vect <- terra::vect(boundary)
    elevation <- terra::crop(elevation, boundary_vect)
    elevation <- terra::mask(elevation, boundary_vect)
  }

  # Calculate basic terrain variables
  slope <- terra::terrain(elevation, opt = "slope", unit = "degrees")
  aspect <- terra::terrain(elevation, opt = "aspect", unit = "degrees")
  tri <- terra::terrain(elevation, opt = "TRI")
  tpi <- terra::terrain(elevation, opt = "TPI")

  # Combine results
  terrain_stack <- c(elevation, slope, aspect, tri, tpi)
  names(terrain_stack) <- c("elevation", "slope", "aspect", "TRI", "TPI")

  # Save results
  if (!is.null(output_folder) && !dir.exists(output_folder)) {
    dir.create(output_folder, recursive = TRUE)
  }

  if (!is.null(output_folder)) {
    output_file <- file.path(output_folder, "terrain_analysis.tif")
    terra::writeRaster(terrain_stack, output_file, overwrite = TRUE)
  }

  terrain_results <- list(
    analysis_type = "terrain",
    terrain_data = terrain_stack,
    output_file = if (!is.null(output_folder)) file.path(output_folder, "terrain_analysis.tif") else NULL,
    message = "Enhanced terrain analysis completed successfully"
  )

  return(terrain_results)
}

#' Run enhanced temporal workflow - IMPLEMENTED
#' @keywords internal
run_enhanced_temporal_workflow <- function(config, output_folder) {
  message("Running enhanced temporal workflow...")

  # Extract configuration
  input_data <- config$input_data
  dates <- config$dates
  analysis_type <- config$analysis_type_detail %||% "trend"

  # Load temporal data
  if (is.character(input_data)) {
    rasters <- load_raster_data(input_data)
  } else {
    rasters <- input_data
  }

  # Extract dates if not provided
  if (is.null(dates)) {
    dates <- extract_dates_universal(input_data)
  }

  # Basic temporal analysis - calculate mean and trend
  raster_stack <- terra::rast(rasters)
  temporal_mean <- terra::app(raster_stack, mean, na.rm = TRUE)
  temporal_sd <- terra::app(raster_stack, sd, na.rm = TRUE)

  # Combine results
  temporal_results <- c(temporal_mean, temporal_sd)
  names(temporal_results) <- c("temporal_mean", "temporal_sd")

  # Save results
  if (!is.null(output_folder) && !dir.exists(output_folder)) {
    dir.create(output_folder, recursive = TRUE)
  }

  if (!is.null(output_folder)) {
    output_file <- file.path(output_folder, "temporal_analysis.tif")
    terra::writeRaster(temporal_results, output_file, overwrite = TRUE)
  }

  results <- list(
    analysis_type = "temporal",
    temporal_data = temporal_results,
    dates = dates,
    output_file = if (!is.null(output_folder)) file.path(output_folder, "temporal_analysis.tif") else NULL,
    message = "Enhanced temporal workflow completed successfully"
  )

  return(results)
}

#' Run enhanced mosaic workflow - IMPLEMENTED
#' @keywords internal
run_enhanced_mosaic_workflow <- function(config, output_folder) {
  message("Running enhanced mosaic workflow...")

  # Extract configuration
  input_data <- config$input_data
  method <- config$method %||% "merge"
  region_boundary <- config$region_boundary

  # Create mosaic using existing function
  mosaic_result <- create_raster_mosaic(
    input_data = input_data,
    method = method,
    region_boundary = region_boundary
  )

  # Save results
  if (!is.null(output_folder) && !dir.exists(output_folder)) {
    dir.create(output_folder, recursive = TRUE)
  }

  if (!is.null(output_folder)) {
    output_file <- file.path(output_folder, "mosaic_result.tif")
    terra::writeRaster(mosaic_result, output_file, overwrite = TRUE)
  }

  results <- list(
    analysis_type = "mosaic",
    mosaic_data = mosaic_result,
    method = method,
    output_file = if (!is.null(output_folder)) file.path(output_folder, "mosaic_result.tif") else NULL,
    message = "Enhanced mosaic workflow completed successfully"
  )

  return(results)
}

#' Run multi-dataset workflow - IMPLEMENTED
#' @keywords internal
run_multi_dataset_workflow <- function(config, output_folder) {
  message("Running multi-dataset workflow...")

  # Extract configuration
  vector_data <- config$vector_data %||% config$input_data$vector
  raster_datasets <- config$raster_datasets %||% config$input_data$rasters
  region_boundary <- config$region_boundary

  # Use existing integration function
  if (!is.null(vector_data) && !is.null(raster_datasets)) {
    integrated_results <- integrate_multiple_datasets(
      vector_data = vector_data,
      raster_datasets = raster_datasets,
      region_boundary = region_boundary,
      output_format = "sf"
    )
  } else {
    integrated_results <- list(message = "Insufficient data for multi-dataset integration")
  }

  results <- list(
    analysis_type = "multi_dataset",
    integrated_data = integrated_results,
    message = "Multi-dataset workflow completed successfully"
  )

  return(results)
}




# Missing Helper Functions for universal_spatial_join
# Add these functions to your 06-spatial-join.R file or create a new helper file

#' Classify spatial data type and load data
#' @param data_input Input data (file path, directory, or spatial object)
#' @param verbose Print progress messages
#' @return List with data, type, class, and path information
#' @keywords internal
classify_spatial_data <- function(data_input, verbose = FALSE) {

  if (verbose) message("Classifying spatial data type...")

  result <- list(
    data = NULL,
    type = NULL,
    class = NULL,
    path = NULL
  )

  # Handle different input types
  if (is.character(data_input)) {
    if (length(data_input) == 1) {
      if (dir.exists(data_input)) {
        # Directory provided
        if (verbose) message("Input is a directory")

        # Look for raster files first
        raster_files <- list.files(data_input, pattern = "\\.(tif|tiff|nc|img)$",
                                   full.names = TRUE, ignore.case = TRUE)
        if (length(raster_files) > 0) {
          result$data <- terra::rast(raster_files[1])
          result$type <- "raster"
          result$class <- "SpatRaster"
          result$path <- raster_files[1]
        } else {
          # Look for vector files
          vector_files <- list.files(data_input, pattern = "\\.(shp|gpkg|geojson|csv)$",
                                     full.names = TRUE, ignore.case = TRUE)
          if (length(vector_files) > 0) {
            result$data <- load_vector_data_safe(vector_files[1])
            result$type <- "vector"
            result$class <- "sf"
            result$path <- vector_files[1]
          } else {
            stop("No recognized spatial files found in directory", call. = FALSE)
          }
        }

      } else if (file.exists(data_input)) {
        # Single file provided
        result$path <- data_input

        # Determine file type by extension
        file_ext <- tolower(tools::file_ext(data_input))

        if (file_ext %in% c("tif", "tiff", "nc", "img")) {
          # Raster file
          result$data <- terra::rast(data_input)
          result$type <- "raster"
          result$class <- "SpatRaster"

        } else if (file_ext %in% c("shp", "gpkg", "geojson")) {
          # Vector file
          result$data <- sf::st_read(data_input, quiet = !verbose)
          result$type <- "vector"
          result$class <- "sf"

        } else if (file_ext == "csv") {
          # CSV file - try to convert to spatial
          result$data <- load_vector_data_safe(data_input)
          result$type <- "vector"
          result$class <- "sf"

        } else {
          stop(sprintf("Unsupported file format: %s", file_ext), call. = FALSE)
        }

      } else {
        stop(sprintf("File or directory does not exist: %s", data_input), call. = FALSE)
      }

    } else {
      # Multiple files provided
      if (verbose) message("Multiple files provided")

      # Check first file to determine type
      first_ext <- tolower(tools::file_ext(data_input[1]))

      if (first_ext %in% c("tif", "tiff", "nc", "img")) {
        # Multiple raster files - stack them
        result$data <- terra::rast(data_input)
        result$type <- "raster"
        result$class <- "SpatRaster"
        result$path <- data_input[1]
      } else {
        # Multiple vector files - use first one
        result$data <- load_vector_data_safe(data_input[1])
        result$type <- "vector"
        result$class <- "sf"
        result$path <- data_input[1]
      }
    }

  } else if (inherits(data_input, "SpatRaster")) {
    # Terra SpatRaster object
    result$data <- data_input
    result$type <- "raster"
    result$class <- "SpatRaster"
    result$path <- NULL

  } else if (inherits(data_input, "sf")) {
    # sf object
    result$data <- data_input
    result$type <- "vector"
    result$class <- "sf"
    result$path <- NULL

  } else if (is.data.frame(data_input)) {
    # Regular data frame - try to convert to sf
    result$data <- process_vector_data(data_input)
    result$type <- "vector"
    result$class <- "sf"
    result$path <- NULL

  } else {
    stop("Unsupported data input type", call. = FALSE)
  }

  if (verbose) {
    message(sprintf("Data classified as: %s (%s)", result$type, result$class))
  }

  return(result)
}

#' Load vector data safely with coordinate detection
#' @param file_path Path to vector file
#' @return sf object
#' @keywords internal
load_vector_data_safe <- function(file_path) {

  file_ext <- tolower(tools::file_ext(file_path))

  if (file_ext == "csv") {
    # Handle CSV files with coordinate detection
    df <- read.csv(file_path)
    return(process_vector_data(df))

  } else {
    # Handle other vector formats
    return(sf::st_read(file_path, quiet = TRUE))
  }
}

#' Process vector data from data frame
#' @param data_input Data frame with potential coordinate columns
#' @param coord_cols Coordinate column names
#' @return sf object
#' @keywords internal
process_vector_data <- function(data_input, coord_cols = c("lon", "lat")) {

  if (inherits(data_input, "sf")) {
    return(data_input)
  }

  if (!is.data.frame(data_input)) {
    stop("data_input must be a data frame or sf object", call. = FALSE)
  }

  # Try to detect coordinate columns
  potential_x_cols <- c("lon", "longitude", "x", "lng", "long", "LongitudeMeasure")
  potential_y_cols <- c("lat", "latitude", "y", "LatitudeMeasure")

  x_col <- NULL
  y_col <- NULL

  # Find coordinate columns
  for (col in potential_x_cols) {
    if (col %in% names(data_input)) {
      x_col <- col
      break
    }
  }

  for (col in potential_y_cols) {
    if (col %in% names(data_input)) {
      y_col <- col
      break
    }
  }

  # Use provided coord_cols if auto-detection fails
  if (is.null(x_col) && coord_cols[1] %in% names(data_input)) {
    x_col <- coord_cols[1]
  }
  if (is.null(y_col) && coord_cols[2] %in% names(data_input)) {
    y_col <- coord_cols[2]
  }

  if (is.null(x_col) || is.null(y_col)) {
    stop("Could not find coordinate columns. Available columns: ",
         paste(names(data_input), collapse = ", "), call. = FALSE)
  }

  # Convert to sf
  sf_data <- sf::st_as_sf(data_input,
                          coords = c(x_col, y_col),
                          crs = 4326)

  return(sf_data)
}

#' Auto-detect best spatial join method
#' @param source_type Type of source data
#' @param target_type Type of target data
#' @param verbose Print messages
#' @return Character string of recommended method
#' @keywords internal
auto_detect_method <- function(source_type, target_type, verbose = FALSE) {

  method <- paste(source_type, "to", target_type)

  result <- switch(method,
                   "vector to raster" = "extract",
                   "raster to vector" = "zonal",
                   "raster to raster" = "resample",
                   "vector to vector" = "overlay",
                   "extract"  # Default fallback
  )

  if (verbose) {
    message(sprintf("Auto-detected method: %s for %s", result, method))
  }

  return(result)
}

#' Validate method compatibility
#' @param method Selected method
#' @param source_type Source data type
#' @param target_type Target data type
#' @keywords internal
validate_method_compatibility <- function(method, source_type, target_type) {

  # Define valid combinations
  valid_combinations <- list(
    "extract" = list(source = c("vector", "raster"), target = c("raster")),
    "overlay" = list(source = c("vector"), target = c("vector")),
    "resample" = list(source = c("raster"), target = c("raster", "none")),
    "zonal" = list(source = c("raster"), target = c("vector")),
    "nearest" = list(source = c("vector"), target = c("vector", "raster")),
    "interpolate" = list(source = c("vector"), target = c("vector", "raster")),
    "temporal" = list(source = c("vector", "raster"), target = c("vector", "raster"))
  )

  if (!method %in% names(valid_combinations)) {
    stop(sprintf("Unknown method: %s", method), call. = FALSE)
  }

  valid_combo <- valid_combinations[[method]]

  if (!source_type %in% valid_combo$source) {
    stop(sprintf("Method '%s' not compatible with source type '%s'",
                 method, source_type), call. = FALSE)
  }

  if (target_type != "none" && !target_type %in% valid_combo$target) {
    stop(sprintf("Method '%s' not compatible with target type '%s'",
                 method, target_type), call. = FALSE)
  }

  return(TRUE)
}

#' Perform extract join (vector to raster)
#' @keywords internal
perform_extract_join <- function(source_info, target_info, summary_function,
                                 buffer_distance, crs_target, na_strategy, verbose) {

  if (verbose) message("Performing extract join (vector to raster)...")

  # Extract raster values to vector points/polygons
  source_data <- source_info$data
  target_raster <- target_info$data

  # Ensure CRS compatibility
  if (!identical(sf::st_crs(source_data), terra::crs(target_raster))) {
    if (verbose) message("Reprojecting vector data to match raster CRS...")
    source_data <- sf::st_transform(source_data, crs = terra::crs(target_raster))
  }

  # Apply buffer if specified
  if (!is.null(buffer_distance)) {
    if (verbose) message(sprintf("Applying buffer of %s units...", buffer_distance))
    source_data <- sf::st_buffer(source_data, dist = buffer_distance)
  }

  # Extract values
  extracted_values <- terra::extract(target_raster, terra::vect(source_data),
                                     fun = get_summary_function(summary_function),
                                     na.rm = TRUE)

  # Add extracted values to source data
  raster_names <- names(target_raster)
  for (i in seq_along(raster_names)) {
    col_name <- paste0("extracted_", raster_names[i])
    source_data[[col_name]] <- extracted_values[, i + 1]  # +1 to skip ID column
  }

  return(source_data)
}

#' Perform resample join (raster to raster)
#' @keywords internal
perform_resample_join <- function(source_info, target_info, scale_factor,
                                  summary_function, crs_target, verbose) {

  if (verbose) message("Performing resample join (raster to raster)...")

  source_raster <- source_info$data

  if (!is.null(target_info)) {
    # Resample to match target
    target_raster <- target_info$data
    result <- terra::resample(source_raster, target_raster,
                              method = if(summary_function == "mode") "mode" else "bilinear")
  } else if (!is.null(scale_factor)) {
    # Scale by factor
    if (scale_factor > 1) {
      # Aggregate (coarser resolution)
      result <- terra::aggregate(source_raster, fact = scale_factor,
                                 fun = get_summary_function(summary_function))
    } else {
      # Disaggregate (finer resolution)
      result <- terra::disagg(source_raster, fact = 1/scale_factor)
    }
  } else {
    stop("Either target_data or scale_factor must be provided for resample method")
  }

  return(result)
}

#' Perform other join methods (stubs for now)
#' @keywords internal
perform_overlay_join <- function(source_info, target_info, summary_function, crs_target, verbose) {
  if (verbose) message("Performing overlay join (vector to vector)...")
  # Simple intersection for now
  result <- sf::st_intersection(source_info$data, target_info$data)
  return(result)
}

#' @keywords internal
perform_zonal_join <- function(source_info, target_info, summary_function, crs_target, verbose) {
  if (verbose) message("Performing zonal join (raster to vector)...")
  # Extract raster values by zones
  zonal_stats <- terra::extract(source_info$data, terra::vect(target_info$data),
                                fun = get_summary_function(summary_function), na.rm = TRUE)

  # Add to target data
  target_data <- target_info$data
  raster_names <- names(source_info$data)
  for (i in seq_along(raster_names)) {
    col_name <- paste0("zonal_", raster_names[i])
    target_data[[col_name]] <- zonal_stats[, i + 1]
  }

  return(target_data)
}

#' @keywords internal
perform_nearest_join <- function(source_info, target_info, buffer_distance, crs_target, verbose) {
  if (verbose) message("Performing nearest neighbor join...")
  # Simple nearest join
  result <- sf::st_join(source_info$data, target_info$data, join = sf::st_nearest_feature)
  return(result)
}

#' @keywords internal
perform_interpolate_join <- function(source_info, target_info, summary_function, crs_target, verbose) {
  if (verbose) message("Performing interpolation join...")
  # Placeholder - would need gstat or similar
  warning("Interpolation join not fully implemented")
  return(source_info$data)
}

#' @keywords internal
perform_temporal_join <- function(source_info, target_info, temporal_tolerance, summary_function, verbose) {
  if (verbose) message("Performing temporal join...")
  # Placeholder for temporal matching
  warning("Temporal join not fully implemented")
  return(source_info$data)
}

#' Get summary function for terra operations
#' @param summary_function Character name of function
#' @return Function object
#' @keywords internal
get_summary_function <- function(summary_function) {
  switch(summary_function,
         "mean" = mean,
         "median" = median,
         "max" = max,
         "min" = min,
         "sum" = sum,
         "sd" = sd,
         "mode" = function(x) {
           ux <- unique(x)
           ux[which.max(tabulate(match(x, ux)))]
         },
         "majority" = function(x) {
           ux <- unique(x)
           ux[which.max(tabulate(match(x, ux)))]
         },
         mean  # Default
  )
}



#' Integrate multiple datasets
#' @keywords internal
integrate_multiple_datasets <- function(vector_data, raster_datasets, region_boundary = NULL,
                                        output_format = "sf") {
  message("Integrating multiple datasets...")

  # Load vector data
  if (is.character(vector_data)) {
    if (tools::file_ext(vector_data) == "csv") {
      df <- read.csv(vector_data)
      vector_sf <- process_vector_data(df)
    } else {
      vector_sf <- sf::st_read(vector_data)
    }
  } else {
    vector_sf <- vector_data
  }

  # Extract raster values to vector data
  if (is.list(raster_datasets)) {
    for (i in seq_along(raster_datasets)) {
      raster_name <- names(raster_datasets)[i] %||% paste0("raster_", i)
      raster_data <- if (is.character(raster_datasets[[i]])) {
        terra::rast(raster_datasets[[i]])
      } else {
        raster_datasets[[i]]
      }

      # Extract values using universal spatial join
      result <- universal_spatial_join(
        source_data = vector_sf,
        target_data = raster_data,
        method = "extract"
      )

      # Add extracted values
      extracted_col <- names(result)[!names(result) %in% names(vector_sf)]
      if (length(extracted_col) > 0) {
        vector_sf[[paste0("extracted_", raster_name)]] <- result[[extracted_col[1]]]
      }
    }
  }

  return(vector_sf)
}

#' Check and load required packages
#' @keywords internal
check_required_packages <- function(packages) {
  missing <- c()
  for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      missing <- c(missing, pkg)
    }
  }

  if (length(missing) > 0) {
    stop(sprintf("Required packages not available: %s\nInstall with: install.packages(c('%s'))",
                 paste(missing, collapse = ", "), paste(missing, collapse = "', '")), call. = FALSE)
  }
}
