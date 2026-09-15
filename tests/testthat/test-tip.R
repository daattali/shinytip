tip_tag <- function(...) {
  as.character(tip(...))
}

test_that("tip() requires some content", {
  expect_error(tip(shiny::div("test")), "Must provide `content`")
})

test_that("tooltip text must be a single non-empty string", {
  for (bad in list("", "   ", NA, NA_character_, c("a", "b"), character(0), 42, TRUE, list("a"))) {
    expect_error(tip(shiny::div(), bad), "single non-empty string")
    expect_error(tip(shiny::div(), content_disabled = bad), "single non-empty string")
  }
  expect_silent(tip(shiny::div(), "ok"))
  expect_silent(tip(shiny::div(), content_disabled = "ok"))
})

test_that("tip() without content_disabled only has the regular text", {
  html <- tip_tag(shiny::div(), "hello")
  expect_match(html, 'data-shinytip-label="hello"')
  expect_false(grepl("data-shinytip-content-disabled", html))
})

test_that("tip() empties aria-label so it never overrides an element's accessible name", {
  html <- tip_tag(shiny::actionButton("b", "Save"), "Saves your work")
  expect_match(html, 'aria-label=""')
  expect_match(html, 'data-shinytip-label="Saves your work"')
})

test_that("tip() with only content_disabled has no regular text", {
  html <- tip_tag(shiny::div(), content_disabled = "why not")
  expect_match(html, 'data-shinytip-content-disabled="why not"')
  expect_false(grepl("data-shinytip-label", html))
})

test_that("tip() with both texts keeps each in its own attribute", {
  html <- tip_tag(shiny::div(), "hello", "why not")
  expect_match(html, 'data-shinytip-label="hello"')
  expect_match(html, 'data-shinytip-content-disabled="why not"')
})

test_that("tip_input() marks the icon as reading its state from the container", {
  html <- as.character(tip_input(shiny::textInput("test", "test"), content_disabled = "why not"))
  expect_match(html, "shinytip-remote")
  expect_match(html, 'data-shinytip-content-disabled="why not"')
  expect_false(grepl("data-shinytip-label", html))
})

test_that("tip_input() without content_disabled is unchanged", {
  html <- as.character(tip_input(shiny::textInput("test", "test"), "hello"))
  expect_false(grepl("shinytip-remote", html))
})

test_that("tip_input() works on checkboxes, which have no <label> of their own", {
  html <- as.character(tip_input(shiny::checkboxInput("test", "test"), "hello", "why not"))
  expect_match(html, "shinytip-remote")
  expect_match(html, 'data-shinytip-content-disabled="why not"')
})

test_that("click is ignored when content_disabled is the only text", {
  direct <- as.character(tip_icon(content = "hello", click = TRUE))
  expect_match(direct, "onclick")
  direct <- as.character(
    tip_input(shiny::textInput("test", "test"), content_disabled = "why not", click = TRUE)
  )
  expect_false(grepl("onclick", direct))

  remote <- as.character(
    tip_input(shiny::textInput("test", "test"), content_disabled = "why not", click = TRUE)
  )
  expect_false(grepl("onclick", remote))
})

test_that("every exported function returns a shiny tag", {
  expect_s3_class(tip("x", "y"), "shiny.tag")
  expect_s3_class(tip_icon("y"), "shiny.tag")
  expect_s3_class(tip_input(shiny::textInput("test", "test"), "y"), "shiny.tag")
})

test_that("the returned tag still answers to htmltools verbs", {
  tagged <- htmltools::tagAppendAttributes(tip("x", "y"), class = "foo")
  rendered <- htmltools::renderTags(tagged)
  expect_match(as.character(rendered$html), 'class="shinytip foo"')
  expect_length(rendered$dependencies, 2)
})

test_that("dependencies already on the caller's tag are kept", {
  own <- htmltools::attachDependencies(
    shiny::div(), htmltools::htmlDependency("mine", "1.0", src = c(href = "x"))
  )
  deps <- htmltools::renderTags(tip(own, "hello"))$dependencies
  expect_true("mine" %in% vapply(deps, `[[`, character(1), "name"))
  expect_true("shinytip" %in% vapply(deps, `[[`, character(1), "name"))
})

test_that("`theme` sets the tooltip appearance", {
  expect_match(as.character(tip("x", "y", theme = tip_theme(bg = "red"))),
               "--balloon-color: red", fixed = TRUE)
  expect_match(as.character(tip("x", "y", theme = tip_theme(fg = "pink", fontsize = 20))),
               "--balloon-text-color: pink; --balloon-font-size: 20px;", fixed = TRUE)
  expect_match(as.character(tip("x", "y", theme = tip_theme(radius = "1em", move = "0.5rem"))),
               "--balloon-border-radius: 1em; --balloon-move: 0.5rem;", fixed = TRUE)
})

test_that("`radius` and `move` fall back to the balloon.css defaults", {
  expect_match(tip_tag("x", "y"), "--balloon-border-radius: 2px;", fixed = TRUE)
  expect_match(tip_tag("x", "y"), "--balloon-move: 4px;", fixed = TRUE)
})

test_that("`theme` rejects anything that is not a tip_theme() object", {
  expect_error(tip("x", "y", theme = list(bg = "red")), "tip_theme")
  expect_error(tip("x", "y", theme = "border: 1px solid red"), "tip_theme")
  expect_error(tip("x", "y", theme = NULL), "tip_theme")
})

test_that("a `style` passed through `...` is merged onto the tag, alongside the theme", {
  html <- as.character(tip("x", "y", theme = tip_theme(bg = "red"), style = "margin: 5px"))
  expect_match(html, "--balloon-color: red", fixed = TRUE)
  expect_match(html, "margin: 5px", fixed = TRUE)
  expect_length(gregexpr("style=", html, fixed = TRUE)[[1]], 1L)

  expect_match(as.character(tip(shiny::img(src = "x.png"), "y", style = "margin: 5px")),
               "shinytip-inline", fixed = TRUE)

  expect_match(as.character(tip_icon("y", style = "color: gray")), "color: gray", fixed = TRUE)
})

test_that("position is translated to the balloon.css value", {
  expect_match(tip_tag("x", "y", position = "top"), 'data-balloon-pos="up"')
  expect_match(tip_tag("x", "y", position = "bottom"), 'data-balloon-pos="down"')
  expect_match(tip_tag("x", "y", position = "left"), 'data-balloon-pos="left"')
  expect_match(tip_tag("x", "y", position = "bottom-left"), 'data-balloon-pos="down-left"')
  expect_match(tip_tag("x", "y", position = "top-right"), 'data-balloon-pos="up-right"')
})

test_that("width is translated to the balloon.css value", {
  expect_match(tip_tag("x", "y", width = "fit"), 'data-balloon-length="fit"')
  expect_match(tip_tag("x", "y", width = "s"), 'data-balloon-length="small"')
  expect_match(tip_tag("x", "y", width = "m"), 'data-balloon-length="medium"')
  expect_match(tip_tag("x", "y", width = "xl"), 'data-balloon-length="xlarge"')
  expect_false(grepl("data-balloon-length", tip_tag("x", "y", width = "line")))
})

test_that("position and width must be one of the allowed values", {
  expect_error(tip("x", "y", position = "up"), "`position` must be one of")
  expect_error(tip("x", "y", width = "100px"), "`width` must be one of")
})

test_that("a newline in the tooltip text allows the tooltip to wrap", {
  expect_match(tip_tag("x", "a\nb"), "data-balloon-break")
  expect_match(tip_tag("x", content_disabled = "a\nb"), "data-balloon-break")
  expect_false(grepl("data-balloon-break", tip_tag("x", "a b")))
})

test_that("animate = FALSE removes the animation", {
  expect_match(tip_tag("x", "y", theme = tip_theme(animate = FALSE)), "data-balloon-blunt")
  expect_false(grepl("data-balloon-blunt", tip_tag("x", "y")))
})

test_that("pointer = FALSE leaves the cursor alone", {
  expect_match(tip_tag("x", "y", theme = tip_theme(pointer = FALSE)), "cursor: inherit", fixed = TRUE)
  expect_false(grepl("cursor", tip_tag("x", "y")))
})

test_that("a numeric length in a theme is treated as pixels", {
  expect_match(tip_tag("x", "y", theme = tip_theme(fontsize = 20)),
               "--balloon-font-size: 20px", fixed = TRUE)
  expect_match(tip_tag("x", "y", theme = tip_theme(fontsize = "2rem")),
               "--balloon-font-size: 2rem", fixed = TRUE)
  expect_match(tip_tag("x", "y", theme = tip_theme(radius = 8)),
               "--balloon-border-radius: 8px", fixed = TRUE)
  expect_match(tip_tag("x", "y", theme = tip_theme(move = 12)),
               "--balloon-move: 12px", fixed = TRUE)
})

test_that("elements that cannot have pseudo-elements are wrapped in a div", {
  wrapped <- list(
    shiny::img(src = "x.png"), shiny::tags$input(), shiny::icon("star"),
    shiny::tags$select(), shiny::tags$textarea(), shiny::tagList("a", "b")
  )
  for (tag in wrapped) {
    html <- tip_tag(tag, "y")
    expect_match(html, "^<div")
    expect_match(html, "shinytip-inline")
  }
  expect_false(grepl("shinytip-inline", tip_tag(shiny::div(), "y")))
})

test_that("plain text is wrapped in a span", {
  expect_match(tip_tag("some text", "y"), "^<span")
  expect_false(grepl("shinytip-inline", tip_tag("some text", "y")))
})

test_that("tip_icon() requires content and rejects content_disabled", {
  expect_error(tip_icon(), "Must provide `content`")
  expect_error(tip_icon("y", content_disabled = "z"), "not supported")
})

test_that("tip_input() requires a shiny input that has a label", {
  expect_error(tip_input("x", "y"), "must be a Shiny input tag")
  expect_error(tip_input(shiny::div(), "y"), "must be a Shiny input tag")
  expect_error(tip_input(shiny::textInput("test", NULL), "y"), "must have a label")
  expect_error(tip_input(shiny::textInput("test", "test"), "y"), NA)
})

test_that("tip() requires a tag", {
  expect_error(tip(NULL, "y"), "`tag` must not be empty")
  expect_error(tip(list(), "y"), "`tag` must not be empty")
  expect_error(tip("y", "y"), NA)
})

test_that("click is only accepted by tip_icon() and tip_input()", {
  expect_match(as.character(tip_icon("y", click = TRUE)), "onclick")
  expect_match(as.character(tip_input(shiny::textInput("t", "T"), "y", click = TRUE)), "onclick")
  expect_error(tip("x", "y", click = TRUE))
})

test_that("defaults can be set with global options", {
  withr::with_options(
    list(shinytip.position = "right", shinytip.width = "l",
         shinytip.bg = "pink", shinytip.solid = TRUE, shinytip.click = TRUE),
    {
      html <- tip_tag("x", "y")
      expect_match(html, 'data-balloon-pos="right"')
      expect_match(html, 'data-balloon-length="large"')
      expect_match(html, "--balloon-color: pink", fixed = TRUE)
      expect_match(as.character(tip_icon("y")), "fa-solid")
      expect_match(as.character(tip_icon("y")), "onclick")
    }
  )
})

test_that("wrap_tag = TRUE wraps the tag and moves the tooltip onto the wrapper", {
  html <- tip_tag(shiny::actionButton("b", "go"), "y", wrap_tag = TRUE)
  expect_match(html, "^<div")
  expect_match(html, "shinytip-inline")
  outer <- substr(html, 1, regexpr(">", html, fixed = TRUE))
  expect_match(outer, "data-balloon-pos", fixed = TRUE)
  expect_match(outer, "shinytip-inline", fixed = TRUE)
  button <- substring(html, regexpr("<button", html, fixed = TRUE))
  expect_false(grepl("data-balloon-pos", button, fixed = TRUE))
  expect_false(grepl("shinytip", button, fixed = TRUE))
})

test_that("`...` lands on the wrapper when wrap_tag = TRUE", {
  html <- tip_tag(shiny::actionButton("b", "go"), "y", wrap_tag = TRUE, style = "margin: 5px")
  expect_match(html, "^<div")
  outer <- substr(html, 1, regexpr(">", html, fixed = TRUE))
  expect_match(outer, "margin: 5px", fixed = TRUE)
})

test_that("wrap_tag must be a single TRUE or FALSE", {
  expect_error(tip("x", "y", wrap_tag = "yes"), "`wrap_tag` must be either")
  expect_error(tip("x", "y", wrap_tag = NA), "`wrap_tag` must be either")
  expect_error(tip("x", "y", wrap_tag = c(TRUE, FALSE)), "`wrap_tag` must be either")
})

test_that("wrap_tag can be set with a global option", {
  withr::with_options(list(shinytip.wrap_tag = TRUE), {
    expect_match(tip_tag(shiny::actionButton("b", "go"), "y"), "shinytip-inline")
  })
  expect_no_match(tip_tag(shiny::actionButton("b", "go"), "y"), "shinytip-inline")
})

test_that("wrap_tag is rejected by tip_icon() and tip_input()", {
  expect_error(tip_icon("y", wrap_tag = TRUE), "`wrap_tag` is not supported")
  expect_error(tip_input(shiny::textInput("t", "T"), "y", wrap_tag = TRUE),
               "`wrap_tag` is not supported")
})

test_that("`id` names the tooltip without touching the tag's own id", {
  html <- tip_tag(shiny::actionButton("btn", "go"), "y", id = "btn")
  expect_match(html, 'data-shinytip-id="btn"')
  # the button keeps the one `id` that Shiny gave it
  expect_length(gregexpr(' id="btn"', html, fixed = TRUE)[[1]], 1L)
})

test_that("`id` lands on whichever element carries the tooltip", {
  # the element that gets the tooltip differs by case, but the id always rides along with it
  carriers <- list(
    text = tip_tag("some text", "y", id = "t"),
    tag = tip_tag(shiny::div(), "y", id = "t"),
    wrapped = tip_tag(shiny::img(src = "x.png"), "y", id = "t"),
    wrap_tag = tip_tag(shiny::actionButton("b", "go"), "y", id = "t", wrap_tag = TRUE),
    icon = as.character(tip_icon("y", id = "t")),
    input = as.character(tip_input(shiny::textInput("i", "I"), "y", id = "t"))
  )
  for (html in carriers) {
    opening <- regmatches(html, regexpr("<[^>]*data-balloon-pos[^>]*>", html))
    expect_match(opening, 'data-shinytip-id="t"')
  }
})

test_that("`id` must be a single non-empty string", {
  for (bad in list("", "  ", NA, c("a", "b"), 42, list("a"))) {
    expect_error(tip("x", "y", id = bad), "`id` must be a single non-empty string")
  }
  expect_silent(tip("x", "y", id = "ok"))
})
