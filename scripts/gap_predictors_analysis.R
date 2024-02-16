#----------------------------------------------------------------------------
# Name:         gap_predictors_analysis.R
# Description:  Script analyzes the values of the predictor variables
#               for canopy gap detection. The values of the spectral bands
#               and the height information in gaps and outside gaps
#               are compared and some plots are generated.
# Contact:      florian.franz@nw-fva.de
#----------------------------------------------------------------------------



# source setup script
source('src/setup.R', local = T)



# 01 - data reading and preparation
#-----------------------------------

train_df <- read.csv(file.path(processed_data_dir, 'train_ds.csv'))
head(train_df)
summary(train_df)

# exclude spatial_ref column
train_df <- train_df[, -which(names(train_df) == 'spatial_ref')]

# replace 0 values with NA in the spectral columns
train_df <- train_df %>%
  dplyr::mutate(
    red   = dplyr::na_if(red, 0),
    green = dplyr::na_if(green, 0),
    blue  = dplyr::na_if(blue, 0),
    nir   = dplyr::na_if(nir, 0)
  )

# select a smaller subset
train_df_subset <- train_df[seq(1, nrow(train_df), by = 25), ]

# remove NAs
train_df_subset <- na.omit(train_df_subset)

# remove rows (pixels) where chm height is
# smaller than 3m and no gap occurs (e.g. meadows)
train_df_subset_filtered <- train_df_subset[
  !(train_df_subset$chm < 3 & train_df_subset$gap_mask == 0),
  ]



# 02 - predictor analysis
#-------------------------

# plot to show correlations
f_bin <- function(data, mapping, ...) {
  ggplot2::ggplot(data = data, mapping = mapping) +
    ggplot2::geom_bin2d(...) +
    colorspace::scale_fill_continuous_divergingx(pal = 'Roma')
}

GGally::ggpairs(data = train_df_subset_filtered[, c('red', 'green', 'blue', 'nir', 'chm')],
                lower = list(continuous = f_bin))

# boxplots gaps vs. non-gaps
tmp <- NULL
for (i in c('red', 'green', 'blue', 'nir', 'chm')) {
  tmp <- rbind(tmp, 
               data.frame(
                 y = as.factor(c('Non-Gaps', 'Gaps')[1 + train_df_subset_filtered$gap_mask]), 
                 x = train_df_subset_filtered[, i], 
                 k = i)
               )
}

ggplot2::ggplot(data = tmp, ggplot2::aes(x = y, y = x)) + 
  ggplot2::geom_boxplot() + 
  ggplot2::facet_wrap(~ k, scales = 'free') +
  ggplot2::labs(y = 'pixel value', x = '')

ggplot2::ggplot(data = tmp, ggplot2::aes(x = factor(k, levels = c("blue", "green", "red", 'nir', 'chm')), y = x, fill = y)) + 
  ggplot2::geom_boxplot() + 
  ggplot2::labs(x = '', y = "pixel value") +
  ggplot2::theme_minimal() +
  ggplot2::scale_fill_manual(values = c('grey', 'grey40'), labels = c('Gaps', 'Non-Gaps')) +
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
                 legend.title = ggplot2::element_blank())




































