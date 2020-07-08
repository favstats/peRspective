globalVariables("text_id")
globalVariables("value")
globalVariables("type")
globalVariables("summary_score")
globalVariables("label")
globalVariables(".")
globalVariables("score_model")

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
#' @param ... arguments passed to \code{\link{prsp_score}}. Don't forget to add the \code{score_model} argument (see `peRspective::prsp_models` for list of valid models).
#' @param save NOT USABLE YET saves data into SQLite database (defaults to `FALSE`).
#' @param dt_name what is the name of the dataset? (defaults to `persp`).
#' @return a `tibble`
#' @examples
#' \dontrun{
#' ## Create a mock tibble
#' text_sample <- tibble(
#' ctext = c("You wrote this? Wow. This is dumb and childish, please go f**** yourself.",
#'           "I don't know what to say about this but it's not good. The commenter is just an idiot",
#'           "This goes even further!",
#'           "What the hell is going on?",
#'           "Please. I don't get it. Explain it again",
#'           "Annoying and irrelevant! I'd rather watch the paint drying on the wall!"),
#' textid = c("#efdcxct", "#ehfcsct", 
#'            "#ekacxwt",  "#ewatxad", 
#'            "#ekacswt",  "#ewftxwd")
#' )
#'            
#' ## GET TOXICITY and SEVERE_TOXICITY Scores for a dataset with a text column
#' text_sample %>%
#' prsp_stream(text = ctext,
#'             text_id = textid,
#'             score_model = c("TOXICITY", "SEVERE_TOXICITY"))
#'   
#' ## Safe Output argument means will not stop on error
# 'text_sample %>%
#' prsp_stream(text = ctext,
#'            text_id = textid,
#'            score_model = c("TOXICITY", "SEVERE_TOXICITY"),
#'            safe_output = T)
#'            
#'            
#' ## verbose = T means you get pretty narration of your scoring procedure
# 'text_sample %>%
#' prsp_stream(text = ctext,
#'            text_id = textid,
#'            score_model = c("TOXICITY", "SEVERE_TOXICITY"),
#'            safe_output = T,
#'            verbose = T)
#' }
#' @export
prsp_stream <- function(.data,
                        text = NULL,
                        text_id = NULL,
                        ...,
                        safe_output = F,
                        verbose = F,
                        save = F,
                        dt_name = "persp") {
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
  
  if (any(is.na(text_col))) {
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
  
  
  if (is.null(prsp_params$score_model)) {
    stop(stringr::str_glue("No Model type provided in score_model.\n\nShould be one of the following:\n\n{peRspective::prsp_models %>% glue::glue_collapse('\n')}"))
  }

  if (!all(prsp_params$score_model %in% prsp_models | prsp_params$score_model %in% prsp_exp_models)) {
    stop(stringr::str_glue("Invalid Model type provided.\n\nShould be one of the following:\n\n{peRspective::prsp_models %>% glue::glue_collapse('\n')}"))
  }
  
  ## loop over prsp_score
  final_text <- .data %>%
    dplyr::select(!!text_id, !!text) %>%
    split(1:nrow(.)) %>%
    ## fix column names
    purrr::map(~purrr::set_names(.x, c("text_id", "text"))) %>%
    purrr::imap(~{
      
      ## Print Progress
      if (verbose) {
        msg(
          type = print_progress(.y, nrow(.data), print_prct = T),
          type_style = crayon::green,
          msg = print_progress(.y, nrow(.data))
        )
      }
      
      
      ## Make prsp_score to safely
      if (safe_output) {
        prsp_score <-
          purrr::safely(prsp_score, otherwise = tibble::tibble(text_id = .x$text_id))
      }
      

      ## run prsp score with parameters
      raw_text <- do.call(prsp_score,
                          c(
                            list(text = .x$text),
                            list(text_id = .x$text_id),
                            # list(score_model = .x$score_model),
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
      
        print_score_labels(prsp_params, int_results)

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
      dplyr::right_join(final_text %>% purrr::map_dfr("result") %>% dplyr::mutate(text_id = as.character(text_id)), by = "text_id")
    
    
    if(is.numeric(id_col)){
      final_text <- final_text %>%
        dplyr::mutate(text_id = as.numeric(text_id))
    }
    
    if(save){
      db_append("data/{dt_name}.db", "perspective", data = final_text)
    }
    
    return(final_text)
  }
  
  cat("Binding rows...\n")
  
  final_text <- dplyr::bind_rows(final_text)
  
  if(save){
    openmindR::db_append(glue::glue("{dt_name}.db"), "perspective", data = final_text)
  }
  
  return(final_text)
}



#' All valid (non-experimental) Perspective API models
#' 
#' @docType data
#' @keywords datasets
#' @name prsp_models
NULL


#' All valid experimental Perspective API models
#' 
#' @docType data
#' @keywords datasets
#' @name prsp_exp_models
NULL


# TODO: Write tests 
# ss <- 
  # tibble(ctext = "kdlfkmgkdfmgjgkfmg", textid = "#ewqyccfr") #%>%
  # prsp_stream_nolimit(text_sample, text = ctext,
  #             text_id = textid,
  #             score_model = c("TOXICITY", "SEVERE_TOXICITY"),
  #             score_sentences  = T,
  #             verbose = T,
  #             safe_output = F)


print_score_labels <- function(prsp_params = NULL, int_results = NULL) {
  ## when not error
  if (length(int_results) != 1) {
    
    ## do a switcheroo because score_sentences argument requires different strategy
    score_sentence_switcher <-  ifelse(is.null(prsp_params[["score_sentences"]]), F, T)
    
    if (!score_sentence_switcher) {
      score_label <- int_results %>%
        dplyr::select(-text_id) %>%
        as.list() %>%
        tibble::enframe() %>%
        dplyr::mutate(value = as.numeric(value))
    } else if (score_sentence_switcher) {
      score_label <- int_results %>%
        dplyr::select(name = type, value = summary_score)
    }
    
    ## get score labels
    score_label <- score_label %>%
      dplyr::arrange(dplyr::desc(value)) %>%
      dplyr::mutate(value = specify_decimal(value, 2)) %>%
      dplyr::mutate(label = stringr::str_glue("{value} {name}")) %>%
      dplyr::select(label) %>%
      dplyr::slice(1:3) %>%
      dplyr::pull(label) %>%
      glue::glue_collapse(sep = "\n\t") %>%
      paste0(., "\n") %>%
      paste0("\t", .)
    
    cat(stringr::str_glue("{crayon::make_style('gray50')(score_label)}\n\n"))
  }  else if (length(int_results) == 1) { ## there are no scores!
    cat(stringr::str_glue("\t{crayon::red('NO SCORES')}\n\n\n"))
    
  }          
}