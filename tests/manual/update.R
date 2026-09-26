library(shiny)
library(shinytip)

mod_UI <- function(id) {
  ns <- NS(id)
  tagList(
    actionButton(ns("go"), paste("Update", id)),
    tip(span(paste("Module", id)), "Not updated yet", tip_id = ns("mod_tip"))
  )
}

mod_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$go, {
      tip_update("mod_tip", paste("Module", id, "updated", input$go, "times"))
    })
  })
}

ui <- fluidPage(
  shinyjs::useShinyjs(),
  br(),
  fluidRow(
    column(
      width = 6,

      h4("Different kinds of tooltips"),
      actionButton("kinds", "Update all of them"), br(), br(),
      tip(span("tip() on text"), "Original text", tip_id = "simple_tip"), br(),
      "tip_icon()", tip_icon("Original text", tip_id = "simple_icon"), br(),
      tip_input(textInput("simple_input", "tip_input()"), "Original text", tip_id = "simple_input_tip"),
      hr(),

      h4("Updates while open: hover and keep the mouse here"),
      tip(span("Ticking tooltip"), "Waiting...", tip_id = "ticker"),
      hr(),

      h4("Multi-line text"),
      actionButton("multi", "Toggle between one and several lines"), br(), br(),
      tip(span("Hover me"), "Just one line", tip_id = "multi_tip", position = "right")
    ),

    column(
      width = 6,

      h4("Disabled text"),
      actionButton("toggle", "Toggle disabled state"),
      actionButton("add_disabled", "Add content_disabled"),
      actionButton("remove_disabled", "Remove content_disabled"),
      actionButton("remove_content", "Remove content"),
      actionButton("restore_content", "Restore content"),
      actionButton("remove_both", "Remove both (should warn)"),
      br(), br(),
      tip(actionButton("dis_btn", "A button"), "The button is enabled", tip_id = "dis_btn_tip", wrap_tag = TRUE),
      tip_input(textInput("dis_txt", "A text input"), "The input is enabled", tip_id = "dis_txt_tip"),
      hr(),

      h4("Shared tip_id: both are updated"),
      actionButton("shared", "Update"), br(), br(),
      tip(span("First"), "Not updated yet", tip_id = "shared_tip"), " / ",
      tip(span("Second"), "Not updated yet", tip_id = "shared_tip"),
      hr(),

      h4("Modules"),
      mod_UI("one"), br(),
      mod_UI("two"),
      hr(),

      h4("renderUI()"),
      actionButton("render", "Render"),
      actionButton("render_update", "Update"), br(), br(),
      uiOutput("rendered")
    )
  )
)

server <- function(input, output, session) {
  observeEvent(input$kinds, {
    text <- paste("Updated", input$kinds, "times")
    lapply(c("simple_tip", "simple_icon", "simple_input_tip"), tip_update, content = text)
  })

  observe({
    invalidateLater(1000)
    tip_update("ticker", format(Sys.time(), "%H:%M:%S"))
  })

  observeEvent(input$multi, {
    if (input$multi %% 2 == 1) {
      tip_update("multi_tip", "Line one\nLine two\nLine three")
    } else {
      tip_update("multi_tip", "Just one line")
    }
  })

  observeEvent(input$toggle, {
    shinyjs::toggleState("dis_btn")
    shinyjs::toggleState("dis_txt")
  })
  dis_tips <- c("dis_btn_tip", "dis_txt_tip")
  observeEvent(input$add_disabled, {
    lapply(dis_tips, tip_update, content_disabled = "Disabled for a reason")
  })
  observeEvent(input$remove_disabled, {
    lapply(dis_tips, tip_update, content_disabled = NA)
  })
  observeEvent(input$remove_content, {
    lapply(dis_tips, tip_update, content = NA)
  })
  observeEvent(input$restore_content, {
    lapply(dis_tips, tip_update, content = "Enabled again")
  })
  observeEvent(input$remove_both, {
    lapply(dis_tips, tip_update, content = NA, content_disabled = NA)
  })

  observeEvent(input$shared, {
    tip_update("shared_tip", paste("Both updated", input$shared, "times"))
  })

  mod_server("one")
  mod_server("two")

  output$rendered <- renderUI({
    req(input$render)
    tip(span("Rendered tooltip"), paste("Rendered", input$render, "times"), tip_id = "rendered_tip")
  })
  observeEvent(input$render_update, {
    tip_update("rendered_tip", paste("Updated", input$render_update, "times"))
  })
}

shinyApp(ui, server)
