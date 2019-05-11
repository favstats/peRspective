#' peRspective: Interface to the Perspective API
#'
#' Provides access to the Perspective API (\url{http://www.perspectiveapi.com/}). Perspective is an API that uses machine learning models to score the perceived impact a comment might have on a conversation.
#' `peRspective` provides access to the API using the R programming language.
#' For an excellent documentation of the Perspective API see [here](https://github.com/conversationai/perspectiveapi/blob/master/api_reference.md).
#'
#' @section Get API Key:
#'   1. Create a Google Cloud project in your [Google Cloud console](https://console.developers.google.com/)
#'
#'   2. Go to [Perspective API's overview page](https://console.developers.google.com/apis/api/commentanalyzer.googleapis.com/overview) and click **_Enable_**
#'   
#'   3. Go to the [API credentials page](https://console.developers.google.com/apis/credentials), just click **_Create credentials_**, and choose "API Key".
#' 
#' @section Suggested Usage of API Key:
#'   \pkg{peRspective} functions will read the API key from
#'   environment variable \code{perspective_api_key}. 
#'   You can specify it like this at the start of your script:
#'   
#'   \code{Sys.setenv(perspective_api_key = "**********")}
#'   
#'   To start R session with the
#'   initialized environment variable create an \code{.Renviron} file in your R home
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
#'   
#' @section Alpha models:
#' 
#' The following alpha models are **recommended** for use. They have been tested
#' across multiple domains and trained on hundreds of thousands of comments tagged
#' by thousands of human moderators. These are available in **English (en) and Spanish (es)**.
#' 
#' *   **TOXICITY**: rude, disrespectful, or unreasonable comment that is likely to
#' make people leave a discussion. This model is a
#' [Convolutional Neural Network](https://en.wikipedia.org/wiki/Convolutional_neural_network) (CNN)
#' trained with [word-vector](https://www.tensorflow.org/tutorials/word2vec)
#' inputs.
#' *   **SEVERE_TOXICITY**: This model uses the same deep-CNN algorithm as the
#' TOXICITY model, but is trained to recognise examples that were considered
#' to be 'very toxic' by crowdworkers. This makes it much less sensitive to
#' comments that include positive uses of curse-words for example. A labelled dataset
#' and details of the methodolgy can be found in the same [toxicity dataset](https://figshare.com/articles/Wikipedia_Talk_Labels_Toxicity/4563973) that is
#' available for the toxicity model.
#' 
#' @section Experimental models:
#' 
#' The following experimental models give more fine-grained classifications than
#' overall toxicity. They were trained on a relatively smaller amount of data
#' compared to the primary toxicity models above and have not been tested as
#' thoroughly.
#' 
#' *   **IDENTITY_ATTACK**: negative or hateful comments targeting someone because of their identity.
#' *   **INSULT**: insulting, inflammatory, or negative comment towards a person
#' or a group of people.
#' *   **PROFANITY**: swear words, curse words, or other obscene or profane
#' language.
#' *   **THREAT**: describes an intention to inflict pain, injury, or violence
#' against an individual or group.
#' *   **SEXUALLY_EXPLICIT**: contains references to sexual acts, body parts, or
#' other lewd content.
#' *   **FLIRTATION**: pickup lines, complimenting appearance, subtle sexual
#' innuendos, etc.
#' 
#' For more details on how these were trained, see the [Toxicity and sub-attribute annotation guidelines](https://github.com/conversationai/conversationai.github.io/blob/master/crowdsourcing_annotation_schemes/toxicity_with_subattributes.md).
#' 
#' @section New York Times moderation models:
#' 
#' The following experimental models were trained on New York Times data tagged by
#' their moderation team.
#' 
#' *   **ATTACK_ON_AUTHOR**: Attack on the author of an article or post.
#' *   **ATTACK_ON_COMMENTER**: Attack on fellow commenter.
#' *   **INCOHERENT**: Difficult to understand, nonsensical.
#' *   **INFLAMMATORY**: Intending to provoke or inflame.
#' *   **LIKELY_TO_REJECT**: Overall measure of the likelihood for the comment to
#' be rejected according to the NYT's moderation.
#' *   **OBSCENE**: Obscene or vulgar language such as cursing.
#' *   **SPAM**: Irrelevant and unsolicited commercial content.
#' *   **UNSUBSTANTIAL**: Trivial or short comments.
#'  
#' @md
#' @docType package
#' @name perspective-package
#' @aliases peRspective
NULL


#' Analyze comments with Perspective API
#'
#' Provide a character string with your text, your API key and what scores you want to obtain.
#'
#' For more details see `?peRspective` or [Perspective API documentation](https://github.com/conversationai/perspectiveapi/blob/master/api_reference.md)
#'
#' @md
#' @param text a character string.
#' @param languages A vector of [ISO 631-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) two-letter language codes specifying the language(s) that comment is in (for example, "en", "es", "fr", "de", etc). If unspecified, the API will autodetect the comment language. If language detection fails, the API returns an error.
#' @param score_sentences A boolean value that indicates if the request should return spans that describe the scores for each part of the text (currently done at per sentence level). Defaults to `FALSE`.
#' @param key Your API key ([see here](https://github.com/conversationai/perspectiveapi/blob/master/quickstart.md) to set up an API key).
#' @param score_model Specify what model do you want to use (for example `TOXICITY` and/or `SEVERE_TOXICITY`). Specify a character vector if you want more than one score. See `peRspective::prsp_models`.
#' @return a `tibble`
#' @export
prsp_score <- function(text, text_id = NULL, languages = NULL, score_sentences = F, score_model, sleep = 1, key = NULL) {

  if (is.null(score_model)) {
    stop(stringr::str_glue("No Model type provided in score_model.\n\nShould be one of the following:\n\n{peRspective::prsp_models %>% glue::glue_collapse('\n')}"))
  }
  
  if (!all(score_model %in% prsp_models)) {
    stop(stringr::str_glue("Invalid Model type provided.\n\nShould be one of the following:\n\n{peRspective::prsp_models %>% glue::glue_collapse('\n')}"))
  }
  
  if (sleep <= 0.7) {
    stop("Sleeps below 0.7s are sure to hit the ratelimit")
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
  
  if (is.null(key)) {
    key <- peRspective:::perspective_api_key()
  }
  
  result <- httr::POST(stringr::str_glue("https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key={key}"),
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
  
  # browser()

  if (!is.null(text_id)) {
    final_dat <- final_dat %>% 
      dplyr::mutate(text_id = text_id) %>% 
      dplyr::select(text_id, dplyr::everything())
  }
  
  return(final_dat)
}

specify_decimal <- function(x, k) trimws(format(round(x, k), nsmall=k))


#' Print progress in purrr::imap environment
#'
#' Provide iterator number and total length of items to be iterated over
#'
#' @md
#' @param x interator number.
#' @param total length of items to be iterated over.
#' @param print_prct only print percentage progress (defaults to `FALSE`).
#' @return a `chr`
#' @export
print_progress <- function(x, total, print_prct = F) {
  iterator <- x %>% as.numeric()
  perc <- specify_decimal((iterator/total)*100, 2)
  
  if (print_prct) {
    return(stringr::str_glue("{perc}%"))
  }
  
  progress_text <- stringr::str_glue("{iterator} out of {total} ({perc}%)\n\n")
  return(progress_text)
}



perspective_api_key <- function () {
  key <- Sys.getenv("perspective_api_key")
  if (key == "") {
    stop("perspective_api_key environment variable is empty. See ?peRspective for help.")
  }
  key
}

msg <- function(type, type_style = crayon::make_style('red4'), msg) {
  
  cat(stringr::str_glue("{type_style(type)} [{crayon::italic(Sys.time())}]: {crayon::make_style('gray90')(msg)}"))

}

# crayon::make_style('red4')("hell")

# msg("WHAT", msg = "hatsap")

#' Stream comment scores with Perspective API
#'
#' This function wraps \code{\link{prsp_score}} and loops over your text input. Provide a character string with your text and which scores you want to obtain. Make sure to keep track of your ratelimit with on [the cloud console quota usage page](https://console.cloud.google.com/iam-admin/quotas).
#'
#' For more details see `?peRspective` or [Perspective API documentation](https://github.com/conversationai/perspectiveapi/blob/master/api_reference.md)
#'
#' @md
#' @param .data a dataset with a text and text_id column.
#' @param text a character vector with text you want to score.
#' @param text_id a unique ID for the text that you supply (required)
#' @param safe_output wraps the function into a `purrr::safely` environment (defaults to `FALSE`). Loop will run without pause and catch + output errors in a tidy `tibble` along with the results.
#' @param verbose narrates the streaming procedure (defaults to `FALSE`).
#' @param ... arguments passed to \code{\link{prsp_score}}.
#' @return a `tibble`
#' @export
prsp_stream <- function(.data,
                        text = NULL,
                        text_id = NULL,
                        ...,
                        safe_output = F,
                        verbose = F) {
  # browser()
  
  text_id <- dplyr::enquo(text_id)
  text <- dplyr::enquo(text)
  
  ## some tests to make sure everything is in order
  if (stringr::str_detect(rlang::as_label(text), "NULL")) {
    stop("You need to provide a text column.")
  }
  
  if (stringr::str_detect(rlang::as_label(text_id), "NULL")) {
    stop("You need to provide a text_id column.")
  }
  
  text_col <- .data %>% dplyr::pull(!!text)
  id_col <- .data %>% dplyr::pull(!!text_id)
  
  if (any(is.na(id_col))) {
    stop(
      "NAs detected in the text_id column. Please make sure your text_id column has no missing values."
    )
  }
  
  if (any(is.na(id_col))) {
    stop(
      "NAs detected in the text column. Please make sure your text column has no missing values."
    )
  }
  
  if (!length(id_col) == length(unique(id_col))) {
    stop(
      "Duplicates detected in the text_id column. Please make sure your text_id column is unique."
    )
  }
  
  ## keep function parameters
  prsp_params <- list(...)
  
  ## loop over prsp_score
  final_text <- .data %>%
    dplyr::select(!!text_id, !!text) %>%
    split(1:nrow(.)) %>%
    ## fix column names
    purrr::map(~purrr::set_names(.x, c("text_id", "text"))) %>%
    purrr::imap(~{
      ## Print Progress
      if (verbose) {
        peRspective:::msg(
          type = peRspective::print_progress(.y, nrow(.data), print_prct = T),
          type_style = crayon::green,
          msg = peRspective::print_progress(.y, nrow(.data))
        )
      }

      ## Make prsp_score to safely
      if (safe_output) {
        prsp_score <-
          purrr::safely(prsp_score, otherwise = tibble::tibble(text_id = .x$text_id))
      }

      # browser()

      ## run prsp score with parameters
      raw_text <- do.call(prsp_score,
                          c(
                            list(text = .x$text),
                            list(text_id = .x$text_id),
                            prsp_params
                          ))

      ## Print scores while everything runs
      if (verbose) {
        # browser()

        ## do a switcheroo because safe output looks a bit different
        if (safe_output) {
          int_id <- raw_text$result %>% dplyr::pull(text_id) %>% unique

          int_results <- raw_text$result
        } else if (!safe_output) {
          int_id <- raw_text %>% dplyr::pull(text_id) %>% unique()

          int_results <- raw_text
        }

        ## always print text_id first
        cat(stringr::str_glue("text_id: {int_id}\n\n"))

        # browser()
        ## when safe output show errors as you go
        if (safe_output) {
          if ("error" %in% class(raw_text$error)) {
            cat(
              stringr::str_glue(
                "\t\t{crayon::red('ERROR')}\n\t\t{crayon::make_style('gray90')(as.character(raw_text$error))}"
              )
            )
          }

        }
browser()
        ## when not error
        if (length(int_results) != 1 & !is.null(prsp_params[["score_sentences"]])) {
          ## do a switcheroo because score_sentences argument requires different strategy
          if (!prsp_params[["score_sentences"]]) {
            score_label <- int_results %>%
              dplyr::select(-text_id) %>%
              as.list() %>%
              tibble::enframe() %>%
              dplyr::mutate(value = as.numeric(value))
          } else if (prsp_params[["score_sentences"]]) {
            score_label <- int_results %>%
              dplyr::select(name = type, value = summary_score)
          }

          ## get score labels
          score_label <- score_label %>%
            dplyr::arrange(dplyr::desc(value)) %>%
            dplyr::mutate(value = peRspective:::specify_decimal(value, 2)) %>%
            dplyr::mutate(label = stringr::str_glue("{value} {name}")) %>%
            dplyr::select(label) %>%
            dplyr::slice(1:3) %>%
            dplyr::pull(label) %>%
            glue::glue_collapse(sep = "\n\t") %>%
            paste0(., "\n") %>%
            paste0("\t", .)

          cat(stringr::str_glue("{crayon::make_style('gray50')(score_label)}\n\n"))
        }  else if (length(int_results) == 1) {
          cat(stringr::str_glue("\t{crayon::red('NO SCORES')}\n\n\n"))

        }


      }

      return(raw_text)
    })
  
  
  # return(final_text)
  ## do some restructuring when safe_output to get tidy data output
  if (safe_output) {
    final_text <- final_text %>%
      purrr::set_names(id_col) %>%
      purrr::map("error") %>%
      purrr::map( ~ ifelse(is.null(.x), "No Error", as.character(.x))) %>%
      dplyr::bind_rows() %>%
      t() %>%
      tibble::as_tibble(rownames = .[1, ]) %>%
      purrr::set_names(c("text_id", "error")) %>%
      dplyr::right_join(final_text %>% purrr::map_dfr("result"), by = "text_id")
    
    return(final_text)
  }
  
  cat("Binding rows...\n")
  
  final_text <- dplyr::bind_rows(final_text)
  
  return(final_text)
}



# TODO: Write tests 
# ss <- 
  # tibble(ctext = "kdlfkmgkdfmgjgkfmg", textid = "#ewqyccfr") #%>%
  # prsp_stream_nolimit(text_sample, text = ctext,
  #             text_id = textid,
  #             score_model = c("TOXICITY", "SEVERE_TOXICITY"),
  #             score_sentences  = T,
  #             verbose = T,
  #             safe_output = F)
