# Create NDVI map visualization

Create NDVI map visualization

## Usage

``` r
create_ndvi_map(
  ndvi_data,
  region_boundary = NULL,
  ndvi_classes = "none",
  title = "NDVI Analysis",
  output_file = NULL
)
```

## Arguments

- ndvi_data:

  NDVI raster data

- region_boundary:

  Optional boundary for analysis

- ndvi_classes:

  Classification scheme for NDVI

- title:

  Plot title

- output_file:

  Optional output file path

## Value

Character string with output file path if saved, or NULL if plotted to
screen. Called primarily for side effects (creating plots).
