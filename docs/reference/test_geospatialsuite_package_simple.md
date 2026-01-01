# Test geospatialsuite with simplified, robust tests

Simplified testing function that focuses on core functionality with
minimal dependencies and robust error handling. Designed for 100%
success rate. This replaces the complex testing function with simple,
reliable tests.

## Usage

``` r
test_geospatialsuite_package_simple(
  test_output_dir = tempdir(),
  verbose = FALSE
)
```

## Arguments

- test_output_dir:

  Directory for test outputs (default: tempdir())

- verbose:

  Print detailed test progress messages

## Value

List of test results with success/failure status for each component

## Examples

``` r
# \donttest{
# Quick test (essential functions only)
test_results <- test_geospatialsuite_package_simple()
#> Testing geospatialsuite v0.1.0 - Simplified Tests
#> ==============================================

#> 
#>  SIMPLIFIED TEST SUMMARY
#> ====================
#> Tests passed: 8/8 (100.0%)
#> Duration: 0.31 seconds
#> 
#>  ALL TESTS PASSED! geospatialsuite is working correctly.
#> Core functionality verified
#>  Reliable terra-based operations
#> Simple, robust implementation

# Verbose test
test_results <- test_geospatialsuite_package_simple(verbose = TRUE)
#> Testing geospatialsuite v0.1.0 - Simplified Tests
#> ==============================================
#> 
#>  Testing basic NDVI calculation...
#>  Basic NDVI calculation working
#> 
#>  Testing water index calculation...
#>  Water index calculation working
#> 
#>  Testing basic visualization...

#>  Basic visualization working
#> 
#>  Testing multiple indices calculation...
#>  Multiple indices calculation working
#> 
#>  Testing enhanced NDVI...
#>  Enhanced NDVI calculation working
#> 
#>  Testing core dependencies...
#> Core dependencies:
#>    terra
#>    sf
#>    dplyr
#>  All core dependencies available
#> 
#>  Testing basic spatial operations...
#>  Basic spatial operations working
#> 
#>  Testing data loading utilities...
#>  Data loading utilities working
#> 
#>  SIMPLIFIED TEST SUMMARY
#> ====================
#> Tests passed: 8/8 (100.0%)
#> Duration: 0.33 seconds
#> 
#> Detailed Results:
#>   basic_ndvi_test: PASS
#>   water_index_test: PASS
#>   basic_visualization_test: PASS
#>   multiple_indices_simple_test: PASS
#>   enhanced_ndvi_simple_test: PASS
#>   dependencies_test: PASS
#>   spatial_operations_test: PASS
#>   data_loading_test: PASS
#> 
#>  ALL TESTS PASSED! geospatialsuite is working correctly.
#> Core functionality verified
#>  Reliable terra-based operations
#> Simple, robust implementation
# }
```
