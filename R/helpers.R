#' Check if API key is present
#'
#' 
#'
perspective_api_key <- function () {
  key <- Sys.getenv("perspective_api_key")
  if (key == "") {
    stop("perspective_api_key environment variable is empty. See ?peRspective for help.")
  }
  key
}

#' Send a fancy message
#'
#' Print a beautiful message in the terminal
#'
#' @param type what message should be displayed in the beginning
#' @param type_style crayon color or style
#' @param msg what message should be printed
msg <- function(type, type_style = crayon::make_style('red4'), msg) {
  
  cat(stringr::str_glue("{type_style(type)} [{crayon::italic(Sys.time())}]: {crayon::make_style('gray90')(msg)}"))
  
}

# crayon::make_style('red4')("hell")

# msg("WHAT", msg = "hatsap")


#' SQL Database Append
#'
#' This is a helper function that will write a dataframe to a SQL database
#'
#' @param path path to SQL database
#' @param tbl specify a tibble name within the SQL database
#' @param data the dataframe to be saved
db_append <- function(path, tbl, data) {
  con <- dbConnect(RSQLite::SQLite(), path)
  
  if(!is.null(DBI::dbListTables(con))) {
    DBI::dbWriteTable(con, tbl, data, append = T)
  } else {
    DBI::dbWriteTable(con, tbl, data)
  }
  DBI::dbDisconnect(con)
  
}



#' Specify a decimal
#'
#' @param x a number to be rounded
#' @param k round to which position after the comma
#' @export
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