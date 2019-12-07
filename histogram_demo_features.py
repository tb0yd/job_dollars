import csv
import numpy as np
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt

def get_curve_max(list1, list2):
    # bar plot data
    width = 1/1.5

    plt.bar(list1, list2, width, alpha=0.75)

    # fit bar plot data using curve_fit
    def func(x, a, b, c):
        # a Gaussian distribution
        return a * np.exp(-(x-b)**2/(2*c**2))

    popt, pcov = curve_fit(func, list1, list2)

    x = np.linspace(1, 20, 100)
    y = func(x, *popt)

    # plt.plot(x + width/2, y, c='g')

    return x[y.tolist().index(y.max())]

print('Language,Planning,Design,Development,Testing,Maintenance,Agile')
with open('data/team_sizes.csv') as csvDataFile:
    csvReader = csv.reader(csvDataFile)
    next(csvReader, None)
    for row in csvReader:
        list1 = [1.0, 3.0, 7.0, 12.0, 17.0, 20.0]
        list2 = row[1:]
        typical = get_curve_max(list1, list2)

        # the general SDLC wrt headcount is 2,2,5,3,1. this calculates the "typical" team size and assumes that's comparable to 3.31.
        # 3.31 is average team size of all 13 of the people in the 2,2,5,3,1 lifecycle.
        print(row[0] + ',' + str(int(round(typical * (2.0/3.31)))) + ',' + str(int(round(typical * (2.0/3.31)))) + ',' + str(int(round(typical * (5.0/3.31)))) + ',' + str(int(round(typical * (3.0/3.31)))) + ',' + str(int(round(typical * (1.0/3.31)))) + ',' + str(int(round(typical))))
