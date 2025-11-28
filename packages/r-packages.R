#!/usr/bin/env Rscript

# R package installation script
# This script installs commonly used R packages

cat("Installing R packages...\n")

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Core tidyverse and data manipulation
packages <- c(
  "tidyverse",
  "data.table",
  "dtplyr",
  "arrow",

  # Visualization
  "ggplot2",
  "patchwork",
  "scales",

  # Development tools
  "devtools",
  "usethis",
  "testthat",
  "roxygen2",

  # Data import/export
  "readxl",
  "writexl",
  "jsonlite",
  "xml2",

  # Database
  "DBI",
  "RPostgres",
  "RSQLite",

  # Utilities
  "here",
  "fs",
  "glue",
  "lubridate"
)

# Install packages that aren't already installed
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("Installing", pkg, "...\n")
    install.packages(pkg, dependencies = TRUE)
  } else {
    cat(pkg, "already installed\n")
  }
}

cat("R package installation complete!\n")
