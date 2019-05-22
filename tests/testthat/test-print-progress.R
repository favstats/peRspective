testthat::test_that("you can print progress", {
  
  score <- print_progress(1, 100)
  
  expect_true(stringr::str_detect(score, "1 out of 100"))
})


testthat::test_that("you can print percentage", {
  
  score <- print_progress(1, 100, print_prct = T)
  
  expect_true(stringr::str_detect(score, "1.00%"))
})
