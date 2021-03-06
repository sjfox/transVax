library(tidyverse)

get_final_sizes <- function(mat){
  # Given a matrix and returns data_frame of final number vaccinated and final epidemic size for the disease
  if(is.null(mat)) return(data_frame(vax=NA, disease=NA))
  data_frame(vax = max(mat[,"cum_vax"]), disease = max(mat[,"cum_dis"]))
}

# get_all_final_sizes <- function(list_mat){
#   # Given list of matrices, returns data_frame of final number vaccinated and final epidemic size for all matrices in the file
#   df <- data.frame()
#   for(i in 1:length(list_mat)){
#     df <- rbind(df, get_final_sizes(list_mat[[i]]))
#   }
#   return(df)
# }
get_all_final_sizes <- function(list_mat){
  list_mat %>% map(get_final_sizes) %>%
    bind_rows()
}

# all_equal(get_all_final_sizes(epidemicRuns), get_all_final_sizes2(epidemicRuns)) ## checks that both outputs are identical

#microbenchmark::microbenchmark(times = 10,
#                               get_all_final_sizes(epidemicRuns),
#                               get_all_final_sizes2(epidemicRuns))
#get_all_final_sizes(epidemicRuns) %>% ggplot(aes(disease))+geom_histogram()

calc_prop_extinct <- function(df, epi_threshold = 500){
  # Calculates the proportion of simulations that resulted in extinction of the epidemic
  1 - sum(df$disease >= epi_threshold, na.rm=T)/nrow(df[!is.na(df$disease), ])
}

prop_extinct <- function(file){
  # load file and return data frame with beta_vax and calculation for proportion of simulations ending in extinction
  load(file)
  data.frame(beta=params['beta_vax'], proportion=get_all_final_sizes(epidemicRuns) %>% calc_prop_extinct())
}

files = list.files('data/transVax_data_init_dis_50/', pattern='.Rdata', full.names=TRUE) # hard coded path to directory
props <- map(files, prop_extinct) %>% bind_rows()

props %>% mutate(R_0=seq(0.05:1, by=0.05)) %>% ggplot(aes(x=R_0, y=proportion)) + geom_point() + ylim(0,1)

