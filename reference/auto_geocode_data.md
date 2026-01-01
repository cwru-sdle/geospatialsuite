# Auto-geocode data with geographic identifiers

Automatically detects and geocodes data containing US geographic
identifiers (states, counties, FIPS codes, HUC watershed codes, ZIP
codes, or city names) without requiring latitude/longitude coordinates.

## Usage

``` r
auto_geocode_data(
  data,
  detect_columns = TRUE,
  entity_column = NULL,
  entity_type = NULL,
  verbose = TRUE
)
```

## Arguments

- data:

  Data frame, file path (CSV, shapefile, etc.), or sf object

- detect_columns:

  Auto-detect geographic entity columns (default: TRUE)

- entity_column:

  Explicitly specify the column containing geographic entities
  (optional)

- entity_type:

  Explicitly specify entity type: "state", "county", "fips", "huc",
  "zipcode", "city" (optional)

- verbose:

  Print detailed progress messages

## Value

sf object with geocoded point or polygon geometries

## Details

Supported geographic entities:

- **States**: Full names or 2-letter abbreviations (e.g., "Ohio", "OH")

- **Counties**: County names, optionally with state

- **FIPS codes**: 5-digit Federal Information Processing Standards codes

- **HUC codes**: Hydrologic Unit Codes (HUC8, HUC10, HUC12)

- **ZIP codes**: 5-digit US postal codes

- **Cities**: City names, works best with state column

Column name variations supported:

- HUC columns: HUC_8, HUC-8, huc8, Huc 8, etc.

- State columns: State, STATE, state_name, StateName, ST, etc.

- All entity types handle spaces, hyphens, underscores, and mixed case

Required packages (installed automatically when needed):

- `tigris`: For US Census boundaries (states, counties, FIPS)

- `nhdplusTools`: For HUC watershed boundaries

- `zipcodeR`: For ZIP code centroids

- `tidygeocoder`: For city name geocoding

## Examples

``` r
if (FALSE) { # \dontrun{
# Auto-detect and geocode - simplest usage
geodata <- auto_geocode_data("mydata.csv")

# With state names
state_data <- data.frame(
  state = c("California", "Texas", "New York"),
  population = c(39538223, 29145505, 20201249)
)
state_sf <- auto_geocode_data(state_data)

# With FIPS codes
fips_data <- data.frame(
  fips = c("39049", "39035", "39113"),  # Ohio counties
  unemployment_rate = c(4.2, 3.8, 5.1)
)
county_sf <- auto_geocode_data(fips_data)

# With HUC codes (handles various formats)
watershed_data <- data.frame(
  HUC_8 = c("04100009", "04100012", "04110002"),
  water_quality_index = c(72, 65, 80)
)
huc_sf <- auto_geocode_data(watershed_data)

# Explicit specification
zip_sf <- auto_geocode_data(
  my_data,
  entity_column = "postal_code",
  entity_type = "zipcode"
)

# Then use with your other geospatialsuite functions
quick_map(state_sf, variable = "population")
} # }
```
