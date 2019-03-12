# Project code for simple linear regression analysis.Shown below is the detailed analysis of the condition test for regression
#people in group: Megan Rich, Michelle Barnett, Timnah Katuka, The Pham

#1

#import qt_binder as qtbind
import qtconsole as qt
import matplotlib.pylab as plt

import pandas as pd
import numpy as np
from pandas import Series, DataFrame

import statsmodels.formula.api as smf
from sklearn.model_selection import train_test_split
from statsmodels.stats.outliers_influence import variance_inflation_factor
from patsy import dmatrices



weightpred = pd.read_csv("C:/stat420/height_weight1.csv")
#print(weightpred.head())
#print(weightpred.dtypes)
#print(weightpred.columns)

#print(weightpred[['height']])
#print(weightpred.height)
weightpred = weightpred.dropna()
#print(weightpred[['height']])

#print(weightpred.describe())

weightTrain, weightTest = train_test_split(weightpred, test_size=.3, random_state=765)
#weightTrain.shape
#weightTest.shape
model = smf.ols(formula='weight ~ 1 + height', data=weightpred).fit()
print(model.summary())
model2 = smf.ols(formula='weight ~ 0 + height', data=weightpred).fit()
print(model2.summary())
residual = model.predict(weightpred) - weightpred.weight
residual2 = model2.predict(weightpred) - weightpred.weight
# Test for normal residuals model1
print("plot for model 1")
plt.hist(residual)
# Test for heteroscedasticity model1
plt.plot(model.predict(weightpred), residual, '.')
print("plot for model 2")
#For model1, the errors seem to be normally distributed and the variance of error seems to be evenly distributed, thus constant
# Test for normal residuals model1
#plt.hist(residual2)
# Test for heteroscedasticity model1
#plt.plot(model2.predict(weightpred), residual2, '.')
#As for model2, as seen in the histogram and scatter plot, the 2 models produce plots that have distributions almost matching to each
#other. Therefore, the errors seem to be normally distributed and the variance of errors seem to be constant for model2.
#In terms of the 3 residual assumptions, the 2 models are equally good.

# model2 is better since R^2 increased significantly while the number of parameters decreased to 1, signifying that this increase is true
# and model2's regression line can explain more of the variation in the data. Also, AIC and BIC are both smaller for model2

#
#2
weightpred2 = pd.read_csv("C:/stat420/height_weight2.csv")
weightpred2 = weightpred2.dropna()

weight2Train, weight2Test = train_test_split(weightpred2, test_size=.3, random_state=453)
weight2Train.shape
weight2Test.shape
model3 = smf.ols(formula='weight ~ 0 + height', data=weightpred2).fit()
print(model3.summary())
residual3 = model3.predict(weightpred2) - weightpred2.weight
# Test for normal residuals model3
plt.hist(residual3)
# Test for heteroscedasticity model3
plt.plot(model3.predict(weightpred), residual3, '.')
plt.show()
#From the histogram, we can see that the errors seem to be normally distributed but the scatter plot tells us that the variance of errors
# increase as the residual value gets bigger. Therefore, this model doesn't meet all residual assumptions, specifically the assumption of
# constant error variance. Non constant error variance will lead to wider prediction interval and basically will decimate our ability to 
# make prediction. It doesn't affect point estimation.

#3
carpred = pd.read_csv("C:/stat420/car.csv")
carpred = carpred.dropna()

carTrain, carTest = train_test_split(carpred, test_size=.3, random_state=2394)
carTrain.shape
carTest.shape
model_categorical = smf.ols(formula='Price ~ 1+ Age + C(Make) + C(Type) + Miles', data=carpred).fit()
print(model_categorical.summary())

model_categorical2 = smf.ols(formula='np.log(Price) ~ 1+ Age + C(Make) + C(Type) + Miles',
data=carpred).fit()
print(model_categorical2.summary())

model_categorical3 = smf.ols(formula='np.log(Price) ~ 1+ np.log(Age) + C(Make) + C(Type) + np.log(Miles)', data=carpred).fit()
print(model_categorical3.summary())

# The AIC and BIC are smallest for model_categorical2. Adj R^2 is also largest for model_categorical2. Therefore, model_categorical2
# is the best model.
#The predicted price of the named vehicle is $14,653.19