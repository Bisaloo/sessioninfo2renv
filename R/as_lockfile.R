#' Convert an object to an renv lockfile
#'
#' @param x An object to convert
#' @param lockfile A file path to write the lockfile to. If `stdout()` (the
#'   default), the lockfile is printed to the console.
#' @param ... Additional arguments passed to methods
#'
#' @export
as_lockfile <- function(x, lockfile, ...) {
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

  if (any(pkgs$Source == "local")) {
    warning(
      "Some packages were installed from local sources which is not fully ",
      "reproducible. They will be dropped from the lockfile.",
      call. = FALSE
    )
    pkgs <- pkgs[pkgs$Source != "local", ]
  }

  pkgs <- pkgs |>
    purrr::transpose() |>
    rlang::set_names(pkgs$Package) |>
    # Some fields are NA (e.g., RemoteRepo for CRAN packages) as required to
    # keep the data.frame rectangular. But in a list, we don't need all elements
    # to have the same fields, so we drop the NA fields.
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
