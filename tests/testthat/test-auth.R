key <- readr::read_lines("prsp.txt")

Sys.setenv(perspective_api_key = key)

test_that("sentence key authorization works without specifying key", {
  
  scored_text <- peRspective::prsp_score("I wanna test this real good.",
                                         score_sentences = T,
                                         score_model = peRspective::prsp_models)
  
  model_valid <- scored_text$type %in% peRspective::prsp_models %>% all %>% as.numeric
  
  expect_equal(model_valid, 1)
})

test_that("text key authorization works without specifying key", {
  
  scored_text <- peRspective::prsp_score("I wanna test this real good.",
                                         score_sentences = F,
                                         score_model = peRspective::prsp_models)
  
  model_valid <- colnames(scored_text) %in% peRspective::prsp_models %>% all %>% as.numeric
  
  expect_equal(model_valid, 1)
})

