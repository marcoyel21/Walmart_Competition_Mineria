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

plot_heatmap <- function(walmart){
  
  walmart <- walmart[complete.cases(walmart), ]
  walmart <- filter(walmart, trip_type != 999)
  
  walmart<-walmart %>% select(trip_type,department_description) %>%
    mutate(value = 1) %>% group_by(trip_type, department_description) %>%
    dplyr::summarise(count=na_sum(value)) %>%
    as.data.frame()
  
  m4 <- walmart %>%
    mutate(department_description=factor(department_description, levels=rev(sort(unique(department_description))))) %>%
    mutate(countfactor=cut(count,breaks=c(1, 100, 500, 1000, 3000, 5000, 10000, max(count,na.rm=T)),
                           labels=c("0-100","100-500","1000-3000","3000-5000","5000-10000","10000-30000",">30000"))) %>%
    mutate(countfactor=factor(as.character(countfactor), levels=rev(levels(countfactor))))
  
  ggplot(m4,aes(x=factor(trip_type),y=department_description,fill=countfactor))+
    #add border white colour of line thickness 0.25
    geom_tile(colour="white",size=0.25)+
    #remove x and y axis labels
    labs(x="",y="")+
    #remove extra space
    scale_y_discrete(expand=c(0,0))+
    
    #set a base size for all fonts
    theme_grey(base_size=8)+
    scale_y_discrete(expand=c(0,0))+
    
    scale_fill_manual(values=c("#d53e4f","#f46d43","#fdae61","#fee08b","#e6f598","#abdda4","#ddf1da"),na.value = "grey90")+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5),
          legend.text=element_text(face="bold"),
          axis.ticks=element_line(size=0.4),
          plot.background=element_blank(),
          panel.border=element_blank())+
    xlab("ID")
}