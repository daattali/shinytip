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
    if (length(tags$children) == 0) {
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

check_text <- function(x) {
  if (is.null(x)) return()
  if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(trimws(x))) {
    stop("tip: `content` and `content_disabled` must be single non-empty strings", call. = FALSE)
  }
}

question_icon <- function(solid) {
  shiny::icon("question-circle", class = if (solid) "fa-solid")
}

shinytip_dependencies <- function() {
  if (is.null(.shinytipglobals$deps)) {
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
        version = as.character(utils::packageVersion("shinytip")),
        package = "shinytip",
        src = "assets/css",
        stylesheet = "shinytip.css"
      )
    )
  }
  .shinytipglobals$deps
}
