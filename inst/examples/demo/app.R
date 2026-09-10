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

  title = paste0("{shinytip} ", as.character(utils::packageVersion("shinytip"))),

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
        "The text can include emojis but not HTML",
        position = "top-left"
      ),
      shinytip::tip_input(
        selectInput("position", "Position", allowed_positions),
        "Tooltip position relative to the tag",
        position = "top-left"
      ),
      selectInput("width", "Width", c("line", "fit", "s", "m", "l", "xl")),
    ),
    column(
      4,
      colourpicker::colourInput("bg", "Background", "black"),
      colourpicker::colourInput("fg", "Text colour", "white"),
      numericInput("fontsize", "Text size", 16),
    ),
    column(
      4,
      shinytip::tip_input(
        textInput("content_disabled", "Disabled text", ""),
        "Shown only while the button is disabled"
      ),
      checkboxInput("disabled", "Disable the button", FALSE),
      br(),
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
    if (nzchar(trimws(input$content))) {
      content <- paste0('  content = "', trimws(input$content), '",\n')
    } else {
      content <- ""
    }
    if (nzchar(trimws(input$content_disabled))) {
      content_disabled <- paste0('  content_disabled = "', trimws(input$content_disabled), '",\n')
    } else {
      content_disabled <- ""
    }
    disabled <- if (input$disabled) ", disabled = TRUE" else ""

    code <- paste0(
      'shinytip::tip(\n',
      '  actionButton("test", "Hover me!"', disabled, '),\n',
      content,
      content_disabled,
      '  position = "', input$position, '",\n',
      '  width = "', input$width, '",\n',
      '  theme = shinytip::tip_theme(\n',
      '    bg = "', input$bg, '",\n',
      '    fg = "', input$fg, '",\n',
      '    fontsize = ', input$fontsize, ',\n',
      '    animate = ', input$animate, ',\n',
      '    pointer = ', input$pointer, '\n',
      '  )\n',
      ')'
    )
  })

  output$code <- renderText({
    clean_code <- sub(", disabled = TRUE", "", code(), fixed = TRUE)
    clean_code
  })

  output$tooltip <- renderUI({
    eval(parse(text = code()))
  })
}

shinyApp(ui, server)
