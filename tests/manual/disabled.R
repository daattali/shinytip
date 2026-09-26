library(shiny)
library(shinytip)

# Toggle the button to disable/enable every input, and check that:
#  - the "only disabled" tooltips are invisible (and their icons hidden) while enabled
#  - the "both texts" tooltips swap their text when the state changes
#  - hovering a disabled input still triggers its tooltip
#  - toggling twice does not leave a tooltip stuck open

ui <- fluidPage(
  shinyjs::useShinyjs(),
  br(),
  actionButton("toggle", "Toggle disabled state", class = "btn-primary btn-lg"),
  div(id = "all_inputs",
    fluidRow(
      column(
        width = 6,

        h4("tip() with only content_disabled"),
        tip(actionButton("btn", "A button"), content_disabled = "The button is disabled", wrap_tag = TRUE),
        tip(textInput("txt", "A text input"), content_disabled = "The text input is disabled"),
        tip(selectInput("sel", "A select input", c("a", "b")), content_disabled = "The select is disabled"),
        tip(sliderInput("sld", "A slider", 0, 10, 5), content_disabled = "The slider is disabled"),
        tip(checkboxInput("chk", "A checkbox"), content_disabled = "The checkbox is disabled"),
        hr(),

        h4("tip() with both texts"),
        tip(textInput("txt2", "A text input"), "Type your name", "You can't type right now"),
        tip(actionButton("btn2", "Another button"), "Click me", "You can't click right now", wrap_tag = TRUE),
        hr(),

        h4("tip_input() with only content_disabled"),
        tip_input(textInput("txt3", "A text input"), content_disabled = "The text input is disabled"),
        tip_input(checkboxInput("chk2", "A checkbox"), content_disabled = "The checkbox is disabled"),
      ),

      column(
        width = 6,

        h4("tip_input() with both texts"),
        tip_input(textInput("txt4", "A text input"), "Type your name", "You can't type right now"),
        tip_input(selectInput("sel2", "A select input", c("a", "b")), "Pick one", "Nothing to pick yet"),
        hr(),

        h4("Both texts with click = TRUE: click the icon to open the tooltip, and the text swaps"),
        tip_input(
          textInput("txt8", "A text input"),
          "Type your name", "You can't type right now",
          click = TRUE
        ),
        hr(),

        h4("tip_input() with click = TRUE, ignored because there is no enabled-state text"),
        tip_input(
          textInput("txt7", "A text input"),
          content_disabled = "The text input is disabled",
          click = TRUE
        ),
        hr(),

        h4("Unaffected by the disabled state"),
        tip(actionButton("btn3", "Always tipped"), "A regular tooltip", wrap_tag = TRUE),
        tip_input(textInput("txt5", "A text input"), "A regular tooltip")
      )
    )
  )
)

server <- function(input, output, session) {
  observeEvent(input$toggle, {
    shinyjs::toggleState("all_inputs")
  })
}

shinyApp(ui, server)
