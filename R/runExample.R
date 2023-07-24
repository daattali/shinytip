#' Run shinytip example
#'
#' Launch an example Shiny app that shows how to use {shinytip}.\cr\cr
#' The demo app is also
#' \href{https://daattali.com/shiny/shinytip-demo/}{available online}
#' to experiment with.
#' @export
runExample <- function() {
  appDir <- system.file("examples", "demo", package = "shinytip")
  shiny::runApp(appDir, display.mode = "normal")
}
