library(shiny)
library(shinytip)

options(
  "shinytip.position" = "bottom-left",
  "shinytip.width" = "m",
  "shinytip.bg" = "black",
  "shinytip.fg" = "green",
  "shinytip.fontsize" = 20,
  "shinytip.animate" = FALSE,
  "shinytip.pointer" = FALSE
)

sample_text <- "Lorem ipsum dolor sit amet, consectetur adipiscing elit."

ui <- fluidPage(
  tip(
    "default tip",
    sample_text
  ), br(),
  tip(
    "blue tip on bottom",
    sample_text,
    fg = "white",
    bg = "red",
    fontsize = 30
  )
)
server <- function(input, output, session) {

}

shinyApp(ui, server)
