#' @keywords package geospatial remote-sensing visualization vegetation-indices
#' @importFrom terra rast values nlyr crop mask mosaic merge resample project terrain plotRGB plot
#' @importFrom sf st_read st_write st_transform st_crs st_as_sf st_geometry st_bbox st_coordinates st_drop_geometry st_filter st_buffer st_distance
#' @importFrom dplyr filter select mutate group_by summarise n
#' @importFrom stats cor lm sd median quantile na.omit coef complete.cases runif as.formula setNames
#' @importFrom utils read.csv write.csv head packageVersion
#' @importFrom grDevices terrain.colors colorRampPalette dev.off png rainbow pdf
#' @importFrom graphics par hist legend lines plot
#' @importFrom tools file_ext file_path_sans_ext
#' @importFrom stringr str_to_title
#' @importFrom parallel detectCores mclapply
#' @importFrom RColorBrewer brewer.pal
#' @importFrom magrittr %>%
#' @importFrom ggplot2 ggplot aes geom_sf geom_tile geom_text geom_raster coord_sf coord_fixed theme_minimal theme element_text labs scale_fill_gradient2 scale_fill_gradientn scale_color_manual ggsave scale_colour_viridis_c scale_fill_viridis_c
#' @importFrom viridis scale_fill_viridis scale_color_viridis
#' @author Olatunde D. Akanbi \email{olatunde.akanbi@case.edu}
#' @author Erika I. Barcelos \email{erika.barcelos@case.edu}
#' @author Roger H. French \email{roger.french@case.edu}
#' @description
#' GeoSpatialSuite provides universal functions for geospatial analysis and reliable
#' visualization that work with any region for multimodal data. Features include
#' 60+ vegetation indices, efficient terra-based visualization, universal spatial mapping,
#' dynamic crop analysis, water quality assessment, and publication-quality mapping with
#' support for any geographic region and robust error handling.
#'
#' @details
#' ## Key Features:
#'
#' ### Universal Spatial Analysis:
#' - Universal region support (states, countries, CONUS, custom boundaries)
#' - Universal spatial join (works with ANY raster-vector combination)
#' - Multi-dataset integration and temporal analysis
#' - Spatial interpolation and terrain analysis
#'
#' ### Advanced Vegetation Analysis:
#' - **60+ vegetation indices** including NDVI, EVI, SAVI, ARVI, PRI, SIPI, etc.
#' - **Specialized crop analysis** with stress detection and yield assessment
#' - **Auto band detection** from multi-band satellite imagery
#' - **Quality filtering** and temporal smoothing for time series
#'
#' ### Reliable Visualization:
#' - **Universal mapping** with auto-detection (`quick_map()` function)
#' - **Terra-based plotting** using reliable terra::plot() and terra::plotRGB()
#' - **Interactive maps** with leaflet integration (optional)
#' - **RGB composites** with stretching algorithms
#' - **Comparison maps** for before/after analysis
#'
#' ### Agricultural Applications:
#' - **Dynamic CDL crop analysis** (all crop codes and categories)
#' - **NDVI time series** with classification
#' - **Crop-specific analysis** (corn, soybeans, wheat, etc.)
#' - **Water quality assessment** with threshold analysis
#'
#' ### Performance & Reliability Features:
#' - **Standard terra plotting** - no complex dependencies required
#' - **Robust error handling** throughout all functions
#' - **Simplified visualization** for maps
#' - **Smart fallback systems** when optional packages unavailable
#'
#' ## Quick Start Examples:
#'
#' ```r
#' # One-line mapping (auto-detects everything!)
#' quick_map("mydata.shp")
#'
#' # Auto-geocode data without coordinates
#' census_data <- data.frame(
#'   state = c("Ohio", "Pennsylvania", "Michigan"),
#'   median_income = c(58642, 61744, 59584)
#' )
#' spatial_data <- auto_geocode_data(census_data)
#' quick_map(spatial_data, variable = "median_income")
#'
#' # Works with HUC codes too (any format: HUC_8, HUC-8, huc8)
#' watershed_data <- data.frame(
#'   HUC_8 = c("04100009", "04100012"),
#'   water_quality = c(72, 65)
#' )
#' huc_spatial <- auto_geocode_data(watershed_data)
#' quick_map(huc_spatial)
#'
#' # Calculate multiple vegetation indices
#' indices <- calculate_multiple_indices(
#'   red = red_band, nir = nir_band,
#'   indices = c("NDVI", "EVI", "SAVI", "PRI")
#' )
#'
#' # Comprehensive crop analysis
#' crop_analysis <- analyze_crop_vegetation(
#'   spectral_data = sentinel_data,
#'   crop_type = "corn",
#'   analysis_type = "comprehensive"
#' )
#'
#' # Enhanced NDVI calculation
#' ndvi_enhanced <- calculate_ndvi_enhanced(
#'   red_data = red_raster,
#'   nir_data = nir_raster,
#'   quality_filter = TRUE
#' )
#'
#' # Fast, reliable RGB plotting
#' plot_rgb_raster(satellite_data, r = 4, g = 3, b = 2,
#'                stretch = "hist", title = "False Color")
#' ```
#'
#' ## Recommended Optional Packages:
#' For enhanced features, consider installing these optional packages:
#'
#' ```r
#' # For interactive mapping
#' install.packages("leaflet")
#'
#' # For enhanced colors
#' install.packages(c("viridis", "RColorBrewer"))
#'
#' # For advanced remote sensing (optional)
#' install.packages("RStoolbox")
#'
#' # For multi-panel plots (optional)
#' install.packages("patchwork")
#' ```
#'
#' ## Core Dependencies Only:
#' The package works reliably with just the core dependencies:
#' - terra (raster operations and plotting)
#' - sf (vector operations)
#' - ggplot2 (static mapping)
#' - dplyr (data manipulation)
#'
#' No complex visualization dependencies required!
"_PACKAGE"

# Package startup message - UPDATED
.onAttach <- function(libname, pkgname) {
  packageStartupMessage("==================================================")
  packageStartupMessage("GeoSpatialSuite v0.1.1 - Reliable Spatiotemporal Analysis")
  packageStartupMessage("==================================================")
  packageStartupMessage("Universal - 60+ Vegetation Indices - Robust & Simple")
  packageStartupMessage("")
  packageStartupMessage("   Reliable terra plotting (no complex dependencies)")
  packageStartupMessage("   60+ vegetation indices with auto band detection")
  packageStartupMessage("   Universal mapping with quick_map()")
  packageStartupMessage("   Enhanced NDVI with quality filtering")
  packageStartupMessage("   Robust error handling throughout")
  packageStartupMessage("")
  packageStartupMessage("Quick Start: help(package='geospatialsuite')")
  packageStartupMessage("Test Package: test_geospatialsuite_package_simple()")
  packageStartupMessage("==================================================")

  # Check for optional packages
  optional <- c("leaflet", "viridis", "RColorBrewer")
  missing <- optional[!sapply(optional, requireNamespace, quietly = TRUE)]

  if (length(missing) > 0) {
    packageStartupMessage("")
    packageStartupMessage("OPTIONAL: For enhanced features, consider:")
    packageStartupMessage(sprintf("   install.packages(c('%s'))", paste(missing, collapse = "', '")))
  } else {
    packageStartupMessage("")
    packageStartupMessage(" All optional packages available!")
  }
}

# Global variables
utils::globalVariables(c(".", "STATEFP", "STUSPS", "NAME", "GEOID", "Var1", "Var2",
                         "Correlation", "threshold_group", ".data", "x", "y", "value",
                         "variable", "dataset", "NDVI", "NDVI_Class", "crop_code",
                         "crop_name", "difference", "time_step", "Category", "Tested",
                         "success", "method", "operation", "time_seconds", "value1", "value2",
                         "extracted_satellite_image", "zonal_mean_precipitation_raster",
                         "county_name", "state_name", "geometry", "site_id", "lon", "lat",
                         "watershed_id", "longitude", "latitude", "dataset_source",
                         "quality_category", "station_id", "Date", "TIME", "var1.pred",
                         "NDVI_enhanced", "NDVI_fallback", "crop_mask_binary", "crop_mask_preserve",
                         "NDWI_water_mask", "MNDWI_water_mask", "consensus_water_mask", "full_address"))
