# nota: en este paso se van a realizar los ejercicios tanto para el dataframe de entrenamiento como el de prueba
source("utils.R"     , encoding = 'UTF-8')
source("00-load.R"   , encoding = 'UTF-8')
source("01-prepare.R", encoding = 'UTF-8')
source("02-clean.R",   encoding = 'UTF-8')
source("03-eda.R"  , encoding = 'UTF-8')

# PASO I: Adecuo la estructura

#importo los datos (MODIFICAR PARA DATOS LIMPIOS)

#Creo una versión auxiliar y una de trabajo
walmart$TripType<-as.character(walmart$TripType)

walmart_aux_train <- read_feather("walmart.feather")
walmart_aux_test <- read_feather("walmart_test.feather")


walmart_train<-read_feather("walmart.feather")
walmart_test<-read_feather("walmart_test.feather")

#Expando dummies (bien podríamos usar otra columna, aquí se decidió usar DeparmentDescription)
walmart_train <- fastDummies::dummy_cols(walmart_train, select_columns = "department_description")
walmart_test <- fastDummies::dummy_cols(walmart_test, select_columns = "department_description")


# Sumo todas las compras por departamento (multiplicando scan_count por las dummies)
for (i in 8:76) {
  walmart_train[i]<-walmart_train[5]*walmart_train[i]
}

for (i in 7:74) {
  walmart_test[i]<-walmart_test[4]*walmart_test[i]
}


#Finalmente, agrego una dummy de si hubo retorno
walmart_train<-walmart_train %>% mutate (regreso=ifelse(scan_count<0,1,0))
walmart_test<-walmart_test %>% mutate (regreso=ifelse(scan_count<0,1,0))


#Paso II: cambio el nivel de análisis: ahora cada observación será cada viaje y no cada producto
# Elimino las columnas que no podré agrupar
walmart_train$fineline_number<-NULL
walmart_train$department_description<-NULL
walmart_train$scan_count<-NULL
walmart_train$upc<-NULL

walmart_test$fineline_number<-NULL
walmart_test$department_description<-NULL
walmart_test$scan_count<-NULL
walmart_test$upc<-NULL

# Agrupo por visit_number(que es la de jerarquía más alta); 
# trip_type y weekday solo las agrupo para que no se sumen o "colapsen":
# El resto (las dummies) se suman o "colapsan"
walmart_train<-walmart_train %>% 
  group_by(visit_number, trip_type,weekday) %>%
  summarise_each(funs(sum)) 

walmart_test<-walmart_test %>% 
  group_by(visit_number,weekday) %>%
  summarise_each(funs(sum)) 


# Como también se sumo ("colapsó) la dummy de regreso, simplemente la convierto a dummy otra vez.
walmart_train<-walmart_train %>% mutate(regreso=ifelse(regreso>0,1,0))
walmart_test<-walmart_test %>% mutate(regreso=ifelse(regreso>0,1,0))

#Solo faltaría agregar la columna de variedad de departments pero para eso tengo que hacer un ejercicio similar al anterior de manera paralela



#PASO III: Creo la columna de variedad para luego juntarla a mi dataset original
# Creo variable de variedad (para esto repito todo el ejercicio).
# Este paso se crea en una base de datos auxiliar que  una vez extraida la columna creada,  no necesitaré más

#Expando dummies
walmart_aux_train <- fastDummies::dummy_cols(walmart_aux_train, select_columns = "department_description")
walmart_aux_test <- fastDummies::dummy_cols(walmart_aux_test, select_columns = "department_description")

#Elimino columnas inagrupables
walmart_aux_train$fineline_number<-NULL
walmart_aux_train$department_description<-NULL
walmart_aux_train$scan_count<-NULL
walmart_aux_train$upc<-NULL

walmart_aux_test$fineline_number<-NULL
walmart_aux_test$department_description<-NULL
walmart_aux_test$scan_count<-NULL
walmart_aux_test$upc<-NULL


# Agrupo:

walmart_aux_train<-walmart_aux_train %>% 
  group_by(visit_number,trip_type,weekday) %>%
  summarise_each(funs(sum)) 

walmart_aux_test<-walmart_aux_test %>% 
  group_by(visit_number,weekday) %>%
  summarise_each(funs(sum)) 


#Finalmente creo mi columna de variedad sumando todas las dummies por fila

#PASO FINAL: JUNTO TODO en walmart_wide

walmart_wide_train<-cbind.data.frame(walmart_train, (data.frame(variedad = apply(walmart_aux_train[4:71], 1, sum))))
walmart_wide_test<-cbind.data.frame(walmart_test, (data.frame(variedad = apply(walmart_aux_test[3:69], 1, sum))))

walmart_wide_test<-add_column(walmart_wide_test, "department_description_HEALTH AND BEAUTY AIDS" = 0, .after = "department_description_HARDWARE")

# Finalmente obtengo las dummies de los días de la semana

walmart_wide_train <- fastDummies::dummy_cols(walmart_wide_train, select_columns = "weekday")
walmart_wide_test <- fastDummies::dummy_cols(walmart_wide_test, select_columns = "weekday")
walmart_wide_train$weekday<-NULL
walmart_wide_test$weekday<-NULL

# Escribo los feather final

write_feather(walmart_wide_train, "walmart_wide_train.feather")
write_feather(walmart_wide_test, "walmart_wide_test.feather")




