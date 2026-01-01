# Load raster data from various sources

Universal function to load raster data from files, directories, or
raster objects with comprehensive error handling and validation.

## Usage

``` r
load_raster_data(
  input_data,
  pattern = "\\.(tif|tiff)$",
  recursive = FALSE,
  verbose = FALSE
)
```

## Arguments

- input_data:

  Character string (path to file or directory), character vector of file
  paths, or a SpatRaster/Raster\* object

- pattern:

  File pattern for directory search (default: tif files)

- recursive:

  Search subdirectories recursively

- verbose:

  Print progress messages

## Value

List of terra SpatRaster objects

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require directory structures with multiple data files
# Load from directory with error handling
rasters <- load_raster_data("/path/to/raster/files")

# Load from file list with validation
rasters <- load_raster_data(c("file1.tif", "file2.tif"))
} # }
```
