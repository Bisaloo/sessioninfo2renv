#' Convert an object to an renv lockfile
#'
#' @param x An object to convert
#' @param ... Additional arguments passed to methods
#'
#' @export
as_lockfile <- function(x, ...) {
  UseMethod("as_lockfile")
}

#' Convert a `session_info` object to an renv lockfile
#'
#' `session_info` objects are produced by the [sessioninfo::session_info()]
#' function.
#'
#' @inheritParams as_lockfile
#'
#' @export
as_lockfile.session_info <- function(x, lockfile = stdout(), ...) {

  pkgs <- x$packages |>
    dplyr::transmute(
      Package = package,
      Version = loadedversion,
      Source = dplyr::case_when(
        startsWith(source, "RSPM") ~ "Repository",
        startsWith(source, "Bioconductor") ~ "Bioconductor",
        startsWith(source, "Github") ~ "GitHub",
        startsWith(source, "CRAN") ~ "Repository",
        source == "local" ~ "local",
      ),
      Repository = dplyr::if_else(
        Source == "Repository",
        gsub("^([^ ]+) ?.*", "\\1", source),
        NA_character_
      ),
      RemoteSha = dplyr::if_else(
        Source == "GitHub",
        gsub(".*@([a-f0-9]+).*", "\\1", source),
        NA_character_
      ),
      RemotePkgRef = dplyr::if_else(
        Source == "GitHub",
        gsub("Github \\(([^@]+)@.*", "\\1", source),
        NA_character_
      ),
      RemoteUsername = dplyr::if_else(
        Source == "GitHub",
        gsub("Github \\(([^/]+)/.*", "\\1", source),
        NA_character_
      ),
      RemoteRepo = dplyr::if_else(
        Source == "GitHub",
        gsub("Github \\([^/]+/([^@]+)@.*", "\\1", source),
        NA_character_
      )
    )

  pkgs <- pkgs |>
    purrr::transpose() |>
    rlang::set_names(pkgs$Package) |>
    purrr::map(~ purrr::discard(.x, is.na))

  lock <- list(
    R = list(
      Version = gsub("R version (\\d+\\.\\d+.\\d+).*", "\\1", x$platform$version),
      # FIXME: this takes the values from the 'receiver' computer but we should
      # ideally take them from the 'sender' computer.
      # Problem: session_info() does not provide this information but renv
      # requires it.
      Repositories = list(
        list(Name = "RSPM", URL = "https://packagemanager.posit.co/cran/latest"),
        list(Name = "CRAN", URL = "https://cloud.r-project.org/")
      )
    ),
    Packages = pkgs
  )

  jsonlite::write_json(
    lock,
    path = lockfile,
    auto_unbox = TRUE,
    pretty = TRUE
  )
}
