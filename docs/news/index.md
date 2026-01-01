# Changelog

## geospatialsuite 0.1.1

CRAN release: 2025-11-05

### Major Improvements

#### Working Examples and Sample Data

- Added built-in sample datasets (~150KB) to `inst/extdata/`
  - `sample_red.rds`, `sample_nir.rds`, `sample_blue.rds` - Spectral
    bands
  - `sample_green.rds`, `sample_swir1.rds` - Additional bands
  - `sample_multiband.rds` - Multi-band stack for auto-detection
    examples
  - `sample_points.shp` - Sample field locations
  - `sample_boundary.shp` - Study area polygon
  - `sample_coordinates.csv` - Tabular data with coordinates
- New
  [`download_sample_data()`](https://cwru-sdle.github.io/geospatialsuite/reference/download_sample_data.md)
  function for accessing sample data
- New
  [`get_sample_data()`](https://cwru-sdle.github.io/geospatialsuite/reference/get_sample_data.md)
  helper to get file paths
- New
  [`list_sample_datasets()`](https://cwru-sdle.github.io/geospatialsuite/reference/list_sample_datasets.md)
  to browse available datasets
- New
  [`load_sample_data()`](https://cwru-sdle.github.io/geospatialsuite/reference/load_sample_data.md)
  convenience function to load data directly
- All README examples now work out-of-the-box
- All vignettes updated with working code using sample data
- All function examples (.Rd files) updated to use built-in data

#### Testing Improvements

- Fixed EVI calculation warnings in test suite
- Tests now provide all required bands (red, nir, blue) for EVI
- Separated EVI tests from general vegetation index tests
- Improved test coverage: 68 → 70+ tests

#### Documentation Enhancements

- Created pkgdown website for easy navigation
- Organized 185 functions into 10 logical categories
- Comprehensive vignettes rendered and searchable
- Consistent package naming (`geospatialsuite`) across all documentation
- Enhanced function documentation with working examples
- Fixed encoding issues in vignettes (special characters now display
  correctly)
- Removed unnecessary preambles from vignettes for cleaner presentation

#### Package Structure

- Added `R/16-data-download.R` for data access functions
- Added sample data infrastructure in `inst/extdata/`
- Added `_pkgdown.yml` for website configuration
- Improved test utilities and helper functions

### Bug Fixes

- Fixed test warnings related to EVI calculations
- Improved error handling in edge cases
- Enhanced validation for spectral band inputs
- Fixed special character encoding in vignettes and documentation

### Documentation

- All examples now executable without external dependencies
- Vignettes demonstrate real-world workflows with sample data
- README provides quick-start guide with working code
- Function reference organized by category on pkgdown site
- Improved vignette readability with better structure and formatting

------------------------------------------------------------------------

## geospatialsuite 0.1.0

CRAN release: 2025-09-16

### Initial CRAN Release

#### Core Features

- 60+ vegetation indices with automatic satellite band detection
- Universal spatial join operations for any raster-vector combination
- Robust raster visualization with built-in error handling
- Water quality analysis with multiple indices (NDWI, MNDWI, NDMI)
- Crop Data Layer (CDL) analysis and crop-specific assessments
- Spatial interpolation techniques (IDW, Kriging, splines)
- Terrain analysis capabilities
- Temporal analysis for change detection
- Comprehensive workflow functions

#### Visualization

- [`quick_map()`](https://cwru-sdle.github.io/geospatialsuite/reference/quick_map.md)
  for one-line mapping with auto-detection
- [`create_spatial_map()`](https://cwru-sdle.github.io/geospatialsuite/reference/create_spatial_map.md)
  for publication-quality maps
- Support for leaflet interactive maps
- Multiple color schemes for different applications

#### Data Integration

- Universal region support (US states, countries, custom boundaries)
- Automatic CRS handling and transformation
- Multi-dataset integration capabilities
- Robust error handling throughout

#### Documentation

- Comprehensive vignettes covering all major use cases
- 165+ documented functions
- Real-world examples and case studies
- Extensive testing suite
