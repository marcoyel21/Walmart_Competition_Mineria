

#Carga los datos de entrenamiento


#Cargar paquetes:




instalar <- function(paquete) {
  if (!suppressPackageStartupMessages(require(paquete,character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE))) {
    install.packages(as.character(paquete), dependecies = TRUE, repos = "http://cran.us.r-project.org")
    suppressPackageStartupMessages(library(paquete, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE))
  }
}

paquetes <- c('reshape2','knitr','gridExtra'  ,'lubridate', 'magrittr', 'ggvis', 'dplyr', 'tidyr', 'readr',
              'rvest', 'ggplot2', 'stringr', 'ggthemes', 'googleVis', 'shiny',
              'tibble','vcd', 'vcdExtra', 'GGally', 'readODS', 'readxl', "RSQLite",
              'patchwork', 'gridExtra', 'grid', 'ggpubr',
              'ggExtra', 'purrr', 'forcats', 'ggridges', 'viridis', 
              'visdat', 'VIM', 'mice', 'ggcorrplot', 'MuMIn','tidyverse')


lapply(paquetes, instalar);

# Cargar datos 

load_train <- function(){
  load<-read_csv("train.csv",col_names=TRUE)
  load
}

# FUNCIONES PARA EDA

rows_with_NAs <- function(df){
  df[rowSums(is.na(df)) > 0,]
}

prop_missings <- function(df){
  aggr(df, prop=TRUE, numbers=TRUE, bars=FALSE, cex.axis=.8, oma = c(9,2,2,2))
}

unique_per_col <- function(df){
  sapply(df, function(x) length(unique(x)))
}

rows_with_string <- function(df, column, string){
  filter(df, column == string)
}



# gráfica para variables numéricas
graphs_numeric <- function(df, name_num_var, log=FALSE){
  "
  Función para generar gráficos de variables de tipo numérico.
  ** Inputs:
    - df: df o tibble con los datos
    - name_num_var (ch): nombre de la variable numérica.
    - log (bool): TRUE si se quiere analizar la variable en log base 10.
  ** Outputs:
    - ggplot object con boxplot, density plot, q-q plot, y estadísticas
    descriptivas (n, min, max, median, iqr, mean, sd)
  "
  if (log==TRUE){
    # si se requiere que sea el log de la variable
    num_var <- log(df[[name_num_var]]) 
    graph_title <- paste('Log', name_num_var)
  } else{
    num_var <- df[[name_num_var]]
    graph_title <- name_num_var
  }
  # boxplot
  plt_boxplot <- ggplot(df, aes(x = "", y = num_var)) +
    stat_summary(fun.data = qtl.bxp, fun.args = list(type = 5),
                 geom = 'boxplot') + xlab(NULL) + 
    theme(axis.text.y = element_blank(), plot.title = element_text(size=10)) +
    coord_flip() + labs(y= name_num_var) +
    ggtitle(graph_title) + theme_wsj()
  # density plot
  plt_density <- ggplot(df, aes(x=num_var)) + 
    geom_density( aes(x=num_var), fill="#69b3a2", alpha=0.3) +
    theme_wsj() +
    theme(text = element_text(size=12), axis.title=element_text(size=12),
          axis.text=element_text(size=12)) +
    labs(x= name_num_var, y='Densidad') 
  
  # q-q plot
  plt_qq <- ggplot(df, aes(sample = num_var)) + 
    stat_qq() + stat_qq_line() + theme_wsj() +
    theme(text = element_text(size=12), axis.title=element_text(size=12),
          axis.text=element_text(size=12)) +
    labs(x= 'Muestral', y='Teórica')
  
  # estadísticas descriptivas
  if (log==TRUE){
    summary.stats <- df %>% 
      select(name_num_var) %>% log() %>% get_summary_stats(type = "common")
  } else{
    summary.stats <- df %>% 
      select(name_num_var) %>% get_summary_stats(type = "common")
  }
  
  plt_summ <- ggsummarytable(summary.stats, x=name_num_var, 
                             y = c("n", "min", "max","median", "iqr", "mean", "sd"),
                             ggtheme = theme_wsj()) +
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank())
  
  # plt conjunto
  plt_all <- (plt_boxplot + plt_density) / ( plt_qq +  plt_summ)
}




qtl.bxp <- function(x, type = 5) {
  "
  Función para generar diferentes boxplot (variando cuantiles)
  Tomada de: https://mgimond.github.io/ES218/Week05a.html
  ** Inputs:
    - x (num): vector numérico
    - type (int): cuantil
  ** Outputs:
    - df con cuantiles para generar boxplot.
  "
  x <- na.omit(x)
  qtl <- quantile(x, type = type)
  df <- data.frame(ymin  = qtl[1], ymax = qtl[5], 
                   upper = qtl[4], lower = qtl[2], middle = qtl[3])
}

# gráficas de categóricas
graphs_categ <- function(df, name_cat_var){
  "
  Función para generar gráficos de variables de tipo numérico.
  ** Inputs:
    - df: df o tibble con los datos
    - name_num_var (ch): nombre de la variable numérica.
    - log (bool): TRUE si se quiere analizar la variable en log base 10.
  ** Outputs:
    - ggplot object con boxplot, density plot, q-q plot, y estadísticas
    descriptivas (n, min, max, median, iqr, mean, sd)
  "
  # barplot
  counts <- df %>% group_by(!!as.symbol(name_cat_var)) %>% 
    summarize(n = n()) %>% mutate(freq = n / sum(n))
  
  plt_bar_cnt <- ggplot(counts, aes(x=reorder(!!as.symbol(name_cat_var), n), y=n)) +
    geom_bar(stat="identity", fill="#69b3a2", alpha=0.3) +
    coord_flip() + theme_wsj() + labs(y='Conteos', name_cat_var, 
                                      title=name_cat_var) +
    theme(text = element_text(size=12), axis.title=element_text(size=12),
          axis.text=element_text(size=10), axis.title.y=element_blank(),
          plot.title = element_text(size=12))
  
  plt_bar_frq <- ggplot(counts, 
                        aes(x=reorder(!!as.symbol(name_cat_var), freq), y=freq)) +
    geom_bar(stat="identity", fill="#69b3a2", alpha=0.3) + 
    coord_flip() + theme_wsj() + labs(y='Proporción') +
    theme(text = element_text(size=10), axis.title=element_text(size=12),
          axis.text=element_text(size=12), axis.title.y=element_blank())
  
  # plt conjunto
  plt_all <- plt_bar_cnt / plt_bar_frq
}






uv_graphs2 <- function(df, var_list, log_vars=FALSE){
  "
  Replica el comportamiento de uv_graphs pero esta es la implementación
  vectorizada. 
  "
  # Si no se provee lista de variables se evalúan todas / o si el tipo es 'all'
  if (missing(var_list)){
    var_list <- colnames(df)
  } else {var_list <- var_list}
  # selecciona las variables elegidas
  df <- df %>% na.omit()
  df <- df %>% select(all_of(var_list))
  # deduce variables numéricas
  nums <- unlist(lapply(df, is.numeric)) 
  num_list <- df[ , nums] %>% colnames()
  # deduce variables categóricas
  cats <- unlist(lapply(df, is.character)) 
  cat_list <- df[ , cats] %>% colnames()
  
  # hace gráficos para numéricas
  num_plots <- df %>% select(all_of(num_list)) %>% 
    names() %>% 
    map(~graphs_numeric(df, name_num_var = ., log=log_vars))
  print(num_plots)
  # plots para categóricas
  cat_plots <- df %>% select(all_of(cat_list)) %>% 
    names() %>% 
    map(~graphs_categ(df, name_cat_var = .))
  print(cat_plots)
  
}
