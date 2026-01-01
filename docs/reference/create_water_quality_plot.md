# Create water quality plot

Create water quality plot

## Usage

``` r
create_water_quality_plot(
  water_data,
  variable,
  region_boundary = NULL,
  river_network = NULL,
  thresholds = NULL,
  output_file = NULL
)
```

## Arguments

- water_data:

  Water quality spatial data

- variable:

  Variable to visualize

- region_boundary:

  Optional boundary for analysis

- river_network:

  Optional river network overlay

- thresholds:

  Quality thresholds for visualization

- output_file:

  Optional output file path

## Value

Character string with output file path if saved, or NULL if plotted to
screen. Called primarily for side effects (creating plots).
