####### Clear Environment and Console
rm(list=ls()) ### Clears existing variables from the environment
cat('\014') ### Clears the console
options(scipen = 999) ### To turn off scientific notation and make things easier to read

####### Setting Working Directory
setwd('C:/Users/anime/Documents')

###### Loading libraries
require(readxl)

###### Loading data
grocery_stores <- read_excel('Grocery_Stores_-_2013.xlsx')

income <- read_excel('IncomeByZipCode.xlsx')
income_refined <- read_excel('IncomeByZipCodeFurtherRefined.xlsx')

race <- read_excel('RaceByZipcode.xlsx')
race_refined <- read_excel('RaceByZipCodeFurtherRefined.xlsx')

crime <- read_excel('CrimeByZipCode.xlsx')


joined_data <- data.frame(read_excel('JoinedDataNeedsProcessing2.xlsx'))

##### Creating population per grocery store
joined_data$pop_per_str <- joined_data$PopulationTotal/joined_data$NumOfStores

# Distribution of the variable
quantile(joined_data$pop_per_str, probs = seq(0, 1, by= 0.1))

# Assuming 20% to be grocery desert, we classify the zipcodes to be greater than 80percentile value (10550.250) to be food desert
joined_data$food_desert <- factor(ifelse(joined_data$pop_per_str <= 10550.250, 0, 1))

# calculating the race percentages per zipcode
joined_data$Caucasian_per <- joined_data$Caucasian/joined_data$PopulationTotal
joined_data$African.American_per <- joined_data$African.American/joined_data$PopulationTotal
joined_data$American.Indian.and.Alaska.Native_per <- joined_data$American.Indian.and.Alaska.Native/joined_data$PopulationTotal
joined_data$Asian_per <- joined_data$Asian/joined_data$PopulationTotal
joined_data$Hispanic.or.Latino_per <- joined_data$Hispanic.or.Latino/joined_data$PopulationTotal

# calculating percentages for income levels low, medium, and high
joined_data$low_income <- joined_data$Low.Income...0.to..49.999./joined_data$PopulationTotal
joined_data$high_income <- joined_data$High.Income...125.000.or.more./joined_data$PopulationTotal
joined_data$med_income <- joined_data$Medium.Income...50.000.to..124.999./joined_data$PopulationTotal

###### Predictors and Outcome Variables
predictors <- c("PopulationTotal", "NumOfCrimeIncidence", "Caucasian_per", "African.American_per", 
                "American.Indian.and.Alaska.Native_per", "Asian_per", "Hispanic.or.Latino_per", 
                "low_income", "med_income", "high_income")

outcome <- 'food_desert'


###### Required for Classifiction
require(caret)

#### 5-Fold Cross validation
fitControl <- trainControl(
  method = "repeatedcv",
  number = 5,
  repeats = 5)


##### Decision Tree
dtree <- train(joined_data[,predictors],joined_data[,outcome],method='rpart',trControl=fitControl)

# Plotting the tree
plot(dtree$finalModel)

# Predictions
predictions_raw <- predict.train(object=dtree,joined_data[,predictors],type="raw")
predictions_prob <- predict.train(object=dtree,joined_data[,predictors],type="prob")

joined_data$prediction_dtree <- predictions_raw
joined_data$prediction_dtree_prob <- predictions_prob$`1`

# Confusion Matrix
confusionMatrix(as.factor(predictions_raw),joined_data[,outcome])

##### Naive Bayes
naive_bayes <- train(x = joined_data[,predictors], y = joined_data[,outcome], method='nb', trControl=fitControl)

# Predictions
predictions_raw_nb <- predict.train(object=naive_bayes,joined_data[,predictors],type="raw")
predictions_prob_nb <- predict.train(object=naive_bayes,joined_data[,predictors],type="prob")

joined_data$prediction_nb <- predictions_raw_nb
joined_data$prediction_nb_prob <- predictions_prob_nb$`1`

# Confusion Matrix
confusionMatrix(as.factor(predictions_raw_nb),joined_data[,outcome])

#Plotting Variable importance for Naive Bayes
plot(varImp(object=naive_bayes),main="Naive Bayes - Variable Importance")


#Export Data File to Excel
