library(shiny)

allowed_positions <- c("top", "bottom", "left", "right", "top-left", "top-right", "bottom-left", "bottom-right")

share <- list(
  title = "{shinytip}",
  url = "https://daattali.com/shiny/shinytip-demo/",
  source = "https://github.com/daattali/shinytip",
  image = "https://daattali.com/shiny/img/shinytip.png",
  description = "Simple flexible tootips for Shiny apps",
  twitter_user = "daattali"
)

ui <- fluidPage(
  shinydisconnect::disconnectMessage2(),

  title = paste0("{shinytip} ", as.character(packageVersion("shinytip"))),

  tags$head(
    tags$link(rel = "stylesheet", href = "style.css"),
    # Favicon
    tags$link(rel = "shortcut icon", type="image/x-icon", href="https://daattali.com/shiny/img/favicon.ico"),
    # Facebook OpenGraph tags
    tags$meta(property = "og:title", content = share$title),
    tags$meta(property = "og:type", content = "website"),
    tags$meta(property = "og:url", content = share$url),
    tags$meta(property = "og:image", content = share$image),
    tags$meta(property = "og:description", content = share$description),

    # Twitter summary cards
    tags$meta(name = "twitter:card", content = "summary"),
    tags$meta(name = "twitter:site", content = paste0("@", share$twitter_user)),
    tags$meta(name = "twitter:creator", content = paste0("@", share$twitter_user)),
    tags$meta(name = "twitter:title", content = share$title),
    tags$meta(name = "twitter:description", content = share$description),
    tags$meta(name = "twitter:image", content = share$image)
  ),

  div(
    id = "header",
    div(id = "pagetitle", share$title),
    div(id = "subtitle", share$description),
    div(
      id = "subsubtitle",
      "Created by",
      tags$a(href = "https://deanattali.com/", "Dean Attali"),
      HTML("&bull;"),
      "Available",
      tags$a(href = share$source, "on GitHub"),
      HTML("&bull;"),
      tags$a(href = "https://daattali.com/shiny/", "More apps"), "by Dean"
    )
  ),

  div(
    id = "main-row",
    uiOutput("tooltip")
  ),

  fluidRow(
    column(
      4,
      shinytip::tip_input(
        textInput("content", "Text", "Hello there 👋 I'm a tooltip from {shinytip}"),
        "The text can include emojis but not HTML"
      ),
      shinytip::tip_input(
        selectInput("position", "Position", allowed_positions),
        "Tooltip position relative to the tag"
      ),
      selectInput("length", "Length", c("line", "fit", "s", "m", "l", "xl")),
    ),
    column(
      4,
      colourpicker::colourInput("bg", "Background", "black"),
      colourpicker::colourInput("fg", "Text colour", "white"),
      numericInput("size", "Text size", 16),
    ),
    column(
      4,
      checkboxInput("click", "Trigger on click", FALSE),
      checkboxInput("animate", "Allow animation", TRUE),
      checkboxInput("pointer", "Change cursor on hover", TRUE)
    )
  ),
  fluidRow(
    column(
      12, h3("Generated code"), verbatimTextOutput("code")
    )
  )
)

server <- function(input, output, session) {
  code <- reactive({
    text <- if (input$click) "Click me!" else "Hover me!"
    code <- paste0(
      'shinytip::tip(\n',
      '  "', text, '",\n',
      '  content = "', input$content, '",\n',
      '  position = "', input$position, '",\n',
      '  length = "', input$length, '",\n',
      '  bg = "', input$bg, '",\n',
      '  fg = "', input$fg, '",\n',
      '  size = ', input$size, ',\n',
      '  click = ', input$click, ',\n',
      '  animate = ', input$animate, ',\n',
      '  pointer = ', input$pointer, ',\n',
      ')'
    )
  })

  output$code <- renderText({
    code()
  })

  output$tooltip <- renderUI({
    eval(parse(text = code()))
  })
}

shinyApp(ui, server)
