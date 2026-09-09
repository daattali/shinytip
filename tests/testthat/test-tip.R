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

test_that("tip() without content_disabled is unchanged", {
  html <- tip_tag(shiny::div(), "hello")
  expect_match(html, 'aria-label="hello"')
  expect_false(grepl("shinytip-disabled-only|shinytip-disabled-swap|data-shinytip-content-disabled", html))
})

test_that("tip() with only content_disabled shows the disabled text", {
  html <- tip_tag(shiny::div(), content_disabled = "why not")
  expect_match(html, 'aria-label="why not"')
  expect_match(html, "shinytip-disabled-only")
  expect_false(grepl("data-shinytip-content-disabled|shinytip-disabled-swap\"", html))
})

test_that("tip() with both texts keeps each in its own attribute", {
  html <- tip_tag(shiny::div(), "hello", "why not")
  expect_match(html, 'aria-label="hello"')
  expect_match(html, 'data-shinytip-content-disabled="why not"')
  expect_match(html, "shinytip-disabled-swap")
  expect_false(grepl("shinytip-disabled-only", html))
})

test_that("tip_input() marks the icon as reading its state from the container", {
  html <- as.character(tip_input(shiny::textInput("test", "test"), content_disabled = "why not"))
  expect_match(html, "shinytip-remote")
  expect_match(html, "shinytip-disabled-only")
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
  direct <- tip_tag(shiny::textInput("test", "test"), content = "hello", content_disabled = "why not", click = TRUE)
  expect_match(direct, "onclick")

  direct <- tip_tag(shiny::textInput("test", "test"), content_disabled = "why not", click = TRUE)
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
