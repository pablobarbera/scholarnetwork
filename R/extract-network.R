#' extractNetwork
#' @export
#'
#' @title
#' Extract collaborators network from Google Scholar page
#'
#' @description
#' Uses \code{scholar} package to scrape Google Scholar page of an author
#' (determined by ID) and returns a list with a list of edges and a data frame
#' with node-level information
#'
#' @param id Character string specifying the Google Scholar ID.
#' @param n Maximum number of publications to retrieve.
#' @param largest_component If \code{TRUE}, keep only largest component in network
#' @param ... Other options to pass to \code{get_publications} function
#'
#' @examples \dontrun{
#' ## Download Google Scholar network data for a sample user
#' d <- extractNetwork(id="jGLKJUoAAAAJ", n=500)
#' ## Plot network into file called \code{network.html}
#' plotNetwork(d$nodes, d$edges, file="network.html")
#' }
#'

extractNetwork <- function(id, n=500, largest_component=TRUE, ...){

  # downloading publications
  pubs <- scholar::get_publications(id=id, pagesize=n, ...)

  # converting to edges
  edges <- lapply(pubs$author, extractAuthors)
  edges <- do.call(rbind, edges)
  edges <- aggregate(edges$weight,
                     by=list(node1=edges$node1, node2=edges$node2),
                     FUN=function(x) sum(x))
  names(edges)[3] <- "weight"

  ### SELECT LARGEST COMPONENT

  # extracting node-level information
  network <- igraph::graph.edgelist(as.matrix(edges[,c("node1", "node2")]), directed=FALSE)
  igraph::edge_attr(network, "weight") <- edges$weight
  fc <- igraph::walktrap.community(network)
  nodes <- data.frame(label = igraph::V(network)$name,
                      degree=igraph::strength(network), group=fc$membership,
                      stringsAsFactors=F)
  nodes <- nodes[order(nodes$label),]

  return(list(nodes=nodes, edges=edges))

}

extractAuthors <- function(x){
  authors <- unlist(stringr::str_split(x, ","))
  # deleting empty authors
  authors <- authors[grepl('[A-Za-z]+', authors)]
  # cleaning author list
  authors <- stringr::str_trim(authors)
  # if more than one author, create edge list
  if (length(authors)>1){
    edges <- as.data.frame(t(combn(x=authors, m=2)), stringsAsFactors=F)
    names(edges) <- c("node1", "node2")
    edges$weight <- 1/length(authors)
    return(edges)
  }
  if (length(authors)<=1) return(NULL)
}

