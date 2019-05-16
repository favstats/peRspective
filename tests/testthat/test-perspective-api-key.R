test_that("key assignment works", {

  key <- perspective_api_key()

  expect_true(nchar(key) != 0)
})


test_that("key assignment throws error when empty", {
  
  expect_error(prsp_score(text = "Hello I should fail!", 
             score_model = "TOXICITY",
             key = "THIS_IS_NOT_A_KEY"),
             regexp = "API key not valid. Please pass a valid API key.")

})

#