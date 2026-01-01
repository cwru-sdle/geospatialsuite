# Create fast raster plot using terra

Create efficient raster plots using terra's native plotting
capabilities. Fast and reliable without external dependencies.

## Usage

``` r
plot_raster_fast(
  raster_data,
  title = "Raster Plot",
  color_scheme = "viridis",
  region_boundary = NULL,
  breaks = NULL,
  output_file = NULL,
  verbose = FALSE
)
```

## Arguments

- raster_data:

  SpatRaster to plot or file path

- title:

  Plot title

- color_scheme:

  Color scheme to apply

- region_boundary:

  Optional boundary to overlay

- breaks:

  Custom breaks for classification

- output_file:

  Optional output file path

- verbose:

  Print progress messages

## Value

NULL (plots directly to device) or file path if saved

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples demonstrate workflows with user's own spatial data
# Simple raster plot
plot_raster_fast(ndvi_raster, "NDVI Analysis", "ndvi")

# With custom breaks and save to file
plot_raster_fast(elevation, "Elevation", "terrain",
                breaks = c(0, 500, 1000, 1500, 2000),
                output_file = "elevation_map.png")
} # }
```
