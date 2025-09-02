test_that("unformat session_info()", {

  si <- sessioninfo::session_info()

  p <- withr::local_tempfile(
    lines = format(si)
  )

  recovered_si <- unformat_session_info(p)

  expect_identical(si, recovered_si)
})
