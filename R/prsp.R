
#' Analyze comments with Perspective API
#'
#' Provide a character string with your text, your API key and what scores you want to obtain.
#'
#' @md
#' @param text a character string.
#' @param key Your API key (see here: `https://github.com/conversationai/perspectiveapi/blob/master/quickstart.md`).
#' @param score_model Specify what model do you want to use (e.g. `TOXICITY` or `SEVERE_TOXICITY`). Specify a character vector if you want more than one score. See `peRspective::prsp_models`.
#' @return a `tibble`
#' @export
prsp_score <- function(text, key, score_model) {

  if (!all(score_model %in% prsp_models)) {
    stop(stringr::str_glue("Invalid Model type provided.\n\nShould be one of the following:\n\n{peRspective::prsp_models %>% glue::glue_collapse('\n')}"))
  }

  # score_model <- c("TOXICITY", "SEVERE_TOXICITY")

  model_list <- score_model %>%
    purrr::map(
      ~{list(x = NULL) %>% purrr::set_names(.x)}
    ) %>%
    purrr::flatten()

  analyze_request <- list(
    comment = list(text = text),
    requestedAttributes = model_list
  ) %>%
    jsonlite::toJSON(auto_unbox = T)


  result <- httr::POST(stringr::str_glue("https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key={key}"),
                 body = analyze_request,
                 httr::add_headers(.headers = c("Content-Type"="application/json")))

  Output <- httr::content(result)

  ## cleaning
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

  return(final_dat)
}
