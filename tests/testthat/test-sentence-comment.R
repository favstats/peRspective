# key <- readr::read_lines("prsp.txt")

test_that("sentence choice works", {
  
  
  scored_text <- peRspective::prsp_score("I wanna test this real good.",
                          score_sentences = T,
                          score_model = peRspective::prsp_models)
  
  expect_equal(length(scored_text), 5)
})


test_that("text choice works", {
  
  scored_text <- peRspective::prsp_score("I wanna test this real good.",
                                         score_sentences = F,
                                         score_model = peRspective::prsp_models)
  
  expect_equal(nrow(scored_text), 1)
})


test_that("when sentence valid models", {
  
  scored_text <- peRspective::prsp_score("I wanna test this real good.",
                                         score_sentences = T,
                                         score_model = peRspective::prsp_models)
  
  model_valid <- scored_text$type %in% peRspective::prsp_models %>% all %>% as.numeric
  
  expect_equal(model_valid, 1)
})


test_that("when text valid models", {
  
  scored_text <- peRspective::prsp_score("I wanna test this real good.",
                                         score_sentences = F,
                                         score_model = peRspective::prsp_models)
  
  model_valid <- colnames(scored_text) %in% peRspective::prsp_models %>% all %>% as.numeric
  
  expect_equal(model_valid, 1)
})