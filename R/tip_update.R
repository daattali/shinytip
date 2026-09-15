#' Update a tooltip from the server
#'
#' Change the text or the appearance of an existing tooltip. The tooltip must have been given an
#' `id` when it was created with [tip()], [tip_icon()], or [tip_input()].\cr\cr
#' Only the parameters you provide are changed; everything else about the tooltip is left as
#' it is. The change is applied immediately, even while the tooltip is being shown.
#'
#' @section Removing text:
#' Passing `NA` (rather than a string) to `content` or `content_disabled` removes that text from
#' the tooltip. A tooltip must keep at least one of the two, so they cannot both be removed.
#' See the *Disabled inputs* section of [tip()] for what each combination means.
#'
#' @section Notes:
#' - If several tooltips share the same `id`, they are all updated. This makes it easy to update
#' a group of tooltips at once, but it also means ids should be unique when that isn't wanted.
#'
#' - Updating a tooltip that isn't on the page does nothing (a message is written to the browser's
#' console). A tooltip that is re-rendered, for example by `renderUI()`, goes back to the text it
#' was created with.
#'
#' @param id The `id` that was given to the tooltip when it was created.
#' @param content The new text in the tooltip, or `NA` to remove it. See the *Removing text*
#' section.
#' @param content_disabled The new text to show while the input is disabled, or `NA` to remove it.
#' See the *Removing text* section.
#' @inheritParams tip
#' @param session The Shiny session object. You should not need to provide this.
#' @return Nothing. Called for the side effect of updating a tooltip in the browser.
#' @seealso [tip()], [tip_icon()], [tip_input()], [tip_theme()]
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   library(shinytip)
#'
#'   shinyApp(
#'     ui = fluidPage(br(),
#'       tip(actionButton("btn", "hover me"), "Click to count", id = "btn_tip")
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
tip_update <- function(
    id,
    content = NULL,
    content_disabled = NULL,
    position = NULL,
    width = NULL,
    theme = NULL,
    session = shiny::getDefaultReactiveDomain()) {
  if (missing(id) || is.null(id)) {
    stop("tip_update: Must provide `id`", call. = FALSE)
  }
  check_id(id)
  if (is.null(session)) {
    stop("tip_update: must be called from inside a Shiny server function", call. = FALSE)
  }
  if (is_removal(content) && is_removal(content_disabled)) {
    stop("tip_update: a tooltip must keep either `content` or `content_disabled`", call. = FALSE)
  }

  spec <- tip_spec(
    content = content, content_disabled = content_disabled, position = position,
    width = width, theme = theme, allow_removal = TRUE
  )

  # `NA` entries reach the browser as `null`, which is how it is told to drop an attribute
  session$sendCustomMessage("shinytip-update", list(
    id = session$ns(id), attrs = spec$attrs, style = spec$style
  ))
  invisible(NULL)
}
