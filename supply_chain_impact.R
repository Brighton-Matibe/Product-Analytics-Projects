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


# ====================================================================
# Phase 3: Applied AI - Predictive Supply Chain Lead-Time Anomalies (Regression)
# Objective: Train a predictive model to forecast shipment arrival delays
# ====================================================================

# Load core machine learning libraries
if(!require(tidymodels)) install.packages("tidymodels")
library(tidymodels)

# 1. Simulate a Production Logistics Ledger Dataset (1,000 Shipments)
set.seed(123)
n_shipments <- 1000

logistics_data <- tibble(
  shipment_id              = 1:n_shipments,
  estimated_lead_time_days = sample(14:30, n_shipments, replace = TRUE),
  macro_freight_index_cost = runif(n_shipments, min = 1500, max = 4500), # Simulating FRED market volatility
  historical_supplier_error= runif(n_shipments, min = 0, max = 5),        # Supplier past average delay
  # Noise + Logic: High macro costs and bad supplier history create longer actual delays
  actual_delay_days        = (macro_freight_index_cost * 0.001) + (historical_supplier_error * 0.8) + rnorm(n_shipments, mean = 0, sd = 1)
)

# Enforce realistic bounds (cannot have negative days of delay)
logistics_data$actual_delay_days <- ifelse(logistics_data$actual_delay_days < 0, 0, logistics_data$actual_delay_days)

# 2. Data Splitting (Training vs Testing Sets)
# Split 80% to train the predictive engine, 20% to validate its forecasts
logistics_split <- initial_split(logistics_data, prop = 0.80)
sc_train_set    <- training(logistics_split)
sc_test_set     <- testing(logistics_split)

# 3. Model Architecture Specification
# Defining a linear regression machine learning model utilizing the standard lm engine
reg_model <- linear_reg() %>% 
  set_engine("lm") %>% 
  set_mode("regression")

# 4. Training the AI Model (Fitting)
reg_fit <- reg_model %>% 
  fit(actual_delay_days ~ estimated_lead_time_days + macro_freight_index_cost + historical_supplier_error, data = sc_train_set)

# 5. Evaluate Model Performance on Unseen Test Shipments
sc_predictions <- predict(reg_fit, new_data = sc_test_set) %>% 
  bind_cols(sc_test_set)

# Calculate R-Squared and RMSE (Industry standard metrics for checking regression accuracy)
sc_metrics <- metrics(sc_predictions, truth = actual_delay_days, estimate = .pred)
print(sc_metrics)

# 6. Extract Feature Importance Metrics
regression_weights <- tidy(reg_fit)
print(regression_weights)