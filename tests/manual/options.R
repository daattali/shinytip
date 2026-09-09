library(shiny)
library(shinytip)

options(
  "shinytip.position" = "bottom-right",
  "shinytip.length" = "m",
  "shinytip.bg" = "black",
  "shinytip.fg" = "green",
  "shinytip.size" = 20,
  "shinytip.click" = TRUE,
  "shinytip.animate" = FALSE,
  "shinytip.pointer" = FALSE
)

sample_text <- "Lorem ipsum dolor sit amet, consectetur adipiscing elit."

ui <- fluidPage(
  tip(
    "default tip (requires a click)",
    sample_text
  ), br(),
  tip(
    "blue tip on bottom",
    sample_text,
    position = "bottom-left",
    fg = "white",
    bg = "red",
    click = FALSE
  )
)
server <- function(input, output, session) {

}

shinyApp(ui, server)
