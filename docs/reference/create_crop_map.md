# Create crop map visualization

Create crop map visualization

## Usage

``` r
create_crop_map(
  cdl_data,
  crop_selection,
  region_boundary = NULL,
  style = "categorical",
  output_file = NULL
)
```

## Arguments

- cdl_data:

  CDL raster data

- crop_selection:

  Selected crop types

- region_boundary:

  Optional boundary for cropping

- style:

  Visualization style

- output_file:

  Optional output file path

## Value

Character string with output file path if saved, or NULL if plotted to
screen. Called primarily for side effects (creating plots).
