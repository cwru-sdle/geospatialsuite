# Create universal spatial map with reliable terra plotting

Universal mapping function that works with any spatial data type using
reliable terra and base R plotting. No complex dependencies required.
Falls back gracefully when optional packages are unavailable.

## Usage

``` r
create_spatial_map(
  spatial_data,
  fill_variable = NULL,
  coord_cols = c("lon", "lat"),
  region_boundary = NULL,
  map_type = "auto",
  color_scheme = "viridis",
  interactive = FALSE,
  title = NULL,
  point_size = 3,
  output_file = NULL,
  verbose = FALSE
)
```

## Arguments

- spatial_data:

  sf object, data.frame with coordinates, file path, or SpatRaster

- fill_variable:

  Variable to use for fill/color (for vector data)

- coord_cols:

  Coordinate column names if data.frame provided

- region_boundary:

  Optional region boundary

- map_type:

  Type of map: "points", "polygons", "raster", "auto"

- color_scheme:

  Color scheme: "viridis", "plasma", "ndvi", "terrain", "categorical"

- interactive:

  Create interactive map using leaflet (if available)

- title:

  Map title

- point_size:

  Size of points (for point data)

- output_file:

  Optional output file path

- verbose:

  Print progress messages

## Value

ggplot2 object, leaflet map, or file path (depending on options)

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
# Simple point map
create_spatial_map(study_sites, fill_variable = "ndvi_mean")

# Raster map with region boundary
create_spatial_map(ndvi_raster, region_boundary = "Ohio",
                  color_scheme = "ndvi")

# Interactive map (if leaflet available)
create_spatial_map(counties, fill_variable = "population",
                  interactive = TRUE)
} # }
```
