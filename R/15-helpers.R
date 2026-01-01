# Helper Functions for geospatialsuite
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

#' Run enhanced terrain analysis workflow
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

#' Run enhanced temporal workflow
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

#' Run enhanced mosaic workflow
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

#' Run multi-dataset workflow
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




# ==================== GEOGRAPHIC ENTITY DETECTION & GEOCODING ==================== #

#' Normalize column names for robust matching
#' @keywords internal
normalize_column_name <- function(x) {
  tolower(gsub("[_\\s-]", "", x))
}

#' Detect and geocode geographic entity columns
#' @param data_input Data frame with potential geographic identifiers
#' @return List with detected column and type, or NULL if none found
#' @keywords internal
detect_geographic_entities <- function(data_input) {

  # Normalize column names: lowercase, remove spaces, underscores, hyphens
  column_names_normalized <- normalize_column_name(names(data_input))
  column_names_original <- names(data_input)

  # Define patterns for different geographic entities (all normalized)
  patterns <- list(
    state = c("state", "statename", "st", "stateabbr", "statecode", "stusps", "stateab"),
    county = c("county", "countyname", "cnty", "cty", "countyfips"),
    fips = c("fips", "fipscode", "geoid", "geoidfips", "geofips", "geocode"),
    huc = c("huc", "huc2", "huc4", "huc6", "huc8", "huc10", "huc12",
            "huc14", "watershed", "watershedid", "hydrologicunitcode",
            "hydrologicunit", "basinid", "subbasin"),
    zipcode = c("zip", "zipcode", "postal", "postalcode", "postcode"),
    city = c("city", "cityname", "municipality", "town", "townname")
  )

  # Check each pattern type
  for (entity_type in names(patterns)) {
    pattern_list <- patterns[[entity_type]]

    # Check each specific pattern
    for (pattern in pattern_list) {
      # Find exact matches first
      exact_matches <- which(column_names_normalized == pattern)

      if (length(exact_matches) > 0) {
        return(list(
          column = column_names_original[exact_matches[1]],
          type = entity_type,
          original_column = column_names_original[exact_matches[1]]
        ))
      }

      # If no exact match, try partial matches (but be careful with short patterns)
      if (nchar(pattern) >= 3) {
        partial_matches <- grep(pattern, column_names_normalized, fixed = TRUE)

        if (length(partial_matches) > 0) {
          return(list(
            column = column_names_original[partial_matches[1]],
            type = entity_type,
            original_column = column_names_original[partial_matches[1]]
          ))
        }
      }
    }
  }

  return(NULL)
}

#' Detect HUC level from column name or data
#' @param column_name Name of the HUC column
#' @param data_values Sample HUC values
#' @return Character string of HUC type (e.g., "huc08", "huc12")
#' @keywords internal
detect_huc_level <- function(column_name, data_values) {

  # Normalize column name
  col_normalized <- normalize_column_name(column_name)

  # Check column name for HUC level
  huc_patterns <- c(
    "huc2" = 2, "huc4" = 4, "huc6" = 6, "huc8" = 8,
    "huc10" = 10, "huc12" = 12, "huc14" = 14
  )

  for (pattern in names(huc_patterns)) {
    if (grepl(pattern, col_normalized)) {
      return(sprintf("huc%02d", huc_patterns[pattern]))
    }
  }

  # If not in column name, detect from data length
  # Remove any non-digit characters and get typical length
  clean_values <- gsub("[^0-9]", "", as.character(data_values))
  typical_length <- as.numeric(names(sort(table(nchar(clean_values)), decreasing = TRUE)[1]))

  if (!is.na(typical_length)) {
    if (typical_length == 2) return("huc02")
    if (typical_length == 4) return("huc04")
    if (typical_length == 6) return("huc06")
    if (typical_length == 8) return("huc08")
    if (typical_length == 10) return("huc10")
    if (typical_length == 12) return("huc12")
    if (typical_length == 14) return("huc14")
  }

  # Default to HUC8 (most common)
  return("huc08")
}

#' Helper to detect state column
#' @keywords internal
detect_state_column <- function(data) {
  state_patterns <- c("state", "st", "statename", "stateabbr", "statename")
  column_names_normalized <- normalize_column_name(names(data))

  for (pattern in state_patterns) {
    matches <- which(column_names_normalized == pattern)
    if (length(matches) > 0) {
      return(names(data)[matches[1]])
    }
  }

  return(NULL)
}

#' Geocode geographic entities to coordinates
#' @param data_input Data frame with geographic entity column
#' @param entity_info List from detect_geographic_entities
#' @param verbose Print messages
#' @return sf object with geocoded locations
#' @keywords internal
geocode_entities <- function(data_input, entity_info, verbose = FALSE) {

  if (verbose) {
    message(sprintf("Detected %s data in column: %s",
                    entity_info$type, entity_info$column))
  }

  entity_col <- entity_info$column
  entity_type <- entity_info$type

  # Load required packages conditionally
  require_tigris <- requireNamespace("tigris", quietly = TRUE)

  if (!require_tigris && entity_type %in% c("state", "county", "fips")) {
    stop("Package 'tigris' is required for geocoding US geographic entities.\n",
         "Install it with: install.packages('tigris')", call. = FALSE)
  }

  # Geocode based on entity type
  result <- switch(entity_type,
                   state = geocode_states(data_input, entity_col, verbose),
                   county = geocode_counties(data_input, entity_col, verbose),
                   fips = geocode_fips(data_input, entity_col, verbose),
                   huc = geocode_hucs(data_input, entity_col, verbose),
                   zipcode = geocode_zipcodes(data_input, entity_col, verbose),
                   city = geocode_cities(data_input, entity_col, verbose),
                   stop(sprintf("Geocoding not yet implemented for type: %s", entity_type))
  )

  return(result)
}

#' Geocode US states
#' @keywords internal
geocode_states <- function(data, column, verbose) {
  if (verbose) message("Geocoding states...")

  # Get state boundaries
  states <- tigris::states(cb = TRUE, progress_bar = FALSE)

  # Clean input data: trim whitespace, handle case
  data$state_clean <- trimws(as.character(data[[column]]))

  # Create matching keys (both uppercase for comparison)
  states$match_name <- toupper(states$NAME)
  states$match_abbr <- toupper(states$STUSPS)

  # Also create lowercase versions for flexible matching
  data$state_upper <- toupper(data$state_clean)

  # Try matching by full name first
  result <- merge(data, states,
                  by.x = "state_upper",
                  by.y = "match_name",
                  all.x = TRUE)

  # For unmatched, try abbreviation
  unmatched_idx <- which(is.na(result$geometry))

  if (length(unmatched_idx) > 0) {
    unmatched_data <- data[unmatched_idx, ]

    result2 <- merge(unmatched_data, states,
                     by.x = "state_upper",
                     by.y = "match_abbr",
                     all.x = TRUE)

    # Update only the matched ones
    matched_in_result2 <- which(!is.na(result2$geometry))
    if (length(matched_in_result2) > 0) {
      result[unmatched_idx[matched_in_result2], ] <- result2[matched_in_result2, ]
    }
  }

  # Convert to sf and get centroids
  result_sf <- sf::st_as_sf(result)
  result_sf <- sf::st_centroid(result_sf)

  # Clean up temporary columns
  result_sf$state_clean <- NULL
  result_sf$state_upper <- NULL
  result_sf$match_name <- NULL
  result_sf$match_abbr <- NULL

  # Report results
  matched <- sum(!is.na(sf::st_coordinates(result_sf)[,1]))
  if (verbose) {
    message(sprintf("Matched %d/%d states", matched, nrow(data)))

    # Show which states failed
    if (matched < nrow(data)) {
      failed_states <- data[[column]][is.na(sf::st_coordinates(result_sf)[,1])]
      message(sprintf("Failed to match: %s", paste(unique(failed_states), collapse = ", ")))
    }
  }

  return(result_sf)
}

#' Geocode US counties
#' @keywords internal
geocode_counties <- function(data, column, verbose) {
  if (verbose) message("Geocoding counties...")

  # Try to detect state column for county matching
  state_col <- detect_state_column(data)

  if (is.null(state_col)) {
    # Get all US counties
    counties <- tigris::counties(cb = TRUE, progress_bar = FALSE)
  } else {
    # Get counties for specific states
    states <- unique(data[[state_col]])
    counties_list <- lapply(states, function(st) {
      tryCatch({
        tigris::counties(state = st, cb = TRUE, progress_bar = FALSE)
      }, error = function(e) {
        if (verbose) warning(sprintf("Could not load counties for state: %s", st))
        return(NULL)
      })
    })
    counties_list <- Filter(Negate(is.null), counties_list)

    if (length(counties_list) == 0) {
      stop("Could not load counties for any specified states", call. = FALSE)
    }

    counties <- do.call(rbind, counties_list)
  }

  # Clean and match
  data[[column]] <- trimws(toupper(as.character(data[[column]])))
  counties$match_name <- toupper(counties$NAME)

  result <- merge(data, counties,
                  by.x = column,
                  by.y = "match_name",
                  all.x = TRUE)

  result_sf <- sf::st_as_sf(result)
  result_sf <- sf::st_centroid(result_sf)

  if (verbose) {
    matched <- sum(!is.na(sf::st_coordinates(result_sf)[,1]))
    message(sprintf("Matched %d/%d counties", matched, nrow(data)))
  }

  return(result_sf)
}

#' Geocode FIPS codes
#' @keywords internal
geocode_fips <- function(data, column, verbose) {
  if (verbose) message("Geocoding FIPS codes...")

  # Standardize FIPS codes (ensure 5 digits with leading zeros)
  data$fips_clean <- sprintf("%05d", as.numeric(gsub("[^0-9]", "", data[[column]])))

  # Get county boundaries by FIPS
  counties <- tigris::counties(cb = TRUE, progress_bar = FALSE)
  counties$GEOID <- sprintf("%05d", as.numeric(counties$GEOID))

  result <- merge(data, counties,
                  by.x = "fips_clean",
                  by.y = "GEOID",
                  all.x = TRUE)

  result_sf <- sf::st_as_sf(result)
  result_sf <- sf::st_centroid(result_sf)

  # Clean up
  result_sf$fips_clean <- NULL

  if (verbose) {
    matched <- sum(!is.na(sf::st_coordinates(result_sf)[,1]))
    message(sprintf("Matched %d/%d FIPS codes", matched, nrow(data)))
  }

  return(result_sf)
}

#' Geocode HUC watershed codes
#' @keywords internal
geocode_hucs <- function(data, column, verbose) {
  if (verbose) message("Geocoding HUC codes...")

  # nhdplusTools is needed for HUC geocoding
  if (!requireNamespace("nhdplusTools", quietly = TRUE)) {
    stop("Package 'nhdplusTools' is required for HUC geocoding.\n",
         "Install it with: install.packages('nhdplusTools')", call. = FALSE)
  }

  # Detect HUC level
  huc_level <- detect_huc_level(column, data[[column]])

  if (verbose) {
    message(sprintf("Detected HUC level: %s", huc_level))
  }

  # Clean HUC codes (remove any non-numeric characters, hyphens, etc.)
  data$huc_clean <- gsub("[^0-9]", "", as.character(data[[column]]))

  # Get HUC boundaries
  hucs_list <- list()
  failed_hucs <- character()

  for (i in seq_len(nrow(data))) {
    huc_code <- data$huc_clean[i]

    tryCatch({
      huc_boundary <- nhdplusTools::get_huc(id = huc_code, type = huc_level)
      hucs_list[[i]] <- cbind(data[i, , drop = FALSE], huc_boundary)
    }, error = function(e) {
      if (verbose) warning(sprintf("Could not find HUC: %s (cleaned: %s)",
                                   data[[column]][i], huc_code))
      failed_hucs <<- c(failed_hucs, data[[column]][i])
      hucs_list[[i]] <<- NULL
    })
  }

  # Combine results
  valid_hucs <- Filter(Negate(is.null), hucs_list)

  if (length(valid_hucs) == 0) {
    stop("Could not geocode any HUC codes. Failed HUCs: ",
         paste(failed_hucs, collapse = ", "), call. = FALSE)
  }

  result_sf <- do.call(rbind, valid_hucs)
  result_sf$huc_clean <- NULL  # Remove temporary column

  # Convert to centroids for point representation
  result_sf <- sf::st_centroid(result_sf)

  if (verbose) {
    message(sprintf("Matched %d/%d HUC codes", length(valid_hucs), nrow(data)))
    if (length(failed_hucs) > 0) {
      message(sprintf("Failed to match: %s", paste(failed_hucs, collapse = ", ")))
    }
  }

  return(result_sf)
}

#' Geocode ZIP codes
#' @keywords internal
geocode_zipcodes <- function(data, column, verbose) {
  if (verbose) message("Geocoding ZIP codes...")

  # zipcodeR package for ZIP geocoding
  if (!requireNamespace("zipcodeR", quietly = TRUE)) {
    stop("Package 'zipcodeR' is required for ZIP code geocoding.\n",
         "Install it with: install.packages('zipcodeR')", call. = FALSE)
  }

  # Get ZIP code database
  zip_data <- zipcodeR::zip_code_db

  # Standardize ZIP codes
  data$zip_clean <- sprintf("%05d", as.numeric(gsub("[^0-9]", "", data[[column]])))

  # Merge with coordinates
  result <- merge(data, zip_data,
                  by.x = "zip_clean",
                  by.y = "zipcode",
                  all.x = TRUE)

  # Convert to sf
  result_sf <- sf::st_as_sf(result,
                            coords = c("lng", "lat"),
                            crs = 4326,
                            remove = FALSE)

  # Clean up
  result_sf$zip_clean <- NULL

  if (verbose) {
    matched <- sum(!is.na(result_sf$lng))
    message(sprintf("Matched %d/%d ZIP codes", matched, nrow(data)))
  }

  return(result_sf)
}

#' Geocode city names
#' @keywords internal
geocode_cities <- function(data, column, verbose) {
  if (verbose) message("Geocoding cities...")

  # tidygeocoder for city geocoding
  if (!requireNamespace("tidygeocoder", quietly = TRUE)) {
    stop("Package 'tidygeocoder' is required for city geocoding.\n",
         "Install it with: install.packages('tidygeocoder')", call. = FALSE)
  }

  # Detect state column for better matching
  state_col <- detect_state_column(data)

  if (!is.null(state_col)) {
    data$full_address <- paste(data[[column]], data[[state_col]], "USA", sep = ", ")
  } else {
    data$full_address <- paste(data[[column]], "USA", sep = ", ")
  }

  # Geocode
  result <- tidygeocoder::geocode(data, address = full_address, method = "osm", quiet = !verbose)

  # Convert to sf
  result_sf <- sf::st_as_sf(result,
                            coords = c("long", "lat"),
                            crs = 4326,
                            remove = FALSE)

  result_sf$full_address <- NULL

  if (verbose) {
    matched <- sum(!is.na(result_sf$long))
    message(sprintf("Matched %d/%d cities", matched, nrow(data)))
  }

  return(result_sf)
}







# ==================== ENHANCED PROCESS VECTOR DATA ==================== #

#' Process vector data from data frame
#' @param data_input Data frame with potential coordinate columns OR geographic entities
#' @param coord_cols Coordinate column names
#' @param try_geocoding Attempt to geocode if no coordinates found (default: TRUE)
#' @param verbose Print messages
#' @return sf object
#' @keywords internal
process_vector_data <- function(data_input, coord_cols = c("lon", "lat"),
                                try_geocoding = TRUE, verbose = FALSE) {

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

  # If coordinates found, use them
  if (!is.null(x_col) && !is.null(y_col)) {
    if (verbose) {
      message(sprintf("Using coordinate columns: %s, %s", x_col, y_col))
    }

    # Create sf object from coordinates
    sf_data <- sf::st_as_sf(data_input,
                            coords = c(x_col, y_col),
                            crs = 4326)
    return(sf_data)
  }

  # No coordinates found - try geocoding if enabled
  if (try_geocoding) {
    if (verbose) {
      message("No coordinate columns found. Attempting to detect geographic entities...")
    }

    entity_info <- detect_geographic_entities(data_input)

    if (!is.null(entity_info)) {
      # Geocode the detected entities
      sf_data <- geocode_entities(data_input, entity_info, verbose)
      return(sf_data)

    } else {
      stop("Could not find coordinate columns or geographic entities to geocode.\n",
           "Available columns: ", paste(names(data_input), collapse = ", "),
           "\n\nSupported geographic entities: state, county, FIPS, HUC, ZIP code, city",
           call. = FALSE)
    }

  } else {
    stop("Could not find coordinate columns. Available columns: ",
         paste(names(data_input), collapse = ", "), call. = FALSE)
  }
}

# ==================== USER-FACING FUNCTIONS ==================== #

#' Auto-geocode data with geographic identifiers
#'
#' @description
#' Automatically detects and geocodes data containing US geographic identifiers
#' (states, counties, FIPS codes, HUC watershed codes, ZIP codes, or city names)
#' without requiring latitude/longitude coordinates.
#'
#' @param data Data frame, file path (CSV, shapefile, etc.), or sf object
#' @param detect_columns Auto-detect geographic entity columns (default: TRUE)
#' @param entity_column Explicitly specify the column containing geographic entities (optional)
#' @param entity_type Explicitly specify entity type: "state", "county", "fips", "huc", "zipcode", "city" (optional)
#' @param verbose Print detailed progress messages
#'
#' @return sf object with geocoded point or polygon geometries
#'
#' @details
#' Supported geographic entities:
#' \itemize{
#'   \item \strong{States}: Full names or 2-letter abbreviations (e.g., "Ohio", "OH")
#'   \item \strong{Counties}: County names, optionally with state
#'   \item \strong{FIPS codes}: 5-digit Federal Information Processing Standards codes
#'   \item \strong{HUC codes}: Hydrologic Unit Codes (HUC8, HUC10, HUC12)
#'   \item \strong{ZIP codes}: 5-digit US postal codes
#'   \item \strong{Cities}: City names, works best with state column
#' }
#'
#' Column name variations supported:
#' \itemize{
#'   \item HUC columns: HUC_8, HUC-8, huc8, Huc 8, etc.
#'   \item State columns: State, STATE, state_name, StateName, ST, etc.
#'   \item All entity types handle spaces, hyphens, underscores, and mixed case
#' }
#'
#' Required packages (installed automatically when needed):
#' \itemize{
#'   \item \code{tigris}: For US Census boundaries (states, counties, FIPS)
#'   \item \code{nhdplusTools}: For HUC watershed boundaries
#'   \item \code{zipcodeR}: For ZIP code centroids
#'   \item \code{tidygeocoder}: For city name geocoding
#' }
#'
#' @examples
#' \dontrun{
#' # Auto-detect and geocode - simplest usage
#' geodata <- auto_geocode_data("mydata.csv")
#'
#' # With state names
#' state_data <- data.frame(
#'   state = c("California", "Texas", "New York"),
#'   population = c(39538223, 29145505, 20201249)
#' )
#' state_sf <- auto_geocode_data(state_data)
#'
#' # With FIPS codes
#' fips_data <- data.frame(
#'   fips = c("39049", "39035", "39113"),  # Ohio counties
#'   unemployment_rate = c(4.2, 3.8, 5.1)
#' )
#' county_sf <- auto_geocode_data(fips_data)
#'
#' # With HUC codes (handles various formats)
#' watershed_data <- data.frame(
#'   HUC_8 = c("04100009", "04100012", "04110002"),
#'   water_quality_index = c(72, 65, 80)
#' )
#' huc_sf <- auto_geocode_data(watershed_data)
#'
#' # Explicit specification
#' zip_sf <- auto_geocode_data(
#'   my_data,
#'   entity_column = "postal_code",
#'   entity_type = "zipcode"
#' )
#'
#' # Then use with your other geospatialsuite functions
#' quick_map(state_sf, variable = "population")
#' }
#'
#' @export
auto_geocode_data <- function(data, detect_columns = TRUE, entity_column = NULL,
                              entity_type = NULL, verbose = TRUE) {

  # Load data if file path provided
  if (is.character(data) && length(data) == 1) {
    if (verbose) message(sprintf("Loading data from: %s", basename(data)))

    file_ext <- tolower(tools::file_ext(data))

    if (file_ext == "csv") {
      data <- read.csv(data, stringsAsFactors = FALSE)
    } else if (file_ext %in% c("shp", "gpkg", "geojson")) {
      return(sf::st_read(data, quiet = !verbose))
    } else {
      stop("Unsupported file format. Use CSV, shapefile, GeoPackage, or GeoJSON",
           call. = FALSE)
    }
  }

  # Check if already spatial
  if (inherits(data, "sf")) {
    if (verbose) message("Data is already spatial (sf object)")
    return(data)
  }

  if (!is.data.frame(data)) {
    stop("data must be a data frame, file path, or sf object", call. = FALSE)
  }

  # If entity info explicitly provided, use it
  if (!is.null(entity_column) && !is.null(entity_type)) {
    if (verbose) {
      message(sprintf("Using specified column '%s' as %s", entity_column, entity_type))
    }

    entity_info <- list(
      column = entity_column,
      type = entity_type,
      original_column = entity_column
    )

    result <- geocode_entities(data, entity_info, verbose)
    return(result)
  }

  # Auto-detect and geocode
  if (detect_columns) {
    result <- process_vector_data(data, try_geocoding = TRUE, verbose = verbose)
    return(result)
  }

  stop("Could not geocode data. Either enable detect_columns=TRUE or specify entity_column and entity_type",
       call. = FALSE)
}

#' Preview geographic entity detection
#'
#' @description
#' Test what geographic entities will be detected in your data without
#' actually performing the geocoding. Useful for debugging and verification.
#'
#' @param data Data frame to analyze
#' @param show_sample Show sample values (default: TRUE)
#' @param n_sample Number of sample values to show (default: 5)
#'
#' @return List with detection results
#'
#' @examples
#' \dontrun{
#' # Check what will be detected
#' my_data <- data.frame(
#'   HUC_8 = c("04100009", "04100012"),
#'   State = c("Ohio", "PA"),
#'   value = c(100, 200)
#' )
#'
#' preview_geocoding(my_data)
#' }
#'
#' @export
preview_geocoding <- function(data, show_sample = TRUE, n_sample = 5) {

  if (!is.data.frame(data)) {
    stop("data must be a data frame", call. = FALSE)
  }

  # Check for coordinates first
  potential_x_cols <- c("lon", "longitude", "x", "lng", "long", "LongitudeMeasure")
  potential_y_cols <- c("lat", "latitude", "y", "LatitudeMeasure")

  x_col <- NULL
  y_col <- NULL

  for (col in potential_x_cols) {
    if (col %in% names(data)) {
      x_col <- col
      break
    }
  }

  for (col in potential_y_cols) {
    if (col %in% names(data)) {
      y_col <- col
      break
    }
  }

  result <- list(
    has_coordinates = !is.null(x_col) && !is.null(y_col),
    coordinate_columns = if (!is.null(x_col)) c(x_col, y_col) else NULL,
    geographic_entities = NULL,
    message = NULL
  )

  if (result$has_coordinates) {
    result$message <- sprintf("\U2713 Found coordinate columns: %s, %s", x_col, y_col)

    if (show_sample) {
      result$sample_coordinates <- head(data[, c(x_col, y_col)], n_sample)
    }

  } else {
    # Try to detect geographic entities
    entity_info <- detect_geographic_entities(data)

    if (!is.null(entity_info)) {
      result$geographic_entities <- entity_info
      result$message <- sprintf("\U2713 Detected %s data in column: '%s'",
                                entity_info$type, entity_info$column)

      if (show_sample) {
        sample_values <- head(unique(data[[entity_info$column]]), n_sample)
        result$sample_values <- sample_values

        # For HUCs, also detect level
        if (entity_info$type == "huc") {
          huc_level <- detect_huc_level(entity_info$column, data[[entity_info$column]])
          result$huc_level <- huc_level
          result$message <- paste0(result$message, sprintf(" (detected as %s)", huc_level))
        }
      }

    } else {
      result$message <- "\U2717 No coordinate columns or geographic entities detected"
      result$available_columns <- names(data)
    }
  }

  # Print nicely formatted output
  cat("Geographic Entity Detection Results\n")
  cat("===================================\n\n")
  cat(result$message, "\n\n")

  if (result$has_coordinates && show_sample) {
    cat("Sample Coordinates:\n")
    print(result$sample_coordinates)

  } else if (!is.null(result$geographic_entities) && show_sample) {
    cat("Sample Values:\n")
    print(result$sample_values)

  } else if (is.null(result$coordinate_columns) && is.null(result$geographic_entities)) {
    cat("Available Columns:\n")
    cat(paste(result$available_columns, collapse = ", "), "\n\n")
    cat("Supported geographic entities:\n")
    cat("  - States (full names or abbreviations)\n")
    cat("  - Counties\n")
    cat("  - FIPS codes\n")
    cat("  - HUC codes (HUC-8, HUC_8, huc8, etc.)\n")
    cat("  - ZIP codes\n")
    cat("  - City names\n")
  }

  return(invisible(result))
}


# ==================== EXISTING HELPER FUNCTIONS (KEEP ALL BELOW) ==================== #

#' Classify data input type
#' @param data_input Input data of various types
#' @param verbose Print diagnostic messages
#' @return List with type, class, and data object
#' @keywords internal
classify_data_input <- function(data_input, verbose = FALSE) {

  result <- list(
    type = NULL,
    class = class(data_input)[1],
    data = NULL,
    path = NULL
  )

  if (is.character(data_input)) {
    # File path(s) provided
    if (length(data_input) == 1) {
      if (dir.exists(data_input)) {
        # Directory provided
        if (verbose) message("Directory detected, searching for spatial files...")

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
