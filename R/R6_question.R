#' R6 Class representing a LimeSurvey question
#'
#' A question has at least a code and a primary language.
Question <- R6::R6Class(
  "Question",

  ###---------------------------------------------------------------------------
  ### Public properties & methods
  ###---------------------------------------------------------------------------

  public = list(

    ###-------------------------------------------------------------------------
    ### Public properties
    ###-------------------------------------------------------------------------

    #' @field code The code of the question.
    code = NULL,

    #' @field id The identifier of the question (a unique number in a survey)
    id = NULL,

    #' @field type The question type.
    type = NULL,

    #' @field lsType The question type in LimeSurvey's format.
    lsType = NULL,

    #' @field questionTexts The question text(s) in all languages.
    questionTexts = NULL,

    #' @field helpTexts The question help text(s) in all languages.
    helpTexts = NULL,

    #' @field relevance The relevance.
    relevance = 1,

    #' @field validation The question's validation.
    validation = "",

    #' @field language The primary language of the question.
    language = NULL,

    #' @field answerOptions The answer options in the question.
    answerOptions = list(),

    #' @field subQuestions The subquestions in the question.
    subQuestions = list(),

    #' @field mandatory Whether the question is mandatory (`Y` or `N`).
    mandatory = NULL,

    #' @field other Whether the question has an 'other' option (`Y` or `N`).
    other = NULL,

    #' @field other_replace_text If the question has an 'other' option, its
    #' label if the default label should be overwritten (multilingual).
    other_replace_text = NULL,

    #' @field default The default value.
    default = NULL,

    #' @field same_default Not entirely sure what this does.
    same_default = NULL,

    #' @field array_filter The question code of the array filter question
    #' to apply.
    array_filter = NULL,

    #' @field cssclass The CSS class(es) to apply to this question.
    cssclass = NULL,

    #' @field hide_tip Whether to hide the tip (`Y` or `N`).
    hide_tip = NULL,

    #' @field otherOptions Any additional options, stored as a named list
    #' by assigning `as.list(...)`.
    otherOptions = NULL,

    ###-------------------------------------------------------------------------
    ### Initialization
    ###-------------------------------------------------------------------------

    #' @description
    #' Create a new question object.
    #' @param code The question code.
    #' @param type The human-readable question type.
    #' @param lsType The type as LimeSurvey type (see
    #' https://manual.limesurvey.org/Question_object_types).
    #' @param id The identifier of the question (in a survey).
    #' @param questionTexts The question text(s).
    #' @param helpTexts The help text(s).
    #' @param relevance The question's relevance equation.
    #' @param validation The question's validation.
    #' @param mandatory Whether the question is mandatory (`Y` or `N`);.
    #' @param other Whether the question has an 'other' option (`Y` or `N`).
    #' @param other_replace_text If the question has an 'other' option, its
    #' label if the default label should be overwritten (multilingual).
    #' @param default The default value.
    #' @param same_default Not entirely sure what this does.
    #' @param array_filter The question code of the array filter question
    #' to apply.
    #' @param cssclass The CSS class(es) to apply to this question.
    #' @param hide_tip Whether to hide the tip (`Y` or `N`).
    #' @param language The question's primary language.
    #' @param ... Any additional options, stored as a named list in the
    #' `otherOptions` property by assigning `as.list(...)`.
    #' @return A new `Survey` object.
    initialize = function(code,
                          type = NULL,
                          lsType = NULL,
                          id = NULL,
                          questionTexts = "",
                          helpTexts = "",
                          relevance = 1,
                          validation = "",
                          mandatory = "N",
                          other = "N",
                          other_replace_text = "",
                          default = "",
                          same_default = "0",
                          array_filter = "",
                          cssclass = "",
                          hide_tip = "",
                          language = "en",
                          ...) {

      ###-----------------------------------------------------------------------
      ### Check whether the multilingual fields have been passed properly
      ###-----------------------------------------------------------------------

      questionTexts <-
        checkMultilingualFields(questionTexts,
                                language = language);

      helpTexts <-
        checkMultilingualFields(helpTexts,
                                language = language);

      ###-----------------------------------------------------------------------
      ### Check question type
      ###-----------------------------------------------------------------------

      type <- tolower(type);

      if (is.null(lsType)) {
        if (type %in% c("array dual scale")) {
          lsType <- "1";

        } else if (type %in% c("multiple numerical input")) {
          lsType <- "K";

        } else if (type %in% c("radio", "radiobuttons")) {
          lsType <- "L";

        } else if (type == c("multiple choice", "checkboxes")) {
          lsType <- "M";

        } else if (type == c("dropdown")) {
          lsType <- "!";

        } else if (type == c("equation")) {
          lsType <- "*";

        } else {
          stop("Questions of type '", type, "' are not yet supported.");
        }
      } else {
        type <- lsType;
        ### Optionally check lsType against valid values
      }

      ###-----------------------------------------------------------------------
      ### Check question type
      ###-----------------------------------------------------------------------

      ###
      ###
      ### Ideally, implement validation of all options
      ###
      ###

      ###-----------------------------------------------------------------------
      ### Set fields
      ###-----------------------------------------------------------------------

      self$id <- id;
      self$code <- code;
      self$type <- type;
      self$lsType <- lsType;

      self$language <- language;

      self$questionTexts <- questionTexts;
      self$helpTexts <- helpTexts;

      self$relevance <- relevance;
      self$validation <- validation;
      self$mandatory <- mandatory;
      self$other <- other;
      self$other_replace_text <- other_replace_text;
      self$default <- default;
      self$same_default <- same_default;
      self$array_filter <- array_filter;
      self$cssclass <- cssclass;
      self$hide_tip <- hide_tip;

      self$otherOptions <- list(...);

    },

    ###-------------------------------------------------------------------------
    ### Add an answer option
    ###-------------------------------------------------------------------------

    #' @description
    #' Add an answer option to a question.
    #' @param code The answer option code.
    #' @param optionTexts The answer option text(s).
    #' @return Invisible, the question object.
    add_answer_option = function(code,
                                 optionTexts) {

      ###-----------------------------------------------------------------------
      ### Check code
      ###-----------------------------------------------------------------------

      if (!grepl("^[a-zA-Z0-9]*$",
                 code)) {
        stop("Answer option codes may only consist of digits and ",
             "letters!");
      }

      ###-----------------------------------------------------------------------
      ### Check and fix option texts
      ###-----------------------------------------------------------------------

      if (!is.character(optionTexts) || (length(optionTexts) == 0)) {
        stop("The option text or texts specified as `optionTexts` ",
             "must be a character vector with at least one element!");
      }

      if (length(optionTexts) == 1) {
        optionTexts <-
          stats::setNames(optionTexts,
                          nm = self$language);
      } else {
        if (!(self$language %in% names(optionTexts))) {
          stop("When providing multiple option texts, at least one ",
               "of them has to be in the question's primary language (",
               self$language, "').");
        }
      }

      ###-----------------------------------------------------------------------
      ### Set the answer options
      ###-----------------------------------------------------------------------

      self$answerOptions <-
        c(self$answerOptions,
          list(list(code = code,
                    optionTexts = optionTexts)));

      ### Set name of this new option
      names(self$answerOptions)[
        length(self$answerOptions)] <- code;

      ### Return self invisibly
      return(invisible(self));
    }

    ###-------------------------------------------------------------------------
    ### Add a subquestion
    ###-------------------------------------------------------------------------

  )
)