# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed. # nolint

# Set target options:
tar_option_set(
  packages = c("tibble","dplyr","ggplot2","tidyr","here","patchwork"), # packages that your targets need to run
  format = "rds" # default storage format
  # Set other options as needed.
)

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multiprocess")

# tar_make_future() configuration (okay to leave alone):
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

# Run the R scripts in the R/ folder with your custom functions:
tar_source()

# Replace the target list below with your own:
list(
  tar_target(dat_file, here::here("Data","anes_timeseries_cdf.csv"), format = "file"),
  tar_target(ANES_raw, read_anes(dat_file)),
  tar_target(full_sample, {transform_data(ANES_raw, desired_mode = 0:5,
                                          group_vars = c("wave"),
                                          pivot_ids = NULL)}),
  tar_target(no_internet, {transform_data(ANES_raw, desired_mode = c(0:3,5),
                                          group_vars = c("wave"),
                                          pivot_ids = NULL)}),
  tar_target(full_by_gen, {transform_data(ANES_raw, desired_mode = c(0:3,5),
                                          group_vars = c("generation","wave"),
                                          pivot_ids = c("generation","wave"))}),
  tar_target(fig1, {create_standard_plot(full_sample,
                                         save = "fig1.png",
                                         title = "After experiencing a lull in the 70s, the percent of strong partisans\nin the US is on the rise\n",
                                         subtitle = "While the US is experiencing an increase in partisan leaners, there is an\nincrease in the percentage of Americans identifying strongly with a political party.\n",
                                         caption = "Data: ANES CDF (2022 Vintage)\nAnalysis by Peter Licari"
  )}),
  tar_target(fig2a, create_standard_plot(full_sample, subtitle = "Full sample")),
  tar_target(fig2b, create_standard_plot(full_sample, subtitle = "Non-Internet respondents")),
  tar_target(fig2,  create_patchwork_plot(fig2a, fig2b, save = "fig2.png")),
  tar_target(fig3, {create_faceted_plot(full_by_gen,
                                        save = "fig3.png",
                                        title = "Some generations were more inclined towards higher strength\nbut all have seen an increase from the 2000s onward\n",
                                        subtitle = "Empty spaces reflect years where there were there were no\nrespondents that could be identified in that generation\n",
                                        caption = "Data: ANES CDF (2022 Vintage)\nAnalysis by Peter Licari"
  )})
  
  
)
