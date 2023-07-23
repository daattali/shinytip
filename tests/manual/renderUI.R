library(shiny)

ui <- fluidPage(
  actionButton("click", "click"),
  uiOutput("ui")
)

server <- function(input, output, session) {
  output$ui <- renderUI({
    req(input$click)

    tagList(
      "no tooltip here",
      shinytip::tip("but yes here", "hello!")
    )
  })
}

shinyApp(ui, server)
