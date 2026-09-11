library(shiny)
library(shinytip)

sample_text <- "Lorem ipsum dolor sit amet, consectetur adipiscing elit."

ui <- fluidPage(fluidRow(
  column(
    offset = 2,
    width = 3,
    h2("Simple tip() calls"),
    tip(
      "tip on right",
      sample_text,
      position = "right"
    ), br(),
    tip(
      "tip on the bottom right, small",
      sample_text,
      position = "bottom-right",
      width = "s"
    ), br(),
    tip(
      "tip on the top left, extra large",
      sample_text,
      position = "top-left",
      width = "xl"
    ), br(),
    tip(
      div("tip on a div; bottom, red background, yellow colour, fit within the dimensions of the parent"),
      sample_text,
      position = "bottom",
      width = "fit",
      theme = tip_theme(bg = "red", fg = "yellow")
    ),
    tip(
     "don't animate, don't change cursor, size 20, rounded corners",
      sample_text,
      width = "fit",
      theme = tip_theme(animate = FALSE, pointer = FALSE, fontsize = 20, radius = 12)
    ), br(),
    tip(
      "slides in from far away",
      sample_text,
      width = "fit",
      theme = tip_theme(move = 40)
    ), br(),
    tip(
      "custom `style` on the tag (via ...), plus a theme on the tooltip",
      sample_text,
      theme = tip_theme(bg = "darkgreen"),
      style = "font-size: 2rem;"
    ), br(),
    tip(
      tagList("one", "two", div("three")),
      "tooltip on tagList"
    ), br(),
    tip(
      "pure text with emoji",
      "tooltip on pure text 😂"
    ),
    tip(
      span("simple span"),
      "tooltip on simple span"
    ),
    tip(
      h3("tooltip on h3"),
      sample_text
    ),
    tip(
      tags$input(),
      "tooltip on input"
    ), br(),
    tip(
      textInput("test", "tip on shiny input"),
      sample_text
    ),
    tip(
      shiny::icon("pencil"),
      "tip on an icon"
    )
  )
))

server <- function(input, output, session) {

}

shinyApp(ui, server)
