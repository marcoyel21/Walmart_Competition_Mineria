# FUNCIONES PARA EL EDA

select_numeric <- function(df){
  df %>% select_if(is.numeric)
}

select_categoric <- function(df){
  df %>% select_if(is.factor)
}

# UNIVARIADO

plot_boxplot <- function(df){
  df %>% stack() %>% drop_na(values) %>% ggplot(aes(x = ind, y = values)) +
    geom_boxplot() + theme_light() + theme_light() +
    facet_wrap(~ind, scale="free")
}

plot_density <- function(df){
  df %>% stack() %>% drop_na(values) %>% ggplot(aes(x = values)) +
    geom_density() + theme_light() +
    facet_wrap(~ind, scale="free")
}

plot_histogram <- function(df){
  df %>% stack() %>% drop_na(values) %>% ggplot(aes(x = values)) +
    geom_histogram(bins = 30) + theme_light() +
    facet_wrap(~ind, scale="free")
}

plot_barplot <- function(df, variable){
  ggplot(df) + aes(x = reorder(variable, variable, function(x) length(x))) +
    geom_bar(fill="steelblue") + theme_light() + coord_flip() +
    ylab("frecuencia")
}