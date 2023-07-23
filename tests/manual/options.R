library(shiny)
library(shinytip)

options(
  "shinytip.position" = "right",
  "shinytip.length" = "m",
  "shinytip.bg" = "brown",
  "shinytip.fg" = "green",
  "shinytip.size" = 20,
  "shinytip.click" = TRUE,
  "shinytip.animate" = FALSE,
  "shinytip.pointer" = FALSE
)

sample_text <- "Lorem ipsum dolor sit amet, consectetur adipiscing elit."

ui <- fluidPage(
  tip(
    "default tip",
    sample_text
  ),
  tip(
    "blue tip on bottom",
    sample_text,
    position = "bottom",
    fg = "blue",
    click = FALSE
  )
)
server <- function(input, output, session) {

}

shinyApp(ui, server)
