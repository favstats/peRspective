test_that("score_model has been supplied", {
  
  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  

  testthat::expect_error(peRspective::prsp_score("Hello, I am a testbot", score_model = NULL))

})

Sys.sleep(1)


test_that("invalid score_model throws error", {
  
  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  

  testthat::expect_error(peRspective::prsp_score("Hello, I am a testbot", score_model = "NOT_A_MODEL"))

})

Sys.sleep(1)

test_that("specifying a valid model works", {
  
  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  

  tox <- peRspective::prsp_score("Hello, I am a testbot",
                          score_model = "TOXICITY")

  expect_equal(length(tox), 1)
})

Sys.sleep(1)

test_that("you can't specify a faster rate limit than 0.7 per second", {
  
  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  

  testthat::expect_error(peRspective::prsp_score("Hello, I am a testbot",
                                                 score_model = "TOXICITY",
                                                 sleep = 0.1))

})

Sys.sleep(1)

test_that("you can't specify a faster rate limit than 0.7 per second", {
  
  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  

  score <- peRspective::prsp_score("Hello, I am a testbot",
                                   score_model = "TOXICITY",
                                   languages = "en")

  expect_equal(length(score), 1)
})

Sys.sleep(1)


test_that("an error is thrown when no valid text", {
  
  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  

  testthat::expect_error(peRspective::prsp_score("",
                                                 score_model = "TOXICITY"))

})


Sys.sleep(1)

test_that("text_id is valid", {
  
  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  

  score <- peRspective::prsp_score("Hello, I am a testbot",
                                   score_model = "TOXICITY",
                                   text_id = "my_text_id")



  expect_true(any(colnames(score) == "text_id"))
})


test_that("score_sentences works", {
  
  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  
  
  score <- peRspective::prsp_score("Hello, I am a testbot",
                                   score_model = "TOXICITY",
                                   score_sentences = T)
  
  
  expect_true(any(colnames(score) == "sentence_scores"))
})
