test_that("tip_theme() returns an object holding the package defaults", {
  theme <- tip_theme()
  expect_s3_class(theme, "shinytip_theme")
  expect_identical(theme$bg, "black")
  expect_identical(theme$fg, "white")
  expect_identical(theme$fontsize, "12px")
  expect_true(theme$animate)
  expect_true(theme$pointer)
})

test_that("tip_theme() reads its defaults from global options", {
  withr::with_options(
    list(shinytip.bg = "pink", shinytip.fg = "navy", shinytip.fontsize = 20,
         shinytip.animate = FALSE, shinytip.pointer = FALSE),
    {
      theme <- tip_theme()
      expect_identical(theme$bg, "pink")
      expect_identical(theme$fg, "navy")
      expect_identical(theme$fontsize, 20)
      expect_false(theme$animate)
      expect_false(theme$pointer)
    }
  )
})

test_that("an explicit argument beats the global option", {
  withr::with_options(list(shinytip.bg = "pink"), {
    expect_identical(tip_theme(bg = "red")$bg, "red")
  })
})

test_that("one theme can be reused across all three functions", {
  theme <- tip_theme(bg = "red")
  expect_match(as.character(tip("x", "y", theme = theme)), "--balloon-color: red", fixed = TRUE)
  expect_match(as.character(tip_icon("y", theme = theme)), "--balloon-color: red", fixed = TRUE)
  expect_match(as.character(tip_input(shiny::textInput("t", "T"), "y", theme = theme)),
               "--balloon-color: red", fixed = TRUE)
})

test_that("printing a theme lists its values", {
  expect_output(print(tip_theme(bg = "red")), "<shinytip theme>", fixed = TRUE)
  expect_output(print(tip_theme(bg = "red")), "bg *red")
})
