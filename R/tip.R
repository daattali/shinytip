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

  shiny::addResourcePath("shinytip-assets",
                         system.file("www", package = "shinytip"))

  if (is.numeric(size)) {
    size <- paste0(size, "px")
  }

  css <- paste0(
    "--balloon-color: ", bg, ";\n",
    "--balloon-text-color: ", fg, ";\n",
    "--balloon-font-size: ", size, ";"
  )

  if (is.null(tag) || is.na(tag) || length(tag) == 0) {
    stop("tip: `tag` must not be empty", call. = FALSE)
  }

  if (!inherits(tag, "shiny.tag")) {
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

  shiny::tagList(
    shiny::singleton(
      shiny::tags$head(
        shiny::tags$link(
          rel = "stylesheet",
          href = file.path("shinytip-assets", "lib", "balloon-1.2.0", "balloon.min.css")
        )
      )
    ),
    tag
  )
}
