# Validate numeric range

Validate numeric range

## Usage

``` r
validate_numeric_range(
  x,
  min_val = NULL,
  max_val = NULL,
  param_name = "parameter",
  allow_null = FALSE
)
```

## Arguments

- x:

  Numeric value to validate

- min_val:

  Minimum allowed value

- max_val:

  Maximum allowed value

- param_name:

  Parameter name for error messages

- allow_null:

  Allow NULL values

## Value

TRUE if valid, stops with error if invalid
