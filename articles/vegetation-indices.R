## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 8,
  fig.height = 6,
  warning = FALSE,
  message = FALSE,
  eval = TRUE
)

## ----load-packages------------------------------------------------------------
library(geospatialsuite)
library(terra)

## ----quick-start--------------------------------------------------------------
# Load sample spectral bands
red <- load_sample_data("sample_red.rds")
nir <- load_sample_data("sample_nir.rds")
blue <- load_sample_data("sample_blue.rds")

# Calculate NDVI using geospatialsuite
ndvi <- calculate_vegetation_index(
  red = red,
  nir = nir,
  index_type = "NDVI"
)

# Visualize
plot(ndvi, main = "Normalized Difference Vegetation Index (NDVI)",
     col = terrain.colors(100))

## ----ndvi-example-------------------------------------------------------------
# Calculate NDVI with geospatialsuite
ndvi <- calculate_vegetation_index(
  red = red,
  nir = nir,
  index_type = "NDVI"
)

# Summary statistics
summary(values(ndvi))

# Classify vegetation density
vegetation_classes <- classify(ndvi,
  rcl = matrix(c(-Inf, 0.2, 1,
                 0.2, 0.6, 2,
                 0.6, Inf, 3), 
               ncol = 3, byrow = TRUE)
)

plot(vegetation_classes, 
     main = "Vegetation Density Classes",
     col = c("brown", "yellow", "darkgreen"),
     legend = FALSE)
legend("topright", 
       legend = c("Sparse", "Moderate", "Dense"),
       fill = c("brown", "yellow", "darkgreen"))

## ----evi-example--------------------------------------------------------------
# Calculate EVI using geospatialsuite
evi <- calculate_vegetation_index(
  red = red,
  nir = nir,
  blue = blue,
  index_type = "EVI"
)

# Compare NDVI and EVI
par(mfrow = c(1, 2))
plot(ndvi, main = "NDVI", col = terrain.colors(100))
plot(evi, main = "EVI", col = terrain.colors(100))
par(mfrow = c(1, 1))

## ----savi-example-------------------------------------------------------------
# Calculate SAVI with geospatialsuite
savi <- calculate_vegetation_index(
  red = red,
  nir = nir,
  index_type = "SAVI"
)

plot(savi, main = "Soil Adjusted Vegetation Index (SAVI)",
     col = terrain.colors(100))

## ----multiple-indices---------------------------------------------------------
# geospatialsuite can calculate multiple indices at once
indices <- calculate_multiple_indices(
  red = red,
  nir = nir,
  blue = blue,
  indices = c("NDVI", "EVI", "SAVI", "GNDVI", "NDRE"),
  output_stack = TRUE
)

# Plot all indices
plot(indices, main = names(indices))

# Access individual indices
ndvi_layer <- indices$NDVI
evi_layer <- indices$EVI

## ----multiband-workflow-------------------------------------------------------
# Load multi-band raster
multiband <- load_sample_data("sample_multiband.rds")

# Check available bands
names(multiband)

# geospatialsuite's auto-detect feature
ndvi_auto <- calculate_vegetation_index(
  spectral_data = multiband,
  index_type = "NDVI",
  auto_detect_bands = TRUE  # Automatically finds red and nir!
)

# Calculate multiple indices with auto-detection
indices_auto <- calculate_multiple_indices(
  spectral_data = multiband,
  indices = c("NDVI", "EVI", "GNDVI"),
  auto_detect_bands = TRUE,
  output_stack = TRUE
)

## ----landsat-example, eval=FALSE----------------------------------------------
# # Use geospatialsuite with Landsat imagery
# 
# # 1. Load Landsat bands using geospatialsuite
# landsat_bands <- load_raster_data(
#   "landsat/LC08_L2SP_021033_20240715/",
#   pattern = "SR_B[2-5].TIF$",
#   verbose = TRUE
# )
# 
# # geospatialsuite validates and loads all bands
# # Extract individual bands (assuming they're scaled to 0-1)
# blue <- landsat_bands[[1]]
# green <- landsat_bands[[2]]
# red <- landsat_bands[[3]]
# nir <- landsat_bands[[4]]
# 
# # 2. Calculate indices using geospatialsuite
# # It has 60+ pre-programmed indices
# landsat_indices <- calculate_multiple_indices(
#   red = red,
#   nir = nir,
#   blue = blue,
#   green = green,
#   indices = c("NDVI", "EVI", "SAVI", "GNDVI", "MSAVI", "OSAVI"),
#   output_stack = TRUE
# )
# 
# # 3. Visualize using geospatialsuite
# quick_map(landsat_indices$NDVI, title = "Landsat 8 NDVI")

## ----sentinel-example, eval=FALSE---------------------------------------------
# # Use geospatialsuite with Sentinel-2
# 
# # 1. Load Sentinel-2 bands using geospatialsuite
# s2_bands <- load_raster_data(
#   "sentinel2/S2A_MSIL2A_20240715/GRANULE/.../IMG_DATA/R10m/",
#   pattern = "*_B0[2-8]_10m.jp2$",
#   verbose = TRUE
# )
# 
# # geospatialsuite handles JPEG2000 format
# # Assuming bands are ordered: blue, green, red, nir
# # and scaled to 0-1
# 
# # 2. Calculate comprehensive indices with geospatialsuite
# s2_indices <- calculate_multiple_indices(
#   red = s2_bands[[3]],
#   nir = s2_bands[[4]],
#   blue = s2_bands[[1]],
#   green = s2_bands[[2]],
#   indices = c("NDVI", "EVI", "SAVI", "GNDVI", "NDMI"),
#   output_stack = TRUE
# )
# 
# # 3. Visualize
# quick_map(s2_indices$NDVI, title = "Sentinel-2 NDVI (10m)")

## ----multitemporal-example, eval=FALSE----------------------------------------
# # Track vegetation changes with geospatialsuite
# 
# # Load imagery from different dates
# dates <- c("2024-05-01", "2024-06-01", "2024-07-01")
# ndvi_series <- list()
# 
# for (date in dates) {
#   # Load bands for each date using geospatialsuite
#   bands <- load_raster_data(
#     sprintf("satellite/%s/", date),
#     pattern = "B[4-5].tif$"
#   )
# 
#   red_date <- bands[[1]]
#   nir_date <- bands[[2]]
# 
#   # Calculate NDVI using geospatialsuite
#   ndvi_series[[date]] <- calculate_vegetation_index(
#     red = red_date,
#     nir = nir_date,
#     index_type = "NDVI"
#   )
# }
# 
# # Stack time series
# ndvi_stack <- rast(ndvi_series)
# names(ndvi_stack) <- dates
# 
# # Visualize temporal progression
# plot(ndvi_stack, main = paste("NDVI -", dates))
# 
# # Calculate change
# ndvi_change <- ndvi_stack[[3]] - ndvi_stack[[1]]
# plot(ndvi_change,
#      main = "NDVI Change (Jul - May)",
#      col = colorRampPalette(c("red", "white", "green"))(100))

## ----chlorophyll-indices------------------------------------------------------
# Green NDVI - sensitive to chlorophyll content
green <- load_sample_data("sample_green.rds")

# Calculate using geospatialsuite
gndvi <- calculate_vegetation_index(
  green = green,
  nir = nir,
  index_type = "GNDVI"
)

plot(gndvi, main = "Green NDVI - Chlorophyll Indicator",
     col = colorRampPalette(c("white", "lightgreen", "darkgreen"))(100))

## ----water-content------------------------------------------------------------
# Load SWIR band for water content analysis
swir1 <- load_sample_data("sample_swir1.rds")

# NDMI using geospatialsuite
ndmi <- calculate_vegetation_index(
  nir = nir,
  swir1 = swir1,
  index_type = "NDMI"
)

plot(ndmi, main = "Vegetation Water Content (NDMI)",
     col = colorRampPalette(c("brown", "yellow", "blue"))(100))

## ----zonal-stats--------------------------------------------------------------
# Load sample boundary
boundary <- load_sample_data("sample_boundary.rds")

# Calculate NDVI using geospatialsuite
ndvi <- calculate_vegetation_index(red = red, nir = nir, index_type = "NDVI")

# Extract statistics for the region
stats <- terra::extract(ndvi, vect(boundary), fun = function(x) {
  c(mean = mean(x, na.rm = TRUE),
    sd = sd(x, na.rm = TRUE),
    min = min(x, na.rm = TRUE),
    max = max(x, na.rm = TRUE))
})

print(stats)

## ----field-analysis-----------------------------------------------------------
# Load sample field points
field_points <- load_sample_data("sample_points.rds")

# Calculate NDVI using geospatialsuite
ndvi <- calculate_vegetation_index(red = red, nir = nir, index_type = "NDVI")

# Extract using geospatialsuite's spatial join
field_ndvi <- universal_spatial_join(
  source_data = field_points,
  target_data = ndvi,
  method = "extract"
)

# View results
head(field_ndvi)

## ----real-field-data, eval=FALSE----------------------------------------------
# # Complete field analysis workflow with geospatialsuite
# 
# library(sf)
# 
# # 1. Load field boundaries
# fields <- sf::st_read("farm_data/field_boundaries.shp")
# 
# # 2. Load and process satellite data using geospatialsuite
# satellite_bands <- load_raster_data(
#   "satellite/imagery/",
#   pattern = "B[2-5].tif$"
# )
# 
# # 3. Calculate indices using geospatialsuite
# indices <- calculate_multiple_indices(
#   red = satellite_bands[[3]],
#   nir = satellite_bands[[4]],
#   blue = satellite_bands[[1]],
#   green = satellite_bands[[2]],
#   indices = c("NDVI", "EVI", "GNDVI", "SAVI"),
#   output_stack = TRUE
# )
# 
# # 4. Extract to fields using geospatialsuite
# fields_with_indices <- universal_spatial_join(
#   source_data = fields,
#   target_data = indices,
#   method = "extract"
# )
# 
# # geospatialsuite extracted all 4 indices
# # Each field now has mean NDVI, EVI, GNDVI, SAVI
# names(fields_with_indices)
# 
# # 5. Visualize using geospatialsuite
# quick_map(fields_with_indices, variable = "NDVI")

## ----list-indices-------------------------------------------------------------
# View all available vegetation indices in geospatialsuite
all_indices <- list_vegetation_indices()

# Show first few indices
head(all_indices[, c("Index", "Category", "Description", "Required_Bands")], 10)

# Filter by category
health_indices <- all_indices[all_indices$Category == "basic", ]
print(health_indices[, c("Index", "Description")])

## ----quality-check------------------------------------------------------------
# Check for valid value ranges
ndvi <- calculate_vegetation_index(red = red, nir = nir, index_type = "NDVI")

# NDVI should be between -1 and 1
ndvi_stats <- global(ndvi, fun = "range", na.rm = TRUE)
cat("NDVI range:", ndvi_stats[1,1], "to", ndvi_stats[2,1], "\n")

