test_that("key assignment works", {
  
  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  

  key <- perspective_api_key()

  expect_true(nchar(key) != 0)
})


test_that("key assignment throws error when invalid key supplied", {
  
  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")

  expect_error(prsp_score(text = "Hello I should fail!",
             score_model = "TOXICITY",
             key = "THIS_IS_NOT_A_KEY"),
             regexp = "API key not valid. Please pass a valid API key.")

})

test_that("key assignment throws error when empty", {


  expect_error(perspective_api_key(test = T))


})

#