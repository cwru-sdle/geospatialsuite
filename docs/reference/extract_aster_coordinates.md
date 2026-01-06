# Extract coordinates from ASTER filename

Internal function to extract lat/lon coordinates from ASTER filenames.
Supports both ASTER GDEM (ASTGTMV003) and WBD (ASTWBDV001) formats.

## Usage

``` r
extract_aster_coordinates(filename, boundingbox = FALSE)
```

## Arguments

- filename:

  ASTER filename (e.g., "ASTGTMV003_N40W084_dem.tif" or
  "ASTWBDV001_N40W084_dem.tif")

- boundingbox:

  Logical. If TRUE, returns bounding box coordinates instead of centroid

## Value

List with coordinates (lat/lon if boundingbox=FALSE, or
lat_min/lat_max/lon_min/lon_max if boundingbox=TRUE), or NULL if pattern
not matched
