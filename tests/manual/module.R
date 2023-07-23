library(shiny)

mod_UI <- function(id) {
  ns <- NS(id)
  tagList(
    shinytip::tip_input(textInput(ns("test"), ns("test")), ns("helper text"), position = "right")
  )
}

ui <- fluidPage(
  mod_UI("one"),
  mod_UI("two")
)

server <- function(input, output, session) {}

shinyApp(ui, server)
