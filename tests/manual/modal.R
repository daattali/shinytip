library(shiny)

ui <- fluidPage()

server <- function(input, output, session) {
  showModal(modalDialog(
    shinytip::tip("Hover over me", "Hello!")
  ))
}

shinyApp(ui, server)
