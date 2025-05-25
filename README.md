# Quantium Retail Analytics Simulation Chips Category Analysis
## 📌 Overview
<p>This project is part of a simulated experience by Quantium on Forage, working within the commercial insights team. The objective was to analyze customer purchase behavior and evaluate the impact of a trial marketing campaign run across select retail stores in the chips category.</p>

## 📂 Project Structure

### ✅ Task 1: Customer Segmentation & Spending Analysis
<ul>
<li>Datasets used:</li>
  <ul>
    <li>QVI_transaction_data.csv – customer transaction data</li>
    <li>QVI_purchase_behaviour.csv – demographic segment labels</li>
  </ul>
</ul>

<ul>
  <li>Key steps:</li>
  <ul>
    <li>Cleaned and preprocessed transaction data (converted Excel-style dates, removed outliers)</li>
    <li>Extracted brand and pack size from product names</li>
    <li>Merged transaction data with customer segment data</li>
    <li>Aggregated average spend, transaction count, and customer count by LIFESTAGE and PREMIUM_CUSTOMER</li>
    <li>Visualized average spend per customer segment using ggplot2</li>
  </ul>
</ul>

<ul>
  <li>Insights:</li>
  <ul>
    <li>Identified high-spending segments such as Mainstream Retirees and Young Singles – Premium</li>
    <li>Observed strong correlation between premium segments and higher average spend per transaction</li>
  </ul>
</ul>


### ✅ Task 2: Trial vs Control Store Performance Analysis
<ul>
  <li>Dataset used: QVI_data.csv – clean transactional record of chip purchases across 95 stores over 12 months (Jul 2018 – Jun 2019)</li>
</ul>

<ul>
  <li>Objectives:</li>
  <ul>
    <li>elect suitable control stores for trial stores (77, 86, and 88)</li>
    <li>Assess performance change during trial period (Feb–Apr 2019)</li>
  </ul>
</ul>

<ul>
  <li>Approach:</li>
  <ul>
    <li>Computed monthly performance metrics: totSales, nCustomers, avgPricePerUnit, etc.</li>
    <li>Implemented custom functions to:</li>
    <ul>
      <li>Calculate correlation in trends between stores</li>
      <li>Measure magnitude similarity in actual values</li>
      <li>Combined these metrics to select the most similar control store for each trial store</li>
      <li>Visualized total sales and customer counts over time using ggplot2</li>
    </ul>
  </ul>
</ul>

  <ul>
    <li>Findings:</li>
    <ul>
      <li>Trial Store 88 showed a significant uplift in sales and customer count during the trial period</li>
      <li>Trial Store 86 showed marginal improvement, suggesting a weaker response to the campaign</li>
      <li>Store 77 showed modest gains with consistent patterns</li>
    </ul>
  </ul>

  ### 📊 Additional Analysis
  <ul>
    <li>Created a stacked bar chart to visualize customer composition by:</li>
    <ul>
      <li>LIFESTAGE (e.g., Young Families, Retirees)</li>
      <li>PREMIUM_CUSTOMER (Budget, Mainstream, Premium)</li>
    </ul>
    <li>This revealed how affluence and life stage interact in shaping chip-buying behavior.</li>
  </ul>

### 🛠️ Tools Used
<ul>
  <li>Language: R</li>
  <li>Libraries:</li>
  <ul>
    <li>tidyverse, dplyr, ggplot2 for data wrangling & visualization</li>
    <li>data.table for fast aggregation and metric computation</li>
    <li>stringr, lubridate for feature engineering</li>
  </ul>
</ul>

### 📌 Outcomes
<ul>
  <li>Developed a commercial recommendation framework based on transaction uplift</li>
  <li>Strengthened skills in uplift analysis, control matching, data visualization, and business storytelling</li>
  <li>Delivered insights to support strategic retail decisions for a hypothetical category manager</li>
</ul>

