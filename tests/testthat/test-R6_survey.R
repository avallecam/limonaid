testthat::test_that("creating a simple survey works", {
  ls <- Survey$new("Test Survey");
  testthat::expect_equal(ls$titles, "Test Survey");
})

testthat::test_that("adding groups works", {
  ls <- Survey$new("Test Survey");
  ls$add_group("Group 1");
  ls$add_group("Group 2");
  testthat::expect_equal(ls$groups$`1`$titles[['en']], "Group 1");
})

testthat::test_that("adding a question works", {
  ls <- Survey$new("Test Survey");
  ls$add_group("Group 1");
  ls$add_question(groupId = 1,
                  code = "firstQuestion",
                  type = "radiobuttons");
  testthat::expect_equal(ls$groups$`1`$questions$firstQuestion$code,
                         "firstQuestion");
})

testthat::test_that("exporting a survey to a TSV file works", {

  ls <- Survey$new("Test Survey");
  ls$add_group("Only group",
               "This is the description of the only group in the survey.");
  ls$add_question(groupId = 1,
                  code = "onlyQuestion",
                  questionTexts = "This is the question text of the only question in this survey.",
                  helpTexts = "This is the help text of the only question in this survey.",
                  type = "radiobuttons");

  ls$groups$`1`$questions$onlyQuestion$add_answer_option(
    code = 1,
    optionTexts = "This is the first answer option");

  ls$groups$`1`$questions$onlyQuestion$add_answer_option(
    code = 2,
    optionTexts = "This is the second answer option");

  tmpFile <- tempfile(fileext = ".txt");

  ### Temporary
  tmpFile <- "B:/Data/R/limonaid/inst/extdata/testing-export.txt";

  ls$export_to_tsv(file = tmpFile,
                   preventOverwriting = FALSE);

  cat(tmpFile);

  testthat::expect_equal(ls$groups$`1`$questions$firstQuestion$code,
                         "firstQuestion");
})