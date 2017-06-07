# Author: Thom Miano
# Description: Script for downloading a list of R packages when you have to do
# it manually.

library(xml2)
library(rvest)

#-----------------------------------------------------------------------------#
#----- User Environment settings
#-----------------------------------------------------------------------------#

# Your working directory
wd <- "your_working_directory"
# txt file with package name per line
package_list <- "./download_packages.txt"
# Define path to save files
save_directory <- "./download_here/"

#-----------------------------------------------------------------------------#
#----- Set environment and read in list of packages
#-----------------------------------------------------------------------------#

setwd(wd)
package_list <- read.table(package_list)

#-----------------------------------------------------------------------------#
#----- Download parameters
#-----------------------------------------------------------------------------#

# This is currently configured to download windows binaries. If you want to
# download binaries other than windows, you will need to comment out this
# section and change accordingly.

#----- Windows

# List of three links will be provided. 1: Development; 2: Stable; 3: Legacy
target_link_position <- 2

# Filter links based on key pattern
filter_key <- "../../../bin/windows/"
# Remove filter_key reference path
reference_path <- "../../../"
key_subtract <- nchar(reference_path) + 1 # plus 1 because 1 is origin

#----- Additional parameters you probably don't want to change

# Set variables for path to appropriate page of package
url_head <- "https://cran.r-project.org/web/packages/"
url_tail <- "/index.html"
url_sep <- ""
# General head for download path
download_url_head <- "https://cran.r-project.org/"
# HTML scraping definitions
node_tag <- "a"
attribute_tag <- "href"
file_extension <- ".zip"

#-----------------------------------------------------------------------------#
#----- Execute download
#-----------------------------------------------------------------------------#

# Loop through every package in list, extract html, and download the file.
for (i in 1:nrow(package_list)) {
  
  url_package <- package_list[i,1]

  url <- paste(url_head,url_package,url_tail, sep=url_sep)

  # Extract target download link from html
  html_doc <- read_html(url)
  node <- html_nodes(html_doc, node_tag)
  links_list <- html_attr(node, attribute_tag)
  windows_bool <- str_detect(links_list, filter_key)
  windows_links <- links_list[windows_bool]
  target_url <- windows_links[target_link_position]
  download_url_tail <- substring(target_url,key_subtract)
  # Concatenate with source to complete download link
  download_url <- paste(download_url_head, download_url_tail, sep=url_sep)

  # Define complete save path for download function
  filename = paste(url_package, file_extension, sep=url_sep)
  download_path = paste(save_directory, filename, sep=url_sep)

  # Download file
  download.file(download_url, download_path)
}