# Moon Oulatta, Ph.D. in Economics
# Crude oil prices and state taxes implications

                # Web Scrapping data from yahoo finance

# These package are open source packages: it is recommended to 
#load the following packages



# 1. Installing the required packages 
install.packages("quantmod")
install.packages("dplyr")
install.packages("lubridate")
install.packages("readxl")
install.packages("writexl")

library(quantmod)
library(dplyr)
library(lubridate)
library(readxl)
library(writexl)


# Setting the directory to store data

rm(list = ls())

setwd ("C:/Users/muuno/Desktop/Energy Economics/raw_data")





# First, the following codes allows us to obtain the data from Yahoo Finance. 
# we want the annual average for the Dow Jones Industrial Average from 1993 to 2025. 


getSymbols("^DJI", src = "yahoo",
           from = "1993-01-01",
           to   = "2025-12-31")


# Following the literature, we transform the download data into data frame. 
# We ignored all the variables and focus only on the closing price. 
# This allows us to obtain a data frame that provides the years with daily closing prices. 


dowjones = data.frame(
years    = index(DJI),
closingprices  = as.numeric(Cl(DJI))
)


# Here we want to compute annual averages to obtain an annual index of DJI prices. 

yearlyprices <- dowjones %>%
  mutate(year = year(years)) %>%
  group_by(year) %>%
  summarise(avgyearlyprices= mean(closingprices, na.rm = TRUE))


#Last thing we want to do is export the data to the raw folder from where 
# can easily compute the annual returns.

write_xlsx(yearlyprices ,"returns_raw.xlsx")   



# Thank you: anything is possible in Jesus name. 

