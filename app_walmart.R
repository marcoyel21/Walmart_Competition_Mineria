#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#



# NOTA; este archivo supone que hay una base de datos LIMPIA llamada WALMART 
#y que ya está cargada en memoria. 


instalar <- function(paquete) {
    
    if (!require(paquete,character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)) {
        install.packages(as.character(paquete), dependecies = TRUE, repos = "http://cran.us.r-project.org")
        library(paquete, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)
    }
}

paquetes <- c("shiny","plotly","ggplot2")

lapply(paquetes, instalar);


walmart_numeric<-walmart %>% select(where(is.numeric)) %>% names()
walmart_categoric<-walmart %>% select(where(is.character) |  where(is.factor)) %>% names()


# Define UI for application that draws a histogram
ui <- fluidPage(
    # Application title
    titlePanel("Walmart Bivariados"),
    
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            conditionalPanel(condition="input.tabs=='Boxplot'",
                #Panel para bivariada cat_num
                selectInput("num_var", "Variable_Numerica",walmart_numeric),
                selectInput("num_cat", "Variable_Categorica", walmart_categoric) ),
            
            conditionalPanel(condition="input.tabs=='Scatterplot'",    
                #Panel para bivariada numerica
                selectInput("num_var_x", "Variable_Numerica_x",walmart_numeric),
                selectInput("num_var_y", "Variable_Numerica_y", walmart_numeric) )
                            
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel(type = "tabs", id='tabs',
                tabPanel("Boxplot", plotlyOutput("boxplot")),
                tabPanel("Scatterplot", plotlyOutput("scatterplot"))
            )
        )        
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    
    
    output$scatterplot <- renderPlotly({
        
        var_num_x <- input$num_var_x
        var_num_y <- input$num_var_y
        
        # draw the scatterplot
        p <-ggplot(walmart,  aes_string(x=var_num_x , y= var_num_y))+
            geom_point(colour='aquamarine3',alpha=0.7)+
            geom_smooth(method=lm , color="gray77", se=FALSE)
        
        ggplotly(p)
    })     
    
    #Genera Boxplot 
    output$boxplot <- renderPlotly({
        var_cat <- input$num_cat
        var_num <- input$num_var
            
    p <-ggplot(walmart)+
            geom_boxplot(mapping=aes_string(x=var_cat , y=var_num), na.rm = TRUE,colour='aquamarine3',fill='royalblue3' )+
            theme(axis.text.x = element_text(angle=90))+
            ggtitle(paste(var_cat, ' y ', var_num)) 
        
    ggplotly(p)
    })
    
}


# Run the application 
shinyApp(ui = ui, server = server)
