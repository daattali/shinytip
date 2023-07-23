library(shiny)

ui <- fluidPage(fluidRow(
  column(
    offset = 2,
    width = 3,
    shinytip::tip_icon("This is the explanation", position = "down"), br(),
    "This one requires a click",
    shinytip::tip_icon("Red background", position = "right", bg = "red", click = TRUE),
    shinytip::tip_input(
      textInput("text", "Name"),
      "Enter your full name"
    ),
    shinytip::tip_input(
      dateInput("date", "DOB (click)"),
      "Enter your date of birth",
      click = TRUE
    ),
    shinytip::tip_input(
      radioButtons("radio", "Label", c("a", "b")),
      "Tooltip"
    ),
    shinytip::tip_input(
      checkboxInput("check", "Label"),
      "Tooltip"
    ),
    shinytip::tip_input(
      checkboxGroupInput("checkgroup", "Label", c("a", "b")),
      "Tooltip"
    )
  ),
  column(
    width = 3,
    shinytip::tip_input(
      sliderInput("num", "Enter a number", 1, 10, 5),
      "The plot will have this many points",
      position = "right"
    ),
    shinytip::tip(
      plotOutput("plot", height = "200"),
      "The slider above controls the number of points"
    ),
    shinycssloaders::withSpinner(
      shinytip::tip(
        plotOutput("plot2", height = "200"),
        "This plot is tip wrapped in spinner",
        position = "left"
      ),
    ),
    "The following plot needs to be clicked",
    shinytip::tip(
      shinycssloaders::withSpinner(
        plotOutput("plot3", height = "200")
      ),
      "This plot is spinner wrapped in tip",
      click = TRUE
    )
  )
))

server <- function(input, output, session) {
  output$plot <- output$plot2 <- output$plot3 <- renderPlot({
    plot(seq(input$num))
  })
}

shinyApp(ui, server)
