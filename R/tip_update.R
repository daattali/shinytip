#' Update the text of a tooltip from the server
#'
#' Change the text of a tooltip that was given a `tip_id` when it was created with [tip()],
#' [tip_icon()], or [tip_input()]. The change is applied immediately, even while the tooltip is
#' being shown. If several tooltips share the same `tip_id`, they are all updated.\cr\cr
#' Each of the two texts can be changed, added, or removed, which means a tooltip can also change
#' how it behaves: for example, adding `content_disabled` to a tooltip that only has `content` makes
#' it show a different text while the input is disabled. See the *Disabled inputs* section of
#' [tip()] for what each combination of the two texts means.
#' @param tip_id The `tip_id` that was given to the tooltip when it was created.
#' @param content The new text of the tooltip. Leave it out to keep the current text, or use `NA`
#' to remove it.
#' @param content_disabled The new text to show while the input is disabled. Leave it out to keep
#' the current text, or use `NA` to remove it.
#' @param session The Shiny session object. You should not need to provide this.
#' @return Nothing. Called for the side effect of updating a tooltip in the browser.
#' @seealso [tip()], [tip_icon()], [tip_input()]
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   library(shinytip)
#'
#'   shinyApp(
#'     ui = fluidPage(br(),
#'       tip(actionButton("btn", "hover me"), "Not clicked yet", tip_id = "btn_tip")
#'     ),
#'     server = function(input, output, session) {
#'       observeEvent(input$btn, {
#'         tip_update("btn_tip", content = paste("Clicked", input$btn, "times"))
#'       })
#'     }
#'   )
#' }
#'
#' @export
tip_update <- function(tip_id, content = NULL, content_disabled = NULL,
                       session = shiny::getDefaultReactiveDomain()) {
  texts <- Filter(Negate(is.null), list(content = content, content_disabled = content_disabled))
  for (text in texts) {
    if (!is_removal(text)) check_text(text)
  }
  if (length(texts) == 2 && all(vapply(texts, is_removal, logical(1)))) {
    stop("tip_update: a tooltip must keep either `content` or `content_disabled`", call. = FALSE)
  }

  # Texts that were left out are not sent at all, and `NA` reaches the browser as `null`
  session$sendCustomMessage("shinytip-update", c(list(id = session$ns(tip_id)), texts))
}
