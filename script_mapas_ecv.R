paquetes <- c("tidyverse", "sf", "ggplot2", "geodata", 
              "classInt", "RColorBrewer", "viridis", "ggspatial")

instalar_si_falta <- function(p) {
  if (!require(p, character.only = TRUE)) install.packages(p)
}
sapply(paquetes, instalar_si_falta)

library(tidyverse)
library(sf)
library(ggplot2)
library(geodata)
library(classInt)
library(RColorBrewer)
library(viridis)
library(ggspatial)

f1  <- read.csv("datos/F1.csv",  sep = ";", encoding = "UTF-8")
f9  <- read.csv("datos/F9.csv",  sep = ";", encoding = "UTF-8")
f51 <- read.csv("datos/F51.csv", sep = ";", encoding = "UTF-8")

colombia <- gadm(country = "COL", level = 1, path = "datos/") |> 
  st_as_sf() |>
  st_transform(crs = 4686)

# Unir NOMBRE_DEPARTAMENTO de F1 a F9 y F51 por LLAVE_VIVIENDA
f9_dept  <- f9  |> left_join(f1 |> select(LLAVE_VIVIENDA, NOMBRE_DEPARTAMENTO), 
                             by = "LLAVE_VIVIENDA")
f51_dept <- f51 |> left_join(f1 |> select(LLAVE_VIVIENDA, NOMBRE_DEPARTAMENTO), 
                             by = "LLAVE_VIVIENDA")

# Verificar valores únicos de INGRESOS_ALCANZAN
unique(f51_dept$INGRESOS_ALCANZAN)

satisfaccion_dept <- f9_dept |>
  group_by(NOMBRE_DEPARTAMENTO) |>
  summarise(
    promedio_satisfaccion = mean(SATISFACCIÓN_VIDA, na.rm = TRUE),
    n_personas = n()
  )

ingresos_dept <- f51_dept |>
  group_by(NOMBRE_DEPARTAMENTO) |>
  summarise(
    pct_ingresos_no_alcanzan = mean(INGRESOS_ALCANZAN >= 3, na.rm = TRUE) * 100
  )

nevera_dept <- f51_dept |>
  group_by(NOMBRE_DEPARTAMENTO) |>
  summarise(
    pct_con_nevera = mean(NEVERA == 1, na.rm = TRUE) * 100
  )

# Ver nombres de departamentos en ambas fuentes para verificar que coincidan
sort(unique(colombia$NAME_1))
sort(unique(f1$NOMBRE_DEPARTAMENTO))

mapa_datos <- colombia |>
  left_join(satisfaccion_dept, by = c("NAME_1" = "NOMBRE_DEPARTAMENTO")) |>
  left_join(ingresos_dept,     by = c("NAME_1" = "NOMBRE_DEPARTAMENTO")) |>
  left_join(nevera_dept,       by = c("NAME_1" = "NOMBRE_DEPARTAMENTO"))

mapa1 <- ggplot(mapa_datos) +
  geom_sf(aes(fill = promedio_satisfaccion), color = "white", linewidth = 0.3) +
  scale_fill_viridis_c(
    option = "mako",
    direction = 1,
    name = "Promedio\n(escala 1-10)",
    na.value = "grey80"
  ) +
  labs(
    title = "El bienestar varía profundamente según\nel departamento donde vives",
    subtitle = "Promedio de satisfacción con la vida por departamento — ECV 2025",
    caption = "Fuente: DANE — ECV 2025. Datos muestrales, no representan estimaciones poblacionales."
  ) +
  theme_void() +
  theme(
    plot.title    = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey40"),
    plot.caption  = element_text(size = 7,  hjust = 0.5, color = "grey60"),
    legend.position = "right"
  )

ggsave("mapas/mapa1_satisfaccion_vida.png", 
       plot = mapa1, width = 10, height = 12, dpi = 300)

mapa2 <- ggplot(mapa_datos) +
  geom_sf(aes(fill = pct_ingresos_no_alcanzan), color = "white", linewidth = 0.3) +
  scale_fill_viridis_c(
    option = "heat",
    direction = 1,
    name = "% hogares",
    na.value = "grey80"
  ) +
  labs(
    title = "En algunos departamentos, más hogares\nsienten que sus ingresos no alcanzan",
    subtitle = "Porcentaje de hogares con ingresos insuficientes por departamento — ECV 2025",
    caption = "Fuente: DANE — ECV 2025. Datos muestrales, no representan estimaciones poblacionales."
  ) +
  theme_void() +
  theme(
    plot.title    = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey40"),
    plot.caption  = element_text(size = 7,  hjust = 0.5, color = "grey60"),
    legend.position = "right"
  )

ggsave("mapas/mapa2_ingresos_no_alcanzan.png",
       plot = mapa2, width = 10, height = 12, dpi = 300)

mapa3 <- ggplot(mapa_datos) +
  geom_sf(aes(fill = pct_con_nevera), color = "white", linewidth = 0.3) +
  scale_fill_viridis_c(
    option = "viridis",
    direction = 1,
    name = "% hogares",
    na.value = "grey80"
  ) +
  labs(
    title = "El acceso a bienes básicos como la nevera\nno es igual en todos los departamentos",
    subtitle = "Porcentaje de hogares con nevera por departamento — ECV 2025",
    caption = "Fuente: DANE — ECV 2025. Datos muestrales, no representan estimaciones poblacionales."
  ) +
  theme_void() +
  theme(
    plot.title    = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey40"),
    plot.caption  = element_text(size = 7,  hjust = 0.5, color = "grey60"),
    legend.position = "right"
  )

ggsave("mapas/mapa3_nevera.png",
       plot = mapa3, width = 10, height = 12, dpi = 300)

message("Mapas guardados en la carpeta mapas/")

summary(satisfaccion_dept$promedio_satisfaccion)
summary(ingresos_dept$pct_ingresos_no_alcanzan)
summary(nevera_dept$pct_con_nevera)
