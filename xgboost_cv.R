#title: "xgboost with crossvalidation in R"
#author: "Arpan"
#date: "January 4, 2017"
#output: pdf_document


Setting the seed so that we get the same results each time we run the model 
set.seed(123)

Importing the library mlbench for sonar dataset

library(mlbench)
library(caret)


Storing the data set named "Sonar" into DataFrame named "DataFrame"
data("Sonar")
DataFrame <- Sonar

Type help("Sonar") to know about the data set 
help("Sonar")

Check the dimension of this data frame
dim(DataFrame)

Check first 3 rows
head(DataFrame,3)

Check the summary of data 
summary(DataFrame)

Lets check the data set again
str(DataFrame)

Lets create the train and test data set.Target variable is Class
library(caTools)
library(caret)
ind = createDataPartition(DataFrame$Class, p = 2/3, list = FALSE)
trainDF<-DataFrame[ind,]
testDF<-DataFrame[-ind,]

We will be using the caret package for crossvalidation.Function named train in caret package is used for crossvalidation.
Let's choose the paramters for the train function in caret
number = 5(It means we are using 5 fold cross-validation)
method="cv"(Means we are using cross-validation.You can also choose other like LOOCV or repeated CV,etc.)
classProbs=TRUE(It will give the probabilities for each class.Not just the class labels)
```{r}
ControlParamteres <- trainControl(method = "cv",
number = 5,
savePredictions = TRUE,
classProbs = TRUE
)

We will put the above paramter in the model below in trControl argument


Following are the Tuning parameters which one can tune for xgboost model in caret:

1. nrounds (# Boosting Iterations)
It is the number of iterations the model runs before it stops.With higher value    of nrounds model will take more time and vice-versa.
2. max_depth (Max Tree Depth)
Higher value of max_depth will create more deeper trees or we can say it will create more complex model.Higher value of   max_depth  may create overfitting and lower value of max_depth may create   underfitting.All depends on data in hand.Default value is 6.
range: [1,infinity]
3. eta (Shrinkage)
It is learning rate which is step size shrinkage which actually shrinks the       feature weights. With high value of eta,model will run fast and vice versa.With higher eta and lesser nrounds,model will take lesser time to run.With lower eta and higher nrounds model will take more time.
range: [0,1]
4. gamma (Minimum Loss Reduction)
It is minimum loss reduction required to make a further partition on a leaf       node of the tree. The larger value will create  more conservative model.     
One can play with this parameter also but mostly other parameters are used for     model tuning.
range: [0,infinity]

5. colsample_bytree (Subsample Ratio of Columns)
Randomly choosing the number of columns out of all columns or variables at a time while tree building process.You can think of mtry paramter in random forest to begin understanding more about this.Higher value may create overfitting and       lower value may create underfitting.One needs to play with this value. 
range: (0,1]
6. min_child_weight (Minimum Sum of Instance Weight)
You can try to begin with thinking of min bucket size in decision tree(  rpart).It is like number of observations a terminal node.If the tree partition step    results in a leaf node with the sum of instance weight less than min_child_weight, then the building process will give up further partitioning. In linear regression mode, this simply corresponds to minimum number of instances needed to be in each node 
range: [0,infinity]

Why do we need model tuning?
As we have already seen there are lot of parameters in xgboost model like eta,colsample_bytree,etc.You do not know which values of each parameters would give you the best predictive model.So you need to create a grid of several combinations of parameters  which you think that can deliver best results.You can start by your intuition and later on keep on modifying the paramters till you are satisfied with the results.
Here,for demonstration purpose I'm only choosing two values of colsample_bytree and two values of max_depth.For rest of the parameters single value is taken.

parametersGrid <-  expand.grid(eta = 0.1, 
                               colsample_bytree=c(0.5,0.7),
                               max_depth=c(3,6),
                               nrounds=100,
                               gamma=1,
                               min_child_weight=2
)

To check how this grid looks like type as below.It gives four combinations of parameters.You can choose more combinations if you need or want.
parametersGrid

Let's now do the 5-fold crossvalidation for the xboost the model with the chosen parameters grid using train function.We will put the parametersGrid in the tuneGrid argument  and controlParameters in trControl argument of train function.
To know more about the train function type and run ?train in the console

modelxgboost <- train(Class~., 
data = trainDF,
method = "xgbTree",
trControl = ControlParamteres,
tuneGrid=parametersGrid)


Let's check the crossvalidation results for parameters tuning for xgboost model.We can easily see that there are four rows with each having the combination and their corresponding accuracy and kappa,etc.For max_depth=3 and colsample_bytree=0.5( rest values are fixed as we choose),the value of accuracy and kappa is 0.8203 and 0.6375(approx) respectively.
As the max_depth =3 and colsample_bytree=0.7 gives the best accuracy,the final model is choosen for [nrounds = 100, max_depth = 3, eta =
                                                                                                       0.1, gamma = 1, colsample_bytree = 0.7 and min_child_weight = 2].You can choose any  customized metric other than accuracy.You have to put that in trainControl function.
modelxgboost

Let's check the predictions on the test data set

predictions<-predict(modelxgboost,testDF)

Let's check the confusion matrix 
t<-table(predictions=predictions,actual=testDF$Class)
t

