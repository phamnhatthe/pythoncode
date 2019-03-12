#!/usr/bin/python3
# Code for logistic regression and LASSO regression. This code included data cleaning techniques for making data suitable for
# LASSO regression

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import sklearn


from sklearn import preprocessing
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn import metrics
from sklearn.metrics import classification_report

icu = pd.read_csv("C:/stat420/icudata.csv")

# determine if data needs to be cleaned
icu.isnull().sum()

race = pd.get_dummies(icu['RACE'], prefix="RACE")
cpr = pd.get_dummies(icu['CPR'], prefix='CPR', drop_first=True)
typ = pd.get_dummies(icu['TYP'], prefix='TYP', drop_first=True)

icu.drop(['RACE', 'CPR', 'TYP', 'SEX', 'ID'], axis=1, inplace=True)
icu = pd.concat([icu, race, cpr, typ], axis=1)
icu.head()

X = icu.ix[:,(1, 2, 3, 4, 5, 6, 7, 8)].values
y = icu.ix[:,0].values
#print(y)


#1a.

X_train, X_test, y_train, y_test, = train_test_split(X, y, test_size=0.3, random_state=25)

LogReg = LogisticRegression()
LogReg.fit(X_train, y_train)

y_pred = LogReg.predict(X_test)
y_prob = LogReg.predict_proba(X_test)

print(y_prob)
#print(y_pred)

#print(LogReg.intercept_)
#print(1/ (1 + np.exp(LogReg.intercept_)))
print(LogReg.intercept_)
print(LogReg.coef_)
print(icu.head())

#1b.
#The odds of a person surviving is 1.9822 times more if the person receives CPR.

from sklearn import preprocessing
from sklearn.linear_model import LassoLarsCV

predvar = icu.copy()
target = predvar.STA
predictors = predvar[['AGE', 'SYS', 'HRA', 'RACE_1', 'RACE_2', 'RACE_3', 'CPR_1', 'TYP_1']].copy()

for i in list(predictors.columns.values):
    predictors[i] = preprocessing.scale(predictors[i].astype('float64'))

pred_train, pred_test, resp_train, resp_test = train_test_split(predictors, target, test_size=.3, random_state=123)
model_lasso=LassoLarsCV(cv=10, precompute=True).fit(pred_train,resp_train)
dict(zip(predictors.columns, model_lasso.coef_))
m_log_alphascv = -np.log10(model_lasso.cv_alphas_)

plt.figure()
plt.plot(m_log_alphascv, model_lasso.mse_path_, ':')
plt.plot(m_log_alphascv, model_lasso.mse_path_.mean(axis=-1), 'k', label='Average across the folds', linewidth=2)
plt.axvline(-np.log10(model_lasso.alpha_), linestyle='--', color='k', label='alpha CV')
plt.legend()
plt.xlabel('-log(alpha)')
plt.ylabel('Mean squared error')
plt.title('Mean squared error on each fold')
#plt.savefig('Fig02')
pred_train.head()

#plt.show()

#1c.
#The optimal alpha value is 0.00137162075311.
#print("The optimal value of alpha is: ")
#print(model_lasso.alpha_)
#print(model_lasso.coef_)

#1d.
#The coefficients of the model are:
#AGE: 0.05951659
#SYS: -0.04463656
#HRA: 0
#RACE_1: 0
#RACE_2: 0
#RACE_3: 0
#CPR_1: 0.05620125
#TYP_1: 0.07460764

#print("Coefficients of the model:")
#print(model_lasso.coef_)

#print("Intercept of the model:")
#print(model_lasso.intercept_)

#2a.

from ast import literal_eval

ted = pd.read_csv('C:/stat420/ted.csv', encoding="iso-8859-1")
ted.drop(['film_date', 'published_date', 'description', 'event', 'related_talks', 'speaker_occupation',
         'title', 'url', 'name', 'languages', 'main_speaker'], axis=1, inplace=True)

ted['tags'] = ted['tags'].apply(literal_eval)
ted['ratings']=ted['ratings'].apply(literal_eval)
# literal_eval turns 'character' strings into some sort of character object without the quote marks
s = ted['tags']
s = pd.get_dummies(s.apply(pd.Series).stack(), prefix="TAG_").sum(level=0) # creating dummy variables for each tag

ted.drop(['tags'], axis=1, inplace=True)
ted = pd.concat([ted, s], axis=1)

#2b.
s = ted['ratings']
s = s.apply(pd.Series)

for i, row in s.iterrows():
    for j in row:
        ted.loc[i, 'RATING_' + j['name']] = j['count']
ted.drop(['ratings'], axis=1, inplace=True)
#ted.head()

target = ted.views
predVars = list(ted.columns.values)
viewsIndex = predVars.index('views')
del predVars[viewsIndex]

predictors = ted[predVars].copy()
predictors.head()

for i in list(predictors.columns.values):
    predictors[i] = preprocessing.scale(predictors[i].astype('float64'))
predictors.head()


#2c.

pred_train, pred_test, resp_train, resp_test = train_test_split(predictors, target, test_size=.3, random_state=123)
model_lasso=LassoLarsCV(cv=10, precompute=True).fit(pred_train, resp_train)


#2d.
#The optimal value for lambda is about 1216.9.

print("Optimal lambda is:")
print(model_lasso.alpha_)


#2e.
#Many of our tags had a coefficient of zero, meaning they were not very significant to the number of views a talk got.
#Although this is true, we did have two tags that were negatively related to the number of views. Those tags were
#science and global issues.

#In terms of the best tags for number of views, we determined that magic, body language, success, performance,
#relationships, live music, time, drones, speech, and youth were the ten most successful tags for gaining viewership.


import operator

coefficients = dict(zip(predictors.columns, model_lasso.coef_))

tag_prefix = 'TAG_'
tag_coefficients = {k:v for k,v in coefficients.items() if tag_prefix in k}


tag_coefficients = sorted(tag_coefficients.items(), key=operator.itemgetter(1))

print(tag_coefficients)


#2f.
#Just like our tags, a few of our ratings (five to be exact) had a coefficient of zero and tied for last place.
#Those ratings were longwinded, confusing, unconvincing, jaw-dropping, and obnoxious.

#The best rating indicator was informative followed by inspiring.


rating_prefix = 'RATING_'
rating_coefficients = {k:v for k,v in coefficients.items() if rating_prefix in k}


rating_coefficients = sorted(rating_coefficients.items(), key=operator.itemgetter(1))

print(rating_coefficients)
