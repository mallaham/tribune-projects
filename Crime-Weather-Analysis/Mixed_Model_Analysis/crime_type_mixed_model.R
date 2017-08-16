#######################################################
# In this R script, we built a multi-level-model (MLM)
# to better understand the relationship between crime rate
# and weather temperature. This is a follow up analysis 
# to a linear regression analysis that looked at the linear
# relationship between crime rate and temperature. For both
# analyses we pulled crime data from City of Chicago Data Portal
# for the past 5 years (2012 - 2017)
# 
# Objective:
# We are trying to capture the effect of temperature
# on crime accounting for the variablity of each type of crime
# in each year.
# 
# Method:
# Our first round of analysis we identified a total of 8
# types of crimes that had the steepest slopes in the linear
# regression model. The 8 crimes are:
#   - Theft
#   - Battery
#   - Criminal Damage
#   - Narcotics
#   - Assualt
#   - Motor Vehicle Theft
#   - Robbery
#   - Burglary
# Accordingly, we coded all other crimes as "Other" and we use this category
# as a frame of reference (baseline) for comparison in the MLM model.
#
# It's worth noting that we conducted additional analyses and we believe
# that Battery tend to include shooting incidents in chicago.
# 
# Conclusion:
# Overall, we found that temperature have a significant effect on
# crime rate. Below is a summary of our results
#############################               #########   ########   #####
#Effects                                    Estimate    std.err   t-value
#############################               #########   ########   #####
# Mean_Temp:Primary.TypeASSAULT               0.335653   0.020328   16.51
# Mean_Temp:Primary.TypeBATTERY               0.949677   0.020328   46.72
# Mean_Temp:Primary.TypeBURGLARY              0.195130   0.020328    9.60
# Mean_Temp:Primary.TypeCRIMINAL DAMAGE       0.495823   0.020328   24.39
# Mean_Temp:Primary.TypeMOTOR VEHICLE THEFT   0.028752   0.020328    1.41
# Mean_Temp:Primary.TypeNARCOTICS             0.070149   0.020328    3.45
# Mean_Temp:Primary.TypeTHEFT                 0.932344   0.020328   45.87
# Mean_Temp:Primary.TypeHOMICIDE              0.0003812   0.0242559  0.02
# the measure of significance in this analysis is when the t-value
# is greater or equals to 2.
# Our analysis shows that for every 10 degrees increase in temperature,
# roughly, there is:
#   * 9 theft incidents 
#   * 9 battery incidents
#   * 3 assault incidents
#   * 2 burgulary incidents
#   * 1 incident related to narcotics 

# the effect of Motor vehicle theft turned out to be statistically
#insignificant. Therefore, we decided not report it.
#######################################################
library(lme4) #importing library for linear mixed models.
library (ggplot2)
#options(scipen=999) #disables scientific notation
setwd('./')
data <- read.csv('temp_reg_analysis.csv')
data$X <- NULL


data$Primary.Type <- factor(data$Primary.Type)

#Structuring the MLM model:
# In this model we are trying to find the temperature on crime
# controlling for the variation of year and type of crime.
# In other words, we allow each Year and each type of Crime to have their
# own means.
mlm.1 <- lmer(Count~Mean_Temp+(1|Year)+(1|Primary.Type),data=data,REML = FALSE)
summary(mlm.1)
ranef(mlm.1)
# Conclusion: overall, for every 10 units increase in temperature,
# roughly, there are 13 crime incidents.

# Now in order to measure the effect of each type of crime and temperature on
# crime rate, we interact crime type and temperature. Since we are interested
# in only 8 crimes with the steepest slopes, we coded all other cirme types in
# the following analysis as other.


####Dummy code the variables
levels(data$Primary.Type) <- c(levels(data$Primary.Type),'Other') #recoding the crimes to "other"
crimeType <-c('THEFT', 'BATTERY', 'CRIMINAL DAMAGE', 'NARCOTICS', 'ASSAULT', 'MOTOR VEHICLE THEFT', 'ROBERRY','BURGLARY','HOMICIDE')
data$Primary.Type[!(data$Primary.Type %in%  crimeType)]<-'Other'

data$Primary.Type<-relevel(data$Primary.Type,ref='Other') #releveling the baseline to "Other"
mlm.2 <- lmer(Count~Mean_Temp*Primary.Type+(1|Year)+(1|Primary.Type),data=data,REML = FALSE)
summary(mlm.2)

# The interaction terms represent the slope of the interaction term in each row.
# The intercepts represent the point where the linear line starts for each
# crime type at x=0.

# Interpretation of slopes:
# e.g., for Mean_Temp:Primary.TypeASSAULT for every 10 units increase in temperature
# there are 3 assault incidents above the average of other crimes.

# How to calculate the intercept, slope, and effect for each crime type?
# Effect = the interaction term of Mean_Temp and crime type (e.g, THEFT) * 10. 10 represent number of degrees.
# Slope = (the interaction term of Mean_Temp and crime type) + (intercept of the slope, which is 
# Mean_Temp)
# Intercept = (the main effect of crime type (e.g., THEFT)) + (Intercept: intercept of other crimes. The first row of the Fixed effects table.)