# Stat109Proj
Quality Review DD: 
https://infohub.nyced.org/docs/default-source/default-document-library/quality-review-rubric_18-19.pdf

2016-2017: 
https://infohub.nyced.org/reports-and-policies/school-quality/school-quality-reports-and-resources/school-quality-report-citywide-data

Information about the above dataset (SAT Scores): 
https://data.cityofnewyork.us/Education/SAT-scores/vtmi-3hwp

Filered out s and N/A: 

Removed 

Assumptions: 

Grade 8 proficiency tests were taken in 9th grade as an indicator of middle school knowledge 


We standardized the values for grade 8 proficiency and for sat scores to subtract the two and use the delta values as our y metric for regression analysis. 

The deltas are calculated by SAT percentile - Grade 8 percentile. E.g. a negative value means schools got dumber. 

We filtered out several indicator variables as well as school rows from our data files. Variables with more that 25% of missing values we deleted, schools with 4 or more out of 9 variables missing were deleted. 