#' peRspective: Interface to the Perspective API
#'
#' Provides access to the Perspective API (\url{http://www.perspectiveapi.com/}).
#'
#' @section Setup:
#'   1. Create a Google Cloud project in your [Google Cloud console](https://console.developers.google.com/)
#'
#'   2. Go to [Perspective API's overview page](https://console.developers.google.com/apis/api/commentanalyzer.googleapis.com/overview) and click **_Enable_**
#'   
#'   3. Go to the [API credentials page](https://console.developers.google.com/apis/credentials), just click **_Create credentials_**, and choose "API Key".
#' 
#' @section API:
#'   \pkg{peRspective} functions will read the API key from
#'   environment variable \code{perspective_api_key}. 
#'   You can specify it like this at the start of your script:
#'   
#'   \code{Sys.setenv(perspective_api_key = "**********")}
#'   
#'   To start R session with the
#'   initialized environvent variable create an \code{.Renviron} file in your R home
#'   with a line like this:
#'   
#'   \code{perspective_api_key = "**********"}
#'
#'   To check where your R home is, try \code{normalizePath("~")}.
#'   
#' @section Quota and character length Limits:
#'   You can check your quota limits by going to [your google cloud project's Perspective API page](https://console.cloud.google.com/apis/api/commentanalyzer.googleapis.com/quotas), and check 
#'   your projects quota usage at 
#'   [the cloud console quota usage page](https://console.cloud.google.com/iam-admin/quotas).
#'
#'   The maximum text size per request is 3000 bytes.
#' @md
#' @docType package
#' @name perspective-package
#' @aliases peRspective
NULL


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
prsp_score <- function(text, languages = NULL, score_sentences = F, key = NULL, score_model, sleep = 1) {

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
  
  result <- httr::POST(stringr::str_glue("https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key={perspective_api_key()}"),
                 body = analyze_request,
                 httr::add_headers(.headers = c("Content-Type"="application/json")))

  Output <- httr::content(result)
  
  if (any(stringr::str_detect(Output %>% names(), "error"))) {
    stop(stringr::str_glue("HTTP {Output$error$code}\n{Output$error$status}: {Output$error$message}"))
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
            dplyr::mutate(sentence_scores = list(final %>% dplyr::select(-summary_score:-type))) %>% 
            dplyr::select(-begin:-score, -sentences) %>% 
            dplyr::mutate(text = text)
          
          return(final)
        }
      ) %>%
      purrr::set_names(score_model) %>% #-> ss 
      dplyr::bind_rows()
    
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



perspective_api_key <- function () {
  key <- Sys.getenv("perspective_api_key")
  if (key == "") {
    stop("perspective_api_key environment variable is empty. See ?airtabler for help.")
  }
  key
}
