from numpy import  zeros, float32
from math import sqrt, pi, exp
import numpy as np
from Converter.DGC_GlobalStereoParameters import DGC_GlobalStereoParameters
from Converter.DGC_ViewInterpolation import ViewInterpolation
from cv2 import imwrite

def gauss(n, sigma):
    """
        Gauss distribution for n points with variance sigma used in depth temporal smoothness
    """
    r = range(-int(n/2), int(n/2)+1)
    return [1 / (sigma * sqrt(2*pi)) * exp(-float(x)**2/(2*sigma**2)) for x in r]

def DGC_StereoConvertor(imageInfoObjects, conversionParam):
    """
        For each frame:
            1) Calculate the global parameters initialization according to the spatialSmoothnessSwitch
            2) Temporally Smooth the depth (if needed, there can be switch for temporal smoothness)
            3) For each image and its smoothed depth, calculate the SideBySide image by using ViewInterpolation method
    """
    endi = len(imageInfoObjects)
    starti = 0

    # 1) Calculate the global parameters initialization according to the spatialSmoothnessSwitch
    globalParam= DGC_GlobalStereoParameters(conversionParam)

    # 2) Temporally Smooth the depth (if needed, there can be switch for temporal smoothness)
    depthTemporalSmoothness(imageInfoObjects, conversionParam)

    # 3) For each image and its smoothed depth, calculate the SideBySide image by using ViewInterpolation method
    for FR in range(starti, endi):
        curImageInfo = imageInfoObjects[FR] 
        #RAW2 = cv2.resize(RAW, (0, 0), fx=R, fy=R, interpolation=cv2.INTER_LINEAR)        
        ViewInterpolation(curImageInfo, conversionParam, globalParam) 
        
        # Path to save the result 
        imwrite(('/Users/OmarEltobgy/Documents/V3V/V3VCore/TestData/Result/' + str(FR+1) + '.png'), curImageInfo.sideBySide*255)


def depthTemporalSmoothness(imageInfoObjects, conversionParam):
    """
        Temporally Smooth the depth according temporalSmoothnessSwitch
    """
    if conversionParam.temporalSmoothnessSwitch == False:
        return
    
    vres, hres = conversionParam.resolution
    R = conversionParam.resizeFactor
    w = conversionParam.temporalSmoothnessWindow 
    endi = len(imageInfoObjects)
    starti = 0
    # No. of frames considered in temporal smoothness according to temporalSmoothnessWindow
    num_frames = 2 * w + 1
    # Gaussian distribution to give weights for the depths considered for temporal smoothness
    g = gauss(num_frames, conversionParam.gaussianSigma) 
    # Array of depths used in calculating the resulting smoothed depth
    D = zeros((vres*R, hres*R, num_frames), dtype=float32)
        
    for FR in range(starti+w, endi-w):
        curImageInfo = imageInfoObjects[FR]
        #RAW2 = cv2.resize(RAW, (0, 0), fx=R, fy=R, interpolation=cv2.INTER_LINEAR)
        K = 0
        for fr in range(FR-w, FR+w+1):
            # for each frame in the temporalSmoothness window get its resized depth and multiply it by its gaussian weight
            # and put it in array D and finally sum all these depths to get the smoothed depth
            if fr >= starti and fr < endi:
                d = imageInfoObjects[fr].depthResized                
                D[:, :, K] = g[K] * d[:, :]
            K = K + 1
            
        curImageInfo.depthResized = np.sum(D, 2)
        # we should also update the depth (unresized) but actually in all next steps now we are only using the resized depth
        # This to decrease the time taken as image processing on the resized image is smaller
