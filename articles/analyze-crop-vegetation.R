## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  warning = FALSE,
  message = FALSE,
  fig.width = 10,
  fig.height = 8,
  eval = TRUE  
)

## ----eval=FALSE---------------------------------------------------------------
# result <- analyze_crop_vegetation(
#   spectral_data = your_data,
#   crop_type = "corn",
#   analysis_type = "comprehensive"
# )
# 
# # Structure:
# result$vegetation_indices      # SpatRaster with calculated indices
# result$analysis_results        # Detailed analysis results
# result$metadata                # Processing metadata

## ----eval=FALSE---------------------------------------------------------------
# # View all calculated indices
# names(result$vegetation_indices)
# # [1] "NDVI" "EVI" "GNDVI" "DVI" "RVI" "PRI"
# 
# # Extract a specific index
# ndvi <- result$vegetation_indices[["NDVI"]]
# 
# # Plot an index
# plot(result$vegetation_indices[["NDVI"]], main = "NDVI")
# 
# # Get values for analysis
# ndvi_values <- terra::values(result$vegetation_indices[["NDVI"]])

## ----eval=FALSE---------------------------------------------------------------
# result$analysis_results$stress_analysis

## ----eval=FALSE---------------------------------------------------------------
# result$analysis_results$stress_analysis$NDVI$thresholds_used
# # $healthy: c(0.6, 1.0)         # NDVI 0.6-1.0 = healthy
# # $moderate_stress: c(0.4, 0.6) # NDVI 0.4-0.6 = moderate stress
# # $severe_stress: c(0.0, 0.4)   # NDVI 0.0-0.4 = severe stress

## ----eval=FALSE---------------------------------------------------------------
# # Access stress results for NDVI
# ndvi_stress <- result$analysis_results$stress_analysis$NDVI
# 
# # What percentage of my field is healthy?
# cat(sprintf("Healthy vegetation: %.1f%%\n", ndvi_stress$healthy_percentage))
# 
# # What's the average NDVI?
# cat(sprintf("Mean NDVI: %.3f\n", ndvi_stress$mean_value))
# 
# # Check all indices analyzed
# names(result$analysis_results$stress_analysis)

## ----eval=FALSE---------------------------------------------------------------
# result$analysis_results$growth_analysis

## ----eval=FALSE---------------------------------------------------------------
# # What growth stage is the crop in?
# growth <- result$analysis_results$growth_analysis
# cat(sprintf("Growth stage: %s (confidence: %.2f)\n",
#             growth$predicted_growth_stage,
#             growth$stage_confidence))
# 
# # Get detailed NDVI statistics
# ndvi_stats <- growth$NDVI
# cat(sprintf("NDVI range: %.3f - %.3f\n", ndvi_stats$min, ndvi_stats$max))
# cat(sprintf("NDVI variability (CV): %.3f\n", ndvi_stats$coefficient_of_variation))

## ----eval=FALSE---------------------------------------------------------------
# result$analysis_results$yield_analysis

## ----eval=FALSE---------------------------------------------------------------
# result$analysis_results$yield_analysis$index_contributions$NDVI
# # $mean_normalized: 0.75    # Normalized contribution (0-1)
# # $raw_mean: 0.68           # Raw mean NDVI value
# # $raw_std: 0.12            # Raw standard deviation

## ----eval=FALSE---------------------------------------------------------------
# # What's the yield potential?
# yield <- result$analysis_results$yield_analysis
# cat(sprintf("Yield Potential: %s (score: %.2f)\n",
#             yield$yield_potential_class,
#             yield$composite_yield_index))
# 
# # Which indices contributed?
# cat(sprintf("Based on %d indices: %s\n",
#             yield$n_indices_used,
#             paste(yield$indices_used, collapse = ", ")))
# 
# # Get individual index contributions
# for (idx in names(yield$index_contributions)) {
#   contrib <- yield$index_contributions[[idx]]
#   cat(sprintf("%s: %.3f (raw: %.3f Ã‚Â± %.3f)\n",
#               idx,
#               contrib$mean_normalized,
#               contrib$raw_mean,
#               contrib$raw_std))
# }

## ----eval=FALSE---------------------------------------------------------------
# result$analysis_results$summary_statistics

## ----eval=FALSE---------------------------------------------------------------
# result$analysis_results$summary_statistics$summary
# # $total_indices_calculated: 6
# # $indices_with_valid_data: c("NDVI", "EVI", "GNDVI", ...)
# # $total_indices_requested: 6
# # $success_rate: 100.0

## ----eval=FALSE---------------------------------------------------------------
# # Get statistics for all indices
# stats <- result$analysis_results$summary_statistics
# 
# # NDVI statistics
# ndvi_stats <- stats$NDVI
# cat(sprintf("NDVI: %.3f Ã‚Â± %.3f (range: %.3f to %.3f)\n",
#             ndvi_stats$mean,
#             ndvi_stats$std_dev,
#             ndvi_stats$min,
#             ndvi_stats$max))
# 
# # Check data quality
# cat(sprintf("Coverage: %.1f%% (%d pixels)\n",
#             ndvi_stats$coverage_percent,
#             ndvi_stats$count))

## ----eval=FALSE---------------------------------------------------------------
# result$metadata

## ----eval=FALSE---------------------------------------------------------------
# # Check what was analyzed
# meta <- result$metadata
# cat(sprintf("Analyzed %s at %s growth stage\n",
#             meta$crop_type,
#             meta$growth_stage))
# cat(sprintf("Used %d indices: %s\n",
#             length(meta$indices_used),
#             paste(meta$indices_used, collapse = ", ")))
# cat(sprintf("Processed on: %s\n", meta$processing_date))

## ----eval=FALSE---------------------------------------------------------------
# library(geospatialsuite)
# library(terra)
# 
# # Run comprehensive crop analysis
# result <- analyze_crop_vegetation(
#   spectral_data = "path/to/sentinel2_data.tif",
#   crop_type = "corn",
#   growth_stage = "mid",
#   analysis_type = "comprehensive",
#   verbose = TRUE
# )
# 
# # ===== 1. Check what was calculated =====
# cat("Indices calculated:\n")
# print(names(result$vegetation_indices))
# 
# # ===== 2. Assess crop stress =====
# stress <- result$analysis_results$stress_analysis$NDVI
# cat(sprintf("\nStress Assessment:\n"))
# cat(sprintf("  Healthy: %.1f%%\n", stress$healthy_percentage))
# cat(sprintf("  Moderate stress: %.1f%%\n", stress$moderate_stress_percentage))
# cat(sprintf("  Severe stress: %.1f%%\n", stress$severe_stress_percentage))
# 
# # ===== 3. Identify growth stage =====
# growth <- result$analysis_results$growth_analysis
# cat(sprintf("\nGrowth Stage: %s (%.0f%% confidence)\n",
#             growth$predicted_growth_stage,
#             growth$stage_confidence * 100))
# 
# # ===== 4. Estimate yield potential =====
# yield <- result$analysis_results$yield_analysis
# cat(sprintf("\nYield Potential: %s\n", yield$yield_potential_class))
# cat(sprintf("Composite Yield Index: %.3f\n", yield$composite_yield_index))
# cat(sprintf("Based on %d indices: %s\n",
#             yield$n_indices_used,
#             paste(yield$indices_used, collapse = ", ")))
# 
# # ===== 5. Visualize results =====
# # Plot stress map
# plot(result$vegetation_indices[["NDVI"]],
#      main = "NDVI - Stress Detection",
#      col = terrain.colors(100))
# 
# # Create stress classification map
# ndvi <- result$vegetation_indices[["NDVI"]]
# stress_map <- classify(ndvi,
#                       matrix(c(-Inf, 0.4, 1,    # Severe stress
#                               0.4, 0.6, 2,       # Moderate stress
#                               0.6, Inf, 3),      # Healthy
#                             ncol = 3, byrow = TRUE))
# plot(stress_map,
#      main = "Crop Stress Classification",
#      col = c("red", "yellow", "green"),
#      legend = FALSE)
# legend("topright",
#        legend = c("Severe Stress", "Moderate Stress", "Healthy"),
#        fill = c("red", "yellow", "green"))
# 
# # ===== 6. Export results =====
# # Save as geotiff
# writeRaster(result$vegetation_indices,
#             "crop_indices.tif",
#             overwrite = TRUE)
# 
# # Save statistics as CSV
# stats_df <- data.frame(
#   Index = names(result$analysis_results$summary_statistics)[-length(names(result$analysis_results$summary_statistics))],
#   Mean = sapply(result$analysis_results$summary_statistics[1:(length(result$analysis_results$summary_statistics)-1)], function(x) x$mean),
#   StdDev = sapply(result$analysis_results$summary_statistics[1:(length(result$analysis_results$summary_statistics)-1)], function(x) x$std_dev),
#   Min = sapply(result$analysis_results$summary_statistics[1:(length(result$analysis_results$summary_statistics)-1)], function(x) x$min),
#   Max = sapply(result$analysis_results$summary_statistics[1:(length(result$analysis_results$summary_statistics)-1)], function(x) x$max)
# )
# write.csv(stats_df, "crop_analysis_statistics.csv", row.names = FALSE)

## ----eval=FALSE---------------------------------------------------------------
# # Find pixels with severe stress
# ndvi <- result$vegetation_indices[["NDVI"]]
# severe_stress <- ndvi < 0.4
# plot(severe_stress, main = "Severe Stress Areas")

## ----eval=FALSE---------------------------------------------------------------
# # Run analysis for multiple fields and compare
# field1_result <- analyze_crop_vegetation(field1_data, crop_type = "corn")
# field2_result <- analyze_crop_vegetation(field2_data, crop_type = "corn")
# 
# # Compare yield potential
# cat(sprintf("Field 1 yield: %s (%.3f)\n",
#             field1_result$analysis_results$yield_analysis$yield_potential_class,
#             field1_result$analysis_results$yield_analysis$composite_yield_index))
# cat(sprintf("Field 2 yield: %s (%.3f)\n",
#             field2_result$analysis_results$yield_analysis$yield_potential_class,
#             field2_result$analysis_results$yield_analysis$composite_yield_index))

## ----eval=FALSE---------------------------------------------------------------
# # Analyze the same field at different dates
# early_season <- analyze_crop_vegetation(june_data, growth_stage = "early")
# mid_season <- analyze_crop_vegetation(july_data, growth_stage = "mid")
# late_season <- analyze_crop_vegetation(august_data, growth_stage = "late")
# 
# # Track NDVI progression
# ndvi_progression <- c(
#   early_season$analysis_results$growth_analysis$NDVI$mean,
#   mid_season$analysis_results$growth_analysis$NDVI$mean,
#   late_season$analysis_results$growth_analysis$NDVI$mean
# )
# plot(1:3, ndvi_progression, type = "b",
#      xlab = "Time Period", ylab = "Mean NDVI",
#      main = "NDVI Progression Through Season")

