#' Analyze comments with Perspective API
#'
#' Provide a character string with your text, your API key and what scores you want to obtain.
#'
#' For more detail see Perspective API documentation: https://github.com/conversationai/perspectiveapi/blob/master/api_reference.md
#'
#' @md
#' @param text a character string.
#' @param languages A vector of [ISO 631-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) two-letter language codes specifying the language(s) that comment is in (for example, "en", "es", "fr", "de", etc). If unspecified, the API will autodetect the comment language. If language detection fails, the API returns an error.
#' @param score_sentences A boolean value that indicates if the request should return spans that describe the scores for each part of the text (currently done at per sentence level). Defaults to `FALSE`.
#' @param key Your API key ([see here](https://github.com/conversationai/perspectiveapi/blob/master/quickstart.md) to set up an API key).
#' @param score_model Specify what model do you want to use (for example `TOXICITY` and/or `SEVERE_TOXICITY`). Specify a character vector if you want more than one score. See `peRspective::prsp_models`.
#' @return a `tibble`
#' @export
prsp_score <- function(text, languages = NULL, score_sentences = F, key, score_model, sleep = 1) {

  if (!all(score_model %in% prsp_models)) {
    stop(stringr::str_glue("Invalid Model type provided.\n\nShould be one of the following:\n\n{peRspective::prsp_models %>% glue::glue_collapse('\n')}"))
  }
  
  Sys.sleep(sleep)

  # browser()
  
  # score_model <- c("TOXICITY", "SEVERE_TOXICITY")
  # score_model <- prsp_models
  # languages <- "es"
  # score_sentences <- T

  model_list <- score_model %>%
    purrr::map(
      ~{list(x = NULL) %>% purrr::set_names(.x)}
    ) %>%
    purrr::flatten()
  
  
  analyze_request <- list(
    comment = list(text = text),
    spanAnnotations = score_sentences,
    requestedAttributes = model_list
  ) 

  if (!is.null(languages)) {
    analyze_request <- rlist::list.append(analyze_request, languages = languages)
  }
  
  analyze_request <- analyze_request %>%
    jsonlite::toJSON(auto_unbox = T)
  
  result <- httr::POST(stringr::str_glue("https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key={key}"),
                 body = analyze_request,
                 httr::add_headers(.headers = c("Content-Type"="application/json")))

  Output <- httr::content(result)
  
  if (any(str_detect(Output %>% names(), "error"))) {
    stop(str_glue("HTTP {Output$error$code}\n{Output$error$status}: {Output$error$message}"))
  }
  
  ## cleaning
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
          
          final <- dplyr::tibble(begin, end, score, summary_score, spans, .x) %>% 
            dplyr::rename(type = .x) %>%
            dplyr::mutate(sentences = stringr::str_sub(text, start = begin, end = end) %>% stringr::str_trim())
          
          final <- final[1,] %>% 
            dplyr::mutate(sentence_scores = list(final %>% select(-summary_score:-type))) %>% 
            dplyr::select(-begin:-score, -sentence) %>% 
            dplyr::mutate(text = text)
          
          return(final)
        }
      ) %>%
      set_names(score_model) %>% #-> ss 
      bind_rows()
    
    #   match_begins <- ss %>% map("begin") %>% magrittr::extract2(1)
    #   
    # ww <- ss %>% 
    #   map("begin") %>% 
    #   map(~identical(.x, match_begins) %>% all) %>% 
    #   bind_rows()
  }

  return(final_dat)
}

#' Print progress in purrr::imap environment
#'
#' Provide iterator number and total length of items to be iterated over
#'
#' @md
#' @param x interator number.
#' @param total length of items to be iterated over.
#' @return a `chr`
#' @export
print_progress <- function(x, total) {
  iterator <- x %>% as.numeric()
  perc <- round((iterator/total)*100, 2)
  progress_text <- stringr::str_glue("{iterator} out of {total} ({perc}%)\n\n")
  return(progress_text)
}
