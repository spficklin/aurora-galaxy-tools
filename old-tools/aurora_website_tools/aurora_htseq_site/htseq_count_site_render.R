##============ Sink warnings and errors to a file ==============
## use the sink() function to wrap all code within it.
##==============================================================
zz = file('warnings_and_errors.txt')
sink(zz)
sink(zz, type = 'message')

#------------import libraries--------------------
options(stringsAsFactors = FALSE)

library(getopt)
library(rmarkdown)
library(htmltools)
#------------------------------------------------


#------------get arguments into R--------------------
# library(dplyr)
# getopt_specification_matrix(extract_short_flags('')) %>%
#   write.table(file = 'spec.txt', sep = ',', row.names = FALSE, col.names = TRUE, quote = FALSE)


spec_matrix = as.matrix(
  data.frame(stringsAsFactors=FALSE,
             long_flags = c("X_e", "X_o", "X_d", "X_s", "X_t", "X_A", "X_B", "X_G",
                            "X_f", "X_r", "X_S", "X_a", "X_T", "X_i", "X_m", "X_c", "X_O"),
             short_flags = c("e", "o", "d", "s", "t", "A", "B", "G", "f", "r", "S",
                             "a", "T", "i", "m", "c", "O"),
             argument_mask_flags = c(1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L,
                                     1L, 1L, 1L, 1L),
             data_type_flags = c("character", "character", "character", "character",
                                 "character", "character", "character", "character",
                                 "character", "character", "character", "character",
                                 "character", "character", "character", "character",
                                 "character")
  )
)
opt = getopt(spec_matrix)
#----------------------------------------------------


#-----------using passed arguments in R 
#           to define system environment variables---
do.call(Sys.setenv, opt[-1])
#----------------------------------------------------

#---------- often used variables ----------------
# OUTPUT_REPORT: path to galaxy output report
# OUTPUT_DIR: path to the output associated directory, which stores all outputs
# TOOL_DIR: path to the tool installation directory
OUTPUT_DIR = opt$X_d
TOOL_DIR =   opt$X_t
OUTPUT_REPORT = opt$X_o


# create the output associated directory to store all outputs
dir.create(OUTPUT_DIR, recursive = TRUE)

#-----------------render site--------------
# copy site generating materials into OUTPUT_DIR
dir.create(paste0(OUTPUT_DIR, '/site_generator'), recursive = TRUE)
system(paste0('cp -r ', TOOL_DIR, '/htseq_count_site.Rmd ', OUTPUT_DIR, '/site_generator/htseq_count_site.Rmd'))
system(paste0('cp -r ', TOOL_DIR, '/htseq_count_site.yml ', OUTPUT_DIR, '/site_generator/_site.yml'))
system(paste0('cp -r ', TOOL_DIR, '/htseq_count_site_index.Rmd ', OUTPUT_DIR, '/site_generator/index.Rmd'))
# render site to OUTPUT_DIR/_site, this is configured in the "_site.yml" file
render_site(input = paste0(OUTPUT_DIR, '/site_generator'))
# remove site generating materials from output associated directory
unlink(paste0(OUTPUT_DIR, '/site_generator'), recursive = TRUE)
# move _site/* into output associated directory
move_cmd = paste0('mv ', OUTPUT_DIR, '/_site/* ', OUTPUT_DIR)
system(move_cmd)
#------------------------------------------

#-----link index.html to output-----
cp_index = paste0('cp ', OUTPUT_DIR, '/index.html ', OUTPUT_REPORT)
system(cp_index)
#-----------------------------------

#==============the end==============


##--------end of code rendering .Rmd templates----------------
sink()
##=========== End of sinking output=============================