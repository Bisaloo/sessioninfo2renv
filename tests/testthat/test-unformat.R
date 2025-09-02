test_that("unformat session_info()", {

  si <- sessioninfo::session_info()
  si$packages <- si$packages[si$packages$package != "sessioninfo2renv", ]


  p <- withr::local_tempfile(
    lines = format(si)
  )

  recovered_si <- unformat_session_info(p)

  expect_identical(recovered_si, si)
})
