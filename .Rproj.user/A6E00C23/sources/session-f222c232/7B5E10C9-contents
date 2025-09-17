#' Input Validation Helpers
#'
#' @description
#' Internal validation functions for robust parameter checking
#' @keywords internal
#' @name validation-helpers
NULL

#' Validate raster input
#' @param x Input to validate
#' @param param_name Parameter name for error messages
#' @param allow_null Allow NULL values
#' @return TRUE if valid, stops with error if invalid
#' @keywords internal
validate_raster_input <- function(x, param_name = "raster_data", allow_null = FALSE) {
  if (is.null(x) && allow_null) return(TRUE)
  if (is.null(x) && !allow_null) {
    stop(sprintf("Parameter '%s' cannot be NULL", param_name), call. = FALSE)
  }

  if (is.character(x)) {
    if (length(x) == 1 && !file.exists(x) && !dir.exists(x)) {
      stop(sprintf("File or directory '%s' does not exist", x), call. = FALSE)
    }
    if (length(x) > 1) {
      missing_files <- x[!file.exists(x)]
      if (length(missing_files) > 0) {
        stop(sprintf("Files do not exist: %s", paste(missing_files, collapse = ", ")),
             call. = FALSE)
      }
    }
  } else if (!inherits(x, c("SpatRaster", "RasterStack", "RasterLayer", "list"))) {
    stop(sprintf("Parameter '%s' must be file path(s), directory, raster object, or list of rasters",
                 param_name), call. = FALSE)
  }

  return(TRUE)
}

#' Validate vector input
#' @param x Input to validate
#' @param param_name Parameter name for error messages
#' @param allow_null Allow NULL values
#' @return TRUE if valid, stops with error if invalid
#' @keywords internal
validate_vector_input <- function(x, param_name = "vector_data", allow_null = FALSE) {
  if (is.null(x) && allow_null) return(TRUE)
  if (is.null(x) && !allow_null) {
    stop(sprintf("Parameter '%s' cannot be NULL", param_name), call. = FALSE)
  }

  if (is.character(x)) {
    if (length(x) == 1 && !file.exists(x)) {
      stop(sprintf("File '%s' does not exist", x), call. = FALSE)
    }
  } else if (!inherits(x, c("sf", "data.frame"))) {
    stop(sprintf("Parameter '%s' must be sf object, data.frame, or file path",
                 param_name), call. = FALSE)
  }

  return(TRUE)
}

#' Validate method parameter
#' @param method Method to validate
#' @param valid_methods Vector of valid methods
#' @param param_name Parameter name for error messages
#' @return TRUE if valid, stops with error if invalid
#' @keywords internal
#' @export
validate_method <- function(method, valid_methods, param_name = "method") {
  if (!method %in% valid_methods) {
    stop(sprintf("Parameter '%s' must be one of: %s. Got: %s",
                 param_name, paste(valid_methods, collapse = ", "), method), call. = FALSE)
  }
  return(TRUE)
}

#' Validate numeric range
#' @param x Numeric value to validate
#' @param min_val Minimum allowed value
#' @param max_val Maximum allowed value
#' @param param_name Parameter name for error messages
#' @param allow_null Allow NULL values
#' @return TRUE if valid, stops with error if invalid
#' @keywords internal
#' @export
validate_numeric_range <- function(x, min_val = NULL, max_val = NULL,
                                   param_name = "parameter", allow_null = FALSE) {
  if (is.null(x) && allow_null) return(TRUE)
  if (is.null(x) && !allow_null) {
    stop(sprintf("Parameter '%s' cannot be NULL", param_name), call. = FALSE)
  }

  if (!is.numeric(x)) {
    stop(sprintf("Parameter '%s' must be numeric. Got: %s", param_name, class(x)[1]), call. = FALSE)
  }

  if (!is.null(min_val) && any(x < min_val, na.rm = TRUE)) {
    stop(sprintf("Parameter '%s' must be >= %s", param_name, min_val), call. = FALSE)
  }

  if (!is.null(max_val) && any(x > max_val, na.rm = TRUE)) {
    stop(sprintf("Parameter '%s' must be <= %s", param_name, max_val), call. = FALSE)
  }

  return(TRUE)
}

#' Check raster compatibility
#' @param raster1 First raster
#' @param raster2 Second raster
#' @param auto_align Attempt automatic alignment
#' @return Aligned raster2 or original if compatible
#' @keywords internal
#' @export
check_raster_compatibility <- function(raster1, raster2, auto_align = TRUE) {
  if (!terra::compareGeom(raster1, raster2, stopOnError = FALSE)) {
    if (auto_align) {
      message("Rasters have different geometries. Attempting to align...")
      raster2 <- tryCatch({
        terra::resample(raster2, raster1)
      }, error = function(e) {
        stop(sprintf("Cannot align rasters: %s", e$message), call. = FALSE)
      })
    } else {
      stop("Rasters have incompatible geometries. Set auto_align=TRUE to attempt alignment.",
           call. = FALSE)
    }
  }
  return(raster2)
}

#' Load raster with error handling
#' @param x File path or raster object
#' @param param_name Parameter name for error messages
#' @return SpatRaster object
#' @keywords internal
load_raster_safe <- function(x, param_name = "raster") {
  if (is.character(x)) {
    tryCatch({
      terra::rast(x)
    }, error = function(e) {
      stop(sprintf("Failed to load %s from '%s': %s", param_name, x, e$message), call. = FALSE)
    })
  } else {
    x
  }
}



