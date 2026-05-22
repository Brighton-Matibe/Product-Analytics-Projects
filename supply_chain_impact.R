# Global Supply Chain Shock Analysis
# Exploring the economic impacts of geopolitical conflicts using public data

# Load required libraries
library(tidyverse)
library(scales)

# URL for Deep Sea Freight Transportation Price Index (Source: St. Louis FRED)
fred_freight_url <- "https://fred.stlouisfed.org/graph/fredgraph.csv?id=PCU483111483111"

print("Initializing data connection to FRED API...")
freight_data <- read_csv(fred_freight_url)

# Clean and rename columns using the correct source column name: observation_date
freight_clean <- freight_data %>%
  rename(Date = observation_date, Shipping_Cost_Index = PCU483111483111) %>%
  mutate(
    Date = as.Date(Date),
    Shipping_Cost_Index = as.numeric(Shipping_Cost_Index)
  ) %>%
  drop_na()

print("Generating high-impact supply chain visualization...")

# Plotting the historical freight rate shocks
ggplot(freight_clean, aes(x = Date, y = Shipping_Cost_Index)) +
  geom_line(color = "#1f77b4", linewidth = 1) +  # Updated 'size' to 'linewidth'
  
  # Highlight: 2020-2022 Pandemic Supply Chain Crisis
  annotate("rect", xmin = as.Date("2020-03-01"), xmax = as.Date("2022-06-01"), 
           ymin = -Inf, ymax = Inf, alpha = 0.15, fill = "red") +  # Capitalized 'Inf'
  annotate("text", x = as.Date("2021-04-01"), y = 430, 
           label = "Pandemic Shock & \nGlobal Port Gridlock", color = "red", size = 3.5, fontface = "bold") +
  
  # Highlight: Recent Maritime Geopolitical Crises (e.g., Red Sea Disruptions)
  annotate("rect", xmin = as.Date("2024-01-01"), xmax = as.Date("2026-04-01"), 
           ymin = -Inf, ymax = Inf, alpha = 0.15, fill = "orange") +  # Capitalized 'Inf'
  annotate("text", x = as.Date("2025-01-01"), y = 350, 
           label = "Geopolitical \nShipping Corridors Shocks", color = "darkorange3", size = 3.5, fontface = "bold") +
  
  # Professional styling
  theme_minimal(base_size = 12) +
  labs(
    title = "Deep Sea Freight Cost Index (1988 - 2026)",
    subtitle = "Visualizing Global Macroeconomic Supply Chain Shocks & Geopolitical Disruptions",
    x = "Timeline",
    y = "Producer Price Index (Base = 100)",
    caption = "Data Source: St. Louis FRED (Series: PCU483111483111) | Analysis Portfolio"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 16, color = "#333333"),
    plot.subtitle = element_text(size = 11, color = "#666666"),
    panel.grid.minor = element_blank()
  )

# Save the generated chart image to your local repository folder
ggsave("supply_chain_shocks_plot.png", width = 10, height = 6, dpi = 300)
print("Analysis complete! Plot saved as 'supply_chain_shocks_plot.png'.")