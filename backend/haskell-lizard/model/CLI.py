import pickle
import numpy as np


import argparse

def load_model():
    with open('trained_model.pkl', 'rb') as file:
        data = pickle.load(file)
    return data

data = load_model()

linear_model = data["model"]


parser = argparse.ArgumentParser(description = "An addition program")


parser.add_argument("values", nargs = '*', metavar = "num", type = float, 
					help = "All the numbers separated by spaces will be added.")


args = parser.parse_args()

if len(args.values) == 8:
    X = np.array([args.values])
    X = X.astype(float)
    print(X)
    difficulty = linear_model.predict(X)
    print(difficulty)
    
    






