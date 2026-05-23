# Global Supply Chain Shock Analysis
# Focusing on Current Geopolitical Disruptions & Middle East Transit Risks

# Load required libraries
library(tidyverse)
library(scales)

# URL for Deep Sea Freight Transportation Price Index (Source: St. Louis FRED)
fred_freight_url <- "https://fred.stlouisfed.org/graph/fredgraph.csv?id=PCU483111483111"

print("Initializing data connection to FRED API...")
freight_data <- read_csv(fred_freight_url)

# Clean, rename, and FILTER for current ongoing timeline (2022 - 2026)
freight_filtered <- freight_data %>%
  rename(Date = observation_date, Shipping_Cost_Index = PCU483111483111) %>%
  mutate(
    Date = as.Date(Date),
    Shipping_Cost_Index = as.numeric(Shipping_Cost_Index)
  ) %>%
  filter(Date >= as.Date("2022-01-01")) %>%  # Focuses strictly on recent/ongoing era
  drop_na()

print("Generating focused current-conflict supply chain visualization...")

# Plotting the ongoing freight rate shocks
ggplot(freight_filtered, aes(x = Date, y = Shipping_Cost_Index)) +
  geom_line(color = "#1f77b4", linewidth = 1.2) +  
  
  # NEW FEATURE: US-03 Risk Threshold Boundary Line at 350
  geom_hline(yintercept = 350, linetype = "dashed", color = "red", linewidth = 1) +
  
  # NEW FEATURE: US-03 Dynamic Alert Highlights (Adds red dots for outliers)
  geom_point(data = filter(freight_filtered, Shipping_Cost_Index > 350), 
             color = "red", size = 2.5, alpha = 0.9) +
  
  # NEW FOCUS: Ongoing Iran / Red Sea / Strait of Hormuz Maritime Disruptions
  annotate("rect", xmin = as.Date("2023-11-01"), xmax = as.Date("2026-05-01"), 
           ymin = -Inf, ymax = Inf, alpha = 0.15, fill = "darkorange") +  
  annotate("text", x = as.Date("2025-01-01"), y = 390, 
           label = "Ongoing Middle East Maritime Shocks:\nStrait of Hormuz & Red Sea Threats", 
           color = "darkorange4", size = 4, fontface = "bold") +
  
  # Professional styling optimized for a shorter, intense timeline
  theme_minimal(base_size = 12) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b %Y") + # Cleaner axis spacing
  labs(
    title = "Current Deep Sea Freight Cost Volatility (2022 - 2026)",
    subtitle = "Monitoring Shipping Rate Shocks Tied to Iran Regional Conflict & Geopolitical Choke Points",
    x = "Recent Timeline",
    y = "Producer Price Index (Base = 100)",
    caption = "Data Source: St. Louis FRED (Series: PCU483111483111) | Operations Risk Portfolio"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 15, color = "#111111"),
    plot.subtitle = element_text(size = 11, color = "#555555"),
    axis.text.x = element_text(angle = 45, hjust = 1), # Rotates dates so they don't overlap
    panel.grid.minor = element_blank()
  )

# Save the focused chart image to your local repository folder
ggsave("supply_chain_shocks_plot.png", width = 10, height = 6, dpi = 300)
print("Analysis complete! Focused plot saved as 'supply_chain_shocks_plot.png'.")