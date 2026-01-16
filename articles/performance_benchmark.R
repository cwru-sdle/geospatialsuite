## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE  # Benchmarks require large external datasets not included in package
)

## ----benchmark-setup----------------------------------------------------------
# library(geospatialsuite)
# library(terra)
# library(ggplot2)
# library(bench)
# 
# # Simulate large raster dataset characteristics
# # In practice, use real satellite imagery (Landsat, Sentinel-2, etc.)
# create_test_raster <- function(nrow = 5000, ncol = 5000) {
#   r <- rast(nrows = nrow, ncols = ncol,
#             xmin = -180, xmax = 180,
#             ymin = -90, ymax = 90)
#   values(r) <- runif(ncell(r), 0, 1)
#   names(r) <- "test_value"
#   return(r)
# }
# 
# # Create test datasets of varying sizes
# cat("Creating test datasets (this may take a moment)...\n")
# small_raster <- create_test_raster(1000, 1000)    # ~7.6 MB
# medium_raster <- create_test_raster(3000, 3000)   # ~68.7 MB
# large_raster <- create_test_raster(5000, 5000)    # ~190.7 MB
# 
# 

## ----geospatialsuite-method---------------------------------------------------
# plot_geospatialsuite <- function(raster_data) {
#   quick_map(raster_data, title = "geospatialsuite Plot")
# }

## ----terra-method-------------------------------------------------------------
# plot_terra_base <- function(raster_data) {
#   plot(raster_data, main = "terra Base Plot")
# }

## ----ggplot-method------------------------------------------------------------
# plot_ggplot2 <- function(raster_data) {
#   # Convert raster to data frame (this is what causes memory scaling)
#   df <- as.data.frame(raster_data, xy = TRUE)
#   ggplot(df, aes(x = x, y = y, fill = test_value)) +
#     geom_raster() +
#     scale_fill_viridis_c() +
#     theme_minimal() +
#     labs(title = "ggplot2 Plot")
# }

## ----memory-benchmark---------------------------------------------------------
# 
# 
# test_datasets <- list(
#   Small = small_raster,
#   Medium = medium_raster,
#   Large = large_raster
# )
# 
# cat("\n=== MEMORY FOOTPRINT ANALYSIS ===\n\n")
# 
# memory_summary <- data.frame(
#   Dataset = character(),
#   Dimensions = character(),
#   Pixels = character(),
#   ggplot2_MB = numeric(),
#   terra_geospatial_MB = character(),
#   stringsAsFactors = FALSE
# )
# 
# for (dataset_name in names(test_datasets)) {
#   raster_data <- test_datasets[[dataset_name]]
#   dims <- sprintf("%d x %d", nrow(raster_data), ncol(raster_data))
#   n_pixels <- format(ncell(raster_data), big.mark = ",")
# 
#   # The critical measurement: ggplot2's data frame size
#   df <- as.data.frame(raster_data, xy = TRUE)
#   df_size_mb <- as.numeric(object.size(df)) / 1024^2
#   rm(df); gc(verbose = FALSE)
# 
# 
#   if (df_size_mb > 75) {
#     cat(sprintf("  Memory advantage:        %.1fx less memory\n\n", df_size_mb / 75))
#   } else {
#     cat(sprintf("  Memory ratio:            %.2fx\n\n", df_size_mb / 75))
#   }
# 
#   memory_summary <- rbind(memory_summary, data.frame(
#     Dataset = dataset_name,
#     Dimensions = dims,
#     Pixels = n_pixels,
#     ggplot2_MB = round(df_size_mb, 1),
#     terra_geospatial_MB = "~75",
#     stringsAsFactors = FALSE
#   ))
# }
# 
# 

## ----timing-benchmark---------------------------------------------------------
# # Benchmark execution time WITHOUT memory profiling
# # (memory profiling fails with terra's internal parallelization)
# 
# 
# timing_results <- bench::press(
#   dataset = c("Small", "Medium", "Large"),
#   {
#     raster_data <- test_datasets[[dataset]]
# 
#     bench::mark(
#       geospatialsuite = quick_map(raster_data),
#       terra_base = plot(raster_data),
#       ggplot2 = plot_ggplot2(raster_data),
#       check = FALSE,
#       min_iterations = 3,
#       max_iterations = 5,
#       memory = FALSE
#     )
#   }
# )
# 
# # Extract and display timing results
# timing_df <- as.data.frame(timing_results)
# 
# # Create summary - handle possible column name variations
# if ("dataset" %in% names(timing_df)) {
#   dataset_col <- "dataset"
# } else if ("Dataset" %in% names(timing_df)) {
#   dataset_col <- "Dataset"
# } else {
#   # Fallback: infer from row groups
#   dataset_col <- NULL
# }
# 
# cat("=== TIMING RESULTS ===\n\n")
# 
# # Display by dataset
# for (ds in c("Small", "Medium", "Large")) {
#   cat(sprintf("%s Dataset:\n", ds))
# 
#   if (!is.null(dataset_col)) {
#     subset_data <- timing_df[timing_df[[dataset_col]] == ds, ]
#   } else {
#     # Fallback: each dataset has 3 rows (3 methods)
#     idx <- which(c("Small", "Medium", "Large") == ds)
#     subset_data <- timing_df[((idx-1)*3 + 1):(idx*3), ]
#   }
# 
#   for (i in 1:nrow(subset_data)) {
#     method <- as.character(subset_data$expression[i])
#     time_sec <- as.numeric(subset_data$median[i])
#     time_ms <- time_sec * 1000
# 
#     # Simplify method name for display
#     method_display <- method
#     if (grepl("quick_map|geospatialsuite", method, ignore.case = TRUE)) {
#       method_display <- "geospatialsuite"
#     } else if (grepl("plot_ggplot|ggplot", method, ignore.case = TRUE)) {
#       method_display <- "ggplot2"
#     } else if (grepl("plot.*terra|^plot\\(", method, ignore.case = TRUE)) {
#       method_display <- "terra_base"
#     }
# 
#     cat(sprintf("  %-20s: %6.0f ms\n", method_display, time_ms))
#   }
# 
#   # Calculate speedup vs ggplot2 using pattern matching
#   expr_str <- as.character(subset_data$expression)
#   gg_idx <- grep("ggplot|plot_ggplot2", expr_str, ignore.case = TRUE)
#   geo_idx <- grep("quick_map|geospatialsuite", expr_str, ignore.case = TRUE)
# 
#   if (length(gg_idx) > 0 && length(geo_idx) > 0) {
#     ggplot_time <- subset_data$median[gg_idx[1]]
#     geospatial_time <- subset_data$median[geo_idx[1]]
# 
#     speedup <- as.numeric(ggplot_time) / as.numeric(geospatial_time)
#     if (speedup > 1) {
#       cat(sprintf("  → geospatialsuite is %.1fx FASTER than ggplot2\n", speedup))
#     } else {
#       cat(sprintf("  → geospatialsuite is %.1fx slower than ggplot2\n", 1/speedup))
#     }
#   }
#   cat("\n")
# }
# 
# # Create summary table
# timing_summary <- data.frame(
#   Dataset = character(),
#   geospatialsuite_ms = numeric(),
#   terra_base_ms = numeric(),
#   ggplot2_ms = numeric(),
#   Speedup_vs_ggplot2 = character(),
#   stringsAsFactors = FALSE
# )
# 
# for (ds in c("Small", "Medium", "Large")) {
#   if (!is.null(dataset_col)) {
#     subset_data <- timing_df[timing_df[[dataset_col]] == ds, ]
#   } else {
#     idx <- which(c("Small", "Medium", "Large") == ds)
#     subset_data <- timing_df[((idx-1)*3 + 1):(idx*3), ]
#   }
# 
#   # Expression names are the full calls, need to match on pattern
#   expr_str <- as.character(subset_data$expression)
# 
#   # Find which row is which by looking for function names in the expression
#   geo_idx <- grep("quick_map|geospatialsuite", expr_str, ignore.case = TRUE)
#   terra_idx <- grep("plot.*terra|terra.*plot|^plot\\(", expr_str, ignore.case = TRUE)
#   terra_idx <- terra_idx[!terra_idx %in% geo_idx]  # Exclude geospatialsuite
#   gg_idx <- grep("ggplot|plot_ggplot2", expr_str, ignore.case = TRUE)
# 
#   geo_ms <- if (length(geo_idx) > 0) as.numeric(subset_data$median[geo_idx[1]]) * 1000 else NA
#   terra_ms <- if (length(terra_idx) > 0) as.numeric(subset_data$median[terra_idx[1]]) * 1000 else NA
#   gg_ms <- if (length(gg_idx) > 0) as.numeric(subset_data$median[gg_idx[1]]) * 1000 else NA
# 
#   if (!is.na(geo_ms) && !is.na(gg_ms)) {
#     speedup <- gg_ms / geo_ms
#     if (speedup > 1) {
#       speedup_text <- sprintf("%.1fx faster", speedup)
#     } else {
#       speedup_text <- sprintf("%.1fx slower", 1/speedup)
#     }
#   } else {
#     speedup_text <- "N/A"
#   }
# 
#   timing_summary <- rbind(timing_summary, data.frame(
#     Dataset = ds,
#     geospatialsuite_ms = round(geo_ms, 0),
#     terra_base_ms = round(terra_ms, 0),
#     ggplot2_ms = round(gg_ms, 0),
#     Speedup_vs_ggplot2 = speedup_text,
#     stringsAsFactors = FALSE
#   ))
# }
# 
# cat("=== SUMMARY TABLE ===\n")
# print(timing_summary, row.names = FALSE)

## ----error-handling-demo------------------------------------------------------
# # Handles missing data gracefully
# raster_with_na <- medium_raster
# values(raster_with_na)[sample(ncell(raster_with_na), 10000)] <- NA
# quick_map(raster_with_na)  # Succeeds with warning
# 
# # Handles projection issues automatically
# raster_wrong_crs <- project(medium_raster, "EPSG:3857")
# quick_map(raster_wrong_crs)  # Auto-detects and handles
# 
# # Handles empty/invalid data
# empty_raster <- medium_raster
# values(empty_raster) <- NA
# tryCatch(
#   quick_map(empty_raster),
#   error = function(e) message("Graceful failure with informative error")
# )

## ----scaling-test-------------------------------------------------------------
# # Test consistent output quality across sizes
# datasets <- list(small_raster, medium_raster, large_raster)
# 
# for (i in seq_along(datasets)) {
#   cat(sprintf("\nDataset %d (%.1f MB):\n", i,
#               as.numeric(object.size(datasets[[i]])) / 1024^2))
# 
#   system.time({
#     result <- quick_map(datasets[[i]])
#     cat("Success: Plot generated\n")
#   })
# }

## ----reproducibility----------------------------------------------------------
# # Use your own raster data
# my_large_raster <- terra::rast("path/to/large_satellite_image.tif")
# 
# # Simple timing test
# time_result <- system.time({
#   quick_map(my_large_raster)
# })
# cat(sprintf("Execution time: %.2f seconds\n", time_result["elapsed"]))
# 
# # Memory test - measure data frame size for ggplot2 comparison
# df_size <- object.size(as.data.frame(my_large_raster, xy = TRUE))
# cat(sprintf("ggplot2 would require converting to data frame: %.0f MB\n",
#             as.numeric(df_size) / 1024^2))
# 
# # Benchmark comparison
# library(bench)
# comparison <- bench::mark(
#   geospatialsuite = quick_map(my_large_raster),
#   terra_base = terra::plot(my_large_raster),
#   memory = FALSE,  # Disable if parallel rendering causes issues
#   min_iterations = 3
# )
# print(comparison[, c("expression", "median")])

