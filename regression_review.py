# Code involving exercise for linear regression, model building, and data visualization. Uncomment plt.show() to see the graphs
'''import pandas as pd
data = pd.read_csv("C:/stat420/height_weight2.csv")
import statsmodels.formula.api as smf
model = smf.ols(formula = "weight ~ 1 + height",data=data).fit()
model2 = smf.ols(formula = "weight ~ 0 + height",data=data).fit()
print(model.summary())
print(model2.summary())'''

import pandas as pd
dat = pd.read_csv("C:/stat420/height_weight2.csv")
import statsmodels.formula.api as smf
model = smf.ols(formula = "weight ~ 1 + height", data = dat).fit()
#print(model.summary())
model2 = smf.ols(formula = "weight ~ 0 + height", data = dat).fit()
#print(model2.summary())
#print(dat.columns)
#print(dat[["weight",'height']]) 
#print(dat.weight)
# make data frame
import numpy as np
import matplotlib.pylab as plt
datnew = pd.DataFrame({"first name":["The","Baylee",np.nan],"last name":["Pham","Pham","name"]})
datnew2 = datnew.dropna()

mydict = {"first":["The","Baylee",np.nan],"last":["pham","pham","name"],"birth":[pd.Timestamp(1940,2,15),pd.Timestamp(1972,1,18),pd.NaT]}
#print(mydict)
mydict["score"] = [1,2,3]
#print(mydict)
mydict.update({"score2":[2,3,4],"score3":[3,4,5]})
#print(mydict)
mydat = pd.DataFrame(mydict)
#print(mydat.head())
mydat2 = mydat.dropna(thresh=5)
#print(mydat2)
#print(mydat.describe())
residual = model.predict(dat) - dat.weight
residual2 = model2.predict(dat) - dat.weight
# check for normality of errors
#plt.hist(residual)
#plt.hist(residual2)
# check for non-constant error variance
#plt.plot(model.predict(dat),residual,'.')
plt.figure(1)
plt.plot(model2.predict(dat),residual2,'g+')
plt.ylabel("residual")
plt.xlabel("yhat")
plt.title("experiment")
plt.axis([80,240,-90,90])
plt.text(130,70,'$\mu=100,\ \sigma=15$')
plt.grid(True)
#plt.show()
 
group = np.arange(0.,5.2,.2)
plt.figure(2)
plt.plot(group,group**2,"k",group,group,"bs",group,group**3,"g^")
plt.ylabel("value")
plt.xlabel("x")
plt.title("math operation")
plt.axis([1,4,-5,30])
plt.text(.5,18,'$\mu=100,\ \sigma=15$')
plt.grid(True)
#plt.show()

def mathy(x): return np.exp(-x)*np.sin(2*np.pi*x)
myrange1 = np.arange(0.,5.,.2)
myrange2 = np.arange(0.,5.,.05)
plt.figure(3)
plt.subplot(311)
plt.plot(myrange1,myrange1**2,"k",myrange2,myrange2**2,"r--")
plt.ylabel("value squared")
plt.xlabel("value")
plt.title("time for exp")
plt.axis([-2,7,-10,30])
plt.text(0,22,'$\mu=100,\ \sigma=15$')
plt.grid(True)

plt.subplot(312)
plt.plot(myrange1,myrange1**2,"k",myrange2,myrange2**3,"b+")
plt.ylabel("modified value")
plt.xlabel("value")
plt.title("values modified")
plt.axis([-3,8,-10,130])
plt.text(0,110,'$\mu=100,\ \sigma=15$')
plt.grid(True)
#plt.show()

#print(mathy(myrange1))
dat2 = pd.read_csv("C:/stat420/car.csv")
print(dat2.columns)
modelnew = smf.ols(formula = "np.log(Price) ~ 1 + np.log(Age) + C(Make) + C(Type) + np.log(Miles)",data=dat2).fit()
print(modelnew.summary())

