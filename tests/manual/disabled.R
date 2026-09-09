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
  fluidRow(column(
    offset = 2, width = 5,

    actionButton("toggle", "Toggle disabled state"),
    hr(),

    h4("tip() with only content_disabled"),
    tip(actionButton("btn", "A button"), content_disabled = "The button is disabled"),
    tip(textInput("txt", "A text input"), content_disabled = "The text input is disabled"),
    tip(selectInput("sel", "A select input", c("a", "b")), content_disabled = "The select is disabled"),
    tip(sliderInput("sld", "A slider", 0, 10, 5), content_disabled = "The slider is disabled"),
    tip(checkboxInput("chk", "A checkbox"), content_disabled = "The checkbox is disabled"),
    hr(),

    h4("tip() with both texts"),
    tip(textInput("txt2", "A text input"), "Type your name", "You can't type right now"),
    tip(actionButton("btn2", "Another button"), "Click me", "You can't click right now"),
    hr(),

    h4("tip_input() with only content_disabled"),
    tip_input(textInput("txt3", "A text input"), content_disabled = "The text input is disabled"),
    tip_input(checkboxInput("chk2", "A checkbox"), content_disabled = "The checkbox is disabled"),
    hr(),

    h4("tip_input() with both texts"),
    tip_input(textInput("txt4", "A text input"), "Type your name", "You can't type right now"),
    tip_input(selectInput("sel2", "A select input", c("a", "b")), "Pick one", "Nothing to pick yet"),
    hr(),

    h4("Both texts with click = TRUE, which is kept: click the input to open the tooltip"),
    tip(
      textInput("txt8", "A text input"),
      "Type your name", "You can't type right now",
      click = TRUE
    ),
    hr(),

    h4("click = TRUE is ignored here, so these behave like the hover ones above"),
    tip(
      textInput("txt6", "A text input"),
      content_disabled = "The text input is disabled",
      click = TRUE
    ),
    hr(),

    h4("tip_input() with click = TRUE, likewise ignored"),
    tip_input(
      textInput("txt7", "A text input"),
      content_disabled = "The text input is disabled",
      click = TRUE
    ),
    hr(),

    h4("Element with no disabled state, toggled manually"),
    tip(span("Some text"), "All good", "Something went wrong", id = "text"),
    hr(),

    h4("Unaffected by the disabled state"),
    tip(actionButton("btn3", "Always tipped"), "A regular tooltip"),
    tip_input(textInput("txt5", "A text input"), "A regular tooltip")
  ))
)

server <- function(input, output, session) {
  disabled <- reactiveVal(FALSE)
  observeEvent(input$toggle, {
    disabled(!disabled())
    inputs <- c("btn", "txt", "sel", "sld", "chk", "txt2", "btn2",
                "txt3", "chk2", "txt4", "sel2", "txt8", "txt6", "txt7", "btn3", "txt5")
    if (disabled()) {
      lapply(inputs, shinyjs::disable)
      shinyjs::addClass("text", "shinytip-disabled")
    } else {
      lapply(inputs, shinyjs::enable)
      shinyjs::removeClass("text", "shinytip-disabled")
    }
  })
}

shinyApp(ui, server)
