# nota: en este paso se van a realizar los ejercicios tanto para el dataframe de entrenamiento como el de prueba
source("utils.R"     , encoding = 'UTF-8')
source("00-load.R"   , encoding = 'UTF-8')
source("01-prepare.R", encoding = 'UTF-8')
source("02-clean.R",   encoding = 'UTF-8')
source("03-eda.R"  , encoding = 'UTF-8')

# PASO I: Adecuo la estructura

#importo los datos (MODIFICAR PARA DATOS LIMPIOS)
sample_submission<-read.csv("sample_submission.csv")

#Creo una versión auxiliar y una de trabajo
walmart$TripType<-as.character(walmart$TripType)
walmart_aux_train <- walmart
walmart_aux_test <- walmart_test

walmart_train<-walmart
walmart_test<-walmart_test

#Expando dummies (bien podríamos usar otra columna, aquí se decidió usar DeparmentDescription)
walmart_train <- fastDummies::dummy_cols(walmart_train, select_columns = "DepartmentDescription")
walmart_test <- fastDummies::dummy_cols(walmart_test, select_columns = "DepartmentDescription")


# Sumo todas las compras por departamento (multiplicando scan_count por las dummies)
for (i in 8:76) {
  walmart_train[i]<-walmart_train[5]*walmart_train[i]
}

for (i in 7:74) {
  walmart_test[i]<-walmart_test[4]*walmart_test[i]
}


#Finalmente, agrego una dummy de si hubo retorno
walmart_train<-walmart_train %>% mutate (regreso=ifelse(ScanCount<0,1,0))
walmart_test<-walmart_test %>% mutate (regreso=ifelse(ScanCount<0,1,0))


#Paso II: cambio el nivel de análisis: ahora cada observación será cada viaje y no cada producto
# Elimino las columnas que no podré agrupar
walmart_train$FinelineNumber<-NULL
walmart_train$DepartmentDescription<-NULL
walmart_train$ScanCount<-NULL
walmart_train$Upc<-NULL

walmart_test$FinelineNumber<-NULL
walmart_test$DepartmentDescription<-NULL
walmart_test$ScanCount<-NULL
walmart_test$Upc<-NULL

# Agrupo por visit_number(que es la de jerarquía más alta); 
# trip_type y weekday solo las agrupo para que no se sumen o "colapsen":
# El resto (las dummies) se suman o "colapsan"
walmart_train<-walmart_train %>% 
  group_by(VisitNumber, TripType,Weekday) %>%
  summarise_each(funs(sum)) 

walmart_test<-walmart_test %>% 
  group_by(VisitNumber,Weekday) %>%
  summarise_each(funs(sum)) 


# Como también se sumo ("colapsó) la dummy de regreso, simplemente la convierto a dummy otra vez.
walmart_train<-walmart_train %>% mutate(regreso=ifelse(regreso>0,1,0))
walmart_test<-walmart_test %>% mutate(regreso=ifelse(regreso>0,1,0))

#Solo faltaría agregar la columna de variedad de departments pero para eso tengo que hacer un ejercicio similar al anterior de manera paralela



#PASO III: Creo la columna de variedad para luego juntarla a mi dataset original
# Creo variable de variedad (para esto repito todo el ejercicio).
# Este paso se crea en una base de datos auxiliar que  una vez extraida la columna creada,  no necesitaré más

#Expando dummies
walmart_aux_train <- fastDummies::dummy_cols(walmart_aux_train, select_columns = "DepartmentDescription")
walmart_aux_test <- fastDummies::dummy_cols(walmart_aux_test, select_columns = "DepartmentDescription")

#Elimino columnas inagrupables
walmart_aux_train$FinelineNumber<-NULL
walmart_aux_train$DepartmentDescription<-NULL
walmart_aux_train$ScanCount<-NULL
walmart_aux_train$Upc<-NULL

walmart_aux_test$FinelineNumber<-NULL
walmart_aux_test$DepartmentDescription<-NULL
walmart_aux_test$ScanCount<-NULL
walmart_aux_test$Upc<-NULL


# Agrupo:

walmart_aux_train<-walmart_aux_train %>% 
  group_by(VisitNumber, TripType,Weekday) %>%
  summarise_each(funs(sum)) 

walmart_aux_test<-walmart_aux_test %>% 
  group_by(VisitNumber,Weekday) %>%
  summarise_each(funs(sum)) 


#Finalmente creo mi columna de variedad sumando todas las dummies por fila

#PASO FINAL: JUNTO TODO en walmart_wide

walmart_wide_train<-cbind.data.frame(walmart_train, (data.frame(variedad = apply(walmart_aux_train[4:71], 1, sum))))
walmart_wide_test<-cbind.data.frame(walmart_test, (data.frame(variedad = apply(walmart_aux_test[3:69], 1, sum))))

walmart_wide_test<-add_column(walmart_wide_test, "DepartmentDescription_HEALTH AND BEAUTY AIDS" = 0, .after = "DepartmentDescription_HARDWARE")

# Finalmente obtengo las dummies de los días de la semana

walmart_wide_train <- fastDummies::dummy_cols(walmart_wide_train, select_columns = "Weekday")
walmart_wide_test <- fastDummies::dummy_cols(walmart_wide_test, select_columns = "Weekday")
walmart_wide_train$Weekday<-NULL
walmart_wide_test$Weekday<-NULL

# Escribo los feather final

write_feather(walmart_wide_train, "walmart_wide_train.feather")
write_feather(walmart_wide_test, "walmart_wide_test.feather")




