# The valid `position` and `width` values, each mapped to the value balloon.css expects
shinytip_positions <- c(
  "top" = "up", "bottom" = "down", "left" = "left", "right" = "right",
  "top-left" = "up-left", "top-right" = "up-right",
  "bottom-left" = "down-left", "bottom-right" = "down-right"
)
shinytip_widths <- c(
  "line" = "line", "fit" = "fit", "s" = "small",
  "m" = "medium", "l" = "large", "xl" = "xlarge"
)

has_class <- function(tag, class) {
  if (!inherits(tag, "shiny.tag")) {
    stop("has_class: `tag` must be a shiny tag")
  }
  if (!nzchar(class)) {
    stop("has_class: `class` must be a non-empty string")
  }
  if (grepl("\\s", class)) {
    stop("has_class: `class` cannot contain any whitespace")
  }

  classes <- htmltools::tagGetAttribute(tag, "class")
  if (is.null(classes)) {
    return(FALSE)
  }
  classes <- strsplit(classes, "\\s+")[[1]]
  class %in% classes
}

is_checkbox <- function(tag) {
  is_checkbox <- tryCatch({
    if (!inherits(tag, "shiny.tag")) {
      return(FALSE)
    }
    if (!has_class(tag, "shiny-input-container")) {
      return(FALSE)
    }
    if (length(tag$children) == 0) {
      return(FALSE)
    }
    if (!tag$children[[1]]$name == "div") {
      return(FALSE)
    }
    if (!has_class(tag$children[[1]], "checkbox")) {
      return(FALSE)
    }

    TRUE
  }, error = function(e) {
    FALSE
  })
  is_checkbox
}

is_string <- function(x) {
  is.character(x) && length(x) == 1L && !is.na(x)
}

# `NA` is how a caller asks for a tooltip option to be dropped rather than changed
is_removal <- function(x) {
  length(x) == 1L && is.na(x)
}

check_text <- function(x, allow_removal = FALSE) {
  if (is.null(x)) return()
  if (allow_removal && is_removal(x)) return()
  if (!is_string(x) || !nzchar(trimws(x))) {
    stop("tip: `content` and `content_disabled` must be single non-empty strings", call. = FALSE)
  }
}

check_id <- function(id) {
  if (is.null(id)) return()
  if (!is_string(id) || !nzchar(trimws(id))) {
    stop("tip: `id` must be a single non-empty string", call. = FALSE)
  }
}

# Tooltip text keeps its line breaks only when balloon.css is told to expect them
has_newline <- function(...) {
  texts <- Filter(is_string, list(...))
  any(vapply(texts, grepl, logical(1), pattern = "\n", fixed = TRUE))
}

# Drop the entries that stand for "this attribute/property should not be present"
drop_removals <- function(x) {
  x[!vapply(x, is_removal, logical(1))]
}

# A bare number in a theme is taken to mean pixels
css_px <- function(x) {
  if (is.numeric(x)) paste0(x, "px") else x
}

question_icon <- function(solid) {
  shiny::icon("question-circle", class = if (solid) "fa-solid")
}

# The CSS is all a tooltip needs. The JavaScript is only attached to tooltips that were given
# an `id`, so that apps that never call `tip_update()` stay free of JavaScript.
shinytip_dependencies <- function(updatable) {
  if (is.null(.shinytipglobals$deps)) {
    version <- as.character(utils::packageVersion("shinytip"))
    .shinytipglobals$deps <- list(
      htmltools::htmlDependency(
        name = "balloon-css",
        version = "1.2.0",
        package = "shinytip",
        src = "assets/lib/balloon-1.2.0",
        stylesheet = "balloon.min.css"
      ),
      htmltools::htmlDependency(
        name = "shinytip",
        version = version,
        package = "shinytip",
        src = "assets/css",
        stylesheet = "shinytip.css"
      )
    )
    .shinytipglobals$update_dep <- htmltools::htmlDependency(
      name = "shinytip-update",
      version = version,
      package = "shinytip",
      src = "assets/js",
      script = "shinytip.js"
    )
  }
  c(.shinytipglobals$deps, if (updatable) list(.shinytipglobals$update_dep))
}
