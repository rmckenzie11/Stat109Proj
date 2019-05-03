library(mice)
library(dplyr) 

dat <- survey_student_final

sapply(dat, function(x) sum(is.na(x)))

dat <- dat %>%
  mutate(
    supportive_environment_score = as.numeric(supportive_environment_score),
    strong_family_community_ties_score = as.numeric(strong_family_community_ties_score),
    trust_score = as.numeric(trust_score)
    
  )

init = mice(dat, maxit = 0)
meth = init$method
predM = init$predictorMatrix

predM[, c("dbn", "total_sat", "total_sat_takers", "sat_perc", "school_name", "missing", "delta")] = 0

meth[c("strong_family_community_ties_score")] = "norm"

set.seed(100)
imputed = mice(dat, method=meth, predictorMatrix=predM, m=5)
imputed_survey_student_final <- complete(imputed)

sapply(imputed_survey_student_final, function(x) sum(is.na(x)))
