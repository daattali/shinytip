% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tip.R
\name{tip_input}
\alias{tip_input}
\title{Add a tooltip to the label of an input}
\usage{
tip_input(
  tag,
  content,
  position = getOption("shinytip.position", "top"),
  length = getOption("shinytip.length", "line"),
  bg = getOption("shinytip.bg", "black"),
  fg = getOption("shinytip.fg", "white"),
  size = getOption("shinytip.size", "12px"),
  click = getOption("shinytip.click", FALSE),
  animate = getOption("shinytip.animate", TRUE),
  pointer = getOption("shinytip.pointer", TRUE),
  solid = getOption("shinytip.solid", FALSE),
  ...
)
}
\arguments{
\item{tag}{A Shiny input tag.}

\item{content}{The text in the tooltip. Can include emojis, but cannot contain HTML.}

\item{position}{The position of the tooltip in relation to the tag. One of: \code{"top"}, \code{"bottom"},
\code{"left"}, \code{"right"}, \code{"top-left"}, \code{"top-right"}, \code{"bottom-left"}, \code{"bottom-right"}.}

\item{length}{How wide should the tooltip be? One of: \code{"line"} (place the entire tooltip in one
line), \code{"fit"} (the tooltip should have the same width as the tag), \code{"s"} (small), \code{"m"} (medium),
\code{"l"} (large), \code{"xl"} (extra large).}

\item{bg}{Background colour of the tooltip.}

\item{fg}{Colour ("foreground") of the tooltip text.}

\item{size}{The font size of the tooltip text.}

\item{click}{If \code{FALSE} (default), the tooltip shows on hover. If \code{TRUE}, the tooltip will
only show when the tag is clicked.}

\item{animate}{If \code{TRUE}, animate the tooltip appearing and disappearing.}

\item{pointer}{If \code{TRUE}, change the cursor when hovering over the tag.}

\item{solid}{If \code{TRUE}, the question-mark icon will have a solid background.}

\item{...}{Additional parameters to pass to the tag.}
}
\value{
The same input tag, with a question-mark icon in the label that triggers a tooltip.
}
\description{
Modifies an input's label to include a question-mark icon at the end that has a tooltip.
}
\examples{
if (interactive()) {
  library(shiny)
  library(shinytip)

  shinyApp(
    ui = fluidPage(br(),
      tip_input(
        textInput("name", "Name"),
        "Enter your full name as appears on your passport",
        position = "right"
      )
    ),
    server = function(input, output) {}
  )
}

}
\seealso{
\code{\link[=tip]{tip()}}, \code{\link[=tip_icon]{tip_icon()}}
}
