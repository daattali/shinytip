#' @export
tip <- function(
    tag,
    content,
    position = getOption("shinytip.position", "up"),
    length = getOption("shinytip.length", "line"),
    bg = getOption("shinytip.bg", "black"),
    fg = getOption("shinytip.fg", "white"),
    size = getOption("shinytip.size", "12px"),
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
    stop("tip: Must proide non-empty content", call. = FALSE)
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

  if (is.null(tag) || is.na(tag) || length(tag) == 0) {
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

  if (length != "line") {
    tag <- shiny::tagAppendAttributes(
      tag,
      `data-balloon-length` = length
    )
  }
  if (!animate) {
    tag <- shiny::tagAppendAttributes(
      tag,
      `data-balloon-blunt` = NA,
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

  shiny::addResourcePath("shinytip-assets", system.file("www", package = "shinytip"))

  htmltools::attachDependencies(
    tag,
    htmltools::htmlDependency(
      name = "balloon",
      version = "1.2.0",
      src = c(href = "shinytip-assets/lib"),
      stylesheet = "balloon-1.2.0/balloon.min.css"
    )
  )
}

#' @export
tip_icon <- function(...) {
  tip(shiny::icon("question-circle"), ...)
}

#' @export
tip_label <- function(label, ...) {
  shiny::tagList(label, tip_icon(...))
}
