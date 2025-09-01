#' Get a `session_info` object from its printed representation
#'
#' @param file A file path to a text file containing the output of
#'
#' @examples
#'
#' @importFrom stats setNames
#' @importFrom utils read.fwf
#'
#' file <- system.file("extdata", "sessioninfo.txt", package = "sessioninfo")
unformat_session_info <- function(file) {
  x <- readLines(file)

  if (all(startsWith(x, "#>"))) {
    file <- withr::local_tempfile()
    x <- gsub("^#> ?", "", x)
    writeLines(x, con = file, sep = "\n")
  }

  platform_section <- grep("^─ Session info ─", x)
  packages_section <- grep("^─ Packages ─", x)
  footnotes <- grep("^$", x)

  platform_header <- x[platform_section + 1]
  colstarts <- regexec(" (setting)\\s+(value)", platform_header)[[1]]

  # FIXME: I would expect we can get the header by skipping one line less and
  # setting `header = TRUE` but it does not work.
  platform <- read.fwf(
    file = file,
    widths = c(diff(colstarts), 50),
    skip = platform_section + 1,
    n = packages_section - platform_section - 3,
  )
  platform <- setNames(
    as.list(platform[, 3]),
    trimws(platform[, 2])
  )
  class(platform) <- c("platform_info")


  packages_header <- x[packages_section + 1]
  colstarts <- regexec("\\s+(!?)\\s*(package)\\s+(\\*)\\s+(version)\\s+(date \\(UTC\\)|date)\\s+(lib)\\s+(source)", packages_header)[[1]]

  packages <- read.fwf(
    file = file,
    widths = c(diff(colstarts), 50),
    skip = packages_section + 1,
    n = footnotes[2] - packages_section - 2
  )
  colnames(packages) <- c("skip", "warn", "package", "attached", "loadedversion", "date", "lib", "source")
  packages <- as.data.frame(vapply(packages, trimws, character(nrow(packages))))
  packages$attached <- packages$attached == "*"
  packages <- packages[, colnames(packages) != "skip"]

  # Guess
  packages$library <- gsub("^\\[(\\d+)\\]\\s*", "\\1", packages$lib)
  packages$ondiskversion <- packages$loadedversion
    packages$md5ok <- NA
  packages$isbase <- FALSE
  packages$path <- "placeholder"
  packages$loadedpath <- "placeholder"

  class(packages) <- c("packages_info", "data.frame")

  structure(
    list(
      platform = platform,
      packages = packages
    ),
    class = "session_info"
  )
}
