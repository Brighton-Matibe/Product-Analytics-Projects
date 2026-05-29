# Global Supply Chain Shock Analysis
# Focus: Direct Operational and Cost Impact on the United States (2022 - 2026)

# Load required libraries
library(tidyverse)
library(scales)

# URL for Deep Sea Freight Index (Source: US Bureau of Labor Statistics via FRED)
# Tracks cost fluctuations specifically hitting US inbound logistics channels
fred_freight_url <- "https://fred.stlouisfed.org/graph/fredgraph.csv?id=PCU483111483111"

print("Initializing US Inbound Logistics Data Pipeline...")
freight_data <- read_csv(fred_freight_url)

# Clean, rename, and filter strictly for the current crisis era (2022 - 2026)
us_impact_data <- freight_data %>%
  rename(Date = observation_date, US_Inbound_Freight_Index = PCU483111483111) %>%
  mutate(
    Date = as.Date(Date),
    US_Inbound_Freight_Index = as.numeric(US_Inbound_Freight_Index)
  ) %>%
  filter(Date >= as.Date("2022-01-01")) %>% 
  drop_na()

print("Generating USA Inbound Shipping Impact Visualization...")

# Plotting the freight rate shocks hitting US businesses
ggplot(us_impact_data, aes(x = Date, y = US_Inbound_Freight_Index)) +
  geom_line(color = "#b22222", linewidth = 1.2) + # Brick red line for US operational focus
  
  # US Operational Baseline Threshold (Index at 350 marks severe stress for US retail/manufacturing)
  geom_hline(yintercept = 350, linetype = "dashed", color = "#333333", linewidth = 1) +
  
  # Highlight Outliers where cost pressures breached the baseline
  geom_point(data = filter(us_impact_data, US_Inbound_Freight_Index > 350), 
             color = "red", size = 2.5, alpha = 0.9) +
  
  # Highlight: Ongoing Middle East Conflict Impact on US Logistics
  annotate("rect", xmin = as.Date("2023-11-01"), xmax = as.Date("2026-05-01"), 
           ymin = -Inf, ymax = Inf, alpha = 0.15, fill = "red") +  
  annotate("text", x = as.Date("2025-01-01"), y = 430, 
           label = "Direct US Operational Shocks:\n+10-14 Day Lead Time to US Ports\nForced Diversions to West Coast\nSpiking Inbound Inventory Costs", 
           color = "red4", size = 3.8, fontface = "bold") +
  
  # US Domestic Operational Framing
  theme_minimal(base_size = 12) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b %Y") + 
  labs(
    title = "US Inbound Deep Sea Freight Cost Impact (2022 - 2026)",
    subtitle = "Visualizing Supply Chain Disruption Metrics Directly Affecting US Domestic Ports",
    x = "Logistics Timeline",
    y = "BLS Producer Price Index (Base = 100)",
    caption = "Data Source: St. Louis FRED / US Bureau of Labor Statistics | US Operations Portfolio"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 15, color = "#111111"),
    plot.subtitle = element_text(size = 11, color = "#444444"),
    axis.text.x = element_text(angle = 45, hjust = 1), 
    panel.grid.minor = element_blank()
  )

# Save the USA-focused chart image to your local folder
ggsave("supply_chain_shocks_plot.png", width = 10, height = 6, dpi = 300)
print("Analysis complete! USA operational impact plot saved.")