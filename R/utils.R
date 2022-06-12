is_checkbox <- function(tag) {
  if (!inherits(tag, "shiny.tag")) {
    return(FALSE)
  }

  classes <- htmltools::tagGetAttribute(tag, "class")
  if (is.null(classes) || !"shiny-input-container" %in% strsplit(classes, " ")[[1]]) {
    return(FALSE)
  }

  if (!tag$children[[1]]$name == "div") {
    return(FALSE)
  }

  child_classes <- htmltools::tagGetAttribute(tag$children[[1]], "class")
  if (is.null(child_classes) || !"checkbox" %in% strsplit(child_classes, " ")[[1]]) {
    return(FALSE)
  }

  if (!tag$children[[1]]$children[[1]]$name == "label") {
    return(FALSE)
  }

  TRUE
}
