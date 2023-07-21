test_that("has_class works", {
  expect_error(has_class())
  expect_error(has_class(htmltools::div()))
  expect_error(has_class(htmltools::div(), ""))
  expect_error(has_class(htmltools::div(), "foo bar"))
  expect_error(has_class("foo", "foo"))

  expect_false(has_class(htmltools::div(), "foo"))
  expect_false(has_class(htmltools::div(class = ""), "foo"))
  expect_true(has_class(htmltools::div(class = "foo"), "foo"))
  expect_true(has_class(htmltools::div(class = "foo bar"), "foo"))
  expect_true(has_class(htmltools::div(class = "foo bar"), "bar"))
  expect_false(has_class(htmltools::div(class = "foobar"), "foo"))
})

test_that("is_checkbox works", {
  expect_error(is_checkbox())
  expect_false(is_checkbox("foo"))
  expect_false(is_checkbox(htmltools::div()))
  expect_false(is_checkbox(shiny::textInput("test", "test")))
  expect_true(is_checkbox(shiny::checkboxInput("test", "test")))
  expect_false(is_checkbox(shiny::checkboxGroupInput("test", "test", c("foo", "bar"))))
})
