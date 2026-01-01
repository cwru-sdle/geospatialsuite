#' Get comprehensive CDL crop codes
#'
#' @description
#' Get USDA Cropland Data Layer (CDL) codes for specific crops or crop categories.
#' Supports all major crops and predefined categories.
#'
#' @param crop_type Crop type or category name. Options include:
#'   \itemize{
#'     \item Individual crops: "corn", "soybeans", "wheat", etc.
#'     \item Categories: "grains", "oilseeds", "fruits", "vegetables", etc.
#'     \item "all" for all available codes
#'   }
#'
#' @return Vector of CDL codes
#'
#' @examples
#' \donttest{
#' # Get corn code
#' corn_codes <- get_comprehensive_cdl_codes("corn")
#' print(corn_codes)  # Should be 1
#'
#' # Get all grain crop codes
#' grain_codes <- get_comprehensive_cdl_codes("grains")
#' print(grain_codes)  # Should be vector of grain codes
#'
#' # See available crop types (this will print to console)
#' get_comprehensive_cdl_codes("help")
#' }
#'
#' @export
get_comprehensive_cdl_codes <- function(crop_type = "all") {

  # Comprehensive CDL codes database
  cdl_database <- list(
    # Major Field Crops
    corn = 1, cotton = 2, rice = 3, sorghum = 4, soybeans = 5,
    sunflower = 6, peanuts = 7, tobacco = 8, sweet_corn = 12,
    pop_or_orn_corn = 13, mint = 14, barley = 21, durum_wheat = 22,
    spring_wheat = 23, winter_wheat = 24, other_small_grains = 25,
    dbl_crop_winwht_soybeans = 26, rye = 27, oats = 28, millet = 29,
    speltz = 30, canola = 31, flaxseed = 32, safflower = 33,
    rape_seed = 34, mustard = 35, alfalfa = 36, other_hay_non_alfalfa = 37,
    camelina = 38, buckwheat = 39, sugarbeets = 41, dry_beans = 42,
    potatoes = 43, other_crops = 44, sugarcane = 45, sweet_potatoes = 46,
    misc_vegs_fruits = 47, watermelons = 48, onions = 49, cucumbers = 50,
    chick_peas = 51, lentils = 52, peas = 53, tomatoes = 54,
    caneberries = 55, hops = 56, herbs = 57, clover_wildflowers = 58,
    sod_grass_seed = 59, switchgrass = 60, fallow_idle_cropland = 61,

    # Fruits and Nuts
    cherries = 66, peaches = 67, apples = 68, grapes = 69,
    christmas_trees = 70, other_tree_crops = 71, citrus = 72,
    pecans = 73, almonds = 74, walnuts = 75, pears = 76,

    # Vegetables (200+ series)
    carrots = 206, asparagus = 207, garlic = 208, cantaloupes = 209,
    prunes = 210, olives = 211, oranges = 212, honeydew_melons = 213,
    broccoli = 214, avocados = 215, peppers = 216, pomegranates = 217,
    nectarines = 218, greens = 219, plums = 220, strawberries = 221,
    squash = 222, apricots = 223, vetch = 224, dbl_crop_oats_corn = 225,
    lettuce = 227,

    # Pasture and Grassland
    pasture_grass = 176, grassland_pasture = 181,

    # Forest
    deciduous_forest = 141, evergreen_forest = 142, mixed_forest = 143,

    # Water and Wetlands
    water = 111, perennial_ice_snow = 112, herbaceous_wetlands = 195,
    woody_wetlands = 190,

    # Developed Areas
    developed_open_space = 121, developed_low_intensity = 122,
    developed_med_intensity = 123, developed_high_intensity = 124,

    # Other Land Cover
    barren = 131, shrubland = 152, grassland_herbaceous = 171
  )

  # Predefined categories
  crop_categories <- list(
    grains = c(1, 4, 21, 22, 23, 24, 25, 27, 28, 29, 30),
    oilseeds = c(5, 6, 31, 32, 33, 34, 35),
    fruits = c(66, 67, 68, 69, 72, 73, 74, 75, 76, 210, 211, 212, 215, 217, 218, 220, 221, 223),
    vegetables = c(47, 48, 49, 50, 54, 206, 207, 208, 209, 213, 214, 216, 219, 222, 227),
    legumes = c(42, 51, 52, 53),
    forage = c(36, 37, 58, 176, 181),
    specialty = c(8, 14, 45, 56, 57, 70),
    food_crops = c(1, 3, 5, 21, 22, 23, 24, 41, 42, 43, 44, 45, 46, 47, 66, 67, 68, 69),
    feed_crops = c(36, 37, 58, 176),
    industrial_crops = c(2, 8, 31, 32, 33, 38),
    all_crops = c(1:8, 12:14, 21:61, 66:76, 204:227)
  )

  if (crop_type == "all") {
    return(sort(unique(unlist(cdl_database))))
  } else if (crop_type == "help") {
    cat("Available crop types and categories:\n")
    cat("\nIndividual crops:\n")
    print(names(cdl_database))
    cat("\nCrop categories:\n")
    print(names(crop_categories))
    return(invisible(NULL))
  } else if (crop_type %in% names(crop_categories)) {
    return(crop_categories[[crop_type]])
  } else if (crop_type %in% names(cdl_database)) {
    return(cdl_database[[crop_type]])
  } else {
    # Try partial matching
    matches <- names(cdl_database)[grepl(crop_type, names(cdl_database), ignore.case = TRUE)]
    if (length(matches) > 0) {
      return(cdl_database[[matches[1]]])
    } else {
      message("Available crop types:")
      message("Individual crops: ", paste(names(cdl_database), collapse = ", "))
      message("Categories: ", paste(names(crop_categories), collapse = ", "))
      stop(paste("Crop type not found:", crop_type))
    }
  }
}

#' Create crop mask from CDL data
#'
#' @description
#' Create binary or classified crop mask from USDA CDL data for specified crops.
#' Fixed to handle terra operations properly.
#'
#' @param cdl_data CDL raster data (file path or SpatRaster)
#' @param crop_codes Vector of CDL codes or crop names
#' @param region_boundary Optional region boundary for clipping
#' @param mask_type Type of mask: "binary" (1/0) or "preserve" (keep original codes)
#'
#' @return SpatRaster with crop mask
#'
#' @examples
#' \dontrun{
#' # These examples require actual CDL data files
#' # Create corn mask
#' corn_mask <- create_crop_mask("cdl_2023.tif", "corn", "Iowa")
#'
#' # Create grain crops mask
#' grain_mask <- create_crop_mask(cdl_raster, "grains", mask_type = "preserve")
#' }
#'
#' \donttest{
#' # Example with mock data (this can run)
#' mock_cdl <- terra::rast(nrows = 5, ncols = 5, crs = "EPSG:4326")
#' terra::values(mock_cdl) <- c(1, 1, 5, 5, 24, 1, 5, 5, 24, 24,
#'                             1, 1, 5, 24, 24, 5, 5, 24, 24, 1,
#'                             1, 5, 5, 24, 1)  # corn, soy, wheat
#'
#' # Create corn mask from mock data
#' corn_mask <- create_crop_mask(mock_cdl, "corn")
#' print(terra::values(corn_mask))  # Should show 1s and 0s
#' }
#'
#' @export
create_crop_mask <- function(cdl_data, crop_codes, region_boundary = NULL, mask_type = "binary") {
  # Load CDL data
  if (is.character(cdl_data)) {
    cdl_raster <- terra::rast(cdl_data)
  } else {
    cdl_raster <- cdl_data
  }

  # Get crop codes if character names provided
  if (is.character(crop_codes)) {
    if (length(crop_codes) == 1) {
      codes <- get_comprehensive_cdl_codes(crop_codes)
    } else {
      codes <- unlist(lapply(crop_codes, get_comprehensive_cdl_codes))
    }
  } else {
    codes <- as.numeric(crop_codes)  # Ensure numeric vector
  }

  # Apply region boundary if provided
  if (!is.null(region_boundary)) {
    boundary <- get_region_boundary(region_boundary)
    boundary_vect <- terra::vect(boundary)
    cdl_raster <- terra::crop(cdl_raster, boundary_vect)
    cdl_raster <- terra::mask(cdl_raster, boundary_vect)
  }

  # Create mask based on type - FIXED VERSION using terra::ifel()
  if (mask_type == "binary") {
    # Create logical mask for all crop codes
    crop_logical <- cdl_raster == codes[1]
    if (length(codes) > 1) {
      for (i in 2:length(codes)) {
        crop_logical <- crop_logical | (cdl_raster == codes[i])
      }
    }

    # Use terra::ifel for safe conditional assignment
    mask <- terra::ifel(crop_logical, 1, 0)
    names(mask) <- "crop_mask_binary"

  } else if (mask_type == "preserve") {
    # Create logical mask first
    crop_logical <- cdl_raster == codes[1]
    if (length(codes) > 1) {
      for (i in 2:length(codes)) {
        crop_logical <- crop_logical | (cdl_raster == codes[i])
      }
    }

    # Use terra::ifel to preserve original values or set to NA
    mask <- terra::ifel(crop_logical, cdl_raster, NA)
    names(mask) <- "crop_mask_preserve"

  } else {
    stop("mask_type must be 'binary' or 'preserve'")
  }

  return(mask)
}

#' Analyze CDL crops dynamically
#'
#' @description
#' Perform dynamic analysis of CDL crop data including area calculations,
#' classification, and masking for any crop combination. Now accepts file paths directly.
#'
#' @param cdl_data CDL raster data (file path, directory, or SpatRaster object)
#' @param crop_selection Crop selection (names, codes, or categories)
#' @param region_boundary Region boundary
#' @param analysis_type Type of analysis: "mask", "classify", "area"
#' @param output_folder Output directory
#' @param year Year for analysis (optional)
#'
#' @return Analysis results depend on analysis_type:
#' \itemize{
#'   \item \strong{"mask"}: SpatRaster with binary mask (1 = crop, 0 = other)
#'   \item \strong{"classify"}: SpatRaster with binary classification
#'   \item \strong{"area"}: List with detailed area analysis:
#'     \itemize{
#'       \item \code{crop_areas_ha}: Named list of areas by crop code (hectares)
#'       \item \code{total_area_ha}: Total crop area (hectares)
#'       \item \code{pixel_size_ha}: Individual pixel size (hectares)
#'       \item \code{crop_codes}: CDL codes analyzed
#'       \item \code{crop_name}: Crop name(s)
#'       \item \code{region}: Region analyzed
#'       \item \code{raster_info}: Technical raster information
#'       \item \code{total_pixels}: Total number of pixels
#'       \item \code{valid_pixels}: Number of valid (non-NA) pixels
#'     }
#' }
#'
#' @details
#' ## Usage Tips:
#'
#' ### Area Analysis Results:
#' ```r
#' # Access specific results
#' result$total_area_ha          # Total area in hectares
#' result$crop_areas_ha          # Area by crop code
#' result$crop_areas_ha[["5"]]   # Soybean area (code 5)
#' ```
#'
#' ### Visualization:
#' ```r
#' # For mask/classify results (SpatRaster):
#' terra::plot(result)           # Plot the raster
#'
#' # For area results (list):
#' print(result$total_area_ha)   # Print total area
#' barplot(unlist(result$crop_areas_ha))  # Simple bar plot
#' ```
#'
#' @examples
#' \dontrun{
#' # These examples require actual CDL data files
#' # Analyze soybean area in Iowa - accepts file path directly
#' soybean_area <- analyze_cdl_crops_dynamic(
#'   "/path/to/cdl_2023.tif", "soybeans", "Iowa", "area"
#' )
#'
#' # Access area results
#' soybean_area$total_area_ha                    # Total hectares
#' soybean_area$crop_areas_ha[["5"]]            # Soybean area (code 5)
#' soybean_area$total_area_ha * 2.47105         # Convert to acres
#'
#' # Create grain classification
#' grain_classes <- analyze_cdl_crops_dynamic(
#'   cdl_data, "grains", "CONUS", "classify"
#' )
#' terra::plot(grain_classes)  # Plot the classification
#'
#' # Works with directories too
#' results <- analyze_cdl_crops_dynamic(
#'   "/path/to/cdl/files/", "corn", "Ohio", "area"
#' )
#' }
#'
#' \donttest{
#' # Example with mock CDL data (this can run)
#' # Create sample CDL raster
#' mock_cdl <- terra::rast(nrows = 10, ncols = 10, xmin = 0, xmax = 10,
#'                        ymin = 0, ymax = 10, crs = "EPSG:4326")
#' terra::values(mock_cdl) <- sample(c(1, 5, 24), 100, replace = TRUE)  # corn, soy, wheat
#'
#' # Analyze mock data
#' result <- analyze_cdl_crops_dynamic(mock_cdl, "corn", analysis_type = "mask")
#' print(class(result))  # Should be SpatRaster
#' }
#'
#' @export
analyze_cdl_crops_dynamic <- function(cdl_data, crop_selection, region_boundary = NULL,
                                      analysis_type = "classify", output_folder = NULL,
                                      year = NULL) {

  message("Starting dynamic CDL crop analysis...")

  # Enhanced input handling - now accepts file paths, directories, or raster objects
  if (is.character(cdl_data)) {
    if (length(cdl_data) == 1) {
      if (dir.exists(cdl_data)) {
        # Directory provided - find CDL files
        message(sprintf("Searching for CDL files in directory: %s", cdl_data))
        cdl_files <- list.files(cdl_data, pattern = "\\.(tif|tiff)$",
                                full.names = TRUE, ignore.case = TRUE)

        if (length(cdl_files) == 0) {
          stop(sprintf("No .tif files found in directory: %s", cdl_data), call. = FALSE)
        }

        # Take the first CDL file or try to find one matching the year
        if (!is.null(year)) {
          year_files <- cdl_files[grepl(as.character(year), cdl_files)]
          cdl_file <- if (length(year_files) > 0) year_files[1] else cdl_files[1]
        } else {
          cdl_file <- cdl_files[1]
        }

        message(sprintf("Using CDL file: %s", basename(cdl_file)))
        cdl_raster <- terra::rast(cdl_file)

      } else if (file.exists(cdl_data)) {
        # Single file provided
        message(sprintf("Loading CDL file: %s", basename(cdl_data)))
        cdl_raster <- terra::rast(cdl_data)
      } else {
        stop(sprintf("CDL data path does not exist: %s", cdl_data), call. = FALSE)
      }
    } else {
      # Multiple files provided - take the first one
      message("Multiple files provided, using the first one")
      cdl_raster <- terra::rast(cdl_data[1])
    }
  } else if (inherits(cdl_data, "SpatRaster")) {
    # Already a raster object
    cdl_raster <- cdl_data
  } else if (is.list(cdl_data) && length(cdl_data) > 0) {
    # List of rasters - take the first one
    message("List of rasters provided, using the first one")
    cdl_raster <- cdl_data[[1]]
  } else {
    stop("cdl_data must be a file path, directory, SpatRaster object, or list of rasters", call. = FALSE)
  }

  # Get crop codes
  if (is.numeric(crop_selection)) {
    crop_codes <- crop_selection
    crop_name <- "custom_selection"
  } else if (is.character(crop_selection)) {
    if (length(crop_selection) == 1) {
      crop_codes <- get_comprehensive_cdl_codes(crop_selection)
      crop_name <- crop_selection
    } else {
      crop_codes <- unlist(lapply(crop_selection, get_comprehensive_cdl_codes))
      crop_name <- paste(crop_selection, collapse = "_")
    }
  } else {
    stop("crop_selection must be numeric codes or character names")
  }

  message(sprintf("Analyzing %d crop codes for %s", length(crop_codes), crop_name))

  # Apply region boundary if provided
  if (!is.null(region_boundary)) {
    message(sprintf("Applying region boundary: %s", region_boundary))

    tryCatch({
      boundary <- get_region_boundary(region_boundary)

      # Check and fix CRS mismatch
      raster_crs <- terra::crs(cdl_raster)
      boundary_crs <- sf::st_crs(boundary)

      if (!identical(raster_crs, as.character(boundary_crs))) {
        message("CRS mismatch detected. Reprojecting boundary to match raster...")
        boundary <- sf::st_transform(boundary, crs = raster_crs)
      }

      boundary_vect <- terra::vect(boundary)
      cdl_raster <- terra::crop(cdl_raster, boundary_vect)
      cdl_raster <- terra::mask(cdl_raster, boundary_vect)
      message("Region boundary applied successfully")
    }, error = function(e) {
      stop(sprintf("Failed to apply region boundary '%s': %s", region_boundary, e$message), call. = FALSE)
    })
  }

  # Perform analysis based on type
  result <- switch(analysis_type,
                   "mask" = {
                     # Create binary mask using terra operations more safely
                     # First create a logical raster for the crop codes
                     crop_logical <- cdl_raster == crop_codes[1]
                     if (length(crop_codes) > 1) {
                       for (i in 2:length(crop_codes)) {
                         crop_logical <- crop_logical | (cdl_raster == crop_codes[i])
                       }
                     }
                     crop_mask <- terra::ifel(crop_logical, 1, 0)
                     names(crop_mask) <- paste0(crop_name, "_mask")
                     crop_mask
                   },

                   "classify" = {
                     # Create binary classification using terra operations more safely
                     # First create a logical raster for the crop codes
                     crop_logical <- cdl_raster == crop_codes[1]
                     if (length(crop_codes) > 1) {
                       for (i in 2:length(crop_codes)) {
                         crop_logical <- crop_logical | (cdl_raster == crop_codes[i])
                       }
                     }
                     binary_class <- terra::ifel(crop_logical, 1, 0)
                     names(binary_class) <- paste0(crop_name, "_binary")
                     binary_class
                   },

                   "area" = {
                     # Get raster information for area calculation
                     raster_info <- list(
                       ncells = terra::ncell(cdl_raster),
                       res = terra::res(cdl_raster),
                       crs = terra::crs(cdl_raster),
                       is_lonlat = terra::is.lonlat(cdl_raster)
                     )

                     message(sprintf("Raster info: %d cells, resolution: %.6f x %.6f",
                                     raster_info$ncells, raster_info$res[1], raster_info$res[2]))
                     message(sprintf("CRS: %s", raster_info$crs))
                     message(sprintf("Is geographic (lon/lat): %s", raster_info$is_lonlat))

                     # Calculate pixel area more robustly
                     if (raster_info$is_lonlat) {
                       # For geographic coordinates, need to calculate actual area
                       message("Geographic coordinates detected - calculating pixel area using cellSize()")
                       cell_areas <- terra::cellSize(cdl_raster, unit = "ha")
                       pixel_size_ha <- terra::global(cell_areas, "mean", na.rm = TRUE)[1,1]
                     } else {
                       # For projected coordinates, use resolution directly
                       pixel_size_m2 <- prod(raster_info$res)
                       pixel_size_ha <- pixel_size_m2 / 10000  # Convert mÂ² to hectares
                     }

                     message(sprintf("Calculated pixel size: %.6f hectares", pixel_size_ha))

                     # Count pixels for each crop code
                     crop_areas <- list()
                     raster_values <- terra::values(cdl_raster, mat = FALSE)

                     for (code in crop_codes) {
                       crop_pixels <- sum(raster_values == code, na.rm = TRUE)
                       crop_area_ha <- crop_pixels * pixel_size_ha
                       crop_areas[[as.character(code)]] <- crop_area_ha
                       message(sprintf("  Code %d: %d pixels = %.2f hectares",
                                       code, crop_pixels, crop_area_ha))
                     }

                     total_area <- sum(unlist(crop_areas))

                     # Enhanced area summary
                     area_summary <- list(
                       crop_areas_ha = crop_areas,
                       total_area_ha = total_area,
                       pixel_size_ha = pixel_size_ha,
                       crop_codes = crop_codes,
                       crop_name = crop_name,
                       region = region_boundary %||% "Full extent",
                       raster_info = raster_info,
                       total_pixels = length(raster_values),
                       valid_pixels = sum(!is.na(raster_values))
                     )

                     # Print summary
                     message("Area Analysis Summary:")
                     message(sprintf("  Crop: %s (codes: %s)", crop_name, paste(crop_codes, collapse = ", ")))
                     message(sprintf("  Region: %s", area_summary$region))
                     message(sprintf("  Total crop area: %.2f hectares (%.2f acres)",
                                     total_area, total_area * 2.47105))
                     message(sprintf("  Pixel size: %.6f hectares", pixel_size_ha))
                     message(sprintf("  Raster: %d total pixels, %d valid pixels",
                                     area_summary$total_pixels, area_summary$valid_pixels))

                     area_summary
                   },

                   stop(paste("Unsupported analysis type:", analysis_type))
  )

  # Save results if output folder specified
  if (!is.null(output_folder)) {
    if (!dir.exists(output_folder)) {
      dir.create(output_folder, recursive = TRUE)
    }

    if (inherits(result, "SpatRaster")) {
      output_file <- file.path(output_folder, paste0(crop_name, "_", analysis_type, ".tif"))
      terra::writeRaster(result, output_file, overwrite = TRUE)
      message(sprintf("Results saved to: %s", output_file))
    } else if (analysis_type == "area") {
      # Save area results as text file
      area_file <- file.path(output_folder, paste0(crop_name, "_area_analysis.txt"))
      area_text <- c(
        paste("CDL Crop Area Analysis for", crop_name),
        paste("Date:", Sys.time()),
        paste("Region:", result$region),
        "",
        "AREA SUMMARY:",
        paste("Total area:", sprintf("%.2f hectares (%.2f acres)",
                                     result$total_area_ha, result$total_area_ha * 2.47105)),
        paste("Pixel size:", sprintf("%.6f hectares", result$pixel_size_ha)),
        "",
        "AREA BY CROP CODE:"
      )

      for (code in names(result$crop_areas_ha)) {
        area_ha <- result$crop_areas_ha[[code]]
        area_acres <- area_ha * 2.47105
        area_text <- c(area_text,
                       sprintf("  Code %s: %.2f ha (%.2f acres)", code, area_ha, area_acres))
      }

      writeLines(area_text, area_file)
      message(sprintf("Area analysis saved to: %s", area_file))
    }
  }

  message("CDL analysis completed!")
  return(result)
}
