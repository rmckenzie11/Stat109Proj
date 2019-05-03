library(mice)
library(dplyr) 

dat <- quality_review_final

sapply(dat, function(x) sum(is.na(x)))

dat <- dat %>%
  mutate(
    quality_review_how_well_does_the_school_assess_what_students_are_learning = as.factor(quality_review_how_well_does_the_school_assess_what_students_are_learning)
  )

init = mice(dat, maxit = 0)
meth = init$method
predM = init$predictorMatrix

predM[, c("dbn", "total_sat", "total_sat_takers", "sat_perc", "total_grade_8_score", "grade_8_perc", "delta",)] = 0

meth[c("quality_review_how_well_does_the_school_assess_what_students_are_learning")] = "polyreg"

set.seed(100)
imputed = mice(dat, method=meth, predictorMatrix=predM, m=5)
imputed_quality_review_final <- complete(imputed)

sapply(imputed_quality_review_final, function(x) sum(is.na(x)))




