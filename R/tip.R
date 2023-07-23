#' Add a tooltip to a Shiny element or text
#'
#' Tooltips can be added to any Shiny UI elements such as tags, inputs, outputs, or plain text.
#' Tooltips are powered by the project `balloon.css`.\cr\cr
#' Most parameters can be set globally in order to use a default setting for all tooltips in your
#' Shiny app. This can be done by setting an R option with the parameter's name prepended by
#' `"shinytip."`. For example, to set all tooltips to appear on the right and have a red background,
#' use `options(shinytip.position = "right", shinytip.bg = "red")`. Only `tag` and `content` cannot
#' be set globally.
#'
#' Note that when adding a tooltip to an `<img>` tag or an icon (such as fontawesome), the tag will get
#' wrapped in a `<div>`. When adding a tooltip to plain text, the text is wrapped in a `<span>`. In
#' all other cases, no additional HTML tags are created.
#'
#' @section Limitations:
#' - The best position for the tooltip cannot be detected automatically.
#' This means that you may need to adjust the position of the tooltip depending on where it appears
#' on the page.
#'
#' - The balloon project makes use of pseudo-elements, so if you're trying to
#' add a tooltip to an element that already has pseudo-elements, it may not work.
#'
#' - On mobile (and other touch devices), all tooltips are only shown on click, since hovering
#' is not a supported interaction.
#' @param tag A Shiny tag, tagList, or plain text to add a tooltip to.
#' @param content The text in the tooltip. Can include emojis, but cannot contain HTML.
#' @param position The position of the tooltip in relation to the tag. One of: `"up"`, `"down"`,
#' `"left"`, `"right"`, `"up-left"`, `"up-right"`, `"down-left"`, `"down-right"`.
#' @param length How wide should the tooltip be? One of: `"line"` (place the entire tooltip in one
#' line), `"fit"` (the tooltip should have the same width as the tag), `"s"` (small), `"m"` (medium),
#' `"l"` (large), `"xl"` (extra large).
#' @param bg Background colour of the tooltip.
#' @param fg Colour ("foreground") of the tooltip text.
#' @param size The font size of the tooltip text.
#' @param click If `FALSE` (default), the tooltip shows on hover. If `TRUE`, the tooltip will
#' only show when the tag is clicked.
#' @param animate If `FALSE`, don't animate the tooltip appearing and disappearing.
#' @param pointer If `FALSE`, don't change the cursor when hovering over the tag.
#' @param ... Additional parameters to pass to the tag.
#' @return A Shiny tag that supports tooltips.
#' @seealso [tip_input()], [tip_icon()]
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   library(shinytip)
#'
#'   shinyApp(
#'     ui = fluidPage(
#'       tip("hover over me", "a tooltip", position = "right"), br(), br(), br(),
#'       tip(actionButton("btn", "hover me"), "Hello"),
#'       tip(actionButton("btn2", "click me"), "Hello again!", click = TRUE)
#'     ),
#'     server = function(input, output) {}
#'   )
#' }
#'
#' @export
tip <- function(
    tag,
    content,
    position = getOption("shinytip.position", "up"),
    length = getOption("shinytip.length", "line"),
    bg = getOption("shinytip.bg", "black"),
    fg = getOption("shinytip.fg", "white"),
    size = getOption("shinytip.size", "12px"),
    click = getOption("shinytip.click", FALSE),
    animate = getOption("shinytip.animate", TRUE),
    pointer = getOption("shinytip.pointer", TRUE),
    ...) {

  allowed_position <- c("up", "down", "left", "right", "up-left", "up-right", "down-left", "down-right")
  if (!position %in% allowed_position) {
    stop("tip: `position` must be one of: [", toString(allowed_position), "]", call. = FALSE)
  }

  allowed_length <- c("line", "fit", "s", "m", "l", "xl")
  if (!length %in% allowed_length) {
    stop("tip: `length` must be one of: [", toString(allowed_length), "]", call. = FALSE)
  }
  if (length == "s") {
    length <- "small"
  } else if (length == "m") {
    length <- "medium"
  } else if (length == "l") {
    length <- "large"
  } else if (length == "xl") {
    length <- "xlarge"
  }

  if (missing(content) || !nzchar(trimws(content))) {
    stop("tip: Must provide non-empty content", call. = FALSE)
  }

  if (is.numeric(size)) {
    size <- paste0(size, "px")
  }

  css <- paste0(
    "--balloon-color: ", bg, "; ",
    "--balloon-text-color: ", fg, "; ",
    "--balloon-font-size: ", size, "; "
  )

  if (!pointer) {
    css <- paste0(css, "cursor: inherit; ")
  }

  if (is.null(tag) || identical(tag, NA) || length(tag) == 0) {
    stop("tip: `tag` must not be empty", call. = FALSE)
  }

  if (inherits(tag, "shiny.tag.list") ||
      (inherits(tag, "shiny.tag") && (tag$name %in% c("img", "input", "i")))) {
    tag <- shiny::div(tag)
    css <- paste0(css, "display: inline-block; ")
  } else if (!inherits(tag, "shiny.tag")) {
    tag <- shiny::span(tag)
  }

  tag <- shiny::tagAppendAttributes(
    tag,
    class = "shinytip",
    `aria-label` = content,
    `data-balloon-pos` = position,
    style = css,
    ...
  )

  if (click) {
    tag <- shiny::tagAppendAttributes(
      tag,
      class = "shinytip-hide",
      `data-balloon-visible` = NA,
      onclick = "this.classList.toggle('shinytip-hide'); return false;"
    )
  }

  if (length != "line") {
    tag <- shiny::tagAppendAttributes(
      tag,
      `data-balloon-length` = length
    )
  }
  if (!animate) {
    tag <- shiny::tagAppendAttributes(
      tag,
      `data-balloon-blunt` = NA
    )
  }

  tag <- shiny::tagList(
    tag,
    htmltools::htmlDependency(
      name = "balloon-css",
      version = "1.2.0",
      package = "shinytip",
      src = "assets/lib/balloon-1.2.0",
      stylesheet = "balloon.min.css",
      head = "<style>.shinytip-hide:before, .shinytip-hide:after { display: none; }</style>"
    )
  )
  tag
}

#' Create a tooltip icon
#'
#' Add a question-mark icon that shows a tooltip when hovered or clicked.
#' @inheritParams tip
#' @param solid If `TRUE`, the question-mark icon will have a solid background.
#' @return A Shiny icon tag that has a tooltip.
#' @seealso [tip()], [tip_input()]
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   library(shinytip)
#'
#'   shinyApp(
#'     ui = fluidPage(
#'       "Section one", tip_icon("This is where some inputs will go", position = "right")
#'     ),
#'     server = function(input, output) {}
#'   )
#' }
#' @export
tip_icon <- function(
    content,
    position = getOption("shinytip.position", "up"),
    length = getOption("shinytip.length", "line"),
    bg = getOption("shinytip.bg", "black"),
    fg = getOption("shinytip.fg", "white"),
    size = getOption("shinytip.size", "12px"),
    click = getOption("shinytip.click", FALSE),
    animate = getOption("shinytip.animate", TRUE),
    pointer = getOption("shinytip.pointer", TRUE),
    solid = getOption("shinytip.solid", FALSE),
    ...) {
  tip(
    tag = shiny::icon("question-circle", class = if (solid) "fa-solid"),
    content = content,
    position = position, length = length, bg = bg, fg = fg,
    size = size, click = click, animate = animate, pointer = pointer,
    ...
  )
}

#' tip the input
#' @inheritParams tip
#' @inheritParams tip_icon
#' @param tag TODO
#' @export
tip_input <- function(
    tag,
    content,
    position = getOption("shinytip.position", "up"),
    length = getOption("shinytip.length", "line"),
    bg = getOption("shinytip.bg", "black"),
    fg = getOption("shinytip.fg", "white"),
    size = getOption("shinytip.size", "12px"),
    click = getOption("shinytip.click", FALSE),
    animate = getOption("shinytip.animate", TRUE),
    pointer = getOption("shinytip.pointer", TRUE),
    solid = getOption("shinytip.solid", FALSE),
    ...) {
  if (!inherits(tag, "shiny.tag")) {
    stop("tip_input: `tag` must be a Shiny input tag", call. = FALSE)
  }

  classes <- htmltools::tagGetAttribute(tag, "class")
  if (is.null(classes) || !"shiny-input-container" %in% strsplit(classes, " ")[[1]]) {
    stop("tip_input: `tag` must be a Shiny input tag", call. = FALSE)
  }

  found_label <- FALSE
  for (idx in seq_along(tag$children)) {
    child <- tag$children[[idx]]
    if (child$name == "label" && !is.null(child$children) &&
        length(child$children) > 0 && !is.null(child$children[[1]])) {
      found_label <- TRUE
      child <- htmltools::tagAppendChild(
        child,
        tip_icon(
          content = content, position = position,
          length = length, bg = bg, fg = fg,
          size = size, click = click, animate = animate, pointer = pointer,
          ...
        )
      )
      tag$children[[idx]] <- child
      break
    }
  }
  if (!found_label) {
    # checkboxes have a different structure since they don't have a typical <label>
    if (is_checkbox(tag)) {
      label <- tag$children[[1]]$children[[1]]
      label <- htmltools::tagAppendChild(
        label,
        tip_icon(
          content = content, position = position,
          length = length, bg = bg, fg = fg,
          size = size, click = click, animate = animate, pointer = pointer,
          ...
        )
      )
      tag$children[[1]]$children[[1]] <- label
    } else {
      stop("tip_input: `tag` must have a label", call. = FALSE)
    }
  }

  tag
}
