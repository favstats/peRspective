text_sample <- tibble::tibble(
  ctext = c("You wrote this? Wow. This is dumb and childish, please go f**** yourself.",
            "I don't know what to say about this but it's not good. The commenter is just an idiot",
            "This goes even further!",
            "What the hell is going on?",
            
            
            
            "Please. I don't get it. Explain it again",
            
            
            "Annoying and irrelevant! I'd rather watch the paint drying on the wall!"),
  textid = c("#efdcxct", "#ehfcsct",
             "#ekacxwt",  "#ewatxad",
             "#ekacswt",  "#ewftxwd")
)

test_that("error thrown when no text_id column", {
  
  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  

  expect_error(text_sample %>%
    prsp_stream(text = ctext,
                score_model = c("TOXICITY", "SEVERE_TOXICITY")))

})



test_that("error thrown when no text column", {
  
  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  

  expect_error(text_sample %>%
                 prsp_stream(text_id = textid,
                             score_model = c("TOXICITY", "SEVERE_TOXICITY")))

})

text_sample <- tibble::tibble(
  ctext = c("You wrote this? Wow. This is dumb and childish, please go f**** yourself.",
            "I don't know what to say about this but it's not good. The commenter is just an idiot",
            "This goes even further!",
            "What the hell is going on?",
            "Please. I don't get it. Explain it again",
            "Annoying and irrelevant! I'd rather watch the paint drying on the wall!"),
  textid = c("#efdcxct", NA,
             "#ekacxwt",  "#ewatxad",
             "#ekacswt",  "#ewftxwd")
)

test_that("error thrown when NAs in text_id column", {
  
  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  

  expect_error(text_sample %>%
                 prsp_stream(text = ctext,
                             text_id = textid,
                             score_model = c("TOXICITY", "SEVERE_TOXICITY")))

})


text_sample <- tibble::tibble(
  ctext = c("You wrote this? Wow. This is dumb and childish, please go f**** yourself.",
            "I don't know what to say about this but it's not good. The commenter is just an idiot",
            NA,
            "What the hell is going on?",
            "Please. I don't get it. Explain it again",
            "Annoying and irrelevant! I'd rather watch the paint drying on the wall!"),
  textid = c("#efdcxct", "#whatnow",
             "#ekacxwt",  "#ewatxad",
             "#ekacswt",  "#ewftxwd")
)

test_that("error thrown when NAs in text column", {

  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  

  expect_error(text_sample %>%
                 prsp_stream(text = ctext,
                             text_id = textid,
                             score_model = c("TOXICITY", "SEVERE_TOXICITY")))

})

text_sample <- tibble::tibble(
  ctext = c("You wrote this? Wow. This is dumb and childish, please go f**** yourself.",
            "I don't know what to say about this but it's not good. The commenter is just an idiot",
            "Never question the righteousness of his actions!",
            "What the hell is going on?",
            "Please. I don't get it. Explain it again",
            "Annoying and irrelevant! I'd rather watch the paint drying on the wall!"),
  textid = c("#efdcxct", "#whatnow",
             "#ekacxwt",  "#ewatxad",
             "#ekacswt",  "#ewftxwd")
) %>%
  dplyr::bind_rows(., .)


test_that("error thrown when not unqiue text_id column", {

  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  

  expect_error(text_sample %>%
                 prsp_stream(text = ctext,
                             text_id = textid,
                             score_model = c("TOXICITY", "SEVERE_TOXICITY")))

})

text_sample <- tibble::tibble(
  ctext = c("You wrote this? Wow. This is dumb and childish, please go f**** yourself.",
            "I don't know what to say about this but it's not good. The commenter is just an idiot",
            "This goes even further!",
            "What the hell is going on?",
            "Please. I don't get it. Explain it again",
            "Annoying and irrelevant! I'd rather watch the paint drying on the wall!"),
  textid = c("#efdcxct", "#ehfcsct",
             "#ekacxwt",  "#ewatxad",
             "#ekacswt",  "#ewftxwd")
)

test_that("supplying valid arguments works", {
  
  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  

  score <- text_sample %>%
    prsp_stream(text = ctext,
                text_id = textid,
                score_model = c("TOXICITY", "SEVERE_TOXICITY"))

  expect_equal(length(score), 3)
})

text_sample <- tibble::tibble(
  ctext = c("You wrote this? Wow. This is dumb and childish, please go f**** yourself.",
            "I don't know what to say about this but it's not good. The commenter is just an idiot",
            ## empty string
            "",
            "This goes even further!",
            "What the hell is going on?",
            "Please. I don't get it. Explain it again",
            ## Gibberish
            "kdlfkmgkdfmgkfmg",
            "Annoying and irrelevant! I'd rather watch the paint drying on the wall!",
            ## Gibberish
            "Hippi Hoppo"),
  textid = c("#efdcxct", "#ehfcsct",
             "#ekacxwt",  "#ewatxad",
             "#ekacswt",  "#ewftxwd",
             "#eeadswt",  "#enfhxed",
             "#efdmjd")
)


test_that("errors are thrown when invalid text is supplied", {

  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  

  expect_error(text_sample %>%
    prsp_stream(text = ctext,
                text_id = textid,
                score_model = c("TOXICITY", "SEVERE_TOXICITY")))

})

test_that("errors are thrown when invalid text is supplied with safe_output true", {

  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  


  score <- text_sample[1:3,] %>%
    prsp_stream(text = ctext,
                text_id = textid,
                score_model = c("TOXICITY", "SEVERE_TOXICITY", "INSULT"),
                safe_output = T)

  
  expect_equal(length(score), 5)

})


test_that("verbose and safe_output work together", {

  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  


  score <- text_sample[1:3,] %>%
    prsp_stream(text = ctext,
                text_id = textid,
                score_model = c("TOXICITY", "SEVERE_TOXICITY"),
                verbose = T,
                safe_output = T)

  expect_equal(length(score), 4)

})


test_that("verbose, score_sentences and safe_output work together", {

  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  


  score <- text_sample[1:3,] %>%
    prsp_stream(text = ctext,
                text_id = textid,
                score_model = c("TOXICITY", "SEVERE_TOXICITY"),
                score_sentences = T,
                verbose = T,
                safe_output = T)

  expect_equal(length(score), 7)

})



test_that("verbose, score_sentences but no safe_output work together", {

  testthat::skip_if(Sys.getenv("perspective_api_key") == "", 
                    message = "perspective_api_key not available in environment. Skipping test.")
  


  score <- text_sample[1:2,] %>%
    prsp_stream(text = ctext,
                text_id = textid,
                score_model = c("TOXICITY", "SEVERE_TOXICITY"),
                score_sentences = T,
                verbose = T,
                safe_output = F)

  expect_equal(length(score), 6)

})

