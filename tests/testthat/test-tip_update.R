# A stand-in for a Shiny session that records what gets sent to the browser. The `ns()`
# prefix mimics what a module's session does to an id.
fake_session <- function() {
  sent <- NULL
  list(
    ns = function(id) paste0("mod-", id),
    sendCustomMessage = function(type, message) {
      sent <<- list(type = type, message = message)
      invisible(NULL)
    },
    sent = function() sent
  )
}

test_that("tip_update() sends the new text to the browser", {
  session <- fake_session()
  tip_update("my_tip", content = "new text", session = session)

  expect_identical(session$sent()$type, "shinytip-update")
  expect_identical(session$sent()$message$attrs, list("data-shinytip-label" = "new text"))
})

test_that("tip_update() namespaces the id the way Shiny inputs are namespaced", {
  session <- fake_session()
  tip_update("my_tip", content = "new text", session = session)
  expect_identical(session$sent()$message$id, "mod-my_tip")
})

test_that("tip_update() sends only the options that were given", {
  session <- fake_session()
  tip_update("my_tip", position = "right", session = session)

  expect_named(session$sent()$message$attrs, "data-balloon-pos")
  expect_identical(session$sent()$message$attrs[["data-balloon-pos"]], "right")
  expect_length(session$sent()$message$style, 0)
})

test_that("tip_update() translates position and width the same way tip() does", {
  session <- fake_session()
  tip_update("my_tip", position = "bottom-left", width = "xl", session = session)
  expect_identical(
    session$sent()$message$attrs,
    list("data-balloon-pos" = "down-left", "data-balloon-length" = "xlarge")
  )
})

test_that("tip_update() sends a theme as individual CSS properties", {
  session <- fake_session()
  tip_update("my_tip", theme = tip_theme(bg = "red", fontsize = 20), session = session)

  style <- session$sent()$message$style
  expect_identical(style[["--balloon-color"]], "red")
  expect_identical(style[["--balloon-font-size"]], "20px")
  # the properties a theme leaves at their default are still sent, so that switching
  # themes cannot leave the previous theme's properties behind
  expect_identical(style[["--balloon-text-color"]], "white")
})

test_that("tip_update() asks the browser to drop attributes with a null", {
  session <- fake_session()
  tip_update("my_tip", content_disabled = NA, width = "line", session = session)

  attrs <- session$sent()$message$attrs
  expect_true(is.na(attrs[["data-shinytip-content-disabled"]]))
  expect_true(is.na(attrs[["data-balloon-length"]]))
  expect_match(shiny:::toJSON(attrs), '"data-shinytip-content-disabled":null', fixed = TRUE)
})

test_that("tip_update() refuses to leave a tooltip with no text at all", {
  session <- fake_session()
  expect_error(
    tip_update("my_tip", content = NA, content_disabled = NA, session = session),
    "must keep either `content` or `content_disabled`"
  )
})

test_that("tip_update() validates its arguments the same way tip() does", {
  session <- fake_session()
  expect_error(tip_update("my_tip", content = "", session = session), "single non-empty string")
  expect_error(tip_update("my_tip", content = c("a", "b"), session = session),
               "single non-empty string")
  expect_error(tip_update("my_tip", position = "up", session = session),
               "`position` must be one of")
  expect_error(tip_update("my_tip", width = "100px", session = session), "`width` must be one of")
  expect_error(tip_update("my_tip", theme = list(bg = "red"), session = session), "tip_theme")
})

test_that("tip_update() needs an id and a session", {
  expect_error(tip_update(content = "x", session = fake_session()), "Must provide `id`")
  expect_error(tip_update("", content = "x", session = fake_session()),
               "`id` must be a single non-empty string")
  expect_error(tip_update("my_tip", content = "x", session = NULL),
               "must be called from inside a Shiny server function")
})

test_that("tip_update() returns nothing", {
  expect_null(tip_update("my_tip", content = "x", session = fake_session()))
})
