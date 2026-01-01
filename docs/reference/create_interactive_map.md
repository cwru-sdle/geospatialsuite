# Create interactive map using leaflet (if available)

Create interactive maps with leaflet integration when available. Falls
back gracefully when leaflet is not installed.

## Usage

``` r
create_interactive_map(
  spatial_data,
  fill_variable = NULL,
  popup_vars = NULL,
  basemap = "terrain",
  color_scheme = "viridis",
  title = "Interactive Map",
  verbose = FALSE
)
```

## Arguments

- spatial_data:

  Spatial data to map (sf object)

- fill_variable:

  Variable for coloring/filling

- popup_vars:

  Variables to show in popups

- basemap:

  Basemap type: "terrain", "satellite", "osm", "light"

- color_scheme:

  Color scheme for continuous variables

- title:

  Map title

- verbose:

  Print progress messages

## Value

leaflet map object or NULL if leaflet unavailable

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples demonstrate workflows with user's own spatial data
# Simple interactive point map
map <- create_interactive_map(study_sites, fill_variable = "ndvi_mean")

# Polygon map with custom basemap
map <- create_interactive_map(counties, fill_variable = "population",
                             basemap = "satellite")
} # }
```
