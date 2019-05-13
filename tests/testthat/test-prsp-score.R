test_that("score_model has been supplied", {

  testthat::expect_error(peRspective::prsp_score("Hello, I am a testbot", score_model = NULL))

})


test_that("invalid score_model throws error", {

  testthat::expect_error(peRspective::prsp_score("Hello, I am a testbot", score_model = "NOT_A_MODEL"))

})


test_that("specifying a valid model works", {

  tox <- peRspective::prsp_score("Hello, I am a testbot",
                          score_model = "TOXICITY")

  expect_equal(length(tox), 1)
})


test_that("you can't specify a faster rate limit than 0.7 per second", {

  testthat::expect_error(peRspective::prsp_score("Hello, I am a testbot",
                                                 score_model = "TOXICITY",
                                                 sleep = 0.1))

})


test_that("you can't specify a faster rate limit than 0.7 per second", {

  score <- peRspective::prsp_score("Hello, I am a testbot",
                                   score_model = "TOXICITY",
                                   languages = "en")

  expect_equal(length(score), 1)
})



test_that("an error is thrown when no valid text", {

  testthat::expect_error(peRspective::prsp_score("",
                                                 score_model = "TOXICITY"))

})



test_that("text_id is valid", {

  score <- peRspective::prsp_score("Hello, I am a testbot",
                                   score_model = "TOXICITY",
                                   text_id = "my_text_id")



  expect_true(any(colnames(score) == "text_id"))
})
