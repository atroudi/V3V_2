import os
from numpy import float64, zeros, float32
from cv2 import imread, imwrite, resize, INTER_LINEAR
from WarpingInitialization_Simple import WarpingInitialization_Simple
from WarpingInitialization import WarpingInitialization
from math import sqrt, pi, exp
import numpy as np
from ViewInterpolation_Simple import ViewInterpolation_Simple
import time
import cv2
from __builtin__ import exit

### Parameters to calculate the time taken in each step
avg_each_frame = 0.0
avg_temp_smooth = 0.0
avg_prepare_cg = 0.0
avg_cg = 0.0
avg_before_remap = 0.0
avg_remap = 0.0
avg_clip = 0.0
avg_ss = 0.0
N = 0


def gauss(n, sigma):
    """
        Gauss distribution for n points with variance sigma
    """
    r = range(-int(n/2), int(n/2)+1)
    return [1 / (sigma * sqrt(2*pi)) * exp(-float(x)**2/(2*sigma**2)) for x in r]

def StereoConvertor(rgb_rootin, d_rootin, st, endi, R, Thresh, w, sigma, SpatialSmoothness):
    
    global avg_each_frame
    global avg_temp_smooth
    global N
    
    rootout = '/Users/OmarEltobgy/Documents/V3V/V3VCore/TestData/Result/';
    dir = os.path.dirname(rootout)
    if not os.path.exists(dir):
        os.makedirs(dir)
    else:
        print ":3 :3"
    
    RAW = float32(imread(rgb_rootin + str(st) + '.png'))
    
    s = time.time()
    
    vres, hres, u = RAW.shape
    print vres
    print hres
    
    num_frames = 2 * w + 1
    g = gauss(num_frames, sigma)
    D = zeros((vres*R, hres*R, num_frames), dtype=float32)
    
    if SpatialSmoothness == 1:
        Gx, Gy, xx, yy, YY = WarpingInitialization(vres, hres, R)
        #Gx, Gy, xx, yy, YY = WarpingInitialization(vres*R, hres*R, R)
    else:
        xx, yy, YY = WarpingInitialization_Simple(vres, hres)
    
    N = endi-st-2*w
    s = time.time()
    
### 
    # This can be parallelized
    # Each frame returns an SS frame
    for FR in range(st+w, endi-w+1):
        # RAW Left Image
        x = time.time()
        RAW = float32(imread(rgb_rootin + str(FR) + '.png')) / 255
        RAW2 = cv2.resize(RAW, (0, 0), fx=R, fy=R, interpolation=cv2.INTER_LINEAR)
        y = time.time()
        s += (y-x)
        
        aa = time.time()
        
        # Read and temporally smooth Depth
    ### 
        # This can be parallelized
        # D_Smoothed Calculation
        K = 0
        for fr in range(FR-w, FR+w+1):
            if fr >= st and fr <= endi:
                x = time.time()
                d = float32(imread(d_rootin + str(fr) + '.png'))
                d = resize(d, (0, 0), fx=R, fy=R, interpolation=cv2.INTER_LINEAR)
                y = time.time()
                s += (y-x)
                aa += (y-x)
                
                D[:, :, K] = g[K] * d[:, :, 0]
            K = K + 1
    ###
        D_smoothed = np.sum(D, 2)
        bb = time.time()
        avg_temp_smooth += float(bb - aa) / N
        
        y = time.time()
        if np.max(np.max(np.abs(D_smoothed))) < 0.1:
            SS = [RAW, RAW]
        else:
            # actual Warping (added spatial smoothness swtich --> SpatialSmoothness)
            if SpatialSmoothness == 1:
                from ViewInterpolation import ViewInterpolation
                SS = ViewInterpolation(RAW, RAW2, D_smoothed, Thresh, R, Gx, Gy, xx, yy, YY)
            else:
                SS = ViewInterpolation_Simple(RAW, D_smoothed, Thresh, R, xx, yy, YY)
        
        bb = time.time()
        avg_each_frame += float((bb-aa)) / N
        x = time.time()
        imwrite((rootout + str(FR) + '_.png'), SS*255)
        y = time.time()
        s += (y-x)
        
    e = time.time()
    print "total conversion time: " + str(e - s)
    print "frames number        : " + str(N)
    print ""
    print "average each frame   : " + str(avg_each_frame*1000)
    print "average temp smooth  : " + str(avg_temp_smooth*1000)  
    print "average prepare cg   : " + str(avg_prepare_cg*1000) 
    print "average cg           : " + str(avg_cg*1000)  
    print "average before remap : " + str(avg_before_remap*1000)  
    print "average remap        : " + str(avg_remap*1000)  
    print "average clip         : " + str(avg_clip*1000)  
    print "average prepare ss   : " + str(avg_ss*1000)

### Functions to calculate the time taken in each step
def average_prepare_cg(t):
    global avg_prepare_cg
    global N
    avg_prepare_cg += float(t) / N
    
def average_cg(t):
    global avg_cg
    global N
    avg_cg += float(t) / N
    
def average_before_remap(t):
    global avg_before_remap
    global N
    avg_before_remap += float(t) / N
    
def average_remap(t):
    global avg_remap
    global N
    avg_remap += float(t) / N
    
def average_clip(t):
    global avg_clip
    global N
    avg_clip += float(t) / N  

def average_ss(t):
    global avg_ss
    global N
    avg_ss += float(t) / N  
    