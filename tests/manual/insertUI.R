library(shiny)

ui <- fluidPage(
  actionButton("click", "click")
)

server <- function(input, output, session) {
  observeEvent(input$click, {
    insertUI("body", "beforeEnd", ui = tagList(
      "no tooltip here",
      shinytip::tip("but yes here", "hello!")
    ))
  })
}

shinyApp(ui, server)
