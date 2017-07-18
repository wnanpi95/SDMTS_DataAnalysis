import pandas as pd
from os import listdir
from os.path import isfile, join

mypath = "/Users/willan/Desktop/SDMTS/ParsedFeedData/Completed"
files = [f for f in listdir(mypath) if isfile(join(mypath, f))]
for f in files:
    df = pd.read_csv(mypath+"/"+f)
    df = df.drop_duplicates()
    df.to_csv(mypath+"/"+f, index=False)
