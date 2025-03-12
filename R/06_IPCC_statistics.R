##
#Step 6: IPCC statistics
##

source("./source/main.R")


# --- Step 1: import data ---
IPCC <- read.csv(paste0(PATH_SAVE, "IPCC_statistics_table.csv"))


# --- Step 2: convert to data table format ---

IPCC <- as.data.table(IPCC)



# --- Step 3: filter IPCC by top 10 croplands IPCC cover ---

# get a list of top 10 IPCC cropland cover
top_10_classes <- IPCC %>%
  arrange(desc(IPCC_r__count)) %>%
  distinct(IPCC_r_) %>%
  head(10) %>%
  as.matrix() %>%
  as.list()

# filter IPCC by list and sort it by descending
IPCC_top_10 <- IPCC[IPCC_r_ %in% top_10_classes] %>%
  arrange(desc(IPCC_r__count))

# --- Step 4: Clean data and RAM memory ---

# remove unnecessary columns from datatable
IPCC_top_10 <- IPCC_top_10[, `fid` := NULL]
IPCC_top_10 <- IPCC_top_10[, `id` := NULL]
IPCC_top_10 <- IPCC_top_10[, `top` := NULL]
IPCC_top_10 <- IPCC_top_10[, `bottom` := NULL]
IPCC_top_10 <- IPCC_top_10[, `left` := NULL]
IPCC_top_10 <- IPCC_top_10[, `right` := NULL]
IPCC_top_10 <- IPCC_top_10[, `row_index` := NULL]
IPCC_top_10 <- IPCC_top_10[, `col_index` := NULL]
IPCC_top_10 <- IPCC_top_10[, `X` := NULL]
IPCC_top_10 <- IPCC_top_10[, `elv_cls` := NULL]
IPCC_top_10 <- IPCC_top_10[, `KG_cl_1` := NULL]
IPCC_top_10 <- IPCC_top_10[, `KG_cl_2` := NULL]
IPCC_top_10 <- IPCC_top_10[, `KG_cl_3` := NULL]
IPCC_top_10 <- IPCC_top_10[, `KG_c_1_` := NULL]
IPCC_top_10 <- IPCC_top_10[, `lnd_cv_` := NULL]
IPCC_top_10 <- IPCC_top_10[, `lnd_c__` := NULL]
IPCC_top_10 <- IPCC_top_10[, `bm_clss` := NULL]
IPCC_top_10 <- IPCC_top_10[, `bm_shr_` := NULL]
IPCC_top_10 <- IPCC_top_10[, `path` := NULL]

# remove object from RAM memory
rm(IPCC)


# --- Step 5: split class name and trend  ---

# split
IPCC_top_10 <- IPCC_top_10[, `Trend` := tstrsplit(layer, " ")[[2]]]
IPCC_top_10 <- IPCC_top_10[, `Class` := tstrsplit(layer, " ")[[1]]]

# remove old column
IPCC_top_10 <- IPCC_top_10[, `layer` := NULL]

# --- Step 6: calculate statistics ---


IPCC_statistics <- IPCC_top_10 %>%
  group_by(IPCC_r_) %>% # Get total GLEAM cropland 
  mutate(
    `Total cropland count` = sum(X_sum)
  ) %>%
  ungroup() %>% # Percentage of region covering classes
  group_by(IPCC_r_, Class) %>%
  mutate(
    `Class percent` = round((sum(X_sum)/`Total cropland count`)*100, 2)
  ) %>%
  ungroup() %>% # Percentage of ET trend
  group_by(IPCC_r_, Trend) %>%
  mutate(
    `Trend percent` = round((sum(X_sum)/`Total cropland count`)*100, 2)
  ) 

# --- Step 7: Create necessary data tables ---
IPCC_statistics_class <- IPCC_statistics %>%
  group_by(IPCC_r_) %>%
  distinct(Class, .keep_all = TRUE) %>%
  as.data.table()


IPCC_statistics_trend <- IPCC_statistics %>%
  group_by(IPCC_r_) %>%
  distinct(Trend, .keep_all = TRUE) %>%
  filter(Trend != "neutral") %>%
  as.data.table() 

# --- Step 8: Clean tables and RAM memory ---
rm(IPCC_top_10, top_10_classes, IPCC_statistics)

# Trend data table cleaning
IPCC_statistics_trend <- IPCC_statistics_trend[, `Class` := NULL]
IPCC_statistics_trend <- IPCC_statistics_trend[, `X_count` := NULL]
IPCC_statistics_trend <- IPCC_statistics_trend[, `X_sum` := NULL]
IPCC_statistics_trend <- IPCC_statistics_trend[, `Total cropland count` := NULL]
IPCC_statistics_trend <- IPCC_statistics_trend[, `Class percent` := NULL]

# Class data table cleaning
IPCC_statistics_class <- IPCC_statistics_class[, `Trend` := NULL]
IPCC_statistics_class <- IPCC_statistics_class[, `X_count` := NULL]
IPCC_statistics_class <- IPCC_statistics_class[, `X_sum` := NULL]
IPCC_statistics_class <- IPCC_statistics_class[, `Total cropland count` := NULL]
IPCC_statistics_class <- IPCC_statistics_class[, `Trend percent` := NULL]


# --- Step 9: Visualization  ---


# Plot and export class statistics

ggplot(IPCC_statistics_class) +
  geom_bar(stat = "identity", 
           aes(x = reorder(`IPCC_r_`, -`IPCC_r__count`), 
          y = `Class percent`, fill = Class), position = "stack") +
  labs(title = "IPCC class statistics", x = "Top 10 IPCC regions by size", y = "Percentage")
  

ggsave(
  filename = "IPCC class statistics.png",
  path = PATH_RESULTS,
  device = "png",
  plot = last_plot(),
  create.dir = TRUE
)


# Plot and export trend statistics
ggplot(IPCC_statistics_trend) +
  geom_bar(stat = "identity", aes(x = reorder(`IPCC_r_`, -`IPCC_r__count`), 
                                  y = `Trend percent`, fill = Trend), 
           position = "stack") +
  labs(title = "IPCC trend statistics", x = "Top 10 IPCC regions by size", y = "Percentage") + 
  scale_fill_manual(values=c("#f8766d","#619cff"))

ggsave(
  filename = "IPCC trend statistics.png",
  path = PATH_RESULTS,
  device = "png",
  plot = last_plot(),
  create.dir = TRUE
)



