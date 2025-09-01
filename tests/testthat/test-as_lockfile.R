test_that("as_lockfile() session_info method", {
  expect_snapshot(
    sessioninfo_lock <- as_lockfile(sessioninfo::session_info())
  )

  # Produces:
  # (1) a lockfile
  # (2) that validates
  withr::with_tempfile(
    "lockfile",
    {
      renv::lockfile_create(sessioninfo_lock, file = lockfile)
      expect_true(file.exists(lockfile))
      expect_true(renv::lockfile_validate(lockfile))
    }
  )
})
