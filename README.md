
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sessioninfo2renv

<!-- badges: start -->

[![R-CMD-check](https://github.com/Bisaloo/sessioninfo2renv/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Bisaloo/sessioninfo2renv/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Software users and researchers are encouraged to provide information
about their R session in order to facilitate reproducibility and help
with debugging. The [sessioninfo R
package](https://sessioninfo.r-lib.org/) provides a convenient way to
gather and display this information. However, it can be tedious to
locally recreate the R environment of another user based on the output
of `sessioninfo::session_info()` output.

The `sessioninfo2renv` package provides a function to convert the output
of `sessioninfo::session_info()` to a lockfile (`renv.lock`) that can be
used by the [renv R package](https://pkgs.rstudio.com/renv/) to recreate
the R environment.

## Installation

You can install the development version of sessioninfo2renv from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("Bisaloo/sessioninfo2renv")
```

## Example

Let’s see this in action!

For this, we are going to use a real session info output that was
attached to a reprex in ggplot2:

``` r
library(sessioninfo2renv)

example_sessioninfo <- system.file("extdata", "session_info.txt", package = "sessioninfo2renv")

cat(readLines(example_sessioninfo), sep = "\n")
#> #> ─ Session info ───────────────────────────────────────────────────────────────
#> #>  setting  value
#> #>  version  R version 4.3.3 (2024-02-29 ucrt)
#> #>  os       Windows 10 x64 (build 19044)
#> #>  system   x86_64, mingw32
#> #>  ui       RTerm
#> #>  language (EN)
#> #>  collate  English_Europe.utf8
#> #>  ctype    English_Europe.utf8
#> #>  tz       Europe/Paris
#> #>  date     2024-03-26
#> #>  pandoc   3.1.1 @ C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools/ (via rmarkdown)
#> #>
#> #> ─ Packages ───────────────────────────────────────────────────────────────────
#> #>  ! package     * version    date (UTC) lib source
#> #>  D class         7.3-22     2023-05-03 [1] CRAN (R 4.3.3)
#> #>    classInt      0.4-10     2023-09-05 [1] CRAN (R 4.3.1)
#> #>    cli           3.6.2      2023-12-11 [1] CRAN (R 4.3.2)
#> #>    colorspace    2.1-0      2023-01-23 [1] CRAN (R 4.3.0)
#> #>    curl          5.2.1      2024-03-01 [1] CRAN (R 4.3.3)
#> #>    DBI           1.2.2      2024-02-16 [1] CRAN (R 4.3.2)
#> #>    digest        0.6.35     2024-03-11 [1] CRAN (R 4.3.3)
#> #>    dplyr         1.1.4      2023-11-17 [1] CRAN (R 4.3.2)
#> #>    e1071         1.7-14     2023-12-06 [1] CRAN (R 4.3.2)
#> #>    evaluate      0.23       2023-11-01 [1] CRAN (R 4.3.2)
#> #>    fansi         1.0.6      2023-12-08 [1] CRAN (R 4.3.2)
#> #>    farver        2.1.1      2022-07-06 [1] CRAN (R 4.3.0)
#> #>    fastmap       1.1.1      2023-02-24 [1] CRAN (R 4.3.0)
#> #>    fs            1.6.3      2023-07-20 [1] CRAN (R 4.3.1)
#> #>    generics      0.1.3      2022-07-05 [1] CRAN (R 4.3.0)
#> #>    ggplot2     * 3.5.0      2024-02-23 [1] CRAN (R 4.3.2)
#> #>    glue          1.7.0      2024-01-09 [1] CRAN (R 4.3.2)
#> #>    gtable        0.3.4      2023-08-21 [1] CRAN (R 4.3.1)
#> #>    highr         0.10       2022-12-22 [1] CRAN (R 4.3.0)
#> #>    htmltools     0.5.8      2024-03-25 [1] CRAN (R 4.3.3)
#> #>  D KernSmooth    2.23-22    2023-07-10 [1] CRAN (R 4.3.3)
#> #>    knitr         1.45       2023-10-30 [1] CRAN (R 4.3.1)
#> #>    labeling      0.4.3      2023-08-29 [1] CRAN (R 4.3.1)
#> #>    lifecycle     1.0.4      2023-11-07 [1] CRAN (R 4.3.2)
#> #>    magrittr      2.0.3      2022-03-30 [1] CRAN (R 4.3.0)
#> #>    munsell       0.5.0      2018-06-12 [1] CRAN (R 4.3.0)
#> #>    pillar        1.9.0      2023-03-22 [1] CRAN (R 4.3.0)
#> #>    pkgconfig     2.0.3      2019-09-22 [1] CRAN (R 4.3.0)
#> #>    proxy         0.4-27     2022-06-09 [1] CRAN (R 4.3.0)
#> #>    purrr         1.0.2      2023-08-10 [1] CRAN (R 4.3.1)
#> #>    R.cache       0.16.0     2022-07-21 [1] CRAN (R 4.3.0)
#> #>    R.methodsS3   1.8.2      2022-06-13 [1] CRAN (R 4.3.0)
#> #>    R.oo          1.26.0     2024-01-24 [1] CRAN (R 4.3.2)
#> #>    R.utils       2.12.3     2023-11-18 [1] CRAN (R 4.3.2)
#> #>    R6            2.5.1      2021-08-19 [1] CRAN (R 4.3.0)
#> #>    Rcpp          1.0.12     2024-01-09 [1] CRAN (R 4.3.2)
#> #>    reprex        2.1.0.9000 2024-01-12 [1] Github (tidyverse/reprex@33ccedf)
#> #>    rlang         1.1.3      2024-01-10 [1] CRAN (R 4.3.2)
#> #>    rmarkdown     2.26       2024-03-05 [1] CRAN (R 4.3.3)
#> #>    rstudioapi    0.16.0     2024-03-24 [1] CRAN (R 4.3.3)
#> #>    scales        1.3.0      2023-11-28 [1] CRAN (R 4.3.2)
#> #>    sessioninfo   1.2.2      2021-12-06 [1] CRAN (R 4.3.0)
#> #>    sf          * 1.0-15     2023-12-18 [1] CRAN (R 4.3.2)
#> #>    styler        1.10.2     2023-08-29 [1] CRAN (R 4.3.1)
#> #>    tibble        3.2.1      2023-03-20 [1] CRAN (R 4.3.0)
#> #>    tidyselect    1.2.1      2024-03-11 [1] CRAN (R 4.3.3)
#> #>    units         0.8-5      2023-11-28 [1] CRAN (R 4.3.2)
#> #>    utf8          1.2.4      2023-10-22 [1] CRAN (R 4.3.2)
#> #>    vctrs         0.6.5.9000 2023-12-14 [1] Github (r-lib/vctrs@8bf5ba5)
#> #>    withr         3.0.0      2024-01-16 [1] CRAN (R 4.3.2)
#> #>    xfun          0.42       2024-02-08 [1] CRAN (R 4.3.2)
#> #>    xml2          1.3.6      2023-12-04 [1] CRAN (R 4.3.2)
#> #>    yaml          2.3.8      2023-12-11 [1] CRAN (R 4.3.2)
#> #>
#> #>  [1] C:/Users/etienne/AppData/Local/Programs/R/R-4.3.3/library
#> #>
#> #>  D ── DLL MD5 mismatch, broken installation.
#> #>
#> #> ──────────────────────────────────────────────────────────────────────────────
```

We can “unprint” this output and get back a `session_info` object with
the `unformat_session_info()` function:

``` r
session_info_obj <- unformat_session_info(example_sessioninfo)
```

This `session_info` object can then be converted to a lockfile with the
`as_lockfile()` function:

``` r
as_lockfile(session_info_obj, lockfile = "renv.lock")
```

Finally, this lockfile can be passed to `renv::restore()` to recreate
the R environment:

``` r
renv::restore(lockfile = "renv.lock")
```
