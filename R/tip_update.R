#' Update the text of a tooltip
#'
#' Change the text of a tooltip that was given a `tip_id` when it was created with [tip()],
#' [tip_icon()], or [tip_input()]. The change is applied immediately, even if the tooltip is
#' being shown.\cr\cr
#' Both `content` and `content_disabled` can be changed, added, or removed. See the *Disabled inputs*
#' section of [tip()] for what each combination of the two texts means.
#' @param tip_id The `tip_id` that was given to the tooltip when it was created.
#' @param content The new text of the tooltip. Leave it out to keep the current text, or use `NA`
#' to remove it.
#' @param content_disabled The new text to show while the input is disabled. Leave it out to keep
#' the current text, or use `NA` to remove it.
#' @param session The Shiny session object. You should not need to provide this.
#' @return Nothing. Called for the side effect of updating a tooltip in the app.
#' @seealso [tip()], [tip_icon()], [tip_input()]
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   library(shinytip)
#'
#'   shinyApp(
#'     ui = fluidPage(br(), br(), br(),
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
  if (!is.null(content) && !is_removal(content)) check_text(content)
  if (!is.null(content_disabled) && !is_removal(content_disabled)) check_text(content_disabled)

  msg <- list(id = session$ns(tip_id))
  if (!is.null(content)) msg$content <- content
  if (!is.null(content_disabled)) msg$content_disabled <- content_disabled
  session$sendCustomMessage("shinytip-update", msg)
}
