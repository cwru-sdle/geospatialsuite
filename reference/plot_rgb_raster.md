# Create multi-band raster RGB plot

Create RGB plots from multi-band rasters using terra's native RGB
plotting. Reliable and fast without external dependencies.

## Usage

``` r
plot_rgb_raster(
  raster_data,
  r = 1,
  g = 2,
  b = 3,
  stretch = "lin",
  title = "RGB Composite",
  output_file = NULL,
  verbose = FALSE
)
```

## Arguments

- raster_data:

  Multi-band SpatRaster or file path

- r:

  Red band index (default: 1)

- g:

  Green band index (default: 2)

- b:

  Blue band index (default: 3)

- stretch:

  Stretch method: "lin", "hist", "minmax", "perc"

- title:

  Plot title

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
# True color composite
plot_rgb_raster(satellite_data, r = 3, g = 2, b = 1, title = "True Color")

# False color composite with histogram stretch
plot_rgb_raster(landsat_data, r = 4, g = 3, b = 2, stretch = "hist",
               title = "False Color Composite", output_file = "rgb_composite.png")
} # }
```
