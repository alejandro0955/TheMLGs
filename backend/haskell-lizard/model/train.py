import pandas as pd
import matplotlib.pyplot as plt
import pickle
from sklearn.linear_model import LinearRegression


#Run this once and 
'''
Format must be
Row 1: Name, Tot NLOC, Avg CCN, Avg Token, Fun Cnt, Warning Cnt, Fun Rt, NLOC Rt, Difficulty
'''
df = pd.read_csv("training_data.csv")
df.info()

X = df.drop(["Difficulty","Name"], axis=1)
X.info()
y = df["Difficulty"]


linear_reg = LinearRegression()
linear_reg.fit(X, y.values)

data = {"model": linear_reg}
with open('trained_model.pkl', 'wb') as file:
    pickle.dump(data, file)
