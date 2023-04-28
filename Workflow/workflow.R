
## Reads in Data
ANES_raw <- read_anes(dat_file)

## Transforms data

### Full sample (fig1 & fig2a)
full_sample <- transform_data(ANES_raw, desired_mode = 0:5,
                              group_vars = c("wave"),
                              pivot_ids = NULL)

### No internet robustness check sample (mode effect test) (fig2b)
no_internet <- transform_data(ANES_raw, desired_mode = c(0:3,5),
                              group_vars = c("wave"),
                              pivot_ids = NULL)

full_by_gen <- transform_data(ANES_raw, desired_mode = c(0:3,5),
                              group_vars = c("generation","wave"),
                              pivot_ids = c("generation","wave"))


## Create figures

### Figure 1: Main plot
fig1 <- create_standard_plot(full_sample,
                             save = "fig1.png",
                             title = "After experiencing a lull in the 70s, the percent of strong partisans\nin the US is on the rise\n",
                             subtitle = "While the US is experiencing an increase in partisan leaners, there is an\nincrease in the percentage of Americans identifying strongly with a political party.\n",
                             caption = "Data: ANES CDF (2022 Vintage)\nAnalysis by Peter Licari"
)


### Figure 2: Robustness check for mode effects
fig2a <- create_standard_plot(full_sample, subtitle = "Full sample")
fig2b <- create_standard_plot(no_internet, subtitle = "Non-Internet respondents")

fig2 <- create_patchwork_plot(fig2a, fig2b, save = "fig2.png")


fig3 <- create_faceted_plot(full_by_gen,
                            save = "fig3.png",
                            title = "Some generations were more inclined towards higher strength\nbut all have seen an increase from the 2000s onward\n",
                            subtitle = "Empty spaces reflect years where there were there were no\nrespondents that could be identified in that generation\n",
                            caption = "Data: ANES CDF (2022 Vintage)\nAnalysis by Peter Licari"
                            )
