
clean_colnames <- function(colnames){
  temp <- gsub("(?<=[A-Za-z])(?=[A-Z])", "_", colnames, perl = TRUE)
  tolower(temp)
}

replace_NULLs <- function(column){
  na_if(column, 'NULL')
}

data_type_conv <- function(walmart){
  walmart$visit_number <- as.numeric(walmart$visit_number)
  walmart$weekday <- as.factor(walmart$weekday)
  walmart$upc <- as.numeric(walmart$upc)
  walmart$scan_count <- as.numeric(walmart$scan_count)
  walmart$department_description <- as.factor(walmart$department_description)
  walmart$fineline_number <- as.factor(walmart$fineline_number)
  if("trip_type" %in% colnames(walmart)){
    walmart$trip_type <- as.factor(walmart$trip_type)
  }
  walmart
}