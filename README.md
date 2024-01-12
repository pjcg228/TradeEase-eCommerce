## Data-Driven Insights into TradeEase - Project Background & Objective:
TradeEase, established in 2018, is a global e-commerce platform focusing on bringing the latest and most popular consumer electronics and accessories to customers worldwide.

The company has vasts amount of data on its sales, marketing efforts, operational effectiveness, product offerings, and loyalty programme. This data, previously underutilised, is now being thoroughly analysed to uncover critical insights aimed at enhancing TradeEase's commercial performance. The project provides insights and recommendations on the following key areas:

- **Sales Trends** - Focused on Revenue, Orders Placed, and Average Order Value (AOV).
- **Product Performance** - An analysis of different product lines and their market impact.
- **Loyalty Programme Performance** - Assessment of the loyalty programme's effectiveness and its future.
- **Operational Effectiveness** - Evaluation of logistics and operational efficiency.
- **Marketing Channel Effectiveness** - Analysis of various marketing channels and their return on investment."

The SQL queries performed to uncover these general insights are found **[here](https://github.com/pjcg228/TradeEase-eCommerce-Dev/blob/main/General%20SQL%20Analysis.sql)**

Targeted SQL queries relating to these categories can also be found **[here](https://github.com/pjcg228/TradeEase-eCommerce/blob/main/SQL_Queries/Targeted_Business_Questions.sql)**

Tableau dashboard can be found **[here](https://public.tableau.com/app/profile/patrick.cairnes/viz/TradeEaseDashboard/MarketingChannelPerformance)**

## Database Structure & Initial Checks
The database structure as seen below consists of four tables: orders, customers, geo_lookup, and order_status, with a total row count of 78846 records.

<kbd><img width="1200" alt="image" src="https://i.imgur.com/CTaGtpI.png" height="370"></kbd>

Prior to commencing the analysis, a series of checks have been carried out to gain an understanding of the data as well as identifying any potential quality issues. A snippet of the SQL code written to identify issues within the orders table can be found **[here](https://github.com/pjcg228/TradeEase-eCommerce/blob/main/SQL_Queries/Initial_Checks.sql)**.

While there were few quality issues found within the tables, they have been documented for completeness **[here](https://github.com/pjcg228/TradeEase-eCommerce/blob/main/tradeease_issue_log.xlsx)**. These issues ranged from ranged from product naming inconsistencies, missing countries, missing columns required for analysis, and nulls.

## Insights Summary
The company's sales performance in 2022 witnessed a significant decline across the board, with annual revenue, orders placed, and average order value (AOV) all experiencing drops of **42%, 36%, and 9%, respectively,** compared to the figures from 2021. This decline can primarily be attributed to a return to normalcy following the easing of the COVID-19 pandemic. However, the following sections will explore additional factors which are potentially contributing to this reduction, as well highlighting key opportunity areas.

**Product Mix:**
- **85%** of the company’s revenue and **70%** of orders are driven from **37.5%** of its SKUs (Gaming Monitor, AirPods, MacBook Air).
- In the headphones category, the Bose SoundSport Headphones have been a considerable disappointment, accounting for **less than 1%** of total revenues and orders, while being **$40 cheaper** than the AirPods on average.
- The laptop category is the most diversified and is the fourth largest category, driving **33%** of total revenue from **6%** of total orders since 2019.
- The company is heavily reliant on the continued popularity of Apple products, with the brand accounting for **50%** of its total sales and **48%** of its total orders since 2019.

**Loyalty Programme:**
- The loyalty programme has proven to be very popular with customers with continued year-on-year growth since its inception in 2019. From members accounting for **9%** of total revenue to now **57%** in 2022.
- As of 2022, loyalty members spend almost **$40 more on average** than non-members (**$248** to **$209**).
- Most of our loyalty programme sign-ups originate from the 'direct' market channel, accounting for **71%** of total memberships.

**Marketing Channel Performance**
- The ‘direct’ channel consistently generates the most revenue year-on-year, accounting for **82%** of total revenue and **77%** of total orders.
- The 'social media’ channel accounts for **just 1%** of total revenue and orders.

**Operational Effectiveness**
- The general average time to ship (**3 days**) and deliver (**14 days**) across all regions has remained extremely consistent since 2019. However, without proper benchmarks it is unclear whether these figures fare well against competitors.
- Loyalty members **do not appear to receive faster delivery times**, with time to deliver being equal with non-members (**14 days**).

## Recommendations
Based on the insights listed above, the company should consider implementing the following recommendations:

- Leverage heavy Apple product offering in order to seek closer ties (preferred agreements) with distributors and also obtain volume-based discounts to ensure availability of stock and superior pricing, benefiting both the company’s profit margins and the customer base.
- Add additional Samsung products to the offering, the company already sells Samsung accessories (webcams and charging cables) and is missing out on anchor products to further increase sales in these product lines.
- Discount, eliminate, and replace Bose SoundSport Headphones from product offering. Investigate reasons for poor performance and apply findings to next product selection.
- Investigate reasons for high performance of direct market channel and apply findings to the social media, email, and affiliate channels.
- Continue and augment the loyalty programme – clarify and augment the benefits to include faster delivery guarantees, early access to deals, and exclusive discounts.
- Place benchmarks on operational performance in line with industry standards to effectively assess the current position.
  
## Dashboard Showcase
The screenshot below showcases the "Marketing Channel Performance" section of the dashboard created as part of this project.

Click **[here](https://public.tableau.com/app/profile/patrick.cairnes/viz/TradeEaseDashboard/MarketingChannelPerformance)** for the link to the full dashboard.

<kbd> <img width="1200" alt="image" src="https://i.imgur.com/1LOkpMx.png"> </kbd> 
