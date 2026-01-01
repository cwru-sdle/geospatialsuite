# Quick diagnostic check

Quick diagnostic to identify what might be wrong with the package.

## Usage

``` r
quick_diagnostic()
```

## Value

List containing diagnostic results with components:

- r_version:

  Character string of R version

- minimal_works:

  Logical indicating if basic functionality works

- function_status:

  Logical indicating function availability status

Called primarily for side effects (printing diagnostic messages).
