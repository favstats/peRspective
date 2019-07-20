test_that("specifying decimal works", {
  
  score <- specify_decimal(20, 2)
  
  expect_equal(nchar(score), 5)
})

