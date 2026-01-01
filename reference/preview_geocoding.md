# Preview geographic entity detection

Test what geographic entities will be detected in your data without
actually performing the geocoding. Useful for debugging and
verification.

## Usage

``` r
preview_geocoding(data, show_sample = TRUE, n_sample = 5)
```

## Arguments

- data:

  Data frame to analyze

- show_sample:

  Show sample values (default: TRUE)

- n_sample:

  Number of sample values to show (default: 5)

## Value

List with detection results

## Examples

``` r
if (FALSE) { # \dontrun{
# Check what will be detected
my_data <- data.frame(
  HUC_8 = c("04100009", "04100012"),
  State = c("Ohio", "PA"),
  value = c(100, 200)
)

preview_geocoding(my_data)
} # }
```
