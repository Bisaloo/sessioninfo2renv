test_that("as_lockfile() session_info method", {
  expect_output(
    expect_warning(
      as_lockfile(sessioninfo::session_info()),
      "local"
    )
  )

  # Produces:
  # (1) a lockfile
  # (2) that validates
  withr::with_tempfile(
    "lockfile",
    {
      expect_warning(
        as_lockfile(sessioninfo::session_info(), lockfile = lockfile),
        "local"
      )
      expect_true(file.exists(lockfile))
      expect_true(renv::lockfile_validate(lockfile = lockfile))
    }
  )
})
