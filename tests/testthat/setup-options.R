# We want to flag partial matching as part of our testing & continuous
# integration process because it makes code more brittle.
options(
  warnPartialMatchAttr = TRUE,
  warnPartialMatchDollar = TRUE,
  warnPartialMatchArgs = TRUE
)

Sys.setenv(NO_COLOR = "true") # to disable cli colour printing
