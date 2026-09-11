#' Create a reusable tooltip theme
#'
#' Bundles the appearance options shared by [tip()], [tip_icon()] and [tip_input()] into a single
#' object that can be defined once and reused. The result  can be passed to their `theme` argument.\cr\cr
#' All theme parameters can be set globally in order to use a default setting for all tooltips in your
#' Shiny app. This can be done by setting an R option with the parameter's name prepended by `"shinytip."`.
#' For example, to set all tooltips to have a red background and font size 24, use
#' `options(shinytip.bg = "red", shinytip.fontsize = 24)`.
#' @param bg Background colour of the tooltip.
#' @param fg Colour ("foreground") of the tooltip text.
#' @param fontsize The font size of the tooltip text. A number is interpreted as pixels.
#' @param radius The roundness of the tooltip's corners. A number is interpreted as pixels.
#' @param animate If `TRUE`, animate the tooltip appearing and disappearing.
#' @param move How far the tooltip slides while animating into view. A number is interpreted as
#' pixels. Has no effect when `animate` is `FALSE`.
#' @param pointer If `TRUE`, change the cursor when hovering over the tag.
#' @return A `shinytip_theme` object, to be passed to the `theme` argument of [tip()],
#' [tip_icon()], or [tip_input()].
#' @seealso [tip()], [tip_icon()], [tip_input()]
#' @examples
#' warning_theme <- tip_theme(bg = "#B00020", fg = "white", fontsize = 14)
#'
#' if (interactive()) {
#'   library(shiny)
#'   library(shinytip)
#'
#'   shinyApp(
#'     ui = fluidPage(
#'       tip("hover over me", "a red tooltip", position = "right", theme = warning_theme),
#'       tip("and me", "the same red tooltip", position = "bottom", theme = warning_theme)
#'     ),
#'     server = function(input, output) {}
#'   )
#' }
#'
#' @export
tip_theme <- function(
    bg = getOption("shinytip.bg", "black"),
    fg = getOption("shinytip.fg", "white"),
    fontsize = getOption("shinytip.fontsize", "12px"),
    radius = getOption("shinytip.radius", "2px"),
    animate = getOption("shinytip.animate", TRUE),
    move = getOption("shinytip.move", "4px"),
    pointer = getOption("shinytip.pointer", TRUE)) {
  structure(
    list(
      bg = bg, fg = fg, fontsize = fontsize, radius = radius,
      animate = animate, move = move, pointer = pointer
    ),
    class = "shinytip_theme"
  )
}

#' @export
print.shinytip_theme <- function(x, ...) {
  cat("<shinytip theme>\n")
  cat(paste0("  ", format(names(x)), "  ", vapply(x, format, character(1))), sep = "\n")
  invisible(x)
}
