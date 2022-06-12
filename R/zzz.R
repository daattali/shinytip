.onLoad <- function(libname, pkgname) {
  shiny::addResourcePath(prefix = "shinytip-assets", directoryPath = system.file("assets", package = "shinytip"))
}

.onUnload <- function(libname, pkgname) {
  if (utils::packageVersion("shiny") >= "1.4.0") {
    shiny::removeResourcePath("shinytip-assets")
  }
}
