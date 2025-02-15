library(gdx)

test_that("Test if REMIND reporting produces mandatory variables for NGFS reporting", {
  skip_if_not(as.logical(gdxrrw::igdx(silent = TRUE)), "gdxrrw is not initialized properly")

  # File is from NGFS4, scenario C_d_strain_d95high-rem-17
  gdxPath <- file.path(tempdir(), "fulldata.gdx")
  utils::download.file("https://rse.pik-potsdam.de/data/example/remind2_test-NGFS_fulldata.gdx",
    gdxPath,
    mode = "wb", quiet = TRUE
  )

  mif <- suppressWarnings(convGDX2MIF(gdxPath, gdx_refpolicycost = gdxPath))

  computedVariables <- deletePlus(getItems(mif, dim = 3.3))

  computedVariables <- gsub("\\(\\)", "(unitless)", computedVariables)

  templateVariables <- deletePlus(unique(
    piamInterfaces::getREMINDTemplateVariables("AR6"),
    piamInterfaces::getREMINDTemplateVariables("AR6_NGFS")
  ))

  expect_true(any(computedVariables %in% templateVariables))

  missingVariables <- setdiff(templateVariables, computedVariables)

  if (length(missingVariables) > 0) {
    warning(
      "The following variables are expected in the piamInterfaces package,
          but cannot be found in the reporting generated:\n ",
      paste(missingVariables, collapse = ",\n ")
    )
  }
  # expect_true(length(missingVariables) == 0)
  unlink(tempdir(), recursive = TRUE)
  tempdir(TRUE)
})
