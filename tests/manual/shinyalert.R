library(shiny)

ui <- fluidPage()

server <- function(input, output, session) {
  shinyalert::shinyalert(text = shinytip::tip("Hover over me", "Hello!"), html = TRUE)
}

shinyApp(ui, server)
