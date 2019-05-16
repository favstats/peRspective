globalVariables("prsp_models")
globalVariables("prsp_exp_models")


#' Analyze comments with Perspective API
#'
#' Provide a character string with your text, your API key and what scores you want to obtain.
#'
#' For more details see `?peRspective` or [Perspective API documentation](https://github.com/conversationai/perspectiveapi/blob/master/api_reference.md)
#'
#' @md
#' @param text a character string.
#' @param text_id a unique ID for the text that you supply (required).
#' @param score_model Specify what model do you want to use (for example `TOXICITY` and/or `SEVERE_TOXICITY`). Specify a character vector if you want more than one score. See `peRspective::prsp_models`.
#' @param score_sentences A boolean value that indicates if the request should return spans that describe the scores for each part of the text (currently done at per sentence level). Defaults to `FALSE`.
#' @param languages A vector of [ISO 631-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) two-letter language codes specifying the language(s) that comment is in (for example, "en", "es", "fr", "de", etc). If unspecified, the API will autodetect the comment language. If language detection fails, the API returns an error.
#' @param sleep how long should `prsp_score` wait between each call
#' @param doNotStore Whether the API is permitted to store comment from this request. Stored comments will be used for future research and community model building purposes to improve the API over time. Perspective API also plans to provide dashboards and automated analysis of the comments submitted, which will apply only to those stored. Defaults to `FALSE` (request data may be stored). Important note: This should be set to true if data being submitted is private (i.e. not publicly accessible), or if the data submitted contains content written by someone under 13 years old.
#' @param key Your API key ([see here](https://github.com/conversationai/perspectiveapi/blob/master/quickstart.md) to set up an API key).
#' @return a `tibble`
#' @examples
#' \dontrun{
#' ## GET TOXICITY SCORES for a comment
#' prsp_score("Hello, I am a test comment!",
#'            score_model = "TOXICITY")
#'            
#' ## GET TOXICITY and SEVERE_TOXICITY Scores for a comment
#' prsp_score("Hello, I am a test comment!",
#'            score_model = c("TOXICITY", "SEVERE_TOXICITY))
#'   
#' ## GET TOXICITY and SEVERE_TOXICITY Scores for each sentence of a comment
#' prsp_score("Hello, I am a test comment! 
#'            I am a second sentence and I will (hopefully) be scored seperately",
#'            score_model = c("TOXICITY", "SEVERE_TOXICITY),
#'            score_sentences = T)
#' }
#' @export
prsp_score <- function(text, text_id = NULL, 
                       languages = NULL, score_sentences = F, 
                       score_model, sleep = 1, doNotStore = F, 
                       key = NULL) {
  
  if (is.null(score_model)) {
    stop(stringr::str_glue("No Model type provided in score_model.\n\nShould be one of the following:\n\n{peRspective::prsp_models %>% glue::glue_collapse('\n')}"))
  }
  
  if (!all(score_model %in% prsp_models | score_model %in% prsp_exp_models)) {
    stop(stringr::str_glue("Invalid Model type provided.\n\nShould be one of the following:\n\n{peRspective::prsp_models %>% glue::glue_collapse('\n')}"))
  }
  
  if (sleep <= 0.7) {
    stop("Sleeps below 0.7s are sure to hit the ratelimit")
  }
  
  Sys.sleep(sleep)
  

  

  analyze_request <- form_request(score_model, text, score_sentences, languages)
  # return(analyze_request)
  
  if (is.null(key)) {
    key <- perspective_api_key()
  }
  # browser()
  
  result <- httr::POST(stringr::str_glue("https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key={key}"),
                       body = analyze_request,
                       httr::add_headers(.headers = c("Content-Type"="application/json")))
  
  Output <- httr::content(result)
  
  if (any(stringr::str_detect(Output %>% names(), "error"))) {
    stop(stringr::str_glue("HTTP {Output$error$code}\n{Output$error$status}: {Output$error$message}"))
  }
  

  
  ## cleaning
  final_dat <- unnest_scores(Output,
                             score_model,
                             score_sentences,
                             text)
  
  ## in case there is a text_id
  if (!is.null(text_id)) {
    final_dat <- final_dat %>% 
      dplyr::mutate(text_id = text_id) %>% 
      dplyr::select(text_id, dplyr::everything())
  }
  
  return(final_dat)
}




unnest_scores <- function(Output, score_model, score_sentences, text){
  if (!score_sentences) {
    final_dat <- score_model %>%
      purrr::map(
        ~{
          Output %>%
            purrr::map(.x) %>%
            purrr::map("spanScores") %>%
            magrittr::extract2(1) %>%
            purrr::map("score") %>%
            purrr::map("value") %>%
            unlist() %>%
            purrr::set_names(.x) %>%
            dplyr::bind_rows()
        }
      ) %>%
      dplyr::bind_cols()    
  } else if (score_sentences) {
    final_dat <- score_model %>%
      purrr::map(
        ~{
          
          # .x <- "TOXICITY"
          
          spanscores <- Output %>%
            purrr::map(.x) %>%
            purrr::map("spanScores") %>%
            magrittr::extract2(1) 
          
          begin <- spanscores %>% 
            purrr::map("begin") %>% 
            unlist()
          
          end <- spanscores %>% 
            purrr::map("end") %>% 
            unlist()
          
          score <- spanscores %>%
            purrr::map("score") %>%
            purrr::map("value") %>% 
            unlist()
          
          summary_score <- Output %>%
            purrr::map(.x) %>% 
            purrr::map("summaryScore")%>%
            purrr::map("value") %>% 
            unlist()
          
          spans <- spanscores %>% length
          
          # browser()
          
          final <- dplyr::tibble(begin, end, score, summary_score, spans, .x) %>% 
            dplyr::rename(type = .x) %>%
            dplyr::mutate(sentences = stringr::str_sub(text, start = begin, end = end) %>% stringr::str_trim())
          
          final <- final[1,] %>% 
            dplyr::mutate(sentence_scores = list(final %>% dplyr::select(-summary_score:-type))) %>% 
            dplyr::select(-begin:-score, -sentences) %>% 
            dplyr::mutate(text = text)
          
          return(final)
        }
      ) %>%
      purrr::set_names(score_model) %>% #-> ss 
      dplyr::bind_rows()
    
    return(final_dat)
  }
}



# browser()

# score_model <- c("TOXICITY", "SEVERE_TOXICITY", "FLIRTATION")
# score_model <- prsp_models
# languages <- "en"
# score_sentences <- T

# score_model <- "SEVERE_TOXICITY_EXPERIMENTAL"
# text <- "ICH HABE WAS GESAGT? das glaube ich ja mal gar nicht!"

form_request <- function(score_model, 
                         text, 
                         score_sentences, 
                         languages,
                         doNotStore = F) {
  
  model_list <- score_model %>%
    purrr::map(
      ~{list(x = NULL) %>% purrr::set_names(.x)}
    ) %>%
    purrr::flatten()
  
  # model_list %>% jsonlite::toJSON()
  
  analyze_request <- list(
    comment = list(text = text),
    spanAnnotations = score_sentences,
    requestedAttributes = model_list,
    doNotStore = doNotStore
  ) 
  
  if (!is.null(languages)) {
    analyze_request <- rlist::list.append(analyze_request, languages = languages)
  }
  
  
  analyze_request <- analyze_request %>%
    jsonlite::toJSON(auto_unbox = T)   
  
  return(analyze_request)
}

# form_request("TOXICITY", "hall", score_sentences = F, languages = "EN", T)

# library(peRspective)


# prsp_score("Hello, I am a testbot",
#            score_sentences = T,
#            score_model = "TOXICITY", doNotStore = F)
