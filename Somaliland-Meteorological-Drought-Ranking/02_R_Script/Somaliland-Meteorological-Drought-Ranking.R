# ============================================================
# Somaliland Meteorological Drought Ranking (CHIRPS) - R Analysis
# Seasons: Gu (MAM) and Deyr (OND)
# Reads: 4 CSVs from 01_raw/csv
# Writes: outputs to 03_outputs (tables, figures, summary)
# ============================================================

# ---------- 0) Packages ----------
pkgs <- c("tidyverse", "readr", "janitor", "scales", "glue")
to_install <- pkgs[!pkgs %in% installed.packages()[, "Package"]]
if (length(to_install) > 0) install.packages(to_install)
invisible(lapply(pkgs, library, character.only = TRUE))
# ---------- 1) Paths ----------
base_dir <- "D:/Somaliland-Meteorological-Drought-Ranking"
in_dir   <- file.path(base_dir, "01_raw", "csv")
out_tbl  <- file.path(base_dir, "03_outputs", "tables")
out_fig  <- file.path(base_dir, "03_outputs", "figures")
out_sum  <- file.path(base_dir, "03_outputs", "summary")

dir.create(out_tbl, recursive = TRUE, showWarnings = FALSE)
dir.create(out_fig, recursive = TRUE, showWarnings = FALSE)
dir.create(out_sum, recursive = TRUE, showWarnings = FALSE)
# ---------- 2) Load CSVs ----------
csvs <- list.files(in_dir, pattern = "\\.csv$", full.names = TRUE)
stopifnot(length(csvs) >= 2)

pick_one <- function(patterns){
  f <- csvs
  for (p in patterns) f <- f[str_detect(f, p)]
  if (length(f) != 1) stop("Could not uniquely match file for patterns: ", paste(patterns, collapse = " + "))
  f
}
gu_file   <- pick_one(c("Gu_MAM", "Table"))
deyr_file <- pick_one(c("Deyr_OND", "Table"))

gu   <- read_csv(gu_file, show_col_types = FALSE) %>% clean_names()
deyr <- read_csv(deyr_file, show_col_types = FALSE) %>% clean_names()

needed_cols <- c("year","season","seasonal_rain_mm","baseline_mean_mm","anomaly_mm","pct_of_normal")
check_cols <- function(df, name){
  miss <- setdiff(needed_cols, names(df))
  if (length(miss) > 0) stop(glue("Missing columns in {name}: {paste(miss, collapse=', ')}"))
}
check_cols(gu, "Gu")
check_cols(deyr, "Deyr")
fix_types <- function(df){
  df %>%
    mutate(
      year = as.integer(year),
      seasonal_rain_mm = as.numeric(seasonal_rain_mm),
      baseline_mean_mm = as.numeric(baseline_mean_mm),
      anomaly_mm = as.numeric(anomaly_mm),
      pct_of_normal = as.numeric(pct_of_normal)
    ) %>%
    arrange(year)
}
gu   <- fix_types(gu)
deyr <- fix_types(deyr)
# ---------- 3) Top 10 + Top 5 ----------
gu_top10   <- gu   %>% arrange(pct_of_normal) %>% slice(1:10)
deyr_top10 <- deyr %>% arrange(pct_of_normal) %>% slice(1:10)
in_dir <- "D:/Somaliland-Meteorological-Drought-Ranking/01_raw/csv"
list.files(in_dir, pattern="\\.csv$", full.names = FALSE)
library(tidyverse)
library(readr)
library(janitor)

in_dir <- "D:/Somaliland-Meteorological-Drought-Ranking/01_raw/csv"
csvs <- list.files(in_dir, pattern="\\.csv$", full.names = TRUE)

# Pick the "Table" files only (not Top10 files)
table_files <- csvs[str_detect(csvs, "Table")]

# Identify Gu and Deyr by keywords
gu_file   <- table_files[str_detect(table_files, "Gu") | str_detect(table_files, "MAM")]
deyr_file <- table_files[str_detect(table_files, "Deyr") | str_detect(table_files, "OND")]

# If multiple match (rare), take the first and print to confirm
gu_file   <- gu_file[1]
deyr_file <- deyr_file[1]

print(gu_file)
print(deyr_file)

gu   <- read_csv(gu_file, show_col_types = FALSE) %>% clean_names()
deyr <- read_csv(deyr_file, show_col_types = FALSE) %>% clean_names()

gu <- gu %>% mutate(year = as.integer(year),
                    seasonal_rain_mm = as.numeric(seasonal_rain_mm),
                    baseline_mean_mm = as.numeric(baseline_mean_mm),
                    anomaly_mm = as.numeric(anomaly_mm),
                    pct_of_normal = as.numeric(pct_of_normal)) %>%
  arrange(year)

deyr <- deyr %>% mutate(year = as.integer(year),
                        seasonal_rain_mm = as.numeric(seasonal_rain_mm),
                        baseline_mean_mm = as.numeric(baseline_mean_mm),
                        anomaly_mm = as.numeric(anomaly_mm),
                        pct_of_normal = as.numeric(pct_of_normal)) %>%
  arrange(year)

# Now create top10 and top5 safely
gu_top10   <- gu %>% arrange(pct_of_normal) %>% slice(1:10)
deyr_top10 <- deyr %>% arrange(pct_of_normal) %>% slice(1:10)

gu_top5    <- gu_top10 %>% slice(1:5)
deyr_top5  <- deyr_top10 %>% slice(1:5)

gu_top5
deyr_top5
gu_top5 %>% select(year, seasonal_rain_mm, anomaly_mm, pct_of_normal)
deyr_top5 %>% select(year, seasonal_rain_mm, anomaly_mm, pct_of_normal)
write_csv(gu_top5 %>% select(year, seasonal_rain_mm, anomaly_mm, pct_of_normal),
          "D:/Somaliland-Meteorological-Drought-Ranking/03_outputs/tables/Gu_MAM_Top5.csv")

write_csv(deyr_top5 %>% select(year, seasonal_rain_mm, anomaly_mm, pct_of_normal),
          "D:/Somaliland-Meteorological-Drought-Ranking/03_outputs/tables/Deyr_OND_Top5.csv")
library(ggplot2)
library(scales)
library(dplyr)

plot_top10 <- function(df, title){
  df %>%
    arrange(pct_of_normal) %>%
    slice(1:10) %>%
    mutate(year = factor(year, levels = year)) %>%
    ggplot(aes(x = year, y = pct_of_normal)) +
    geom_col() +
    scale_y_continuous(labels = label_percent(scale = 1)) +
    labs(title = title, x = "Year (worst → best)", y = "% of normal") +
    theme_minimal()
}

p_gu <- plot_top10(gu, "Gu (MAM) — Top 10 Drought Years (% of normal)")
p_deyr <- plot_top10(deyr, "Deyr (OND) — Top 10 Drought Years (% of normal)")

ggsave("D:/Somaliland-Meteorological-Drought-Ranking/03_outputs/figures/Gu_Top10.png", p_gu, dpi=300, width=10, height=5)
ggsave("D:/Somaliland-Meteorological-Drought-Ranking/03_outputs/figures/Deyr_Top10.png", p_deyr, dpi=300, width=10, height=5)

p_gu
p_deyr
gu_top5 %>% select(year, seasonal_rain_mm, anomaly_mm, pct_of_normal)
deyr_top5 %>% select(year, seasonal_rain_mm, anomaly_mm, pct_of_normal)
threshold <- 70

compound <- gu %>%
  select(year, gu_pct = pct_of_normal, gu_anom = anomaly_mm) %>%
  inner_join(deyr %>% select(year, deyr_pct = pct_of_normal, deyr_anom = anomaly_mm), by="year") %>%
  mutate(compound_flag = gu_pct <= threshold & deyr_pct <= threshold,
         compound_score = (100 - gu_pct) + (100 - deyr_pct)) %>%
  arrange(desc(compound_score))

compound %>% filter(compound_flag) %>% select(year, gu_pct, deyr_pct, compound_score) %>% head(15)
threshold <- 80

compound %>%
  mutate(compound_flag = gu_pct <= threshold & deyr_pct <= threshold,
         compound_score = (100 - gu_pct) + (100 - deyr_pct)) %>%
  filter(compound_flag) %>%
  select(year, gu_pct, deyr_pct, compound_score) %>%
  arrange(desc(compound_score)) %>%
  head(15)
# mark worst 20% as drought years per season
gu_cut   <- quantile(gu$pct_of_normal, 0.20, na.rm = TRUE)
deyr_cut <- quantile(deyr$pct_of_normal, 0.20, na.rm = TRUE)

compound2 <- gu %>%
  select(year, gu_pct = pct_of_normal) %>%
  inner_join(deyr %>% select(year, deyr_pct = pct_of_normal), by="year") %>%
  mutate(
    gu_drought = gu_pct <= gu_cut,
    deyr_drought = deyr_pct <= deyr_cut,
    compound_flag = gu_drought & deyr_drought,
    compound_score = (100 - gu_pct) + (100 - deyr_pct)
  ) %>%
  arrange(desc(compound_score))

gu_cut; deyr_cut
compound2 %>% filter(compound_flag) %>% select(year, gu_pct, deyr_pct, compound_score) %>% head(15)
compound3 <- gu %>%
  select(year, gu_pct = pct_of_normal) %>%
  inner_join(deyr %>% select(year, deyr_pct = pct_of_normal), by="year") %>%
  mutate(
    gu_z = (gu_pct - mean(gu_pct, na.rm=TRUE)) / sd(gu_pct, na.rm=TRUE),
    deyr_z = (deyr_pct - mean(deyr_pct, na.rm=TRUE)) / sd(deyr_pct, na.rm=TRUE),
    combined_dryness = -(gu_z + deyr_z)  # higher = drier combined
  ) %>%
  arrange(desc(combined_dryness))

compound3 %>% select(year, gu_pct, deyr_pct, combined_dryness) %>% head(15)
compound_years80 <- compound %>%
  mutate(compound_flag = gu_pct <= 80 & deyr_pct <= 80,
         compound_score = (100 - gu_pct) + (100 - deyr_pct)) %>%
  filter(compound_flag) %>%
  select(year, gu_pct, deyr_pct, compound_score) %>%
  arrange(desc(compound_score))

compound_years80
library(ggplot2)
library(scales)
threshold <- 80

p_comp <- compound %>%
  ggplot(aes(x = gu_pct, y = deyr_pct)) +
  geom_point() +
  geom_vline(xintercept = threshold, linetype="dashed") +
  geom_hline(yintercept = threshold, linetype="dashed") +
  geom_text(data = compound %>% filter(year %in% c(1984, 1988)),
            aes(label = year), vjust = -1) +
  scale_x_continuous(labels = label_percent(scale=1)) +
  scale_y_continuous(labels = label_percent(scale=1)) +
  labs(
    title = "Compound drought check (Gu vs Deyr, % of normal)",
    x = "Gu (MAM) % of normal",
    y = "Deyr (OND) % of normal",
    caption = "Bottom-left quadrant = both seasons ≤ 80% (compound drought)"
  ) +
  theme_minimal()

p_comp
library(dplyr)
library(ggplot2)
library(scales)

# create top10 for each season and combine
gu10 <- gu %>% arrange(pct_of_normal) %>% slice(1:10) %>% mutate(season="Gu (MAM)")
dey10 <- deyr %>% arrange(pct_of_normal) %>% slice(1:10) %>% mutate(season="Deyr (OND)")

both10 <- bind_rows(gu10, dey10) %>%
  group_by(season) %>%
  mutate(year = factor(year, levels = year)) %>%  # keep worst->best order
  ungroup()

p_both <- ggplot(both10, aes(x = year, y = pct_of_normal)) +
  geom_col() +
  facet_wrap(~season, ncol = 1, scales = "free_x") +
  scale_y_continuous(labels = label_percent(scale = 1)) +
  labs(
    title = "Somaliland Seasonal Drought Ranking (CHIRPS, 1981–2024)",
    subtitle = "Top 10 drought years by lowest % of normal (baseline 1981–2010)",
    x = "Year (worst → best)", y = "% of normal"
  ) +
  theme_minimal()

ggsave("D:/Somaliland-Meteorological-Drought-Ranking/03_outputs/figures/Top10_Gu_Deyr_Combined.png",
       p_both, dpi=300, width=11, height=8)

p_both
library(dplyr)
library(ggplot2)
library(scales)

# ---- Build Top10 for each season ----
gu10 <- gu %>%
  arrange(pct_of_normal) %>%
  slice(1:10) %>%
  mutate(season = "Gu (MAM)")

dey10 <- deyr %>%
  arrange(pct_of_normal) %>%
  slice(1:10) %>%
  mutate(season = "Deyr (OND)")

both10 <- bind_rows(dey10, gu10) %>%
  group_by(season) %>%
  mutate(
    rank = row_number(),                        # 1 = worst
    year = factor(year, levels = year),         # keep worst → best order
    highlight = if_else(rank == 1, "Worst", "Other")
  ) %>%
  ungroup()

# ---- Colors (professional, not loud) ----
# Deyr = warm; Gu = cool; worst year = bold tone
fill_map <- c(
  "Deyr (OND)_Worst"  = "#7A1F1F",
  "Deyr (OND)_Other"  = "#C98A8A",
  "Gu (MAM)_Worst"    = "#0B3C5D",
  "Gu (MAM)_Other"    = "#7FA9C5"
)

both10 <- both10 %>%
  mutate(fill_key = paste0(season, "_", highlight))

# ---- Plot ----
p <- ggplot(both10, aes(x = year, y = pct_of_normal, fill = fill_key)) +
  geom_col(width = 0.82) +
  geom_text(
    aes(label = paste0(round(pct_of_normal, 1), "%")),
    vjust = -0.25,
    size = 3.2
  ) +
  facet_wrap(~season, ncol = 1, scales = "free_x") +
  scale_y_continuous(
    labels = label_percent(scale = 1),
    expand = expansion(mult = c(0, 0.12))
  ) +
  scale_fill_manual(values = fill_map, guide = "none") +
  labs(
    title = "Somaliland Seasonal Drought Ranking (CHIRPS, 1981–2024)",
    subtitle = "Top 10 drought years by lowest % of normal (baseline 1981–2010). Bold bar = worst year.",
    x = NULL, y = "% of normal"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 11),
    strip.text = element_text(face = "bold", size = 12),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    axis.text.x = element_text(size = 10),
    axis.title.y = element_text(face = "bold"),
    plot.margin = margin(12, 12, 12, 12)
  )

# ---- Save ----
ggsave(
  "D:/Somaliland-Meteorological-Drought-Ranking/03_outputs/figures/Top10_Gu_Deyr_Combined_Polished.png",
  p, width = 12, height = 7, dpi = 400
)

p
library(dplyr)
library(ggplot2)
library(scales)

threshold <- 80

compound <- gu %>%
  select(year, gu_pct = pct_of_normal) %>%
  inner_join(deyr %>% select(year, deyr_pct = pct_of_normal), by="year") %>%
  mutate(
    compound_flag = gu_pct <= threshold & deyr_pct <= threshold,
    label_year = if_else(year %in% c(1984, 1988, 2022, 2009, 1986), as.character(year), NA_character_)
  )

p_scatter_pro <- ggplot(compound, aes(x = gu_pct, y = deyr_pct)) +
  geom_point(aes(color = compound_flag), size = 3, alpha = 0.9) +
  geom_vline(xintercept = threshold, linetype = "dashed", linewidth = 0.6) +
  geom_hline(yintercept = threshold, linetype = "dashed", linewidth = 0.6) +
  geom_text(aes(label = label_year), vjust = -1, size = 3.4, na.rm = TRUE) +
  scale_x_continuous(labels = label_percent(scale = 1)) +
  scale_y_continuous(labels = label_percent(scale = 1)) +
  scale_color_manual(
    values = c(`FALSE` = "#6B7280", `TRUE` = "#111827"),
    guide = "none"
  ) +
  labs(
    title = "Compound drought check (Gu vs Deyr, % of normal)",
    subtitle = paste0("Compound drought defined as BOTH seasons ≤ ", threshold, "% of normal (baseline 1981–2010)."),
    x = "Gu (MAM) % of normal",
    y = "Deyr (OND) % of normal",
    caption = "Bottom-left quadrant indicates compound two-season meteorological drought."
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 11),
    panel.grid.minor = element_blank(),
    plot.margin = margin(12, 12, 12, 12)
  )

ggsave(
  "D:/Somaliland-Meteorological-Drought-Ranking/03_outputs/figures/Compound_Drought_Scatter_Polished.png",
  p_scatter_pro, width = 12, height = 6.5, dpi = 400
)

p_scatter_pro
if (!requireNamespace("magick", quietly = TRUE)) install.packages("magick")
library(magick)
fig_dir <- "D:/Somaliland-Meteorological-Drought-Ranking/03_outputs/figures"

# Adjust these keywords if your filenames differ
targets <- c("Gu_MAM_Anomaly_mm_2022", "Gu_MAM_Anomaly_mm_2009",
             "Deyr_OND_Anomaly_mm_1986", "Deyr_OND_Anomaly_mm_2020")

all_png <- list.files(fig_dir, pattern="\\.png$", full.names=TRUE)

pick <- function(key) {
  f <- all_png[grepl(key, all_png)]
  if (length(f) == 0) stop("Could not find a PNG matching: ", key)
  f[1]
}

files4 <- c(pick(targets[1]), pick(targets[2]), pick(targets[3]), pick(targets[4]))
print(files4)

# Read and standardize size
imgs <- lapply(files4, image_read)

# Make consistent widths (so montage looks clean)
imgs <- lapply(imgs, function(im) image_resize(im, "1800x"))

# Add clean titles on each map panel
titles <- c(
  "Gu (MAM) anomaly — 2022 vs 1981–2010",
  "Gu (MAM) anomaly — 2009 vs 1981–2010",
  "Deyr (OND) anomaly — 1986 vs 1981–2010",
  "Deyr (OND) anomaly — 2020 vs 1981–2010"
)

imgs_labeled <- Map(function(im, ttl){
  image_annotate(im, ttl, size = 40, gravity = "northwest",
                 location = "+30+30", color = "black")
}, imgs, titles)

# Make 2×2 layout
panel <- image_montage(
  image_join(imgs_labeled),
  tile = "2x2",
  geometry = "+30+30",
  bg = "white"
)

# Add a main title bar
panel2 <- image_append(c(
  image_blank(width = image_info(panel)$width, height = 120, color = "white") %>%
    image_annotate("Somaliland seasonal rainfall anomaly maps (CHIRPS)", size = 55,
                   gravity = "center", color = "black"),
  panel
), stack = TRUE)

out_path <- file.path(fig_dir, "MAP_PANEL_2x2_Somaliland_CHIRPS_Anomalies.png")
image_write(panel2, out_path)
out_path
fig_dir <- "D:/Somaliland-Meteorological-Drought-Ranking/03_outputs/figures"

# show ALL pngs
list.files(fig_dir, pattern="\\.png$", full.names=FALSE)

# show only map pngs (common patterns)
list.files(fig_dir, pattern="MAP_.*\\.png$", full.names=FALSE)
list.files(fig_dir, pattern="Anomaly|anom|anomaly|tif|TIF|GeoTIFF|mm", full.names=FALSE)
tif_dir1 <- "D:/Somaliland-Meteorological-Drought-Ranking/01_raw/tiff"
tif_dir2 <- "D:/Somaliland-Meteorological-Drought-Ranking/GEE"

list.files(tif_dir1, pattern="\\.tif(f)?$", full.names=FALSE)
list.files(tif_dir2, pattern="\\.tif(f)?$", full.names=FALSE)
base_dir <- "D:/Somaliland-Meteorological-Drought-Ranking"

list.files(base_dir, recursive = TRUE, full.names = TRUE) %>%
  .[grepl("\\.tif(f)?$", ., ignore.case = TRUE)] %>%
  print()
base_dir <- "D:/Somaliland-Meteorological-Drought-Ranking"

files_found <- list.files(base_dir, recursive = TRUE, full.names = TRUE)

files_found[grepl("\\.(zip|tif|tiff)$", files_found, ignore.case = TRUE)] %>% print()
library(terra)

tif_dir <- "D:/Somaliland-Meteorological-Drought-Ranking/01_Raw/GeoTiff"
fig_dir <- "D:/Somaliland-Meteorological-Drought-Ranking/03_outputs/figures"
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

tifs <- list.files(tif_dir, pattern="\\.tif(f)?$", full.names=TRUE, ignore.case=TRUE)
print(tifs)

# consistent scale across all 4 maps
all_vals <- c()
for (f in tifs) {
  r <- rast(f)
  v <- values(r, mat = FALSE)
  v <- v[is.finite(v)]
  all_vals <- c(all_vals, v)
}

lo <- as.numeric(quantile(all_vals, 0.02, na.rm=TRUE))
hi <- as.numeric(quantile(all_vals, 0.98, na.rm=TRUE))
max_abs <- max(abs(lo), abs(hi), na.rm=TRUE)
zlim <- c(-max_abs, max_abs)

ncol <- 101
pal <- colorRampPalette(c("red", "white", "blue"))(ncol)   # opposite palette
breaks <- seq(zlim[1], zlim[2], length.out = ncol)

for (f in tifs) {
  r <- rast(f)
  nm <- tools::file_path_sans_ext(basename(f))
  out_png <- file.path(fig_dir, paste0("MAP_", nm, ".png"))
  
  png(out_png, width=2000, height=1200, res=200)
  plot(r, col = pal, breaks = breaks, main = nm, axes = FALSE, box = FALSE)
  mtext("Rainfall anomaly (mm) | RED=drier (negative), BLUE=wetter (positive)", side=3, line=0.5, cex=0.95)
  dev.off()
}

list.files(fig_dir, pattern="MAP_.*\\.png$", full.names=FALSE)
library(magick)

fig_dir <- "D:/Somaliland-Meteorological-Drought-Ranking/03_outputs/figures"
map_pngs <- list.files(fig_dir, pattern="^MAP_.*\\.png$", full.names=TRUE)

pick <- function(pattern) {
  f <- map_pngs[grepl(pattern, map_pngs)]
  if (length(f) == 0) stop("Missing map for pattern: ", pattern)
  f[1]
}

files4 <- c(
  pick("Gu_MAM.*2022"),
  pick("Gu_MAM.*2009"),
  pick("Deyr_OND.*1986"),
  pick("Deyr_OND.*2020")
)

imgs <- lapply(files4, image_read) |> lapply(\(im) image_resize(im, "1800x"))

titles <- c(
  "Gu (MAM) anomaly — 2022 vs 1981–2010",
  "Gu (MAM) anomaly — 2009 vs 1981–2010",
  "Deyr (OND) anomaly — 1986 vs 1981–2010",
  "Deyr (OND) anomaly — 2020 vs 1981–2010"
)

imgs_labeled <- Map(function(im, ttl){
  image_annotate(im, ttl, size = 42, gravity = "northwest",
                 location = "+30+30", color = "black")
}, imgs, titles)

panel <- image_montage(
  image_join(imgs_labeled),
  tile = "2x2",
  geometry = "+30+30",
  bg = "white"
)

title_bar <- image_blank(width = image_info(panel)$width, height = 120, color = "white") |>
  image_annotate("Somaliland seasonal rainfall anomaly maps (CHIRPS)", size = 58,
                 gravity = "center", color = "black")

panel2 <- image_append(c(title_bar, panel), stack = TRUE)

out_path <- file.path(fig_dir, "MAP_PANEL_2x2_Somaliland_CHIRPS_Anomalies.png")
image_write(panel2, out_path)
out_path
library(terra)

tif_dir <- "D:/Somaliland-Meteorological-Drought-Ranking/01_Raw/GeoTiff"
fig_dir <- "D:/Somaliland-Meteorological-Drought-Ranking/03_outputs/figures"
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

tifs <- list.files(tif_dir, pattern="\\.tif(f)?$", full.names=TRUE, ignore.case=TRUE)
stopifnot(length(tifs) > 0)

# ---- consistent scale across all 4 maps ----
all_vals <- c()
for (f in tifs) {
  r <- rast(f)
  v <- values(r, mat = FALSE)
  v <- v[is.finite(v)]
  all_vals <- c(all_vals, v)
}
lo <- as.numeric(quantile(all_vals, 0.02, na.rm=TRUE))
hi <- as.numeric(quantile(all_vals, 0.98, na.rm=TRUE))
max_abs <- max(abs(lo), abs(hi), na.rm=TRUE)
zlim <- c(-max_abs, max_abs)

# ---- clearer legend: fewer breaks ----
n_breaks <- 9                      # gives 8 color bins (cleaner than 100+)
breaks <- seq(zlim[1], zlim[2], length.out = n_breaks)
pal <- colorRampPalette(c("red", "white", "blue"))(length(breaks) - 1)  # RED=dry, BLUE=wet (opposite)

for (f in tifs) {
  r <- rast(f)
  nm <- tools::file_path_sans_ext(basename(f))
  out_png <- file.path(fig_dir, paste0("MAPclean_", nm, ".png"))
  
  png(out_png, width=2400, height=1600, res=220)
  par(mar = c(2, 2, 3, 6))  # more space on right for legend
  plot(
    r,
    col = pal,
    breaks = breaks,
    main = "",              # IMPORTANT: remove internal title
    axes = FALSE,
    box = FALSE,
    plg = list(
      title = "Anomaly (mm)",
      cex = 1.25,
      title.cex = 1.35
    )
  )
  dev.off()
}

list.files(fig_dir, pattern="^MAPclean_.*\\.png$", full.names=FALSE)
library(magick)

fig_dir <- "D:/Somaliland-Meteorological-Drought-Ranking/03_outputs/figures"
map_pngs <- list.files(fig_dir, pattern="^MAPclean_.*\\.png$", full.names=TRUE)

pick <- function(pattern) {
  f <- map_pngs[grepl(pattern, map_pngs)]
  if (length(f) == 0) stop("Missing map for pattern: ", pattern)
  f[1]
}

files4 <- c(
  pick("Gu_MAM.*2022"),
  pick("Gu_MAM.*2009"),
  pick("Deyr_OND.*1986"),
  pick("Deyr_OND.*2020")
)

imgs <- lapply(files4, image_read) |> lapply(\(im) image_resize(im, "2200x"))

# Add a small panel label (no long text inside maps)
labels <- c("Gu (MAM) 2022", "Gu (MAM) 2009", "Deyr (OND) 1986", "Deyr (OND) 2020")
imgs_labeled <- Map(function(im, ttl){
  image_annotate(im, ttl, size = 55, gravity = "northwest",
                 location = "+40+35", color = "black")
}, imgs, labels)

panel <- image_montage(
  image_join(imgs_labeled),
  tile = "2x2",
  geometry = "+60+60",   # more spacing
  bg = "white"
)

# Overall title with period + baseline
title_text <- "Somaliland seasonal rainfall anomaly maps (1981–2024)\nCHIRPS rainfall | Anomalies relative to 1981–2010 baseline | RED=drier, BLUE=wetter"

title_bar <- image_blank(width = image_info(panel)$width, height = 200, color = "white") |>
  image_annotate(title_text, size = 60, gravity = "center", color = "black")

panel2 <- image_append(c(title_bar, panel), stack = TRUE)

out_path <- file.path(fig_dir, "MAP_PANEL_2x2_Somaliland_Anomalies_Clean.png")
image_write(panel2, out_path)
out_path
library(terra)

tif_dir <- "D:/Somaliland-Meteorological-Drought-Ranking/01_Raw/GeoTiff"
fig_dir <- "D:/Somaliland-Meteorological-Drought-Ranking/03_outputs/figures"
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

tifs <- list.files(tif_dir, pattern="\\.tif(f)?$", full.names=TRUE, ignore.case=TRUE)
stopifnot(length(tifs) > 0)

# ---- consistent scale across all maps ----
all_vals <- c()
for (f in tifs) {
  r <- rast(f)
  v <- values(r, mat = FALSE)
  v <- v[is.finite(v)]
  all_vals <- c(all_vals, v)
}

# robust symmetric limits around 0, rounded to a "nice" number
lo <- as.numeric(quantile(all_vals, 0.02, na.rm=TRUE))
hi <- as.numeric(quantile(all_vals, 0.98, na.rm=TRUE))
max_abs <- max(abs(lo), abs(hi), na.rm=TRUE)

# round to nearest 10 for cleaner legend labels
max_abs <- ceiling(max_abs / 10) * 10
zlim <- c(-max_abs, max_abs)

# clean breaks (9 ticks -> 8 bins)
breaks <- seq(zlim[1], zlim[2], length.out = 9)
pal <- colorRampPalette(c("red", "white", "blue"))(length(breaks) - 1)  # RED=dry, BLUE=wet

for (f in tifs) {
  r <- rast(f)
  nm <- tools::file_path_sans_ext(basename(f))
  out_png <- file.path(fig_dir, paste0("MAPclean_", nm, ".png"))
  
  png(out_png, width=2600, height=1700, res=220)
  
  # BIGGER right margin so legend labels never clip
  par(mar = c(2.5, 2.5, 2.0, 10.5), xpd = NA)
  
  plot(
    r,
    col = pal,
    breaks = breaks,
    main = "",
    axes = FALSE,
    box = FALSE,
    plg = list(
      title = "Anomaly (mm)",
      cex = 1.35,
      title.cex = 1.45,
      x = 1.06,          # push legend slightly to the right
      y = 0.5
    )
  )
  
  dev.off()
}

list.files(fig_dir, pattern="^MAPclean_.*\\.png$", full.names=FALSE)
library(terra)

tif_dir <- "D:/Somaliland-Meteorological-Drought-Ranking/01_Raw/GeoTiff"
fig_dir <- "D:/Somaliland-Meteorological-Drought-Ranking/03_outputs/figures"
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

tifs <- list.files(tif_dir, pattern="\\.tif(f)?$", full.names=TRUE, ignore.case=TRUE)
stopifnot(length(tifs) > 0)

# Robust symmetric limits
all_vals <- c()
for (f in tifs) {
  v <- values(rast(f), mat = FALSE)
  v <- v[is.finite(v)]
  all_vals <- c(all_vals, v)
}
lo <- as.numeric(quantile(all_vals, 0.02, na.rm=TRUE))
hi <- as.numeric(quantile(all_vals, 0.98, na.rm=TRUE))
max_abs <- ceiling(max(abs(lo), abs(hi), na.rm=TRUE) / 10) * 10
zlim <- c(-max_abs, max_abs)

breaks <- seq(zlim[1], zlim[2], length.out = 9)
pal <- colorRampPalette(c("red", "white", "blue"))(length(breaks) - 1)

for (f in tifs) {
  r <- rast(f)
  nm <- tools::file_path_sans_ext(basename(f))
  out_png <- file.path(fig_dir, paste0("MAP_nolegend_", nm, ".png"))
  
  png(out_png, width=2400, height=1600, res=220)
  par(mar = c(0.5, 0.5, 0.5, 0.5))
  plot(r, col = pal, breaks = breaks, main = "", axes = FALSE, box = FALSE, plg = FALSE)
  dev.off()
}

list.files(fig_dir, pattern="^MAP_nolegend_.*\\.png$", full.names=FALSE)
library(magick)

fig_dir <- "D:/Somaliland-Meteorological-Drought-Ranking/03_outputs/figures"
map_pngs <- list.files(fig_dir, pattern="^MAP_nolegend_.*\\.png$", full.names=TRUE)

pick <- function(pattern) {
  f <- map_pngs[grepl(pattern, map_pngs)]
  if (length(f) == 0) stop("Missing map for pattern: ", pattern)
  f[1]
}

files4 <- c(
  pick("Gu_MAM.*2022"),
  pick("Gu_MAM.*2009"),
  pick("Deyr_OND.*1986"),
  pick("Deyr_OND.*2020")
)

imgs <- lapply(files4, image_read) |> lapply(\(im) image_resize(im, "2000x"))
labels <- c("Gu (MAM) 2022", "Gu (MAM) 2009", "Deyr (OND) 1986", "Deyr (OND) 2020")

imgs_labeled <- Map(function(im, ttl){
  image_annotate(im, ttl, size = 65, gravity = "northwest",
                 location = "+40+35", color = "black")
}, imgs, labels)

panel_maps <- image_montage(image_join(imgs_labeled), tile="2x2", geometry="+60+60", bg="white")

# Add title
title_text <- "Somaliland seasonal rainfall anomaly maps (1981–2024)\nCHIRPS rainfall | anomalies relative to 1981–2010 baseline"
title_bar <- image_blank(width=image_info(panel_maps)$width, height=200, color="white") |>
  image_annotate(title_text, size=65, gravity="center", color="black")

panel_with_title <- image_append(c(title_bar, panel_maps), stack=TRUE)

# Add legend on the right
legend_img <- image_read(file.path(fig_dir, "LEGEND_TEXT.png")) |> image_resize("900x")
final <- image_append(c(panel_with_title, legend_img), stack = FALSE)

out_path <- file.path(fig_dir, "MAP_PANEL_2x2_Somaliland_Anomalies_SHAREDLEGEND.png")
image_write(final, out_path)
out_path
library(terra)

tif_dir <- "D:/Somaliland-Meteorological-Drought-Ranking/01_Raw/GeoTiff"
fig_dir <- "D:/Somaliland-Meteorological-Drought-Ranking/03_outputs/figures"
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

tifs <- list.files(tif_dir, pattern="\\.tif(f)?$", full.names=TRUE, ignore.case=TRUE)
stopifnot(length(tifs) > 0)

# consistent scale
all_vals <- c()
for (f in tifs) {
  v <- values(rast(f), mat = FALSE)
  v <- v[is.finite(v)]
  all_vals <- c(all_vals, v)
}
lo <- as.numeric(quantile(all_vals, 0.02, na.rm=TRUE))
hi <- as.numeric(quantile(all_vals, 0.98, na.rm=TRUE))
max_abs <- ceiling(max(abs(lo), abs(hi), na.rm=TRUE) / 10) * 10
zlim <- c(-max_abs, max_abs)

breaks <- seq(zlim[1], zlim[2], length.out = 9)
pal <- colorRampPalette(c("red", "white", "blue"))(length(breaks) - 1)

for (f in tifs) {
  r <- rast(f)
  nm <- tools::file_path_sans_ext(basename(f))
  out_png <- file.path(fig_dir, paste0("MAP_NOLEG_", nm, ".png"))
  
  png(out_png, width=2200, height=1500, res=220)
  par(mar = c(0.5, 0.5, 0.5, 0.5))
  plot(r, col = pal, breaks = breaks, main = "", axes = FALSE, box = FALSE, plg = FALSE)
  dev.off()
}

list.files(fig_dir, pattern="^MAP_NOLEG_.*\\.png$", full.names=FALSE)
library(magick)

fig_dir <- "D:/Somaliland-Meteorological-Drought-Ranking/03_outputs/figures"

# A simple, clean legend block (no clipping risk)
legend_text <- image_blank(width = 950, height = 820, color = "white") |>
  image_annotate(
    "Legend\n\nRainfall anomaly (mm)\nRED = drier (negative)\nBLUE = wetter (positive)\n\nBaseline: 1981–2010",
    size = 52, gravity = "northwest", location = "+50+50", color = "black"
  )

image_write(legend_text, file.path(fig_dir, "LEGEND_SHARED.png"))
