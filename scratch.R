
library(tidyverse)
library(readxl)
library(stringr)
library(janitor)

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
  clean_names() %>%
  mutate(school_year = as.POSIXct(school_year, format = "%d/%m/%Y %H:%m:%s"))


