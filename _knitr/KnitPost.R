
packages <- c("ggplot2", "data.table", "gridExtra", "dplyr", "highcharter", "prettydoc")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))  
}



KnitPost <- function(site_path='/Users/meiyi/meidata.github.io/', overwriteAll=T, overwriteOne=NULL) {
  require(knitr)

  ## Blog-specific directories.  This will depend on how you organize your blog.
  site_path <- site_path # directory of jekyll blog (including trailing slash)
  rmd_path <- paste0(site_path, "_knitr/markdown_blog/") # directory where your Rmd-files reside (relative to base)
  fig_dir <- paste0(site_path,"pic") # directory to save figures
  posts_path <- paste0(site_path, "_posts/") # directory for converted markdown files
  cache_path <- paste0(site_path, "_cache") # necessary for plots

  render_jekyll(highlight = "pygments")
  opts_knit$set(base.url = '/', base.dir = site_path)
  opts_chunk$set(fig.path=fig_dir, fig.width=8.5, fig.height=5.25, dev='svg', cache=F,
                 warning=F, message=F, cache.path=cache_path, tidy=F)


  setwd(rmd_path) # setwd to base

  # some logic to help us avoid overwriting already existing md files
  files_rmd <- data.frame(rmd = list.files(path = rmd_path,
                                           full.names = T,
                                           pattern = "\\.Rmd$",
                                           ignore.case = T,
                                           recursive = F), stringsAsFactors=F)

  file_name <- basename(gsub(pattern = "\\.Rmd$", replacement = ".md", x = files_rmd$rmd))
  file_name <- gsub('\\s+','-',file_name)
  file_name <- paste0(format(Sys.time(), "%Y-%m-%d"),sep = "-",file_name)

  files_rmd$corresponding_md_file <- paste0(posts_path,file_name)
  files_rmd$corresponding_md_exists <- file.exists(files_rmd$corresponding_md_file)
  #basename(gsub(pattern = "\\.Rmd$", replacement = ".md", x = files_rmd$rmd
  ## determining which posts to overwrite from parameters overwriteOne & overwriteAll
  files_rmd$md_overwriteAll <- overwriteAll
  if(is.null(overwriteOne)==F) files_rmd$md_overwriteAll[grep(overwriteOne, files_rmd[,'rmd'], ignore.case=T)] <- T
  files_rmd$md_render <- F
  for (i in 1:dim(files_rmd)[1]) {
    if (files_rmd$corresponding_md_exists[i] == F) {
      files_rmd$md_render[i] <- T
    }
    if ((files_rmd$corresponding_md_exists[i] == T) && (files_rmd$md_overwriteAll[i] == T)) {
      files_rmd$md_render[i] <- T
    }
  }

  # For each Rmd file, render markdown (contingent on the flags set above)
  for (i in 1:dim(files_rmd)[1]) {
    if (files_rmd$md_render[i] == T) {
      out_file <- knit(as.character(files_rmd$rmd[i]),
                       output = as.character(files_rmd$corresponding_md_file[i]),
                       envir = parent.frame(),
                       quiet = T)
      message(paste0("KnitPost(): ", basename(files_rmd$rmd[i])))
    }
  }

}
