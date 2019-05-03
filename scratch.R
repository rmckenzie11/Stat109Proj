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
  
# Filtering out schools missing total_sat data 
  
  filter(!(dbn %in% c("84M335", "08X332", "08X432", "16K688", "84M709"))) %>%
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
  mutate(sat_perc = round(pnorm((sat$total_sat - mean(na.omit(sat$total_sat)))/sd(na.omit(sat$total_sat)))*100,0)) %>%
  filter(!is.na(total_sat))

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
                                  levels = c("Well Developed", "Proficient", "Developing", "Under Developed"), 
                                  labels = c(4,3,2,1))


quality_review_subset3 = quality_review %>%
  select(c(1, 9:14, 25:31))

quality_review = cbind(quality_review_subset3, quality_review_subset, quality_review_subset2) %>%
  mutate_if(is.factor, as.numeric)

# Joining files 

quality_review_final = sat %>%
  inner_join(quality_review, by = "dbn") %>%
  mutate(total_grade_8_score = (average_grade_8_english_proficiency + average_grade_8_math_proficiency) / 2,
         grade_8_perc = pnorm((total_grade_8_score - mean(total_grade_8_score)) / sd(na.omit(total_grade_8_score))),
         delta = sat_perc - grade_8_perc) %>% 
  
# Filtering out columns with 310 missing values under quality_review
  
  select(-c(quality_review_how_safe_and_inclusive_is_the_school_while_supporting_social_emotional_growth,
            quality_review_how_well_does_the_school_allocate_and_manage_resources,
            quality_review_how_well_does_the_school_identify_track_and_meet_its_goals,
            quality_review_how_thoughtful_is_the_school_s_approach_to_teacher_development_and_evaluation,
            quality_review_how_well_are_school_decisions_evaluated_and_adjusted))

perc <- quality_review_final[c("dbn", "delta")]

demographics_final = sat %>%
  inner_join(demographics, by = "dbn") %>%
  inner_join(perc, by = "dbn")

survey_student_final = sat %>% 
  inner_join(survey_student, by = "dbn") %>%
  inner_join(perc, by = "dbn")

survey_parent_final = sat %>%
  inner_join(survey_parent, by = "dbn") %>%
  inner_join(perc, by = "dbn")

survey_teacher_final = sat %>%
  inner_join(survey_teacher, by = "dbn") %>%
  inner_join(perc, by = "dbn")

# Converting N/A to NA 

survey_student_final[survey_student_final == "N/A"] <- NA
survey_teacher_final[survey_teacher_final == "N/A"] <- NA
survey_parent_final[survey_parent_final == "N/A"] <- NA

# Creating rows for number of missing entries AND
# Filtering out schools with missing values for survey_parent/student/teacher of
# 4 or 5 (there are only 9 relevant indicators)

quality_review_final = quality_review_final %>% 
  mutate(missing = rowSums(is.na(quality_review_final)))

demographics_final = demographics_final %>% 
  mutate(missing = rowSums(is.na(demographics_final)))

survey_student_final = survey_student_final %>% 
  mutate(missing = rowSums(is.na(survey_student_final))) %>%
  filter(missing < 4)

survey_teacher_final = survey_teacher_final %>% 
  mutate(missing = rowSums(is.na(survey_teacher_final))) %>%
  filter(missing < 4)

survey_parent_final = survey_parent_final %>% 
  mutate(missing = rowSums(is.na(survey_parent_final))) %>%
  filter(missing < 4)

# Calculating number of missing entries in each column

na_count_demographics <-sapply(demographics_final, function(y) sum(length(which(is.na(y)))))
na_count_demographics <- data.frame(na_count_demographics)

na_count_quality <-sapply(quality_review_final, function(y) sum(length(which(is.na(y)))))
na_count_quality <- data.frame(na_count_quality)

na_count_students <-sapply(survey_student_final, function(y) sum(length(which(is.na(y)))))
na_count_students <- data.frame(na_count_students)

na_count_teachers <-sapply(survey_teacher_final, function(y) sum(length(which(is.na(y)))))
na_count_teachers <- data.frame(na_count_teachers)

na_count_parents <-sapply(survey_parent_final, function(y) sum(length(which(is.na(y)))))
na_count_parents <- data.frame(na_count_parents)


