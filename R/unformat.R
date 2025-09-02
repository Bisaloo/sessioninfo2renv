#' Get a `session_info` object from its printed representation
#'
#' @param file A file path to a text file containing the output of
#'
#' @importFrom stats setNames
#' @importFrom utils read.fwf
#'
#' @export
#'
#' @examples
#' file <- system.file("extdata", "session_info.txt", package = "sessioninfo2renv")
#' unformat_session_info(file)
#'
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
  class(platform) <- c("platform_info", "list")

  libs <- trimws(scan(
    file,
    what = character(),
    sep = "\n",
    skip = footnotes[2],
    nlines = footnotes[3] - footnotes[2],
    quiet = TRUE
  ))

  libs <- libs[startsWith(libs, "[")]
  libs <- strsplit(libs, " ")
  libs <- do.call(rbind, libs)
  libs <- as.data.frame(libs, stringsAsFactors = TRUE)
  colnames(libs) <- c("num", "path")

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

  # Guess
  packages$library <- libs$path[match(packages$lib, libs$num)]
  packages$ondiskversion <- packages$loadedversion
  packages$md5ok <- NA
  packages$is_base <- FALSE
  packages$path <- packages$loadedpath <- file.path(packages$library, packages$package)

  packages <- packages[, c("package", "ondiskversion", "loadedversion", "path", "loadedpath", "attached", "is_base", "date", "source", "md5ok", "library")]
  rownames(packages) <- packages$package
  class(packages) <- c("packages_info", "data.frame")

  structure(
    list(
      platform = platform,
      packages = packages
    ),
    class = c("session_info", "list")
  )
}
