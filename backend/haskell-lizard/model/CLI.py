import pickle
import numpy as np

# importing required modules
import argparse

def load_model():
    with open('trained_model.pkl', 'rb') as file:
        data = pickle.load(file)
    return data

data = load_model()

linear_model = data["model"]

# create a parser object
parser = argparse.ArgumentParser(description = "An addition program")

# add argument
parser.add_argument("values", nargs = '*', metavar = "num", type = float, 
					help = "All the numbers separated by spaces will be added.")

# parse the arguments from standard input
args = parser.parse_args()

# check if add argument has any input data.
# If it has, then print sum of the given numbers
if len(args.values) == 5:
    X = np.array([args.values])
    X = X.astype(float)
    print(X)
    difficulty = linear_model.predict(X)
    print(difficulty)
    
    



