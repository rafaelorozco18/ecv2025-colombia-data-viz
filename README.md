# ¿Cómo Viven los Hogares Colombianos? — ECV 2025 Data Visualization

> **Academic Project · Universidad Externado de Colombia · Visualización de Datos I, 2026**  
> Ailyn Gómez · Allison Loango · Rafael Orozco  
> Data: DANE — Encuesta Nacional de Calidad de Vida (ECV) 2025 · 87,000 households

**[📊 Interactive Power BI Dashboard](https://app.powerbi.com/links/iIhnY5TYfR?ctid=3b944d9a-1051-4685-b09d-9a95ee2dbd99&pbi_source=linkShare)** *(requires Universidad Externado de Colombia login)*

---

## Overview

A data storytelling project answering a single question for Colombian citizens: **does where you live determine how well you live?** Built on DANE's 2025 National Quality of Life Survey (87,000 households), the project combines three R-built choropleth maps with an interactive Power BI dashboard, following the **SCQA narrative framework** (Situation → Complication → Question → Answer) to communicate findings to a non-technical, public audience.

**Central finding:** Colombia's territory is not just geography — it determines opportunity, access, and quality of life. The urban–rural gap is real, measurable, and visible across every indicator analyzed.

---

## Data Sources

| Module | Content |
|---|---|
| F1 | Housing and household conditions |
| F9 | Household composition and subjective wellbeing |
| F51 | Living conditions and household assets |

Joined at the household/person level using `DIRECTORIO` + `SECUENCIA_P` (and `ORDEN` for person-level F9 records), validated against DANE's official data dictionary.

---

## Key Findings

| Metric | National Average |
|---|---|
| Life satisfaction (scale 1–10) | **8.16** |
| Households in poverty | **49%** |
| Food insecurity | **23%** |
| Households with insufficient income | **5.18%** |
| Social perception of the country | **5/10** |

- **Urban vs. rural split:** 50.88% / 49.12% — but access to refrigerators, TVs, vehicles, and computers is structurally higher in urban households
- **Life satisfaction range across departments: 1.63 points** (San Andrés 8.5, Antioquia/Valle 8.4 → Pacific Region & Bogotá 7.6)
- **Income insufficiency gap: ~8x** between the lowest (1.43%) and highest (11.46%) departments
- **Refrigerator access gap: 53 percentage points** between the lowest (44.6%) and highest (98.4%) departments

---

## R — Choropleth Mapping

Three department-level thematic maps built in R, each with a deliberate, justified palette choice:

| Map | Variable | Palette | Rationale |
|---|---|---|---|
| Map 1 | Life satisfaction | **Mako** (sequential) | Narrow national range (1.63 pts) — continuous scale avoids artificial binning |
| Map 2 | % income insufficient | **Inferno** | Dark tones emphasize economic hardship concentration |
| Map 3 | % households with refrigerator | **Viridis** | Colorblind-accessible; captures 53-point asset access gap |

**Technical pipeline:**
```r
colombia <- geodata::gadm(country = "COL", level = 1, path = "datos/") |>
  st_as_sf() |>
  st_transform(crs = 4686)   # MAGNA-SIRGAS — official Colombian CRS

# Aggregate household/person-level indicators by department
satisfaccion_dept <- f9_dept |> group_by(NOMBRE_DEPARTAMENTO) |>
  summarise(promedio_satisfaccion = mean(SATISFACCIÓN_VIDA, na.rm = TRUE))

# Spatial join + ggplot2 + geom_sf()
mapa_datos <- colombia |> left_join(satisfaccion_dept, by = c("NAME_1" = "NOMBRE_DEPARTAMENTO"))
```

**Stack:** `R` · `sf` · `ggplot2` · `geodata` (GADM boundaries) · `classInt` · `viridis`

A key data-cleaning challenge: department names didn't match exactly between the ECV survey and the GADM shapefile, requiring manual name correspondence mapping before the spatial join would resolve correctly.

---

## Power BI — Interactive Dashboard

Built on top of the same DANE data via Power Query, with:
- Urban / Rural / All toggle, plus Region, Department, and Zone filters
- Bar chart of life satisfaction by region
- Donut chart of urban/rural household distribution
- Grouped bar chart comparing asset ownership (refrigerator, TV, vehicle, computer) by zone
- Native Power BI department-level map for the territorial dimension
- Declarative chart titles ("The region where you live influences how satisfied you feel") instead of technical variable names — designed for citizen readability

**Power Query transformations:** numeric retyping, DANE non-response codes (9/99) recoded to null, accent/special-character normalization, conditional zone column (`CLASE == 1 → Urbano`, `CLASE == 2 → Rural`, `CLASE == 3 → Centro poblado`).

---

## Methodology & Narrative Framework

The presentation follows **SCQA**:
- **Situation:** 87,000 households, one trusted source (DANE), one question
- **Complication:** the national average (8.16 satisfaction) hides real territorial variation
- **Question:** is this the same across the whole country?
- **Answer:** no — three maps and a dashboard make the urban–rural and inter-departmental gaps visible and actionable

---

## Project Structure

```
ecv2025-colombia-data-viz/
├── README.md
├── ECV2025_Mapas.Rproj
├── scripts/
│   └── script_mapas_ecv.R
├── datos/
│   └── (F1.csv, F9.csv, F51.csv — DANE microdata, not redistributed)
├── mapas/
│   ├── mapa1_satisfaccion_vida.png
│   ├── mapa2_ingresos_no_alcanzan.png
│   └── mapa3_nevera.png
├── dashboard/
│   ├── Dashboard_P3.pbix
│   └── Dashboard_P3.pdf
└── docs/
    ├── Como_viven_los_hogares_colombianos.pdf   # Presentation deck
    └── Declaracion_Uso_IA.pdf                    # AI usage disclosure
```

---

## Data Disclosure

Per Universidad Externado de Colombia's institutional AI-use guidelines, this project included a formal AI usage declaration covering Power Query joins, R spatial code debugging, visualization recommendations, and narrative structuring — all reviewed, corrected, and adopted critically by the team rather than used as-is.

---

*Universidad Externado de Colombia · Facultad de Administración de Empresas · Visualización de Datos I · Mayo 2026*
