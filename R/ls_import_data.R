#' Reading LimeSurvey data exported to R
#'
#' This function can be used to import files exported by LimeSurvey.
#'
#' This function was intended to make importing data from LimeSurvey a bit
#' easier. The default settings used by LimeSurvey are not always convenient,
#' and this function provides a bit more control.
#'
#' @param datafile The path and filename of the file containing the data (comma
#' separated values).
#' @param dataPath,datafileRegEx Path containing datafiles: this can be used to
#' read multiple datafiles, if the data is split between those. This is useful
#' when downloading the entire datafile isn't possible because of server
#' restrictions, for example when the processing time for the script in
#' LimeSurvey that generates the datafiles is limited. In that case, the data
#' can be downloaded in portions, and specifying a path here enables reading
#' all datafiles in one go. Use the regular expression to indicate which files
#' in the path should be read.
#' @param scriptfile The path and filename of the file containing the R script
#' to import the data.
#' @param limeSurveyRegEx.varNames The regular expression used to extract the
#' variable names from the script file. The first regex expression (i.e. the
#' first expression between parentheses) will be extracted as variable name.
#' @param limeSurveyRegEx.toChar The regular expression to detect the lines in
#' the import script where variables are converted to the character type.
#' @param limeSurveyRegEx.varLabels The regular expression used to detect the
#' lines in the import script where variable labels are set.
#' @param limeSurveyRegEx.toFactor The regular expression used to detect the
#' lines in the import script where vectors are converted to factors.
#' @param limeSurveyRegEx.varNameSanitizing A list of regular expression
#' patterns and their replacements to sanitize the variable names (e.g. replace
#' hashes/pound signs ('#') by something that is not considered the comment
#' symbol by R).
#' @param setVarNames,setLabels,convertToCharacter,convertToFactor Whether to
#' set variable names or labels, or convert to character or factor, using the
#' code isolated using the specified regular expression.
#' @param categoricalQuestions Which variables (specified using LimeSurvey
#' variable names) are considered categorical questions; for these, the script
#' to convert the variables to factors, as extracted from the LimeSurvey import
#' file, is applied.
#' @param massConvertToNumeric Whether to convert all variables to numeric
#' using \code{\link{massConvertToNumeric}}.
#' @param dataHasVarNames Whether the variable names are included as header
#' (first line) in the comma separated values file (data file).
#' @param dataEncoding,scriptEncoding The encoding of the files; can be used
#' to override the setting in the `limonaid` options (i.e. in `opts`) in the
#' `encoding` field (the default value is "`UTF-8`").
#' @return The dataframe.
#' @examples
#'
#' \dontrun{
#' ### Of course, you need valid LimeSurvey files. This is an example of
#' ### what you'd do if you have them, assuming you specified that path
#' ### containing the data in 'dataPath', the name of the datafile in
#' ### 'dataFileName', the name of the script file in 'dataLoadScriptName',
#' ### and that you only want variables 'informedConsent', 'gender', 'hasJob',
#' ### 'currentEducation', 'prevEducation', and 'country' to be converted to
#' ### factors.
#' dat <- limonaid::ls_import_data(
#'   datafile = file.path(dataPath, dataFileName),
#'   scriptfile = file.path(dataPath, dataLoadScriptName),
#'   categoricalQuestions = c('informedConsent',
#'                            'gender',
#'                            'hasJob',
#'                            'currentEducation',
#'                            'prevEducation',
#'                            'country')
#' );
#' }
#'
#' @export
ls_import_data <- function(datafile = NULL,
                           dataPath = NULL,
                           datafileRegEx = NULL,
                           scriptfile = NULL,
                           setVarNames = TRUE,
                           setLabels = TRUE,
                           convertToCharacter = FALSE,
                           convertToFactor = FALSE,
                           categoricalQuestions = NULL,
                           massConvertToNumeric = TRUE,
                           dataHasVarNames = TRUE,
                           dataEncoding=NULL, #'UTF-8', 'unknown',
                           scriptEncoding=NULL) { # 'ASCII'

  limeSurveyRegEx.varNames <-
    limonaid::opts$get("data_import_RegEx_varNames");
  limeSurveyRegEx.toChar <-
    limonaid::opts$get("data_import_RegEx_toChar");
  limeSurveyRegEx.varLabels <-
    limonaid::opts$get("data_import_RegEx_varLabels");
  limeSurveyRegEx.toFactor <-
    limonaid::opts$get("data_import_RegEx_toFactor");
  limeSurveyRegEx.varNameSanitizing <-
    limonaid::opts$get("data_import_RegEx_varNameSanitizing");

  if (is.null(dataEncoding)) {
    dataEncoding <- limonaid::opts$get("encoding");
  }
  if (is.null(scriptEncoding)) {
    scriptEncoding <- limonaid::opts$get("encoding");
  }

  ### Set filename(s) to read
  if (!is.null(dataPath) && !is.null(datafileRegEx)) {
    files <- unique(list.files(path = dataPath,
                               pattern = datafileRegEx,
                               ignore.case = TRUE,
                               recursive=TRUE,
                               full.names=TRUE));

  } else if (!is.null(datafile)) {
    if (!file.exists(datafile)) {
      stop("File specified as datafile ('", datafile, "') does not exist!");
    } else {
      files <- datafile;
    }
  } else {
    stop("Please specify a datafile to read, or a datafileRegEx to read multiple datafiles!");
  }

  ### Load datafile(s)
  data <- NULL;
  for (currentDatafile in files) {
    if (dataHasVarNames) {
      currentData <-
        utils::read.csv(currentDatafile,
                        quote = "'\"",
                        na.strings=c("", "\"\""),
                        stringsAsFactors=FALSE,
                        encoding=dataEncoding,
                        header=TRUE);
    } else {
      currentData <-
        utils::read.csv(currentDatafile,
                        quote = "'\"",
                        na.strings=c("", "\"\""),
                        stringsAsFactors=FALSE,
                        encoding=dataEncoding,
                        header=FALSE);
    }
    if (is.null(data)) {
      data <- currentData;
    } else {
      data <- rbind(data, currentData);
    }
  }

  ### Load scriptfile
  if (!is.null(scriptfile)) {
    if (!file.exists(scriptfile)) {
      stop("File specified as scriptfile ('", scriptfile, "') does not exist!");
    }
    ### Use separate connection to make sure proper encoding is selected
    con <- file(scriptfile, encoding=scriptEncoding)
    datascript <- readLines(con);
    close(con);

    varNamesScript <- datascript[grepl(limeSurveyRegEx.varNames,
                                       datascript)];
    varLabelsScript <- datascript[grepl(limeSurveyRegEx.varLabels,
                                        datascript)];
    toCharScript <- datascript[grepl(limeSurveyRegEx.toChar,
                                     datascript)];
    toFactorScript <- datascript[grepl(limeSurveyRegEx.toFactor,
                                       datascript)];

    if (setVarNames) {
      eval(parse(text=varNamesScript));
    }
    if (setLabels) {
      eval(parse(text=varLabelsScript));
    }
    if (convertToCharacter) {
      eval(parse(text=toCharScript));
    }
    if (convertToFactor || (!is.null(categoricalQuestions))) {
      if (massConvertToNumeric) {
        data <- massConvertToNumeric(data);
      }
      if (!is.null(categoricalQuestions)) {
        if (setVarNames) {
          varNames <- names(data);
        } else {
          stop("You can't set setVarNames to FALSE and also set ",
               "categoricalQuestions to anything else than NULL, ",
               "because the content of categoricalQuestions should ",
               "be the LimeSurvey variables names!");
        }
        toFactorScript <- unlist(lapply(as.list(categoricalQuestions),
                                        function(x, string=toFactorScript,
                                                 varNms=varNames) {
                                          return(grep(paste0("data\\[, ",
                                                             which(varNms==x),
                                                             "\\] <-"),
                                                      string, value=TRUE));
                                        }));
      }
      eval(parse(text=toFactorScript));
    }
  } else {
    if (massConvertToNumeric) {
      data <- massConvertToNumeric(data);
    }
  }
  if (length(limeSurveyRegEx.varNameSanitizing)) {
    for (currentRegexPair in limeSurveyRegEx.varNameSanitizing) {
      names(data) <- gsub(currentRegexPair$pattern,
                          currentRegexPair$replacement,
                          names(data));
    }
  }

  return(data);
}