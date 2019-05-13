test_that("key assignment works", {

  key <- perspective_api_key()

  expect_true(nchar(key) != 0)
})


# test_that("key assignment throws error when empty", {
#
#   Sys.setenv(perspective_api_key = "")
#
#   expect_error(perspective_api_key())
#
# })

#