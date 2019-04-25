
library(tidyverse)
library(readxl)
library(stringr)
library(janitor)
library(lubridate)

sat <- read_excel("2016-17_hs_sqr.xlsx", 
                              sheet = "Additional Info") %>%
  clean_names()

demographics <- read_excel("demographics.xlsx", 
                           sheet = "School")

demographics <- demographics %>%
  filter(Year == "2016-17",
         `Grade 12` > 0) %>%
  clean_names()

dbn <- demographics$dbn
dbn2 <- str_sub(dbn, start = -4)

survey_parent <- read_excel("survey_parent.xlsx") %>%
  filter(DBN %in% dbn) %>%
  clean_names()

survey_teacher <- read_excel("survey_teacher.xlsx") %>%
  filter(DBN %in% dbn) %>%
  clean_names()

survey_student <- read_excel("survey_student.xlsx") %>%
  filter(DBN %in% dbn) %>%
  clean_names()

quality_review <- read_csv("2005_-_2018_Quality_Review_Ratings.csv") %>%
  filter(BN %in% dbn2) %>%
  clean_names()

# Turn school_year into date
quality_review = quality_review %>% 
  separate(col = school_year, into = c("school_year", "time"), sep = " ", extra = "merge") %>%
  mutate(school_year = date(as.POSIXct(school_year, format = "%d/%m/%Y"))) %>%
  select(-time)

# Turn start_date into date
quality_review = quality_review %>%
  separate(col = start_date, into = c("start_date", "time"), sep = " ", extra = "merge") %>%
  mutate(start_date = date(as.POSIXct(start_date, format = "%m/%d/%Y"))) %>%
  select(-time)

scores <- read_excel("scores.xlsx", sheet = "Student Achievement") %>%
  filter(DBN %in% dbn) %>%
  select(1,2,94,95,96,74,75,76)

