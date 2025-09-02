test_that("as_lockfile() session_info method", {
  expect_output(
    as_lockfile(sessioninfo::session_info())
  )

  # Produces:
  # (1) a lockfile
  # (2) that validates
  withr::with_tempfile(
    "lockfile",
    {
      as_lockfile(sessioninfo::session_info(), lockfile = lockfile)
      expect_true(file.exists(lockfile))
      expect_true(renv::lockfile_validate(lockfile))
    }
  )
})
