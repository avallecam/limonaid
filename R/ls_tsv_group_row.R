# #' @export
# ls_tsv_group_row <- function(name,
#                              text,
#                              id=NULL,
#                              type.scale = "0",
#                              relevance = 1,
#                              language = "en",
#                              random_group = "",
#                              silent = limonaid::opts$get("silent")) {
#
#   if (is.null(id)) {
#     id <- new_id(silent = silent);
#   }
#
#   class = "G";
#
#   res <- as.list(environment());
#   res$silent <- NULL;
#   res <- as.data.frame(res);
#
#   return(res);
#
# }
