#' Search OpenAlex for scientific papers mentioning a species
#'
#' Query the OpenAlex API using the \pkg{openalexR} package to retrieve
#' journal articles mentioning a focal species and optional synonyms.
#' Results are restricted to works published in journals and exclude
#' paratext (e.g., editorials and letters).
#'
#' The function is useful for rapidly assembling literature datasets
#' for ecological evidence mapping, scoping reviews, or species
#' bibliographies.
#'
#' @param species Character string giving the focal species name
#'   (typically the Latin binomial).
#' @param synonyms Optional character vector of synonyms or common
#'   names (e.g., "gray wolf", "grey wolf").
#' @param pages Integer giving the number of pages of results to
#'   retrieve from OpenAlex. Default = 5.
#' @param per_page Integer giving the number of records per page.
#'   Default = 200 (OpenAlex maximum).
#' @param verbose Logical indicating whether query information should
#'   be printed. Default = FALSE.
#'
#' @return
#' A tibble containing OpenAlex records with additional columns:
#' \describe{
#'   \item{species}{The focal species used in the search}
#'   \item{journal}{Journal name}
#'   \item{year}{Publication year}
#' }
#'
#' Duplicate records are removed based on DOI.
#'
#' @details
#' The function builds a search query combining the species name and
#' optional synonyms using an OR operator. Results are filtered to
#' journal sources using the OpenAlex field
#' `primary_location.source.type = "journal"` and exclude paratext
#' records.
#'
#' Note that OpenAlex search is not equivalent to formal database
#' Boolean searches used in systematic reviews (e.g., Web of Science
#' or Scopus), but it is very useful for discovery, scoping, and
#' automated literature harvesting.
#'
#' @examples
#' # Example 1: single species search
#' wolf <- search_species_openalex(
#'   species = "Canis lupus",
#'   synonyms = c("gray wolf", "grey wolf"),
#'   pages = 2
#' )
#'
#' # Example 2: search multiple species
#' species_list <- list(
#'   wolf = c("Canis lupus", "gray wolf", "grey wolf"),
#'   lynx = c("Lynx lynx", "Eurasian lynx"),
#'   bear = c("Ursus arctos", "brown bear")
#' )
#'
#' results <- purrr::imap_dfr(
#'   species_list,
#'   ~ search_species_openalex(
#'       species = .x[1],
#'       synonyms = .x[-1],
#'       pages = 2
#'     )
#' )
#'
#' results |> View()
#'
#' @author Matthew Grainger \email{matt.grainger@nina.no}
#' @export
search_species_openalex <- function(
    species,
    synonyms = NULL,
    pages = 5,
    per_page = 200,
    verbose = FALSE
) {
  
  # build search string
  terms <- c(species, synonyms)
  
  search_string <- paste0('"', terms, '"', collapse = " OR ")
  
  if (verbose) {
    message("Search query: ", search_string)
  }
  
  # query OpenAlex
  res <- openalexR::oa_fetch(
    entity = "works",
    search = search_string,
    `primary_location.source.type` = "journal",
    is_paratext = FALSE,
    pages = pages,
    per_page = per_page,
    verbose = verbose
  )
  
  # clean output
  out <- res |>
    dplyr::mutate(
      species = species,
      journal = source_display_name,
      year = publication_year
    ) |>
    dplyr::select(
      species,
      title,
      journal,
      year,
      doi,
      cited_by_count,
      publication_date,
      dplyr::everything()
    ) |>
    dplyr::distinct(doi, .keep_all = TRUE)
  
  return(out)
}
