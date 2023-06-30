library(httr)
library(jsonlite)

mp_data_loc <- "https://www.theyworkforyou.com/mps/?f=csv"
la_data_loc <- "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/WD22_PCON22_LAD22_UTLA22_UK_LU/FeatureServer/0/query"
la_data_query <- list(where = "1=1",
                    outFields = "PCON22CD,PCON22NM,LAD22CD,LAD22NM,UTLA22CD,UTLA22NM",
                    outSR = "4326",
                    f = "json")
entities_per_page <- 1000 # Set by the server
max_entities <- 10000 # This is a little over-cautious, but will hopefully not need to
                      # be changed if they add more wards

# Get MP info, removing columns 'Person.ID' and 'URI'
mp_list <- subset(read.csv(mp_data_loc), select = -c(Person.ID, URI))


# Get LA/Constituency info
get_starting_at_x <- function(x, url, query) {
    query_with_offset <- c(query, list(resultOffset = as.character(x)))
    res <- GET(url, query = query_with_offset)
    # each JSON record holds a lot of data, but we only want the "features"
    features <- fromJSON(rawToChar(res$content), flatten = TRUE)$features
    return(features)
}

# unique removes duplicate rows for multiple wards
local_authorities_const <- unique(
    bind_rows( # combine pages together
        lapply( # loop through all pages
            (seq_len(max_entities / entities_per_page) - 1) * 1000,
            get_starting_at_x,
            url = la_data_loc,
            query = la_data_query
        )
    )
)

# Remove 'attributes.' prefix from names
names(local_authorities_const) <- substr(names(a), 12, 1000)

la_with_mp <- merge(local_authorities_const,
                mp_list,
                all.x = TRUE,
                by.x = "PCON22NM",
                by.y = "Constituency")
