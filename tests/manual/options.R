library(shiny)
library(shinytip)

options(
  "shinytip.position" = "bottom-left",
  "shinytip.width" = "m",
  "shinytip.bg" = "black",
  "shinytip.fg" = "green",
  "shinytip.fontsize" = 20,
  "shinytip.radius" = 0,
  "shinytip.animate" = FALSE,
  "shinytip.move" = 20,
  "shinytip.pointer" = FALSE
)

sample_text <- "Lorem ipsum dolor sit amet, consectetur adipiscing elit."

ui <- fluidPage(
  tip(
    "default tip: bottom-left, medium, black/green, 20 fontsize, 0 radius, no animate, move 20, no pointer",
    sample_text
  ), br(),
  tip(
    "bottom-right, small, red/white, size 10, radius 8, animate",
    sample_text,
    position = "bottom-right",
    width = "s",
    theme = tip_theme(fg = "white", bg = "red", fontsize = 10, radius = "8px", animate = TRUE)
  )
)
server <- function(input, output, session) {

}

shinyApp(ui, server)
