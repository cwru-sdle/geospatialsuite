# Run comprehensive geospatial workflow -

Execute complete geospatial analysis workflows with simplified
visualization. to handle test cases and provide robust error handling
without complex dependencies.

## Usage

``` r
run_comprehensive_geospatial_workflow(analysis_config)
```

## Arguments

- analysis_config:

  List containing analysis configuration with required fields:

  - analysis_type: "ndvi_crop_analysis", "water_quality_analysis",
    "terrain_analysis", "temporal_analysis", "vegetation_comprehensive",
    "mosaic_analysis", "interactive_mapping"

  - input_data: Input data paths or objects

  - region_boundary: Region boundary specification

  - output_folder: Output directory (optional)

  - visualization_config: Visualization settings (optional)

## Value

List containing analysis results, visualizations, summary, and
configuration

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
# Simple NDVI crop analysis workflow
config <- list(
  analysis_type = "ndvi_crop_analysis",
  input_data = list(red = red_raster, nir = nir_raster),
  region_boundary = "Ohio",
  output_folder = "results/"
)
results <- run_comprehensive_geospatial_workflow(config)
} # }
```
