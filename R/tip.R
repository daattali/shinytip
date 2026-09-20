#' Add a tooltip to a Shiny element or text
#'
#' Tooltips can be added to any Shiny UI elements such as tags, inputs, outputs, or plain text.
#' Tooltips are powered by the project `balloon.css`.\cr\cr
#' All the theme parameters, along with `position` and `width`, can be set globally in order to use
#' a default setting for all tooltips in your Shiny app. This can be done by setting an R option with
#' the parameter's name prepended by `"shinytip."`. For example, to set all tooltips to appear on the
#' right and have a red background, use `options(shinytip.position = "right", shinytip.bg = "red")`.
#' Only `tag`, `content`, and `content_disabled` cannot be set globally.
#'
#' Note that when adding a tooltip to an `<img>` tag or an icon (such as fontawesome),
#' the tag will get wrapped in a `<div>`. When adding a tooltip to plain text, the text is wrapped
#' in a `<span>`. In all other cases, no additional HTML tags are created, unless you ask for one
#' with `wrap_tag = TRUE`.
#'
#' @section Disabled inputs:
#' Use `content_disabled` to give an input a tooltip that appears when it's disabled,
#' which can be used for explaining *why* an input is disabled.\cr\cr
#' Providing only `content_disabled` without `content` results in a tooltip that is shown
#' only while the input is disabled. Providing both `content` and `content_disabled`
#' results in a tooltip that swaps its text depending on the input's state.\cr\cr
#' Any inputs disabled with `shinyjs::disable()` are automatically detected.
#'
#' @section Limitations:
#' - The best position for the tooltip cannot be detected automatically.
#' This means that you may need to adjust the position of the tooltip depending on where it appears
#' on the page.
#'
#' - The balloon project makes use of pseudo-elements, so if you're trying to
#' add a tooltip to an element that already has pseudo-elements, it may not work. Use
#' `wrap_tag = TRUE` to place the tooltip on a wrapper element instead, which avoids the conflict.
#'
#' - On mobile (and other touch devices), all tooltips are only shown on click, since hovering
#' is not a supported interaction.
#'
#' - If an element loses its opacity when disabled, then the tooltip will also lose its
#' opacity when the element is disabled. This commonly affects tooltips on disabled `actionButton()`.
#' Bootstrap 5 (used by `{bslib}`) also prevents disabled buttons from having tooltips on hover.
#' Both these issues are fixed by `wrap_tag = TRUE`, which moves the tooltip onto a wrapper element.
#' @param tag A Shiny tag, tagList, or plain text to add a tooltip to.
#' @param content The text in the tooltip. Can include emojis, but cannot contain HTML.
#' Use `\n` to force a new line. Can be `NULL` if `content_disabled` is given, in which case
#' tooltip is only shown while the input is disabled.
#' @param content_disabled The text to show in the tooltip while the input is disabled. See the
#' *Disabled inputs* section.
#' @param position The position of the tooltip in relation to the tag. One of: `"top"`, `"bottom"`,
#' `"left"`, `"right"`, `"top-left"`, `"top-right"`, `"bottom-left"`, `"bottom-right"`.
#' @param width How wide should the tooltip be? One of: `"line"` (place the entire tooltip in one
#' line), `"fit"` (the tooltip should have the same width as the tag), `"s"` (small), `"m"` (medium),
#' `"l"` (large), `"xl"` (extra large).
#' @param theme A [tip_theme()] object holding the tooltip's appearance (colours, font size,
#' animation, cursor).
#' @param wrap_tag If `TRUE`, wrap `tag` in a `<div>` and place the tooltip on that wrapper rather
#' than on the tag itself. Use this when the tag cannot carry a tooltip of its own: a disabled input
#' passes its faded appearance onto the tooltip (and under Bootstrap 5 hides it entirely), and a
#' tag that already uses pseudo-elements will conflict with the tooltip. This behaviour is opt-in
#' because the extra `<div>` can affect the UI layout.
#' @param tip_id An optional name for the tooltip, which lets you change its text from the server
#' with [tip_update()]. This is separate from the `id` attribute of the tag, which can still be set
#' through `...`. In a Shiny module, wrap it in `ns()`.
#' @param ... Additional attributes to pass to the tag, or to the wrapper when the tag gets wrapped.
#' @return A Shiny tag that supports tooltips.
#' @seealso [tip_input()], [tip_icon()], [tip_theme()], [tip_update()]
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   library(shinytip)
#'
#'   shinyApp(
#'     ui = fluidPage(
#'       tip("hover over me", "a tooltip", position = "right"), br(), br(), br(),
#'       tip(actionButton("btn", "hover me"), "Hello"),
#'       tip(
#'         actionButton("btn3", "can't touch this", disabled = TRUE),
#'         content_disabled = "You do not have permission to do this",
#'         wrap_tag = TRUE
#'       )
#'     ),
#'     server = function(input, output) {}
#'   )
#' }
#'
#' @export
tip <- function(
    tag,
    content = NULL,
    content_disabled = NULL,
    position = getOption("shinytip.position", "top"),
    width = getOption("shinytip.width", "line"),
    theme = tip_theme(),
    wrap_tag = getOption("shinytip.wrap_tag", FALSE),
    tip_id = NULL,
    ...) {
  build_tip(
    tag = tag, content = content, content_disabled = content_disabled, position = position,
    width = width, theme = theme, wrap_tag = wrap_tag, click = FALSE, remote = FALSE, tip_id = tip_id, ...
  )
}

#' Create a tooltip icon
#'
#' Add a question-mark icon that shows a tooltip when hovered or clicked.
#' @inheritParams tip
#' @param content The text in the tooltip. Can include emojis, but cannot contain HTML.
#' @param click If `FALSE` (default), the tooltip shows on hover. If `TRUE`, the tooltip is only
#' shown once the icon is clicked. Ignored when `content_disabled` is given without `content`.
#' On mobile/touch devices that do not support hover, tooltips are always shown on click
#' regardless of this parameter.
#' @param solid If `TRUE`, the question-mark icon will have a solid background.
#' @param ... Additional attributes to pass to the question-mark icon.
#' @return A Shiny icon tag that has a tooltip.
#' @seealso [tip()], [tip_input()], [tip_theme()]
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   library(shinytip)
#'
#'   shinyApp(
#'     ui = fluidPage(
#'       h2("Section one", tip_icon("This is where some inputs will go", position = "right"))
#'     ),
#'     server = function(input, output) {}
#'   )
#' }
#'
#' @export
tip_icon <- function(
    content,
    position = getOption("shinytip.position", "top"),
    width = getOption("shinytip.width", "line"),
    theme = tip_theme(),
    click = getOption("shinytip.click", FALSE),
    solid = getOption("shinytip.solid", FALSE),
    tip_id = NULL,
    ...) {
  if (missing(content)) {
    stop("tip_icon: Must provide `content`", call. = FALSE)
  }
  if ("content_disabled" %in% names(list(...))) {
    stop("tip_icon: `content_disabled` is not supported because an icon has no disabled state ",
         "of its own. Use `tip_input()` to attach the icon to an input's label, or `tip()` to put the ",
         "tooltip on the input itself.", call. = FALSE)
  }
  if ("wrap_tag" %in% names(list(...))) {
    stop("tip_icon: `wrap_tag` is not supported because the tooltip is placed on an icon that ",
         "shinytip creates, which never needs to be wrapped.", call. = FALSE)
  }

  build_tip(
    tag = question_icon(solid), content = content, content_disabled = NULL,
    position = position, width = width, theme = theme, wrap_tag = FALSE,
    click = click, remote = FALSE, tip_id = tip_id, ...
  )
}

#' Add a tooltip to the label of an input
#'
#' Modifies an input's label to include a question-mark icon at the end that has a tooltip.
#' @inheritParams tip
#' @inheritParams tip_icon
#' @inheritSection tip Disabled inputs
#' @param tag A Shiny input tag.
#' @param ... Additional attributes to pass to the question-mark icon added to the label.
#' @return The same input tag, with a question-mark icon in the label that triggers a tooltip.
#' @seealso [tip()], [tip_icon()], [tip_theme()]
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   library(shinytip)
#'
#'   shinyApp(
#'     ui = fluidPage(br(),
#'       tip_input(
#'         textInput("name", "Name"),
#'         "Enter your full name as appears on your passport",
#'         position = "right"
#'       )
#'     ),
#'     server = function(input, output) {}
#'   )
#' }
#'
#' @export
tip_input <- function(
    tag,
    content = NULL,
    content_disabled = NULL,
    position = getOption("shinytip.position", "top"),
    width = getOption("shinytip.width", "line"),
    theme = tip_theme(),
    click = getOption("shinytip.click", FALSE),
    solid = getOption("shinytip.solid", FALSE),
    tip_id = NULL,
    ...) {
  if (!inherits(tag, "shiny.tag")) {
    stop("tip_input: `tag` must be a Shiny input tag", call. = FALSE)
  }

  classes <- htmltools::tagGetAttribute(tag, "class")
  if (is.null(classes) || !"shiny-input-container" %in% strsplit(classes, " ")[[1]]) {
    stop("tip_input: `tag` must be a Shiny input tag", call. = FALSE)
  }
  if ("wrap_tag" %in% names(list(...))) {
    stop("tip_input: `wrap_tag` is not supported because the tooltip is placed on an icon in the ",
         "input's label rather than on the input itself.", call. = FALSE)
  }

  icon <- build_tip(
    tag = question_icon(solid), content = content, content_disabled = content_disabled,
    position = position, width = width, theme = theme, wrap_tag = FALSE,
    click = click, remote = TRUE, tip_id = tip_id, ...
  )

  found_label <- FALSE
  for (idx in seq_along(tag$children)) {
    child <- tag$children[[idx]]
    if (inherits(child, "shiny.tag") && child$name == "label" && !is.null(child$children) &&
        length(child$children) > 0 && !is.null(child$children[[1]])) {
      found_label <- TRUE
      tag$children[[idx]] <- htmltools::tagAppendChild(child, icon)
      break
    }
  }
  if (!found_label) {
    # checkboxes have a different structure since they don't have a typical <label>
    if (is_checkbox(tag)) {
      label <- tag$children[[1]]$children[[1]]
      tag$children[[1]]$children[[1]] <- htmltools::tagAppendChild(label, icon)
    } else {
      stop("tip_input: `tag` must have a label", call. = FALSE)
    }
  }

  tag
}

### The actual workhorse of building the tooltip
build_tip <- function(tag, content, content_disabled, position, width, theme, wrap_tag,
                      click, remote, tip_id, ...) {
  if (!inherits(theme, "shinytip_theme")) {
    stop("tip: `theme` must be a `tip_theme()` object.", call. = FALSE)
  }
  bg <- theme$bg
  fg <- theme$fg
  fontsize <- css_px(theme$fontsize)
  radius <- css_px(theme$radius)
  animate <- theme$animate
  move <- css_px(theme$move)
  pointer <- theme$pointer

  if (!position %in% names(shinytip_positions)) {
    stop("tip: `position` must be one of: [", toString(names(shinytip_positions)), "]", call. = FALSE)
  }
  position <- shinytip_positions[[position]]

  if (!width %in% names(shinytip_widths)) {
    stop("tip: `width` must be one of: [", toString(names(shinytip_widths)), "]", call. = FALSE)
  }
  width <- shinytip_widths[[width]]

  if (!is.logical(wrap_tag) || length(wrap_tag) != 1L || is.na(wrap_tag)) {
    stop("tip: `wrap_tag` must be either `TRUE` or `FALSE`", call. = FALSE)
  }

  if (is.null(content) && is.null(content_disabled)) {
    stop("tip: Must provide `content` or `content_disabled`", call. = FALSE)
  }
  check_text(content)
  check_text(content_disabled)
  newlines <- (!is.null(content) && grepl("\n", content)) ||
    (!is.null(content_disabled) && grepl("\n", content_disabled))

  only_disabled <- is.null(content)

  css <- paste0(
    "--balloon-color: ", bg, "; ",
    "--balloon-text-color: ", fg, "; ",
    "--balloon-font-size: ", fontsize, "; ",
    "--balloon-border-radius: ", radius, "; ",
    "--balloon-move: ", move, ";",
    if (!pointer) " cursor: inherit;"
  )

  if (is.null(tag) || identical(tag, NA) || length(tag) == 0) {
    stop("tip: `tag` must not be empty", call. = FALSE)
  }

  # balloon.css uses ::before/::after for tooltips, so some elements need to be
  # wrapped in a div to allow pseudo-elements to work. `wrap_tag` lets the user
  # ask for the same treatment for any tag
  wrap_tags <- c("img", "input", "i", "select", "textarea")
  wrapped <- wrap_tag || inherits(tag, "shiny.tag.list") ||
    (inherits(tag, "shiny.tag") && (tag$name %in% wrap_tags))
  if (wrapped) {
    tag <- shiny::div(tag)
    tag <- shiny::tagAppendAttributes(tag, class = "shinytip-inline")
  } else if (!inherits(tag, "shiny.tag")) {
    tag <- shiny::span(tag)
  }

  # An empty `aria-label` is kept so that balloon.css works, but the actual tooltip
  # text comes from `data-shinytip-label`. This is done so that we don't override
  # the accessible name of the element.
  tag <- shiny::tagAppendAttributes(
    tag,
    class = "shinytip",
    `aria-label` = "",
    `data-balloon-nofocus` = NA,   # don't show after clicking, re-enable for keyboard focus using css
    `data-shinytip-label` = content,
    `data-shinytip-content-disabled` = content_disabled,
    `data-shinytip-id` = tip_id,
    `data-balloon-pos` = position,
    `data-balloon-break` = if (newlines) NA,
    style = css,
    ...
  )

  if (remote) {
    tag <- shiny::tagAppendAttributes(tag, class = "shinytip-remote")
  }


  # `click` is ignored when `content_disabled` is the only text, because CSS already drives
  # the tooltip's visibility, and a toggled class would outlive the input being re-enabled and
  # reopen the tooltip by itself the next time it was disabled
  if (click && !only_disabled) {
    tag <- shiny::tagAppendAttributes(
      tag,
      class = "shinytip-hide",
      `data-balloon-visible` = NA,
      onclick = "this.classList.toggle('shinytip-hide'); return false;"
    )
  }

  if (width != "line") {
    tag <- shiny::tagAppendAttributes(
      tag,
      `data-balloon-length` = width
    )
  }
  if (!animate) {
    tag <- shiny::tagAppendAttributes(
      tag,
      `data-balloon-blunt` = NA
    )
  }

  htmltools::attachDependencies(tag, shinytip_dependencies(updatable = !is.null(tip_id)), append = TRUE)
}
