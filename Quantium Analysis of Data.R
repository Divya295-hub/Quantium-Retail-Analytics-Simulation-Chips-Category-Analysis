install.packages("tidyverse")
library(tidyverse)

purchase_df <- read.csv("QVI_purchase_behaviour.csv")
transaction_df <- read.csv("QVI_transaction_data.csv")
colnames(purchase_df)
colnames(transaction_df)

# Counts missing values column-wise
colSums(is.na(purchase_df))
colSums(is.na(transaction_df))

# Transforming transaction data: Convert the Date(INT) column to Date(DATETIME)
transaction_df <- transaction_df %>%
  mutate(DATE = as.Date(DATE, origin = "1899-12-30"))

head(transaction_df)

# Extract Brand & Pack Size from PROD_NAME
transaction_df <- transaction_df %>%
  mutate(
    BRAND = word(PROD_NAME, 1),
    PACK_SIZE = parse_number(str_extract(PROD_NAME, "\\d+g"))
  )

head(transaction_df)

# Merge with Customer Segments
merged_df <- transaction_df %>%
  inner_join(purchase_df, by = "LYLTY_CARD_NBR")

head(merged_df)

#Check for any discrepancies
summary(merged_df$TOT_SALES)
boxplot(merged_df$TOT_SALES, main = 'Outlier Check: Total Sales', ylim = c(0,200))
merged_df <- merged_df %>% filter(TOT_SALES < 100)

head(merged_df)

segment_df <- merged_df %>%
  group_by(LIFESTAGE, PREMIUM_CUSTOMER) %>%
  summarise(
    avg_spend = mean(TOT_SALES),
    total_transactions = n(),
    unique_customers = n_distinct(LYLTY_CARD_NBR),
    .groups = "drop"
  )

head(segment_df)


library(ggplot2)
library(stringr)

segment_df$Segment <- paste(segment_df$LIFESTAGE, segment_df$PREMIUM_CUSTOMER)
segment_df$Segment <- str_wrap(segment_df$Segment, width = 15)

ggplot(segment_df, aes(x = reorder(Segment, avg_spend), y = avg_spend)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Average Spend by Customer Segment",
       x = "Customer Segment",
       y = "Average Spend ($)") +
  theme_minimal(base_size = 6.5)






# TASK 2
library(data.table)
library(ggplot2)
library(tidyr)

data <- read.csv("QVI_data.csv")
data <- as.data.table(data)

#Add YEARMONTH column
data[, YEARMONTH := format(as.Date(DATE, origin = "1899-12-30"), "%Y%m")]
head(data)

#Define trail period
trail_stores <- c(77, 86, 88)
trail_months <- c("201902", "201903", "201904")
pre_trial_months <- c("201807", "201808", "201809", "201810", "201811", "201812", "201901")

#Calculate Metrics
measureOverTime <- data[, .(
     totSales = sum(TOT_SALES),
     nCustomers = uniqueN(LYLTY_CARD_NBR),
     nTxnPerCust = .N / uniqueN(LYLTY_CARD_NBR),
     nChipsPerTxn = sum(PROD_QTY) / .N,
     avgPricePerUnit = sum(TOT_SALES) / sum(PROD_QTY)
   ), by = .(STORE_NBR, YEARMONTH)]

head(measureOverTime)

#Stores with Full Pre-Trail Data
store_counts <- measureOverTime[YEARMONTH %in% pre_trial_months, .N, 
                                by = STORE_NBR]
head(store_counts)

storesWithFullData <- store_counts[N == length(pre_trial_months), STORE_NBR]
head(storesWithFullData)


calculateCorrelation <- function(metric_data, metric, trial_store){
  all_stores <- unique(metric_data$STORE_NBR)
  correlations <- lapply(all_stores, function(store){
    if (store != trial_store){
      trial_series <- metric_data[STORE_NBR == trial_store, get(metric)]
      control_series <- metric_data[STORE_NBR == store, get(metric)]
      data.table(Store1 = trial_store, Store2 = store,
                 corr = cor(trial_series, control_series, use = "complete.obs"))
    }
  })
  rbindlist(correlations)
}


calculateMagnitude <- function(metric_data, metric, trial_store){
  stores <- unique(metric_data$STORE_NBR)
  trial_vals <- metric_data[STORE_NBR == trial_store, get(metric)]
  magnitudes <- lapply(stores, function(store){
    if (store != trial_store){
      control_vals <- metric_data[STORE_NBR == store, get(metric)]
      dist <- mean(1 - abs(trial_vals - control_vals)/(max(trial_vals) - min(trial_vals)))
      data.table(Store1 = trial_store, Store2 = store, mag = dist)
    }
  })
  rbindlist(magnitudes)
}

# Store 77
trial_store <- 77
preTrialData <- measureOverTime[YEARMONTH %in% pre_trial_months & STORE_NBR %in%
                                  storesWithFullData]
corr_sales <- calculateCorrelation(preTrialData, "totSales", trial_store)
mag_sales <- calculateMagnitude(preTrialData, "totSales", trial_store)

combined_score <- merge(corr_sales, mag_sales, by = c("Store1","Store2"))
combined_score[, finalScore := (corr + mag)/2]

control_store <- combined_score[order(-finalScore)][1, Store2]


# Store 86
trial_store <- 86
preTrialData <- measureOverTime[YEARMONTH %in% pre_trial_months & STORE_NBR %in%
                                  storesWithFullData]
corr_sales <- calculateCorrelation(preTrialData, "totSales", trial_store)
mag_sales <- calculateMagnitude(preTrialData, "totSales", trial_store)

combined_score <- merge(corr_sales, mag_sales, by = c("Store1","Store2"))
combined_score[, finalScore := (corr + mag)/2]

control_store <- combined_score[order(-finalScore)][1, Store2]


# Store 88
trial_store <- 88
preTrialData <- measureOverTime[YEARMONTH %in% pre_trial_months & STORE_NBR %in%
                                  storesWithFullData]
corr_sales <- calculateCorrelation(preTrialData, "totSales", trial_store)
mag_sales <- calculateMagnitude(preTrialData, "totSales", trial_store)

combined_score <- merge(corr_sales, mag_sales, by = c("Store1","Store2"))
combined_score[, finalScore := (corr + mag)/2]

control_store <- combined_score[order(-finalScore)][1, Store2]


# Visualization
sales_plot_data <- measureOverTime[STORE_NBR %in% c(trial_store, control_store)]
sales_plot_data[, StoreType := ifelse(STORE_NBR == trial_store, "Trial", "Control")]


ggplot(sales_plot_data, aes(x = YEARMONTH, y = totSales, colour = StoreType, group = StoreType)) + 
  geom_line(size = 1) + 
  labs(title = paste("Total Sales: Trial Store", trial_store, "vs Control Store", control_store),
       x = "Month", y = "Total Sales") + 
  theme_minimal()


customers_plot_data <- measureOverTime[STORE_NBR %in% c(trial_store, control_store)]
customers_plot_data[, StoreType := ifelse(STORE_NBR == trial_store, "Trial", "Control")]

ggplot(customers_plot_data, aes(x = YEARMONTH, y = nCustomers, colour = StoreType, group = StoreType)) +
  geom_line(size = 1) +
  labs(title = paste("Number of Customers: Trial Store", trial_store, "vs Control Store", control_store),
       x = "Month", y = "Number of Unique Customers") +
  theme_minimal()


















library(dplyr)
library(ggplot2)

# Assuming merged_df has customer-level info
customer_composition <- merged_df %>%
  group_by(LIFESTAGE, PREMIUM_CUSTOMER) %>%
  summarise(n_customers = n_distinct(LYLTY_CARD_NBR), .groups = "drop")

# Calculate percentage per life stage
customer_composition <- customer_composition %>%
  group_by(LIFESTAGE) %>%
  mutate(percentage = n_customers / sum(n_customers) * 100)

ggplot(customer_composition, aes(x = LIFESTAGE, y = percentage, fill = PREMIUM_CUSTOMER)) +
  geom_bar(stat = "identity") +
  labs(title = "Customer Composition by Lifestage and Affluence",
       x = "Lifestage Group",
       y = "Percentage of Customers",
       fill = "Affluence") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
