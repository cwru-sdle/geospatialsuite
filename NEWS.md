# GeoSpatialSuite 0.1.0

## Major Features

### Vegetation Analysis
- 60+ vegetation indices including NDVI, EVI, SAVI, ARVI, PRI, SIPI
- Enhanced NDVI calculation with quality filtering
- Multiple indices calculation in single operation
- Automatic band detection from multi-band rasters
- Support for Landsat, Sentinel-2, and MODIS platforms

### Spatial Operations
- Universal spatial join system (vector-raster, raster-raster, vector-vector)
- Automatic CRS handling and reprojection
- Comprehensive error handling and validation
- Memory-efficient processing for large datasets
- Support for multiple input formats (.tif, .shp, .gpkg, .geojson, .nc)

### Water Analysis
- Water detection indices (NDWI, MNDWI, NDMI, MSI)
- Water quality assessment with threshold analysis
- Specialized moisture and stress indices

### Visualization
- Universal mapping with `quick_map()` auto-detection
- Terra-based plotting (reliable, minimal dependencies)
- RGB composite creation with stretching algorithms
- Interactive mapping with leaflet integration (optional)
- Publication-quality static maps

### Agricultural Applications
- Dynamic Cropland Data Layer (CDL) analysis
- Crop-specific analysis (corn, soybeans, wheat, etc.)
- NDVI time series with classification
- Stress detection and yield assessment

### Reliability Features
- Robust error handling throughout all functions
- Smart fallback systems for optional dependencies
- Comprehensive testing suite
- Simplified workflow design
- Performance optimization for large datasets

## Technical Details

### Dependencies
- **Required**: terra, sf, ggplot2, dplyr, stats, utils
- **Optional**: leaflet, viridis, RColorBrewer, rnaturalearth, tigris

### System Requirements
- R >= 3.5.0
- GDAL >= 3.0 (through terra package)
- PROJ >= 6.0 (through sf package)

### Performance
- Optimized for large raster processing
- Parallel processing support where applicable
- Memory-efficient algorithms
- Chunked processing for massive datasets

## Functions Added

### Core Functions
- `calculate_vegetation_index()` - Single vegetation index calculation
- `calculate_multiple_indices()` - Multiple indices at once
- `calculate_ndvi_enhanced()` - Enhanced NDVI with quality filtering
- `calculate_water_index()` - Water and moisture indices
- `universal_spatial_join()` - Comprehensive spatial operations
- `quick_map()` - One-line universal mapping
- `create_spatial_map()` - Advanced mapping with customization

### Utility Functions
- `list_vegetation_indices()` - Browse available indices
- `get_region_boundary()` - Load administrative boundaries
- `load_raster_data()` - Robust raster loading
- `process_vector_data()` - Vector data processing
- `test_geospatialsuite_package_simple()` - Package testing

### Agricultural Functions
- `analyze_crop_vegetation()` - Comprehensive crop analysis
- `get_cdl_data()` - Cropland Data Layer integration
- `calculate_crop_stress()` - Stress detection algorithms

### Advanced Functions
- `spatial_interpolation()` - Spatial interpolation methods
- `temporal_analysis()` - Time series analysis
- `terrain_analysis()` - Topographic analysis
- `workflow_analysis()` - Automated analysis workflows

## Known Issues
- None at release

## Future Plans
- Additional vegetation indices based on user feedback
- Enhanced time series analysis capabilities
- Integration with more satellite data sources
- Advanced machine learning applications
- Cloud processing integration

---

**Funding**: This material is based upon financial support by the National Science Foundation, EEC Division of Engineering Education and Centers, NSF Engineering Research Center for Advancing Sustainable and Distributed Fertilizer production (CASFER), NSF 20-553 Gen-4 Engineering Research Centers award 2133576.
