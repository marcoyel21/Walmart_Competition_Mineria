
# PASO I: Adecuo la estructura

#importo los datos (MODIFICAR PARA DATOS LIMPIOS)
#walmart<-read_csv("https://raw.githubusercontent.com/marcoyel21/Walmart_Competition_Mineria/master/train.csv")

walmart_aux <- walmart
#ESTO DE CASOS COMPLETOS LO PODEMOS QUITAR O DEJAR
walmart<-walmart[complete.cases(walmart), ] 

#Clasifico a mi variable objetivo como factor
walmart$trip_type<-as.character(walmart$trip_type)
#Expando dummies (bien podríamos usar otra columna, aquí se decidió usar DeparmentDescription)
walmart <- fastDummies::dummy_cols(walmart, select_columns = "department_description")
# Sumo todas las compras por departamento (multiplicando scan_count por las dummies)
for (i in 6:74) {
  walmart[i]<-walmart[5]*walmart[i]
}
#Finalmente, agrego una dummy de si hubo retorno
walmart<-walmart %>% mutate (regreso=ifelse(scan_count<0,1,0))


#Paso II: cambio el nivel de análisis: ahora cada observación será cada viaje y no cada producto
# Elimino las columnas que no podré agrupar
walmart$fineline_number<-NULL
walmart$department_description<-NULL
walmart$scan_count<-NULL
walmart$upc<-NULL
# Agrupo por visit_number(que es la de jerarquía más alta); 
# trip_type y weekday solo las agrupo para que no se sumen o "colapsen":
# El resto (las dummies) se suman o "colapsan"
walmart<-walmart %>% 
  group_by(visit_number, trip_type,weekday) %>%
  summarise_each(funs(sum)) 
# Como también se sumo ("colapsó) la dummy de regreso, simplemente la convierto a dummy otra vez.
walmart<-walmart %>% mutate(regreso=ifelse(regreso>0,1,0))
#Solo faltaría agregar la columna de variedad de departments pero para eso tengo que hacer un ejercicio similar al anterior de manera paralela



#PASO III: Creo la columna de variedad para luego juntarla a mi dataset original
# Creo variable de variedad (para esto repito todo el ejercicio).
# Este paso se crea en una base de datos auxiliar que  una vez extraida la columna creada,  no necesitaré más

#walmart_aux<-read_csv("https://raw.githubusercontent.com/marcoyel21/Walmart_Competition_Mineria/master/train.csv")
walmart_aux<-walmart_aux[complete.cases(walmart_aux), ]
#Clasifico a mi variable objetivo como factor
walmart_aux$trip_type<-as.character(walmart_aux$trip_type)
#Expando dummies
walmart_aux <- fastDummies::dummy_cols(walmart_aux, select_columns = "department_description")
#Elimino columnas inagrupables
walmart_aux$fineline_number<-NULL
walmart_aux$department_description<-NULL
walmart_aux$scan_count<-NULL
walmart_aux$upc<-NULL
# Agrupo:
walmart_aux<-walmart_aux %>% 
  group_by(visit_number, trip_type,weekday) %>% 
  summarise_each(funs(sum))
#Ahora como tengo sumas en cada columna de departmeent, las convierto en dummies otra vez
#Creo una función que rehace en dummies las variables 
myfun<-function(x) {ifelse(x>0,(min(x[x > 0])),0)}
for (i in 4:71) {
  walmart_aux[i]<-myfun(walmart_aux[i])
}
#Finalmente creo mi columna de variedad sumando todas las dummies por fila
variedad <- data.frame(variedad = apply(walmart_aux[4:71], 1, sum)) 


#PASO FINAL: JUNTO TODO en walmart_wide
walmart_wide<-cbind.data.frame(walmart,variedad)

