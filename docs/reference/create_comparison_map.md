# Create comparison map (before/after, side-by-side)

Create comparison maps showing before/after analysis or side-by-side
comparisons using reliable terra plotting.

## Usage

``` r
create_comparison_map(
  data1,
  data2,
  comparison_type = "side_by_side",
  titles = c("Dataset 1", "Dataset 2"),
  region_boundary = NULL,
  color_scheme = "viridis",
  output_file = NULL,
  verbose = FALSE
)
```

## Arguments

- data1:

  First dataset (before, reference)

- data2:

  Second dataset (after, comparison)

- comparison_type:

  Type: "side_by_side", "difference"

- titles:

  Titles for each dataset

- region_boundary:

  Optional region boundary

- color_scheme:

  Color scheme for datasets

- output_file:

  Optional output file path

- verbose:

  Print progress messages

## Value

NULL (plots directly to device) or file path if saved

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
# Before/after NDVI comparison
create_comparison_map("ndvi_2020.tif", "ndvi_2023.tif",
                     comparison_type = "side_by_side",
                     titles = c("2020", "2023"),
                     output_file = "ndvi_comparison.png")
} # }
```
