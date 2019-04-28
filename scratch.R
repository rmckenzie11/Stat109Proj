library(tidyverse)
library(readr)
library(readxl)
library(stringr)
library(janitor)

# Reading in files 

quality_review = read_excel("2016-17_hs_sqr.xlsx") %>%
  clean_names() %>%
  select(-c(2:4, 28, 31:41))

sat <- read_excel("2016-17_hs_sqr.xlsx", 
                  sheet = "Additional Info") %>%
  clean_names() %>% 
  select(dbn, metric_value_average_score_sat_math, 
         n_count_average_score_sat_math, 
         metric_value_average_score_sat_reading_and_writing, 
         n_count_average_score_sat_reading_and_writing) %>% 
  mutate(total_sat = metric_value_average_score_sat_math + metric_value_average_score_sat_reading_and_writing) %>%
  mutate(total_sat_takers = n_count_average_score_sat_math) %>% 
  select(-c(metric_value_average_score_sat_math, 
            n_count_average_score_sat_math, 
            metric_value_average_score_sat_reading_and_writing, 
            n_count_average_score_sat_reading_and_writing)) %>%
  mutate(perc = pnorm((sat$total_sat - mean(na.omit(sat$total_sat))) / sd(na.omit(sat$total_sat))))

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

# Changing factor levels 

quality_review_subset = quality_review %>%
  select(2:8)

quality_review_subset[] = lapply(quality_review_subset, factor, 
                                 levels=c("Exceeding Target", "Meeting Target", "Approaching Target", "Not Meeting Target"), 
                                 labels = c(4,3,2,1))

quality_review_subset2 = quality_review %>%
  select(15:24)

quality_review_subset2[] = lapply(quality_review_subset2, factor, 
                                  levels=c("Well Developed", "Proficient", "Developing", "Under Developed"), 
                                  labels = c(4,3,2,1))


quality_review_subset3 = quality_review %>%
  select(c(1, 9:14, 25:31))

quality_review = cbind(quality_review_subset3, quality_review_subset, quality_review_subset2) %>%
  mutate_if(is.factor, as.numeric)

# Joining files 

demographics_final = sat %>%
  inner_join(demographics, by = "dbn")

survey_student_final = sat %>% 
  inner_join(survey_student, by = "dbn")

survey_parent_final = sat %>%
  inner_join(survey_parent, by = "dbn")

survey_teacher_final = sat %>%
  inner_join(survey_teacher, by = "dbn")

quality_review_final = sat %>%
  inner_join(quality_review, by = "dbn")