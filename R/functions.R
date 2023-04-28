## Recodes missing values (0 in the data) as NA
recode_missing <- function(x) {
  car::recode(x, "0=NA")
  
}

## Get our data file
dat_file <-
  here::here("Data", "anes_timeseries_cdf_csv_20220916.csv")


## Read in our data file; we only need a few vars
read_anes <- function(file) {
  vars <- c(
    "VCF0017",
    #mode
    "VCF0301",
    #pid7
    "VCF0101",
    #age
    "VCF0004",
    #year
    "VCF0009z") #weight
    
    readr::read_csv(file, col_select = vars)
    
}


## Transforms the data for plotting.

transform_data <- function(raw_data,
                           desired_mode,
                           group_vars,
                           pivot_ids) {
  raw_data %>%
    dplyr::rename(
      wave = VCF0004,
      weight = VCF0009z,
      age = VCF0101,
      mode = VCF0017,
      pid7 = VCF0301
    ) %>%
    dplyr::mutate(dplyr::across(c(age, pid7), recode_missing)) %>%
    dplyr::mutate(byear = wave - age) %>%
    dplyr::mutate(
      generation = dplyr::case_when(
        ## Generations
        byear < 1900 ~ 1,
        byear %in% 1901:1927 ~ 2,
        byear %in% 1928:1945 ~ 3,
        byear %in% 1946:1964 ~ 4,
        byear %in% 1965:1981 ~ 5,
        byear %in% 1982:1996 ~ 6,
        byear %in% 1997:2010 ~ 7
      )
    ) %>%
    dplyr:::filter(mode %in% desired_mode) %>% # Filtering by mode effect
    dplyr::count_(unique(c("pid7", group_vars)), wt = "weight") %>%
    tidyr::drop_na() %>%
    dplyr::group_by(wave) %>%
    dplyr::mutate(prop = n / sum(n)) %>%
    dplyr::ungroup() %>%
    dplyr::select(-n) %>%
    tidyr::pivot_wider(
      id_cols = unique(c("wave", pivot_ids)),
      names_from = 'pid7',
      values_from = 'prop',
      names_prefix = "pid_"
    ) %>%
    dplyr::mutate(
      leaner = pid_3 + pid_5,
      ind = pid_4,
      weak_partisan = pid_2 + pid_6,
      strong_partisan = pid_1 + pid_7
    ) %>%
    dplyr::select(-dplyr::starts_with("pid")) %>%
    tidyr::drop_na()
  
}


## Creating the standard plot
create_standard_plot <-
  function(data,
           title = NULL,
           subtitle = NULL,
           caption = NULL,
           save = NULL) {
    tibble_lab <- tibble::tibble(
      x = 1987,
      y = c(.90, .55, .25, .05),
      labels = c(
        "Strong Partisans",
        "Weak Partisans",
        "Leaners",
        "Independents"
      ),
      fill = c("a", "a", "b", "b")
    )
    
    
    plot <- data %>%
      tidyr::pivot_longer(!wave) %>%
      dplyr::arrange(name, wave) %>%
      ggplot() +
      geom_area(aes(
        x = wave,
        y = value,
        fill = forcats::fct_relevel(name, "strong_partisan", "weak_partisan", "leaner")
      )) +
      scale_fill_manual(values = rev(c(
        "#7FB3C8", "#6690A1", "#4D6D7A", "#344A53"
      ))) +
      scale_color_manual(values = c("white", "white")) +
      geom_text(data = tibble_lab,
                aes(
                  x = x,
                  y = y,
                  label = labels,
                  color = fill
                ),
                size = 10) +
      scale_y_continuous(labels = scales::percent_format(1),
                         expand = expansion(0, .01)) +
      scale_x_continuous(breaks = seq(1950, 2020, 10),
                         expand = expansion(0, .7)) +
      guides(fill = "none",
             color = "none") +
      ylab("% of adult\npopulation") +
      xlab("") +
      theme_minimal() +
      theme(
        axis.text = element_text(size = 15),
        plot.title = element_text(size = 25, hjust = .5),
        axis.title.y = element_text(angle = 90, size = 15),
        plot.subtitle = element_text(size = 18, hjust = .5)
      ) +
      
      labs(title = title,
           subtitle = subtitle,
           caption = caption)
    
    if (!is.null(save)) {
      ggsave(
        here::here("Images", save),
        plot,
        units = "in",
        width = 12,
        height = 7,
        bg = "white"
      )
      
      
      
    }
    
    return(plot)
    
  }


## patchwork plot for fig2

create_patchwork_plot <- function(plt1, plt2, save = NULL) {
  patch_plot <-
    patchwork::wrap_plots(plt1, plt2, ncol = 1) + patchwork::plot_annotation(
      title = "Non-internet respondents display substantively similar patterns\nin partisan identity",
      theme = theme(
        plot.title = element_text(size = 25, hjust = .5),
        plot.caption = element_text(size = 10)
      )
    ) +
    patchwork::plot_annotation(caption = "Data: ANES CDF (2022 Vintage)\nAnalysis by Peter Licari")
  
  if (!is.null(save)) {
    ggsave(
      here::here("Images", save),
      patch_plot,
      units = "in",
      width = 12,
      height = 8.5,
      bg = "white"
    )
    
    
    
  }
  
  return(patch_plot)
  
}


create_faceted_plot <-
  function(data,
           title = NULL,
           subtitle = NULL,
           caption = NULL,
           save = NULL){
    labs <- c(
      `1` = "Pre-Silent",
      `2` = "Silent",
      `3` = "Greatest",
      `4` = "Boomers",
      `5` = "Gen-X",
      `6` = " Millennials"
    )
    
    
    plot <- data %>%
      dplyr::select(-dplyr::starts_with("pid")) %>%
      dplyr::filter(generation != 7) %>%
      tidyr::pivot_longer(!c(wave, generation)) %>%
      dplyr::group_by(wave, generation) %>%
      dplyr::mutate(value = value / sum(value)) %>%
      ggplot() +
      geom_area(aes(
        x = wave,
        y = value,
        fill = forcats::fct_relevel(name, "strong_partisan", "weak_partisan", "leaner")
      )) +
      facet_wrap( ~ generation, labeller = as_labeller(labs)) +
      scale_fill_manual(
        values = rev(c(
          "#7FB3C8", "#6690A1", "#4D6D7A", "#344A53"
        )),
        name = "",
        labels =rev(c("Independents", "Leaners", "Weak Partisans", "Strong Partisans"))) +
          scale_y_continuous(
            labels = scales::percent_format(1),
            expand = expansion(0, .01)
          ) +
          scale_x_continuous(breaks = seq(1950, 2020, 20),
                             expand = expansion(0, 1.1)) +
          guides(color = "none") +
          ylab("% of adult\npopulation") +
          xlab("") +
          theme_minimal() +
          theme(
            axis.text = element_text(size = 15),
            plot.title = element_text(size = 25, hjust = .5),
            axis.title.y = element_text(angle = 90, size = 15),
            plot.subtitle = element_text(size = 18, hjust = .5)
          ) +
          
          labs(
            title = title,
            subtitle = subtitle,
            caption = caption
          )
        
    if (!is.null(save)) {
      ggsave(
        here::here("Images", save),
        plot,
        units = "in",
        width = 12,
        height = 8.5,
        bg = "white"
      )
      
       return(plot) 
        
    }
    
  }

