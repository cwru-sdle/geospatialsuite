# Contributing to GeoSpatialSuite

Thank you for your interest in contributing to GeoSpatialSuite! We
welcome contributions from the community.

## How to Contribute

### Reporting Issues

- Use the [GitHub
  Issues](https://github.com/cwru-sdle/geospatialsuite/issues) page
- Provide a minimal reproducible example
- Include your R version and package version
- Describe expected vs actual behavior

### Suggesting Enhancements

- Open an issue with the “enhancement” label
- Clearly describe the proposed feature
- Explain the use case and benefits

### Pull Requests

1.  Fork the repository
2.  Create a new branch (`git checkout -b feature/your-feature`)
3.  Make your changes
4.  Add tests for new functionality
5.  Update documentation as needed
6.  Ensure all tests pass: `devtools::test()`
7.  Submit a pull request

### Code Style

- Follow standard R package conventions
- Use roxygen2 for documentation
- Include examples in function documentation
- Add unit tests for new functions

### Testing

Run the test suite before submitting:

``` r
library(devtools)
devtools::test()
test_geospatialsuite_package_simple()
```

## Code of Conduct

We are committed to providing a welcoming and inclusive experience for
everyone. Please be respectful and professional in all interactions.

## Questions?

Contact the maintainers: - Olatunde D. Akanbi:
<olatunde.akanbi@case.edu> - Roger H. French: <roger.french@case.edu>

## License

By contributing, you agree that your contributions will be licensed
under the MIT License.
