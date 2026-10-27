# Title: Shiny App Project #1: S&P500 Projections
# Description: An app that allows us to track investments using S&P500
# Author: Brandon Marron

# =======================================================
# Required Packages
# =======================================================

library(shiny)
library(tidyverse)
library(lubridate)
library(tidyquant)
library(plotly)

# ======================================================
# Import data
# ======================================================
cache_file = "sp500.rds"

if (file.exists(cache_file)) {
  sp500 = readRDS(cache_file)
} else {
  sp500 = tryCatch(
    tq_get("^GSPC", from = "1928-01-01", to = "2024-12-31"),
    error = function(e) NULL
  )
  # tq_get() can return a one-row table of NAs (or a single NA) when a download fails
  if (!is.data.frame(sp500) || nrow(sp500) < 100 || all(is.na(sp500$close))) {
    stop("Could not download S&P500 data and no cached file '", cache_file,
         "' was found. Check the internet connection and try again.")
  }
  sp500 = sp500 %>% filter(date <= as.Date("2024-12-31"))
  saveRDS(sp500, cache_file)
}

# Annual return = (last close - first close) / first close within each calendar year
sp500_return = sp500 %>%
  select(date, close) %>%
  filter(!is.na(close)) %>%
  arrange(date) %>%
  mutate(year = year(date)) %>%
  group_by(year) %>%
  summarise(
    first_close = dplyr::first(close),
    last_close = dplyr::last(close),
    annual_return = (last_close - first_close) / first_close,
    .groups = "drop"
  )

year_min = min(sp500_return$year)
year_max = max(sp500_return$year)


# =======================================================
# Define UI
# =======================================================
ui <- fluidPage(
  titlePanel("S&P500 Investments"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput(inputId = "year",
                  label = "Time Period:",
                  min = year_min,
                  max = year_max,
                  value = c(1990, 2015),
                  sep = ""),
      numericInput(inputId = "initial",
                   label = "Initial Amount ($):",
                   value = 5000,
                   min = 0),
      numericInput(inputId = "contribution",
                   label = "Annual Contribution ($):",
                   value = 1000,
                   min = 0),
      radioButtons(inputId = "beg_end",
                   label = "Contributions made:",
                   choices = c("At the beginning of the year" = "begin",
                               "At the end of the year" = "end"),
                   selected = "begin"),
      numericInput(inputId = "growth",
                   label = "Annual growth of the contribution (%):",
                   value = 3,
                   min = 0,
                   step = 1)
    ),  # closes sidebarPanel of inputs
    
    mainPanel(
      h3("Annual Return Bar Chart"),
      plotlyOutput(outputId = "plot1"),
      hr(),
      h3("Timeline"),
      plotlyOutput(outputId = "plot2"),
      hr(),
      h3("Investment Balance"),
      tableOutput(outputId = "table"),
      p(em("Returns are based on the S&P500 index price only (dividends are not included) and are not adjusted for inflation."))
    ) # closes mainPanel of outputs
  ) # closes sidebarLayout
) # closes fluidPage (UI)


# ======================================================
# Define server logic
# ======================================================
server <- function(input, output) {
  
  # S&P500 returns in the selected period
  filtered_return = reactive({
    sp500_return %>%
      filter(year >= input$year[1], year <= input$year[2])
  })
  
  # Year-by-year investment balance
  sp500_year_return = reactive({
    req(input$initial, input$contribution, input$growth)
    validate(
      need(input$initial >= 0, "Initial amount must be 0 or more."),
      need(input$contribution >= 0, "Annual contribution must be 0 or more."),
      need(input$growth >= 0, "Growth of the contribution must be 0 or more.")
    )
    
    returns_1 = filtered_return()
    validate(need(nrow(returns_1) > 0, "No S&P500 data for this time period."))
    
    r = returns_1$annual_return
    n = length(r)
    g = input$growth / 100
    contrib = input$contribution * (1 + g)^(0:(n - 1))
    
    balance = numeric(n)
    for (i in seq_len(n)) {
      prev = if (i == 1) input$initial else balance[i - 1]
      
      balance[i] = if (input$beg_end == "begin") {
        (prev + contrib[i]) * (1 + r[i])
      } else {
        prev * (1 + r[i]) + contrib[i]
      }
    }
    
    tibble(
      year = returns_1$year,
      annual_return = r,
      contribution = contrib,
      total_invested = input$initial + cumsum(contrib),
      balance = balance
    )
  })
  
  
  # ------------------------------------------------------------
  # Plot 1: bar-chart of annual returns
  # ------------------------------------------------------------
  output$plot1 = renderPlotly({
    d = sp500_return %>%
      mutate(period = if_else(year >= input$year[1] & year <= input$year[2],
                              "Within Selected Time Period",
                              "Outside Selected Time Period"))
    
    chart = ggplot(d, aes(x = year, y = annual_return, fill = period)) +
      geom_col() +
      scale_fill_manual(
        values = c("Within Selected Time Period" = "darkblue",
                   "Outside Selected Time Period" = "gray")
      ) +
      scale_y_continuous(labels = scales::percent) +
      labs(
        title = "Return Rate Based on the Year",
        x = "Year",
        y = "Return",
        fill = "Time Period"
      ) +
      theme_minimal()
    
    ggplotly(chart)
  })
  
  # ------------------------------------------------------------
  # Plot 2: timeline of investment balance vs. total invested
  # ------------------------------------------------------------
  output$plot2 = renderPlotly({
    d = sp500_year_return()
    
    long = d %>%
      select(year,
             `Portfolio balance` = balance,
             `Total invested`    = total_invested) %>%
      pivot_longer(-year, names_to = "series", values_to = "value")
    
    timeline = ggplot() +
      geom_area(data = d, aes(x = year, y = balance), fill = "skyblue", alpha = 0.4) +
      geom_line(data = long, aes(x = year, y = value, color = series), linewidth = 1) +
      geom_point(data = long, aes(x = year, y = value, color = series)) +
      scale_color_manual(values = c("Portfolio balance" = "darkblue",
                                    "Total invested"    = "orange")) +
      scale_y_continuous(labels = scales::dollar) +
      labs(title = "Investment Balance vs. Total Invested",
           x = "Year",
           y = "Amount",
           color = "") +
      theme_minimal()
    
    ggplotly(timeline)
  })
  
  # ------------------------------------------------------------
  # Table
  # ------------------------------------------------------------
  output$table = renderTable({
    sp500_year_return() %>%
      transmute(
        Year = as.character(year),
        `Annual Return` = scales::percent(annual_return, accuracy = 0.01),
        Contribution = scales::dollar(contribution, accuracy = 0.01),
        `Total Invested` = scales::dollar(total_invested, accuracy = 0.01),
        Balance = scales::dollar(balance, accuracy = 0.01)
      )
  })
} # closes server

# Run the application
shinyApp(ui = ui, server = server)