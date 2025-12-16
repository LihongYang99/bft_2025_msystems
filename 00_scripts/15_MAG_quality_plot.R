# load packages 
library(tidyverse)

# set work dir 
setwd("/Users/lihong/Desktop/I2GDS_final")

# read summary data after dereplicate 
quality <- read_csv("plot_1/dereplicated_mags_quality.csv", show_col_types = FALSE)

# extract and clean data 
quality_clean <- quality %>%
  select(
    bin_id = genome,              
    completeness = completeness,  
    contamination = contamination
  ) %>%
  mutate(
    # classify according to MIMAG 
    quality_tier = case_when(
      completeness >= 90 & contamination < 5 ~ "High-quality",
      completeness >= 50 & contamination < 10 ~ "Medium-quality",
      TRUE ~ "Low-quality"
    ),
    quality_tier = factor(quality_tier, 
                          levels = c("High-quality", "Medium-quality", "Low-quality"))
  )

# print information 
cat("\n=== Quality Summary ===\n")
quality_summary <- quality_clean %>%
  count(quality_tier) %>%
  mutate(percentage = n / sum(n) * 100)
print(quality_summary)

#=============================================================================
# Plot: completeness + contamination 
#=============================================================================

p1 <- ggplot(quality_clean, aes(x = completeness, y = contamination, 
                                color = quality_tier)) +
  geom_point(alpha = 0.7, size = 3) +
  
  # color scheme 
  scale_color_manual(
    values = c(
      "High-quality" = "#2E7D32",
      "Medium-quality" = "#F57C00", 
      "Low-quality" = "#C62828"
    ),
    name = "Quality Tier"
  ) +
  
  # MIMAG standard line\
  geom_hline(yintercept = 5, linetype = "dashed", color = "gray40", linewidth = 1) +
  geom_hline(yintercept = 10, linetype = "dashed", color = "gray40", linewidth = 1) +
  geom_vline(xintercept = 50, linetype = "dashed", color = "gray40", linewidth = 1) +
  geom_vline(xintercept = 90, linetype = "dashed", color = "gray40", linewidth = 1) +
  
  # annotations 
  annotate("text", x = 95, y = 3, 
           label = "High-quality\n≥90% comp\n<5% cont", 
           size = 3.5, color = "#2E7D32", fontface = "bold") +
  annotate("text", x = 70, y = 7.5, 
           label = "Medium-quality\n≥50% comp\n<10% cont",
           size = 3.5, color = "#F57C00", fontface = "bold") +
  
  # axis 
  scale_x_continuous(breaks = seq(0, 100, 20), limits = c(0, 100)) +
  scale_y_continuous(breaks = seq(0, 20, 5), limits = c(0, 20)) +
  
  # label 
  labs(
    title = "MAG Quality Distribution from Biofloc Metagenomes",
    subtitle = sprintf("Total: %d MAGs | High: %d (%.1f%%) | Medium: %d (%.1f%%) | Low: %d (%.1f%%)",
                       nrow(quality_clean),
                       sum(quality_clean$quality_tier == "High-quality"),
                       mean(quality_clean$quality_tier == "High-quality") * 100,
                       sum(quality_clean$quality_tier == "Medium-quality"),
                       mean(quality_clean$quality_tier == "Medium-quality") * 100,
                       sum(quality_clean$quality_tier == "Low-quality"),
                       mean(quality_clean$quality_tier == "Low-quality") * 100),
    x = "Completeness (%)",
    y = "Contamination (%)",
    caption = "MIMAG standards (Bowers et al. 2017) | Data: dRep dereplicated MAGs"
  ) +
  
  # theme 
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10),
    legend.position = "right",
    panel.grid.minor = element_blank()
  )

# save figure 1 
ggsave("figures/fig1_mag_quality_scatter.png", p1, 
       width = 12, height = 8, dpi = 300)
cat("✓ Figure 1 save to: figures/fig1_mag_quality_scatter.png\n")

#=============================================================================
# coloum comparison plot 
#=============================================================================

p2 <- ggplot(quality_summary, aes(x = quality_tier, y = n, fill = quality_tier)) +
  geom_bar(stat = "identity", alpha = 0.8, width = 0.7) +
  
  # add labels 
  geom_text(aes(label = sprintf("%d\n(%.1f%%)", n, percentage)), 
            vjust = -0.5, size = 5, fontface = "bold") +
  
  # color setting 
  scale_fill_manual(
    values = c(
      "High-quality" = "#2E7D32",
      "Medium-quality" = "#F57C00",
      "Low-quality" = "#C62828"
    )
  ) +
  
  # axis 
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  
  # labels 
  labs(
    title = "Distribution of MAGs by Quality Tier",
    subtitle = "Based on MIMAG standards (Bowers et al. 2017)",
    x = "Quality Tier",
    y = "Number of MAGs",
    caption = "Data: dRep dereplicated MAGs (n=398)"
  ) +
  
  # themes 
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "none",
    panel.grid.major.x = element_blank()
  )

# save figure 2 
ggsave("figures/fig2_quality_tier_barplot.png", p2,
       width = 10, height = 7, dpi = 300)
cat("✓ figure 2 save to : figures/fig2_quality_tier_barplot.png\n")

#=============================================================================
# Figure 3: completeness distribution 
#=============================================================================

p3 <- ggplot(quality_clean, aes(x = completeness, fill = quality_tier)) +
  geom_histogram(bins = 30, alpha = 0.7, position = "identity") +
  
  # color 
  scale_fill_manual(
    values = c(
      "High-quality" = "#2E7D32",
      "Medium-quality" = "#F57C00",
      "Low-quality" = "#C62828"
    ),
    name = "Quality Tier"
  ) +
  
  # baseline 
  geom_vline(xintercept = c(50, 90), linetype = "dashed", 
             color = "gray40", linewidth = 1) +
  
  # annotations 
  annotate("text", x = 50, y = Inf, label = "50%", 
           vjust = 1.5, hjust = -0.2, size = 4, fontface = "bold") +
  annotate("text", x = 90, y = Inf, label = "90%", 
           vjust = 1.5, hjust = -0.2, size = 4, fontface = "bold") +
  
  # labels 
  labs(
    title = "Distribution of MAG Completeness",
    x = "Completeness (%)",
    y = "Number of MAGs",
    caption = "Vertical lines indicate MIMAG quality thresholds"
  ) +
  
  # themes 
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "top"
  )

# save figure 3 
ggsave("figures/fig3_completeness_distribution.png", p3,
       width = 10, height = 6, dpi = 300)
cat("✓ figure 3 save to figures/fig3_completeness_distribution.png\n")


# save the summary results 


detailed_stats <- quality_clean %>%
  summarise(
    total_mags = n(),
    high_quality = sum(quality_tier == "High-quality"),
    medium_quality = sum(quality_tier == "Medium-quality"),
    low_quality = sum(quality_tier == "Low-quality"),
    pct_standards_met = sum(quality_tier != "Low-quality") / n() * 100,
    mean_completeness = mean(completeness),
    mean_contamination = mean(contamination)
  )
