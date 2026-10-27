# S&P 500 Historical Investment Simulator
An interactive **R Shiny application** that uses S&P 500 price data from 1928-2024 to simulate how an investment portfolio could have grown under various conditions. 

Users can customize their initial investment, annual contributions, contribution growth rate, contribution timing, and investment period to see how market performance and compounding affect returns over time.

# Project Overview
Investment performance depends not only on market returns, but also on factors like: 

- When an investor begins investing
- How much they initially invest
- How much they contribute each year
- Whether contributions increase over time
- When contributions are made during the year
- The sequence of positive and negative market returns

The goal of the project is to create an interactive tool that allows users to experiment with variables using S&P 500 price movements.

The application seeks to answer the following questions: 
- How would an investment have performed during a selected period?
- How much of the ending portfolio came from contributions v.s. market growth?
- How does increasing annual contributions affect long-term portfolio value?
- How does the timing of annual contributions affect investment growth?
- How volatile were S&P 500 returns during the selected period? 

# Data
The application retrieves the data from the **S&P 500 Index (^GSPC)** using the `tidyquant` package.

**Period**: 1928 - 2024
**Frequency**: Daily market data
**Metric Used**: S&P 500 closing index level

After downloading, the data is cached locally as `sp500.rds`, so future runs don't need to download it.

# Tools Used

- **R**
- **Shiny**: interactive application
- **tidyverse**: data manipulation and transformation
- **tidyquant**: financial market data retrival
- **lubridate**: date processing
- **ggplot2**: data visualization
- **Plotly**: interactive charts

# Data Preparation
S&P 500 prices are cleaned and transformed into yearly observations before being used by the simulator.

Steps include: 
- Retrieving daily S&P 500 index data
- Removing missing closing prices
- Extracting calendar year from each trading date
- Identifying the first and final closing index values within each year
- Calculating the price change for each year
- Filtering returns dynamically based on the user-selected investment period

We calculate yearly price return as:
```text
Annual Return = (Last Closing Value - First Closing Value) / First Closing Value
```
We then apply these returns sequentially to the simulated investment portfolio.

# Investment Simulation
Users have control over these inputs: 

## Time Period
Select the years to simulate the investment over.

## Initial Investment
The amount invested at the beginning of the simulation.

## Annual Contribution
The amount added to the investment each year.

## Contribution Timing 
Annual contributions can be made either:

- At the beginning of the year
- At the end of the year

This lets the user explore how additional time in the market affects portfolio growth. 

## Annual Contribution Growth
Users can specify a percentage by which their annual contribution increases each year.

For example, an initial annual contribution of $1,000 with 3% annual growth results in progressively larger contributions throughout the investment period.

# Application Features

## 1. Annual Returns
The first visualization displays S&P 500 price returns by year.

The user's selected investment period is highlighted against the full dataset, making it easier to see the positive and negative market environments experienced during the simulation.


## 2. Portfolio Growth Timeline
The second visualization compares:
- Portfolio Balance
- Total Amount Invested

over the selected investment period.

This lets you visually separate money contributed by the investor from portfolio value generated through market performance.

## 3. Year-by-Year Investment Table
The application also provides a detailed table containing:
- Year
- Annual return
- Annual contribution
- Total amount invested
- Portfolio balance

This shows how the simulation progresses from one year to the next.

# What the Simulator Demonstrates
Because the application is interactive, there is no single fixed result. Outcomes depend on the investment period and the assumptions the user selects.

However, the simulator demonstrates several important characteristics of long-term investing:

- **Market returns can vary substantially from year to year**. Long-term portfolio growth occurs despite periods of negative market performance.
- **Investment results are highly dependent on the selected time period**. Starting immediately before or during a major market decline can produce very different short-term results from starting during a strong market period.
- **Compounding becomes increasingly important over longer investment periods**. As portfolio value grows, market returns have a progressively larger effect on the ending balance.
- **Increasing annual contributions can materially affect long-term portfolio value**. The contribution-growth input lets users model gradually increasing investment amounts over time.
- **Contribution timing affects the amount of time new money participates in market returns**. Beginning-of-year contributions receive that year's market return, while end-of-year contributions do not.
- Comparing **portfolio balance against total invested** provides a clear way to distinguish investor contributions from growth generated by market movements.

## Example Scenario
Here is an example:
```text
Investment Period: 1990-2024
Initial Investment: $5,000
Annual Contribution: $1,000
Contribution Timing: Beginning of year
Contribution Growth: 3% per year
```
This period spans multiple market cycles and demonstrates long-term portfolio behavior across positive and negative market environments. 

# Repository Structure
```text
sp500-investment-simulator/
│
├── app.R
├── README.md
│
├── sp500.rds  
│
└── images/
    ├── annual-returns.png
    ├── portfolio-growth.png
    └── investment-table.png
```
# Running the Application
The application requires **R** and the following **packages**:
```R
library(shiny)
library(tidyverse)
library(lubridate)
library(tidyquant)
library(plotly)
```
Clone or download the repository and run:
```R
shiny::runApp()
```
If `sp500.rds` does not already exist, the application attempts to retrieve the S&P 500 data automatically and creates the cache file after downloading. 

## Alternatively
The application is published on **Posit Connect**. Please see the **Links** section to access the application. 

[Links Section](https://github.com/brandon-marron/S-P-500-Historical-Investment-Simulator/tree/main#links)

**OR** 

**Application Link**: [S&P 500 Project](https://brandonmarron-sp500-project.share.connect.posit.cloud/)

# Limitations
This project analyzes raw collision counts, not collision rates. As a result, counties and cities with larger populations or higher traffic volumes would record more collisions. Additional analysis that incorporates population, roadway mileage, or vehicle miles traveled would be needed to compare relative crash risk across locations. 

# Limitations
Several limitations should be considered when interpreting the simulation:
- The application uses the **S&P 500 index price only** and does not include reinvested dividends.
- Results are **not adjusted for inflation**
- Taxes, transaction fees, management fees, and other investment costs are not included.
- The simulation assumes contributions occur consistently according to the selected schedule.
- Annual price changes are calculated using the first and last available closing values within each year.
- Performance does not imply or guarantee future investment performance.

Because dividends are excluded, do not interpret the application as a complete total-return simulation of an S&P 500 investment. 

# Links

**Application Link**: [S&P 500 Project](https://brandonmarron-sp500-project.share.connect.posit.cloud/)

**Dataset Download Link**: [Dataset]()

**GitHub Repository**: [Repository](https://github.com/brandon-marron/S-P-500-Historical-Investment-Simulator)

**LinkedIn**: [LinkedIn Profile](https://www.linkedin.com/in/brandonmarron)













