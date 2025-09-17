# Test the main package testing functions
# ===================================================================

test_that("package testing functions work", {
  # Test the minimal test function
  expect_no_error({
    suppressMessages({
      result <- test_package_minimal(verbose = FALSE)
    })
  })

  expect_type(result, "logical")
})

test_that("function availability check works", {
  expect_no_error({
    suppressMessages({
      result <- test_function_availability(verbose = FALSE)
    })
  })

  expect_type(result, "list")
  expect_true("function_status" %in% names(result))
})
