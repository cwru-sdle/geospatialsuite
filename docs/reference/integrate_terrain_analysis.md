# Integrate terrain analysis with vector data

Specialized function for terrain analysis integration. Calculates
terrain variables from DEM and extracts values to vector data
points/polygons.

## Usage

``` r
integrate_terrain_analysis(
  vector_data,
  elevation_raster,
  terrain_vars = c("slope", "aspect", "TRI", "TPI", "flowdir"),
  custom_terrain_functions = NULL,
  extraction_method = "simple"
)
```

## Arguments

- vector_data:

  Vector data (points, lines, or polygons)

- elevation_raster:

  Digital elevation model

- terrain_vars:

  Terrain variables to calculate

- custom_terrain_functions:

  Custom terrain analysis functions

- extraction_method:

  Method for extracting terrain values

## Value

sf object with terrain attributes

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
# Extract terrain variables for study sites
sites_with_terrain <- integrate_terrain_analysis(
  vector_data = "study_sites.shp",
  elevation_raster = "dem.tif",
  terrain_vars = c("slope", "aspect", "TRI", "TPI")
)

# Use custom terrain functions
custom_functions <- list(
  ruggedness = function(sf_data) {
    sf_data$slope * sf_data$TRI
  }
)

terrain_analysis <- integrate_terrain_analysis(
  vector_data = field_boundaries,
  elevation_raster = dem_raster,
  custom_terrain_functions = custom_functions
)
} # }
```
