# geospatialsuite: Comprehensive Geospatiotemporal Analysis and Multimodal Integration Toolkit

geospatialsuite provides universal functions for geospatial analysis and
reliable visualization that work with any region for multimodal data.
Features include 60+ vegetation indices, efficient terra-based
visualization, universal spatial mapping, dynamic crop analysis, water
quality assessment, and publication-quality mapping with support for any
geographic region and robust error handling.

## Details

### Key Features:

#### Universal Spatial Analysis:

- Universal region support (states, countries, CONUS, custom boundaries)

- Universal spatial join (works with ANY raster-vector combination)

- Multi-dataset integration and temporal analysis

- Spatial interpolation and terrain analysis

#### Advanced Vegetation Analysis:

- **60+ vegetation indices** including NDVI, EVI, SAVI, ARVI, PRI, SIPI,
  etc.

- **Specialized crop analysis** with stress detection and yield
  assessment

- **Auto band detection** from multi-band satellite imagery

- **Quality filtering** and temporal smoothing for time series

#### Reliable Visualization:

- **Universal mapping** with auto-detection
  ([`quick_map()`](https://cwru-sdle.github.io/geospatialsuite/reference/quick_map.md)
  function)

- **Terra-based plotting** using reliable terra::plot() and
  terra::plotRGB()

- **Interactive maps** with leaflet integration (optional)

- **RGB composites** with stretching algorithms

- **Comparison maps** for before/after analysis

#### Agricultural Applications:

- **Dynamic CDL crop analysis** (all crop codes and categories)

- **NDVI time series** with classification

- **Crop-specific analysis** (corn, soybeans, wheat, etc.)

- **Water quality assessment** with threshold analysis

#### Performance & Reliability Features:

- **Standard terra plotting** - no complex dependencies required

- **Robust error handling** throughout all functions

- **Simplified visualization** for maps

- **Smart fallback systems** when optional packages unavailable

### Quick Start Examples:

    # One-line mapping (auto-detects everything!)
    quick_map("mydata.shp")

    # Auto-geocode data without coordinates
    census_data <- data.frame(
      state = c("Ohio", "Pennsylvania", "Michigan"),
      median_income = c(58642, 61744, 59584)
    )
    spatial_data <- auto_geocode_data(census_data)
    quick_map(spatial_data, variable = "median_income")

    # Works with HUC codes too (any format: HUC_8, HUC-8, huc8)
    watershed_data <- data.frame(
      HUC_8 = c("04100009", "04100012"),
      water_quality = c(72, 65)
    )
    huc_spatial <- auto_geocode_data(watershed_data)
    quick_map(huc_spatial)

    # Calculate multiple vegetation indices
    indices <- calculate_multiple_indices(
      red = red_band, nir = nir_band,
      indices = c("NDVI", "EVI", "SAVI", "PRI")
    )

    # Comprehensive crop analysis
    crop_analysis <- analyze_crop_vegetation(
      spectral_data = sentinel_data,
      crop_type = "corn",
      analysis_type = "comprehensive"
    )

    # Enhanced NDVI calculation
    ndvi_enhanced <- calculate_ndvi_enhanced(
      red_data = red_raster,
      nir_data = nir_raster,
      quality_filter = TRUE
    )

    # Fast, reliable RGB plotting
    plot_rgb_raster(satellite_data, r = 4, g = 3, b = 2,
                   stretch = "hist", title = "False Color")

### Recommended Optional Packages:

For enhanced features, consider installing these optional packages:

    # For interactive mapping
    install.packages("leaflet")

    # For enhanced colors
    install.packages(c("viridis", "RColorBrewer"))

    # For advanced remote sensing (optional)
    install.packages("RStoolbox")

    # For multi-panel plots (optional)
    install.packages("patchwork")

### Core Dependencies Only:

The package works reliably with just the core dependencies:

- terra (raster operations and plotting)

- sf (vector operations)

- ggplot2 (static mapping)

- dplyr (data manipulation)

No complex visualization dependencies required!

## See also

Useful links:

- <https://cwru-sdle.github.io/geospatialsuite/>

- <https://github.com/cwru-sdle/geospatialsuite>

- Report bugs at <https://github.com/cwru-sdle/geospatialsuite/issues>

## Author

Olatunde D. Akanbi <olatunde.akanbi@case.edu>

Erika I. Barcelos <erika.barcelos@case.edu>

Roger H. French <roger.french@case.edu>
