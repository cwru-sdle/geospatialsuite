# Geocoding Examples and Use Cases

This file contains documented examples for the auto-geocoding
functionality. These examples demonstrate various use cases for the
auto_geocode_data function.

## Examples

``` r
if (FALSE) { # \dontrun{
# ========================================
# Example 1: State-level analysis
# ========================================
state_data <- data.frame(
  state = c("California", "TX", "New York", "FL"),
  gdp_billions = c(3598, 2357, 2053, 1389),
  population_millions = c(39.5, 29.1, 20.2, 22.2)
)

# Auto-detect and geocode
state_sf <- auto_geocode_data(state_data, verbose = TRUE)

# Visualize
quick_map(state_sf, variable = "gdp_billions",
          title = "GDP by State (Billions)")

# ========================================
# Example 2: County-level with FIPS codes
# ========================================
county_data <- data.frame(
  fips = c("39049", "39035", "39113", "39061"),
  county_name = c("Franklin", "Cuyahoga", "Montgomery", "Hamilton"),
  unemployment = c(4.2, 5.1, 4.8, 3.9)
)

county_sf <- auto_geocode_data(county_data)
quick_map(county_sf, variable = "unemployment")

# ========================================
# Example 3: Watershed analysis with HUC codes
# ========================================
# Works with ANY HUC format: HUC_8, HUC-8, huc8, Huc 8, etc.
watershed_data <- data.frame(
  HUC_8 = c("04100009", "04100012", "04110002"),
  basin_name = c("Great Miami", "Mill Creek-Cincinnati", "Middle Ohio"),
  water_quality_index = c(72, 65, 80),
  nitrogen_mg_l = c(2.3, 3.1, 1.8)
)

huc_sf <- auto_geocode_data(watershed_data, verbose = TRUE)
quick_map(huc_sf, variable = "water_quality_index",
          title = "Water Quality by Watershed")

# ========================================
# Example 4: ZIP code analysis
# ========================================
zip_data <- data.frame(
  zip = c("43215", "44113", "45202", "43017"),
  median_home_price = c(285000, 195000, 320000, 410000)
)

zip_sf <- auto_geocode_data(zip_data)
quick_map(zip_sf, variable = "median_home_price")

# ========================================
# Example 5: Loading from CSV file
# ========================================
# Assuming you have a CSV with state data
census_sf <- auto_geocode_data("state_census_data.csv", verbose = TRUE)
quick_map(census_sf)

# ========================================
# Example 6: Preview before geocoding
# ========================================
# Check what will be detected without actually geocoding
my_data <- data.frame(
  State = c("Ohio", "Michigan"),
  HUC8 = c("04100009", "04100012"),
  value = c(100, 200)
)

preview_geocoding(my_data)

# ========================================
# Example 7: Explicit column specification
# ========================================
# When auto-detection isn't working or you want to be explicit
data_with_weird_names <- data.frame(
  my_state_col = c("CA", "TX", "NY"),
  revenue = c(1000000, 800000, 1200000)
)

result <- auto_geocode_data(
  data_with_weird_names,
  entity_column = "my_state_col",
  entity_type = "state",
  verbose = TRUE
)

# ========================================
# Example 8: Integration with other geospatialsuite functions
# ========================================
# Geocode, then use with spatial analysis
state_sf <- auto_geocode_data(state_data)

# Use with universal_spatial_join
raster_data <- terra::rast("ndvi_data.tif")
result <- universal_spatial_join(
  source_data = state_sf,
  target_data = raster_data,
  method = "extract"
)

# Create comprehensive analysis
quick_map(result, variable = "extracted_mean_ndvi")
} # }
```
