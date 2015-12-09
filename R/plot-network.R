#' plotNetwork
#' @export
#'
#' @title
#' Plot collaborators network from Google Scholar page
#'
#' @description
#' Takes value from \code{extractNetwork} function and visualizes network
#' using networkD3.
#'
#' @param nodes Data frame with node information returned by \code{extractNetwork}.
#' @param edges Data frame with edge list returned by \code{extractNetwork}.
#' @param file File where network visualization will be exported to.
#' @param width numeric width for the network graph's frame area in pixels
#' @param height numeric height for the network graph's frame area in pixels.
#' @param opacity numeric value of the proportion opaque you would like the graph elements to be.
#' @param fontsize numeric font size in pixels for the node text labels.
#' @param charge numeric value indicating either the strength of the node repulsion (negative value) or attraction (positive value).
#' @param ... Other options to pass to \code{networkD3} function
#'
#' #' @examples \dontrun{
#' ## Download Google Scholar network data for a sample user
#' d <- extractNetwork(id="jGLKJUoAAAAJ", n=500)
#' ## Plot network into file called \code{network.html}
#' plotNetwork(d$nodes, d$edges, file="network.html")
#' }
#'

plotNetwork <- function(nodes, edges, file='network.html', width=550,
                        height=400, opacity = .75, fontsize=10,
                         charge=-400,...){

  df <- data.frame(
    Source=as.numeric(factor(edges$node1, levels=nodes$label))-1,
    Target=as.numeric(factor(edges$node2, levels=nodes$label))-1,
    value=edges$weight)

  output <- networkD3::forceNetwork(Links = df, Nodes = nodes, Source="Source", Target="Target",
               NodeID = "label", Group = "group",linkWidth = 1,
               Nodesize = "degree", fontSize=fontsize,
               opacity = opacity, charge=charge,
               width = width, height = height, ...)

  saveNetwork(output, file, selfcontained = FALSE)

}

#d3Network::d3ForceNetwork(
#  Links = df, Nodes = nodes, Source="Source", Target="Target",
#  NodeID = "label", Group="group", width = width, height = height,
#  opacity = opacity, file=file, fontsize=fontsize,
#  linkDistance=linkDistance, ...)
