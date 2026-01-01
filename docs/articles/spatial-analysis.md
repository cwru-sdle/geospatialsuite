# Universal Spatial Mapping with geospatialsuite

------------------------------------------------------------------------

## Universal Spatial Mapping with geospatialsuite

This vignette demonstrates the powerful and flexible mapping
capabilities of geospatialsuite, including auto-detection mapping,
custom visualizations, and publication-quality outputs.

### Loading the Package

``` r
library(geospatialsuite)
library(terra)
library(sf)

# Check package functionality
test_package_minimal(verbose = TRUE)
#> [1] TRUE
```

### Quick Start: One-Line Mapping

The
[`quick_map()`](https://cwru-sdle.github.io/geospatialsuite/reference/quick_map.md)
function auto-detects your data type and creates appropriate
visualizations with minimal code:

``` r
# Create sample data for demonstration
sample_points <- data.frame(
  lon = c(-83.1, -83.2, -83.3, -82.9, -82.8),
  lat = c(40.1, 40.2, 40.3, 40.0, 40.4),
  ndvi = c(0.7, 0.8, 0.6, 0.75, 0.85),
  yield = c(150, 180, 120, 160, 200)
)

# One-line mapping with auto-detection
quick_map(sample_points)

# Quick map with specific variable
quick_map(sample_points, variable = "ndvi", title = "NDVI Distribution")

# Quick map with raster data (if available)
# quick_map("path/to/raster.tif")
```

### Universal Spatial Map Function

The
[`create_spatial_map()`](https://cwru-sdle.github.io/geospatialsuite/reference/create_spatial_map.md)
function provides comprehensive mapping with extensive customization
options:

#### Basic Point Mapping

``` r
# Convert sample data to sf object
sample_sf <- sf::st_as_sf(sample_points, 
                          coords = c("lon", "lat"), 
                          crs = 4326)

# Basic point map
basic_map <- create_spatial_map(
  spatial_data = sample_sf,
  fill_variable = "ndvi",
  map_type = "points",
  title = "Sample NDVI Points",
  verbose = TRUE
)

print(basic_map)
```

#### Custom Color Schemes

geospatialsuite provides specialized color schemes for different
applications:

``` r
# NDVI-specific colors
ndvi_map <- create_spatial_map(
  spatial_data = sample_sf,
  fill_variable = "ndvi",
  color_scheme = "ndvi",
  title = "NDVI with Specialized Colors"
)

# Terrain colors for elevation data
# terrain_map <- create_spatial_map(
#   spatial_data = elevation_data,
#   color_scheme = "terrain",
#   title = "Elevation Map"
# )

# Plasma colors for general data
plasma_map <- create_spatial_map(
  spatial_data = sample_sf,
  fill_variable = "yield",
  color_scheme = "plasma",
  title = "Yield with Plasma Colors"
)

print(plasma_map)
```

### Raster Mapping

#### Fast Raster Plotting

The
[`plot_raster_fast()`](https://cwru-sdle.github.io/geospatialsuite/reference/plot_raster_fast.md)
function provides efficient raster visualization using terra’s native
plotting:

``` r
# Create sample raster for demonstration
sample_raster <- terra::rast(nrows = 50, ncols = 50, 
                             xmin = -84, xmax = -82, 
                             ymin = 39, ymax = 41)
terra::values(sample_raster) <- runif(2500, 0.2, 0.9)
names(sample_raster) <- "NDVI"

# Fast raster plot
plot_raster_fast(
  raster_data = sample_raster,
  title = "Sample NDVI Raster",
  color_scheme = "ndvi"
)

# With custom breaks
plot_raster_fast(
  raster_data = sample_raster,
  title = "NDVI with Custom Classes",
  color_scheme = "ndvi",
  breaks = c(0, 0.3, 0.5, 0.7, 1.0)
)
```

#### RGB Composite Mapping

Create RGB composites from multi-band imagery:

``` r
# Create sample multi-band raster
red_band <- terra::rast(nrows = 30, ncols = 30, 
                        xmin = -84, xmax = -82, 
                        ymin = 39, ymax = 41)
terra::values(red_band) <- runif(900, 0.1, 0.3)

green_band <- red_band
terra::values(green_band) <- runif(900, 0.2, 0.4)

blue_band <- red_band
terra::values(blue_band) <- runif(900, 0.05, 0.15)

# Stack bands
rgb_stack <- c(red_band, green_band, blue_band)
names(rgb_stack) <- c("Red", "Green", "Blue")

# RGB composite plot
plot_rgb_raster(
  raster_data = rgb_stack,
  r = 1, g = 2, b = 3,
  stretch = "lin",
  title = "RGB Composite"
)

# False color composite
plot_rgb_raster(
  raster_data = rgb_stack,
  r = 2, g = 1, b = 3,  # Green-Red-Blue
  stretch = "hist",
  title = "False Color Composite"
)
```

### Interactive Mapping

Create interactive maps using leaflet integration:

``` r
# Interactive point map (requires leaflet package)
if (requireNamespace("leaflet", quietly = TRUE)) {
  interactive_map <- create_interactive_map(
    spatial_data = sample_sf,
    fill_variable = "ndvi",
    basemap = "terrain",
    title = "Interactive NDVI Map"
  )
  
  # Save interactive map
  # htmlwidgets::saveWidget(interactive_map, "interactive_ndvi.html")
}

# Interactive mapping with custom basemap
if (requireNamespace("leaflet", quietly = TRUE)) {
  satellite_map <- create_interactive_map(
    spatial_data = sample_sf,
    fill_variable = "yield",
    basemap = "satellite",
    title = "Yield on Satellite Imagery"
  )
}
```

### Regional Boundary Integration

#### Auto-Detection with Region Boundaries

``` r
# Simulate Ohio boundary for demonstration
ohio_boundary <- sf::st_polygon(list(matrix(c(
  -84.5, 38.5, -80.5, 38.5, -80.5, 42.0, -84.5, 42.0, -84.5, 38.5
), ncol = 2, byrow = TRUE)))
ohio_sf <- sf::st_sf(geometry = sf::st_sfc(ohio_boundary, crs = 4326))

# Map with region boundary
map_with_boundary <- create_spatial_map(
  spatial_data = sample_sf,
  fill_variable = "ndvi",
  region_boundary = ohio_sf,  # Would normally use "Ohio"
  title = "NDVI in Ohio",
  color_scheme = "ndvi"
)

print(map_with_boundary)

# The package supports many boundary types:
# create_spatial_map(data, region_boundary = "Ohio")          # US State
# create_spatial_map(data, region_boundary = "CONUS")         # Continental US
# create_spatial_map(data, region_boundary = "Ohio:Franklin") # State:County
# create_spatial_map(data, region_boundary = c(-84, 39, -82, 41)) # Bounding box
```

### Comparison Maps

Create side-by-side or difference maps for before/after analysis:

``` r
# Create "before" and "after" rasters
before_raster <- terra::rast(nrows = 30, ncols = 30, 
                             xmin = -84, xmax = -82, 
                             ymin = 39, ymax = 41)
terra::values(before_raster) <- runif(900, 0.3, 0.7)
names(before_raster) <- "NDVI_Before"

after_raster <- before_raster
terra::values(after_raster) <- terra::values(before_raster) + runif(900, -0.1, 0.2)
names(after_raster) <- "NDVI_After"

# Side-by-side comparison
create_comparison_map(
  data1 = before_raster,
  data2 = after_raster,
  comparison_type = "side_by_side",
  titles = c("Before Treatment", "After Treatment"),
  color_scheme = "ndvi"
)

# Difference map
create_comparison_map(
  data1 = before_raster,
  data2 = after_raster,
  comparison_type = "difference",
  titles = c("Before", "After"),
  color_scheme = "RdBu"
)
```

### Advanced Customization

#### Custom Color Palettes

``` r
# Get available color schemes
color_schemes <- c("viridis", "plasma", "ndvi", "terrain", "water", "categorical")

# Apply different schemes to the same data
for (scheme in color_schemes[1:3]) {
  map <- create_spatial_map(
    spatial_data = sample_sf,
    fill_variable = "ndvi",
    color_scheme = scheme,
    title = paste("NDVI with", scheme, "colors"),
    point_size = 4
  )
  
  print(paste("Created map with", scheme, "color scheme"))
}
```

#### Map Styling Options

``` r
# Customize point appearance
styled_map <- create_spatial_map(
  spatial_data = sample_sf,
  fill_variable = "yield",
  map_type = "points",
  point_size = 6,
  color_scheme = "plasma",
  title = "Customized Point Map"
)

print(styled_map)

# Map with transparent points
# (Demonstrated conceptually - actual implementation may vary)
```

### Publication-Quality Maps

#### High-Resolution Output

``` r
# Create high-resolution map for publication
publication_map <- create_spatial_map(
  spatial_data = sample_sf,
  fill_variable = "ndvi",
  color_scheme = "ndvi",
  title = "NDVI Distribution in Study Area",
  output_file = "publication_ndvi_map.png"
)

# Customize for journal specifications
journal_map <- create_spatial_map(
  spatial_data = sample_sf,
  fill_variable = "yield",
  color_scheme = "viridis",
  title = "",  # No title for journal figure
  output_file = "figure_1.png"
)
```

#### Map Layout and Legends

``` r
# The package automatically handles legends and layouts
# Maps include appropriate legends, scale bars, and formatting

# For complex layouts, combine with other packages:
# library(patchwork)  # For multi-panel figures
# library(ggplot2)    # For additional customization
```

### Error Handling and Troubleshooting

#### Common Issues and Solutions

``` r
# Test data validation
tryCatch({
  # This should work
  valid_map <- create_spatial_map(sample_sf, fill_variable = "ndvi")
  print("Valid map created successfully")
}, error = function(e) {
  print(paste("Error:", e$message))
})

# Handle missing data
sample_with_na <- sample_sf
sample_with_na$ndvi[1:2] <- NA

na_map <- create_spatial_map(
  spatial_data = sample_with_na,
  fill_variable = "ndvi",
  title = "Data with Missing Values"
)

print("Map with NA values handled automatically")
```

#### Diagnostic Functions

``` r
# Quick diagnostic check
diagnostic_result <- quick_diagnostic()

# Test specific mapping functions
mapping_test <- tryCatch({
  test_map <- create_spatial_map(sample_sf, fill_variable = "ndvi")
  "Mapping functions working"
}, error = function(e) {
  paste("Mapping error:", e$message)
})

print(mapping_test)
```

### Best Practices

#### 1. Data Preparation

``` r
# Always check your data first
print("Sample data structure:")
print(head(sample_sf))

# Verify coordinate reference system
print(paste("CRS:", sf::st_crs(sample_sf)$input))

# Check for valid geometries
valid_geoms <- sf::st_is_valid(sample_sf)
print(paste("Valid geometries:", all(valid_geoms)))
```

#### 2. Progressive Enhancement

``` r
# Start simple, then add complexity
simple_map <- quick_map(sample_sf)

# Add customization progressively
enhanced_map <- create_spatial_map(
  spatial_data = sample_sf,
  fill_variable = "ndvi",
  color_scheme = "ndvi",
  title = "Enhanced NDVI Map",
  point_size = 5
)

# Add interactivity if needed
# interactive_version <- create_interactive_map(sample_sf, fill_variable = "ndvi")
```

#### 3. Performance Optimization

``` r
# For large datasets, consider:
# 1. Simplifying geometries
# 2. Reducing point density
# 3. Using raster instead of vector for very dense data

# Example: Check data size
print(paste("Number of features:", nrow(sample_sf)))
print(paste("Number of variables:", ncol(sample_sf) - 1))  # Minus geometry

# For large rasters, use terra's efficient plotting
if (exists("sample_raster")) {
  print(paste("Raster dimensions:", paste(dim(sample_raster), collapse = " x ")))
}
```

### Integration with Other Packages

#### ggplot2 Integration

``` r
# geospatialsuite maps work well with ggplot2
library(ggplot2)

# Extract ggplot object for further customization
base_map <- create_spatial_map(sample_sf, fill_variable = "ndvi")

# Customize with ggplot2 (if the map is a ggplot object)
if (inherits(base_map, "ggplot")) {
  enhanced_ggplot <- base_map +
    theme_minimal() +
    labs(caption = "Data source: Field measurements") +
    theme(
      plot.title = element_text(size = 16, face = "bold"),
      legend.position = "bottom"
    )
}
```

#### Leaflet Integration

``` r
# For interactive web maps
if (requireNamespace("leaflet", quietly = TRUE)) {
  web_map <- create_interactive_map(
    spatial_data = sample_sf,
    fill_variable = "ndvi",
    popup_vars = c("ndvi", "yield"),
    basemap = "terrain"
  )
  
  # Further customize with leaflet functions
  enhanced_web_map <- web_map %>%
    leaflet::addMiniMap() %>%
    leaflet::addScaleBar()
}
```

### Specialized Mapping Functions

#### NDVI Mapping

``` r
# Create sample NDVI raster
ndvi_raster <- terra::rast(nrows = 40, ncols = 40, 
                           xmin = -84, xmax = -82, 
                           ymin = 39, ymax = 41)
terra::values(ndvi_raster) <- runif(1600, 0.1, 0.9)
names(ndvi_raster) <- "NDVI"

# Specialized NDVI visualization
ndvi_map <- create_ndvi_map(
  ndvi_data = ndvi_raster,
  title = "NDVI Analysis",
  ndvi_classes = "none"  # Use continuous colors
)

print("NDVI map created with specialized colors")
```

#### Water Quality Mapping

``` r
# Create sample water quality data
water_points <- data.frame(
  lon = c(-83.0, -83.1, -83.2, -82.9, -82.8),
  lat = c(40.0, 40.1, 40.2, 39.9, 40.3),
  dissolved_oxygen = c(8.2, 7.5, 6.8, 8.9, 7.1),
  temperature = c(18.5, 19.2, 20.1, 17.8, 19.5)
)

water_sf <- sf::st_as_sf(water_points, 
                         coords = c("lon", "lat"), 
                         crs = 4326)

# Water quality visualization
water_map <- create_water_quality_plot(
  water_data = water_sf,
  variable = "dissolved_oxygen",
  title = "Dissolved Oxygen Levels"
)
```

### Export Options

#### Static Map Export

``` r
# High-resolution PNG export
create_spatial_map(
  spatial_data = sample_sf,
  fill_variable = "ndvi",
  color_scheme = "ndvi",
  title = "NDVI Distribution",
  output_file = "high_res_ndvi.png"
)

# PDF export for vector graphics
create_spatial_map(
  spatial_data = sample_sf,
  fill_variable = "yield",
  color_scheme = "viridis",
  title = "Yield Distribution",
  output_file = "yield_map.pdf"
)
```

#### Interactive Map Export

``` r
# Export interactive map as HTML
if (requireNamespace("leaflet", quietly = TRUE)) {
  interactive_map <- create_interactive_map(
    spatial_data = sample_sf,
    fill_variable = "ndvi",
    title = "Interactive NDVI Map"
  )
  
  # Save as HTML file
  if (requireNamespace("htmlwidgets", quietly = TRUE)) {
    htmlwidgets::saveWidget(
      interactive_map,
      "interactive_ndvi_map.html",
      selfcontained = TRUE
    )
  }
}
```

### Advanced Features

#### Multi-Layer Visualization

``` r
# Create comparison visualization
create_comparison_map(
  data1 = sample_raster,
  data2 = sample_raster * 1.2,  # Simulated change
  comparison_type = "side_by_side",
  titles = c("Year 1", "Year 2"),
  color_scheme = "ndvi"
)
```

#### Automatic Map Type Detection

``` r
# The package automatically detects appropriate mapping approaches

# Point data -> scatter plot with colors
point_auto <- create_spatial_map(
  spatial_data = sample_sf,
  fill_variable = "ndvi",
  map_type = "auto"  # Auto-detects as points
)

# Raster data -> raster plot
raster_auto <- create_spatial_map(
  spatial_data = sample_raster,
  map_type = "auto"  # Auto-detects as raster
)

print("Auto-detection completed successfully")
```

### Performance Tips

#### For Large Datasets

``` r
# 1. Use terra plotting for speed
plot_raster_fast(sample_raster, title = "Fast Plotting")

# 2. Simplify data when appropriate
# simplified_sf <- sf::st_simplify(complex_sf, dTolerance = 100)

# 3. Use appropriate map types
# For very dense points, consider raster interpolation
# For large rasters, consider aggregation

# 4. Monitor memory usage
print(paste("Sample data memory usage:", 
            format(object.size(sample_sf), units = "KB")))
```

#### Memory Management

``` r
# Clean up large objects when done
# rm(large_raster)
# gc()  # Garbage collection

# Use temporary files for intermediate results
temp_file <- tempfile(fileext = ".tif")
print(paste("Temporary file:", temp_file))

# For very large analyses, process in chunks
# chunk_size <- 1000  # Adjust based on available memory
```

### Troubleshooting Common Issues

#### CRS Mismatches

``` r
# Check CRS compatibility
sample_utm <- sf::st_transform(sample_sf, crs = 3857)  # Web Mercator

# The package handles CRS automatically in most cases
mixed_crs_map <- create_spatial_map(
  spatial_data = sample_utm,  # UTM coordinates
  fill_variable = "ndvi",
  title = "Map with Different CRS"
)

print("CRS handling completed automatically")
```

#### Data Format Issues

``` r
# Test with different data formats
formats_test <- list(
  sf_object = sample_sf,
  data_frame = sample_points,
  raster_object = sample_raster
)

for (format_name in names(formats_test)) {
  tryCatch({
    test_map <- quick_map(formats_test[[format_name]])
    print(paste(format_name, "format: OK"))
  }, error = function(e) {
    print(paste(format_name, "format error:", e$message))
  })
}
```

### Summary

geospatialsuite’s mapping capabilities provide:

1.  **Auto-detection**:
    [`quick_map()`](https://cwru-sdle.github.io/geospatialsuite/reference/quick_map.md)
    for instant visualization
2.  **Flexibility**: Support for points, polygons, lines, and rasters
3.  **Customization**: Multiple color schemes and styling options
4.  **Interactivity**: Optional leaflet integration
5.  **Publication quality**: High-resolution export options
6.  **Regional integration**: Automatic boundary handling
7.  **Performance**: Efficient terra-based rendering

#### Key Functions Summary

- [`quick_map()`](https://cwru-sdle.github.io/geospatialsuite/reference/quick_map.md):
  One-line mapping with auto-detection
- [`create_spatial_map()`](https://cwru-sdle.github.io/geospatialsuite/reference/create_spatial_map.md):
  Comprehensive mapping with customization
- [`plot_raster_fast()`](https://cwru-sdle.github.io/geospatialsuite/reference/plot_raster_fast.md):
  Efficient raster visualization
- [`plot_rgb_raster()`](https://cwru-sdle.github.io/geospatialsuite/reference/plot_rgb_raster.md):
  RGB composite mapping
- [`create_interactive_map()`](https://cwru-sdle.github.io/geospatialsuite/reference/create_interactive_map.md):
  Web-based interactive maps
- [`create_comparison_map()`](https://cwru-sdle.github.io/geospatialsuite/reference/create_comparison_map.md):
  Before/after comparisons
- [`create_ndvi_map()`](https://cwru-sdle.github.io/geospatialsuite/reference/create_ndvi_map.md):
  Specialized vegetation mapping

The mapping system is designed to work reliably with minimal
dependencies while providing extensive customization when needed.

### Acknowledgments

This work was developed by the geospatialsuite team with contributions
from: Olatunde D. Akanbi, Erika I. Barcelos, and Roger H. French.
