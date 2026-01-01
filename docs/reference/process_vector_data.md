# Process vector data from data frame

Process vector data from data frame

Process vector data from data frame

## Usage

``` r
process_vector_data(
  data_input,
  coord_cols = c("lon", "lat"),
  try_geocoding = TRUE,
  verbose = FALSE
)

process_vector_data(
  data_input,
  coord_cols = c("lon", "lat"),
  try_geocoding = TRUE,
  verbose = FALSE
)
```

## Arguments

- data_input:

  Data frame with potential coordinate columns OR geographic entities

- coord_cols:

  Coordinate column names

- try_geocoding:

  Attempt to geocode if no coordinates found (default: TRUE)

- verbose:

  Print messages

## Value

sf object
