# Search OpenAlex for scientific papers mentioning a species

Query the OpenAlex API using the openalexR package to retrieve journal
articles mentioning a focal species and optional synonyms. Results are
restricted to works published in journals and exclude paratext (e.g.,
editorials and letters).

## Usage

``` r
search_species_openalex(
  species,
  synonyms = NULL,
  pages = 5,
  per_page = 200,
  verbose = FALSE
)
```

## Arguments

- species:

  Character string giving the focal species name (typically the Latin
  binomial).

- synonyms:

  Optional character vector of synonyms or common names (e.g., "gray
  wolf", "grey wolf").

- pages:

  Integer giving the number of pages of results to retrieve from
  OpenAlex. Default = 5.

- per_page:

  Integer giving the number of records per page. Default = 200 (OpenAlex
  maximum).

- verbose:

  Logical indicating whether query information should be printed.
  Default = FALSE.

## Value

A tibble containing OpenAlex records with additional columns:

- species:

  The focal species used in the search

- journal:

  Journal name

- year:

  Publication year

Duplicate records are removed based on DOI.

## Details

The function is useful for rapidly assembling literature datasets for
ecological evidence mapping, scoping reviews, or species bibliographies.

The function builds a search query combining the species name and
optional synonyms using an OR operator. Results are filtered to journal
sources using the OpenAlex field
`primary_location.source.type = "journal"` and exclude paratext records.

Note that OpenAlex search is not equivalent to formal database Boolean
searches used in systematic reviews (e.g., Web of Science or Scopus),
but it is very useful for discovery, scoping, and automated literature
harvesting.

## Author

Matthew Grainger <matt.grainger@nina.no>

## Examples

``` r
# Example 1: single species search
wolf <- search_species_openalex(
  species = "Canis lupus",
  synonyms = c("gray wolf", "grey wolf"),
  pages = 2
)
#> Using basic paging...

# Example 2: search multiple species
species_list <- list(
  wolf = c("Canis lupus", "gray wolf", "grey wolf"),
  lynx = c("Lynx lynx", "Eurasian lynx"),
  bear = c("Ursus arctos", "brown bear")
)

results <- purrr::imap_dfr(
  species_list,
  ~ search_species_openalex(
      species = .x[1],
      synonyms = .x[-1],
      pages = 2
    )
)
#> Using basic paging...
#> Using basic paging...
#> Using basic paging...

results |> View()
#> Warning: unable to open display
#> Error in .External2(C_dataviewer, x, title): unable to start data viewer
```
