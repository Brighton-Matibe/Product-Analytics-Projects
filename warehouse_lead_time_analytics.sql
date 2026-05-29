-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

-- ====================================================================
-- Enterprise Logistics Optimization: Lead-Time Variance & Anomalies
-- Author: Brighton Matibe
-- Objective: Track supplier transit variations, flag bottlenecks, 
--            and calculate moving distribution windows.
-- ====================================================================

WITH Raw_Transit_Metrics AS (
    SELECT 
        shipment_id,
        supplier_id,
        origin_port,
        destination_hub,
        order_date,
        actual_arrival_date,
        estimated_lead_time_days,
        -- Calculate actual days spent in transit
        DATEDIFF(day, order_date, actual_arrival_date) AS actual_lead_time_days,
        freight_cost_usd
    FROM supply_chain_ledger.shipment_transactions
    WHERE order_date >= '2025-01-01'
),

Anomalies_Calculated AS (
    SELECT 
        shipment_id,
        supplier_id,
        origin_port,
        actual_lead_time_days,
        estimated_lead_time_days,
        -- Delta metrics showing supplier delays
        (actual_lead_time_days - estimated_lead_time_days) AS lead_time_variance_days,
        -- Window function: 5-shipment moving average delay per supplier to identify structural vs random choke points
        AVG(actual_lead_time_days - estimated_lead_time_days) OVER(
            PARTITION BY supplier_id 
            ORDER BY order_date 
            ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
        ) AS supplier_moving_avg_variance,
        -- Window function: Compare current cost against the next scheduled route to monitor pricing volatility
        LEAD(freight_cost_usd, 1) OVER(
            PARTITION BY origin_port, destination_hub 
            ORDER BY order_date
        ) AS next_scheduled_lane_cost
    FROM Raw_Transit_Metrics
)

-- Final operational risk filtering for dashboard injection
SELECT 
    shipment_id,
    supplier_id,
    origin_port,
    actual_lead_time_days,
    lead_time_variance_days,
    ROUND(supplier_moving_avg_variance, 2) AS rolling_supplier_delay_index,
    CASE 
        WHEN lead_time_variance_days >= 7 THEN 'CRITICAL DELAY'
        WHEN lead_time_variance_days BETWEEN 3 AND 6 THEN 'WARNING: DELAY RISK'
        ELSE 'OPTIMIZED / ON-TIME'
    END AS operational_risk_status
FROM Anomalies_Calculated
ORDER BY lead_time_variance_days DESC;
