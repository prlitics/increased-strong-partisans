# Strong Partisans are on the Rise in the US: Code Repository

An investigation and visualization of the proportion of the US public identifying as "Strong Partisans".

This is the code directory for this [Medium](https://prlicari.medium.com/strong-partisans-are-on-the-rise-in-the-us-7db7fa0434ab) post discussing how the percentage of the public identifying as a "strong" partisan (either Democrat or Republican) has increased over the last 40 years. It investigates two potential confounding factors (mode of interview and cohort effects) and finds that neither can explain the overall societal increase.

## Data

These data come from the American National Election Study (ANES)'s Cumulative Data File (CDF). I am using the September 16, 2022 version which was accessed April 2023. I do not include these data here in the directory itself but they are [publicly available.](https://electionstudies.org/data-center/anes-time-series-cumulative-data-file/).  


## Reproducibility 

This project uses the `{renv}` and `{targets}` packages to assist in reproducibility. Anyone looking to replicate this analysis (once they've gotten the data) can reproduce the analyses by running `renv::restore()` and `targets::tar_make()`. This analysis was conducted in R 4.2.2 on Windows 11. 

`{targets}` encourages a functional approach to projects. To get a commented version of the workflow, you can go to the `workflow.R` file in the "Workflows" directory. The function definitions are in the "R" directory. I made these functions pretty minimally paramertized; hopefully even folks who are less immersed in the more computer-sciency side of working in R will be able to read through! 


## License

This is a CC BY 4.0 licensed project. You can read the LICENSE.md document for further detail but, basically: You're free to use this code more or less however you want. But if you're going to use some/parts/all of it in your own work, please just be sure you cite it. 


```
Peter R. Licari (2023). Strong Partisans are on the Rise in the US: Code Repository. Version 1.0.0. https://github.com/prlitics/increased-strong-partisans

```

