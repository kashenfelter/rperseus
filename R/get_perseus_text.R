#' Get a primary text by URN.
#'
#' @param urn Valid uniform resource number (URN) obtained from \code{\link{perseus_catalog}}.
#' @param excerpt An index to excerpt the text. For example, the first four "verses" of a text might be 1.1-1.4. If NULL, the entire work is returned.
#'
#' @return A seven column \code{tbl_df} with one row for each "section" (splits vary from text--could be line, chapter, etc.).
#' Columns:
#' \describe{
#'   \item{text}{character vector of text}
#'   \item{urn}{Uniform Resource Number}
#'   \item{group_name}{Could refer to author (e.g. "Aristotle") or corpus (e.g. "New Testament")}
#'   \item{label}{Text label, e.g. "Phaedrus"}
#'   \item{description}{Text description}
#'   \item{language}{Text language, e.g. "grc" = Greek, "lat" = Latin, "eng" = English}
#'   \item{section}{Text section or excerpt if specified}
#' }
#' @importFrom dplyr %>%
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' get_perseus_text("urn:cts:greekLit:tlg0013.tlg028.perseus-grc2")
#' get_perseus_text("urn:cts:latinLit:stoa0215b.stoa003.opp-lat1")
#' get_perseus_text(urn = "urn:cts:greekLit:tlg0031.tlg009.perseus-grc2", excerpt = "5.1-5.5")

get_perseus_text <- function(urn, excerpt = NULL) {

  if (length(urn) > 1) {
    stop("Please supply one valid URN.",
         call. = FALSE)
  }

  if (!urn %in% internal_perseus_catalog$urn) {
    stop("invalid text_urn argument: check perseus_catalog for valid URNs",
         call. = FALSE)
  }

  new_urn <- reformat_urn(urn)

  if (is.null(excerpt)) {
    text_index <- get_full_text_index(new_urn)
    if (grepl("NA", text_index)) stop("No text available.")
  } else {
    text_index <- excerpt
  }
    text_url <- get_text_url(urn, text_index)
    text_df <- extract_text(text_url) %>%
      dplyr::mutate(urn = urn) %>%
      dplyr::left_join(internal_perseus_catalog, by = "urn")
    if (is.null(excerpt)) {
      text_df <- text_df %>%
        dplyr::mutate(section = dplyr::row_number(.data$urn))
    } else {
      text_df <- text_df %>%
        dplyr::mutate(section = excerpt)
    }
    text_df
}

