
from StereoConverter import StereoConvertor
from cv2 import imread
from WarpingInitialization import WarpingInitialization
from ViewInterpolation import ViewInterpolation
from numpy import float64
import time
import numpy as np

def testStereoConverter():
    
    # The folder that contains the input RGB Images
    rgb_rootin = '/Users/OmarEltobgy/Documents/V3V/V3VCore/TestData/RGB/'
    # The folder that contains the estimated depth Images
    d_rootin = '/Users/OmarEltobgy/Documents/V3V/V3VCore/TestData/Depth/'
    
    st = 1                # start of sequence
    endi = 30             # end of sequence
    R = 0.25              # resize factor
    Thresh = 20           # pop-out level
    w = 4                 # temporal smoothness window
    sigma = 2             # temporal smoothenss std
    SpatialSmoothness = 1 # spatial smoothness switch
    StereoConvertor(rgb_rootin, d_rootin, st, endi, R, Thresh, w, sigma, SpatialSmoothness)
    
if __name__ == '__main__': 
    
    testStereoConverter()