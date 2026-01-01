# Extract dates from filenames using various patterns

Universal function to extract dates from filenames or provide custom
labels. Enhanced with more flexible regex patterns that work with any
filename prefix.

## Usage

``` r
extract_dates_universal(input_data, date_patterns = NULL, verbose = FALSE)
```

## Arguments

- input_data:

  Character vector (file paths or folder), or list of raster layers

- date_patterns:

  Named list of custom regex patterns for date extraction

- verbose:

  Print progress messages

## Value

Character vector of extracted or inferred date labels

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
# Extract dates from filenames
dates <- extract_dates_universal(c("ndvi_2023-05-15.tif", "evi_2023-06-15.tif"))

# Custom date patterns
custom_patterns <- list("MMDDYYYY" = "\\b[0-9]{2}[0-9]{2}[0-9]{4}\\b")
dates <- extract_dates_universal(files, custom_patterns)
} # }
```
