#' Check if API key is present
#'
#' 
#' @param test necessary when in a test environment. Defaults to `FALSE`.
perspective_api_key <- function(test = F) {
  if (test) {
    key <- Sys.getenv("perspective_api_key_test")
  } else if (!test) {
    key <- Sys.getenv("perspective_api_key")
  }
  if (key == "") {
    stop("perspective_api_key environment variable is empty. See ?peRspective for help.")
  }
  key
}

#' Send a fancy message
#'
#' Print a beautiful message in the console
#'
#' @param type what message should be displayed in the beginning
#' @param type_style crayon color or style
#' @param msg what message should be printed
#' @examples 
#' ## Send a message to the world
#' msg("MESSAGE", crayon::make_style('blue4'), "This is a message to the world")
#' @export
msg <- function(type, type_style = crayon::make_style('red4'), msg) {
  
  cat(stringr::str_glue("{type_style(type)} [{crayon::italic(Sys.time())}]: {crayon::make_style('gray90')(msg)}"))
  
}

# crayon::make_style('red4')("hell")

# msg("WHAT", msg = "hatsap")


#' Specify a decimal
#'
#' @param x a number to be rounded
#' @param k round to which position after the comma
#' @export
#' @examples
#' ## specify 2 decimals of a number
#' specify_decimal(1.0434, 2)
specify_decimal <- function(x, k) trimws(format(round(x, k), nsmall=k))



#' Print progress in purrr::imap environment
#'
#' Provide iterator number and total length of items to be iterated over
#'
#' @md
#' @param x iterator number.
#' @param total length of items to be iterated over.
#' @param print_prct only print percentage progress (defaults to `FALSE`).
#' @return a `chr`
#' @export
#' @examples
#' ## Print progress (1 out of 100)
#' print_progress(1, 100)
#' 
#' ## Only print percentage
#' print_progress(1, 100, print_prct = TRUE)
print_progress <- function(x, total, print_prct = F) {
  iterator <- x %>% as.numeric()
  perc <- specify_decimal((iterator/total)*100, 2)
  
  if (print_prct) {
    return(stringr::str_glue("{perc}%"))
  }
  
  progress_text <- stringr::str_glue("{iterator} out of {total} ({perc}%)\n\n")
  return(progress_text)
}