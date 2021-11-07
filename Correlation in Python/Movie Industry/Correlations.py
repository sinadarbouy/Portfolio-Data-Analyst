# from matplotlib.pyplot import figure
import pandas as pd


# import matplotlib.pyplot as plt
# import matplotlib.mlab as mlab
# import matplotlib
# plt.style.use('ggplot')


# matplotlib.rcParams['figure.figsize'] = (12, 8)

# Read Data
df = pd.read_csv('movies.csv')

# Display top rows
df.head()
df.count
df.describe().T

# Summary
# 7668 rows
# 1980-2020


# Basic Data Cleaning
df.isnull().sum()

df.dtypes

df['released'] = pd.to_datetime(df.released)

df['budget'] = df['budget'].astype('int64')

df['gross'] = df['gross'].astype('int64')

df['yearcorrect'] = df['yearcorrect'].astype('int64')


df.drop_duplicates(inplace=True)
