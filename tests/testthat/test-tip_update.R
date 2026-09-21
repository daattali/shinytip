# Runs tip_update() against a stand-in session, and returns the message as JSON, which is how
# the browser receives it
update_json <- function(...) {
  sent <- NULL
  session <- list(
    ns = function(id) paste0("mod-", id),
    sendCustomMessage = function(type, message) sent <<- list(type = type, message = message)
  )
  tip_update("t", ..., session = session)
  expect_identical(sent$type, "shinytip-update")
  as.character(shiny:::toJSON(sent$message))
}

test_that("tip_update() sends the new text, namespaced like a Shiny input", {
  expect_identical(update_json(content = "new"), '{"id":"mod-t","content":"new"}')
})

test_that("a text that is left out is not sent, so the browser keeps it", {
  expect_no_match(update_json(content = "new"), "content_disabled")
  expect_no_match(update_json(content_disabled = "new"), '"content"')
})

test_that("a text can be added or changed", {
  expect_match(update_json(content = "a", content_disabled = "b"),
               '"content":"a","content_disabled":"b"', fixed = TRUE)
})

test_that("NA removes a text, by reaching the browser as null", {
  expect_match(update_json(content_disabled = NA), '"content_disabled":null', fixed = TRUE)
  expect_match(update_json(content = NA, content_disabled = "b"), '"content":null', fixed = TRUE)
})

test_that("tip_update() validates the text", {
  for (bad in list("", "  ", c("a", "b"), 42, TRUE, list("a"))) {
    expect_error(update_json(content = bad), "single non-empty string")
    expect_error(update_json(content_disabled = bad), "single non-empty string")
  }
})
