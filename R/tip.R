#' Add a tooltip to a Shiny element or text
#'
#' img input i: div
#' Text: span
#' @param tag The tag
#' @param content the content
#' @param position the position
#' @param length length of tip
#' @param bg background
#' @param fg foreground
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
    stop("tip: `position` must be one of: [", paste(allowed_position, collapse = ", "), "]", call. = FALSE)
  }

  allowed_length <- c("line", "fit", "s", "m", "l", "xl")
  if (!length %in% allowed_length) {
    stop("tip: `length` must be one of: [", paste(allowed_length, collapse = ", "), "]", call. = FALSE)
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

  if (inherits(tag, "shiny.tag") && (tag$name %in% c("img", "input", "i"))) {
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

  runtime <- knitr::opts_knit$get("rmarkdown.runtime")
  if (!is.null(runtime) && runtime == "shiny") {
    # we're inside an Rmd document
    insert_into_doc <- shiny::tagList
  } else {
    # we're in a shiny app
    insert_into_doc <- shiny::tags$head
  }

  htmltools::attachDependencies(
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
}

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
    ...) {
  tip(
    tag = shiny::icon("question-circle"),
    content = content,
    position = position, length = length, bg = bg, fg = fg,
    size = size, click = click, animate = animate, pointer = pointer,
    ...
  )
}

#' tip the input
#' @export
tip_input <- function(
    input,
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
  if (!inherits(input, "shiny.tag")) {
    stop("tip_input: `input` must be a Shiny input tag", call. = FALSE)
  }

  classes <- htmltools::tagGetAttribute(input, "class")
  if (is.null(classes) || !"shiny-input-container" %in% strsplit(classes, " ")[[1]]) {
    stop("tip_input: `input` must be a Shiny input tag", call. = FALSE)
  }

  found_label <- FALSE
  for (idx in seq_along(input$children)) {
    tag <- input$children[[idx]]
    if (tag$name == "label" && !is.null(tag$children) &&
        length(tag$children) > 0 && !is.null(tag$children[[1]])) {
      found_label <- TRUE
      tag <- htmltools::tagAppendChild(
        tag,
        tip_icon(
          content = content, position = position,
          length = length, bg = bg, fg = fg,
          size = size, click = click, animate = animate, pointer = pointer,
          ...
        )
      )
      input$children[[idx]] <- tag
      break
    }
  }
  if (!found_label) {
    # checkboxes have a different structure since they don't have a typical <label>
    if (is_checkbox(input)) {
      label <- input$children[[1]]$children[[1]]
      label <- htmltools::tagAppendChild(
        label,
        tip_icon(
          content = content, position = position,
          length = length, bg = bg, fg = fg,
          size = size, click = click, animate = animate, pointer = pointer,
          ...
        )
      )
      input$children[[1]]$children[[1]] <- label
    } else {
      stop("tip_input: `input` must have a label", call. = FALSE)
    }
  }

  input
}
