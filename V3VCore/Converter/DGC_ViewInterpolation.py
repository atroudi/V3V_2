import cv2
import numpy as np
from scipy.misc.pilutil import imfilter
from numpy import float64, float32
from scipy.sparse.construct import spdiags
from scipy.sparse.linalg.isolve.iterative import cg
from cv2 import BORDER_TRANSPARENT, imwrite
import time

def ViewInterpolation(curImageInfo, conversionParam, globalParam):
    """
        This function takes the image and its depth and calculates the SideBySide image 
        by using stereoWarpK_noMotion_singleSided function
    """
    if np.max(np.max(np.abs(curImageInfo.depth))) < 0.1:
        # no need for interpolation the depth is the same for all the pixels
        curImageInfo.leftImage = curImageInfo.originalImage
        curImageInfo.rightImage = curImageInfo.originalImage
        
        vres, hres, u = curImageInfo.leftImage.shape
        curImageInfo.sideBySide = np.zeros((vres, hres*2, 3), dtype=np.float32)
        curImageInfo.sideBySide[:, 0:hres, :]  = curImageInfo.leftImage
        curImageInfo.sideBySide[:, hres: , :]  = curImageInfo.rightImage
                
        return
            
    # Warping
    disparity = stereoWarpK_noMotion_singleSided(curImageInfo, conversionParam, globalParam)
    
    # Create Side by Side image
    vres, hres, u = curImageInfo.leftImage.shape
    curImageInfo.sideBySide = np.zeros((vres, hres*2, 3), dtype=np.float32)
    curImageInfo.sideBySide[:, 0:hres, :]  = curImageInfo.leftImage
    curImageInfo.sideBySide[:, hres: , :]  = curImageInfo.rightImage
    

def stereoWarpK_noMotion_singleSided(curImageInfo, conversionParam, globalParam):
    """
        This function warps an image sequence (with corresponding flow and depth) to a stereo sequence
        
            1) First of all it uses a heuristic to calculate initial depth
            2) Then, It smooth this initial depth by spatial smoothness if needed
            4) After that, it warps the image and does interpolation to generate the right image \
               it pushes the pixels [to the right] as the depth increases 
        
    """    
    h, w, u = curImageInfo.originalImageResized.shape # shape after resize
    K = 1
    N = h * w * K
    gr = np.mean(curImageInfo.originalImageResized, 2) # not 3 as it is zero based :3
    grs = cv2.GaussianBlur(gr, (5, 5), 1)
    
    # One heuristic for converting depth to disparity
    disparity0 = imnormalize(1/(1+imnormalize(curImageInfo.depthResized)))*conversionParam.maxDisp - conversionParam.maxDisp/2;
    
    if conversionParam.spatialSmoothnessSwitch == True:
        # Smoothing the depth spatially according to adjacent pixels by using Gx, Gy gradients
        # Vertical and Horizontal Edges
        dx = cv2.filter2D(grs, -1, np.transpose(np.array([[-1, 1, 0]])))
        dy = cv2.filter2D(grs, -1, np.array([[-1, 1, 0]]))
        
        W = ( imnormalize(disparity0) + sigmoid(np.sqrt(np.power(dx, 2) + np.power(dy, 2)), 0.01, 500) ) / 2  
        
        A = np.transpose(spdiags(np.transpose(W).flatten(), 0, N, N, "csc") \
            + (conversionParam.spatialSmoothCoeff_x * globalParam.Gx.transpose() * globalParam.Gx) \
            + (conversionParam.spatialSmoothCoeff_y * globalParam.Gy.transpose() * globalParam.Gy))
        
        b = np.transpose(W).flatten() * np.transpose(disparity0).flatten()
        
        [x, flag] = cg(A, b, np.transpose(disparity0).flatten(), 5e-1, 50)
        
        disparity = np.transpose(np.reshape(x, (w, h))) # remove (h, w, 1, K)
    else:
        disparity = disparity0
    
    curImageInfo.leftImage = curImageInfo.originalImage
    
    # The -ve sign to convert the white to black and black to white 
    warpright = -disparity
            
    # only the warping interp2 is done on the original size image with no resizing to have good estimation
    warpright = cv2.resize(warpright, (curImageInfo.originalImage.shape[1], curImageInfo.originalImage.shape[0]), 
                           interpolation=cv2.INTER_LINEAR)
    
    curImageInfo.rightImage = (clip(warpImage_v2((curImageInfo.originalImage), (warpright), 
              conversionParam.resizeFactor, globalParam.xx, globalParam.yy, globalParam.YY)))
    
    return disparity

# Normalize all elements
def imnormalize(img, low_prc=None, up_prc=None):
    I = np.array(img)
    if type(I) != float32:
        I = float32(I)
    if abs(np.max(I)-np.min(I)) < 1e-8:
        I_norm = img
    else:
        if low_prc == None or up_prc == None:
            I_norm = (I - np.min(I)) / (np.max(I) - np.min(I))
        else:
            m = np.percentile(I, low_prc)
            M = np.percentile(I, up_prc)
            I_norm = (I-m)/(M-m);
    return I_norm
    
def sigmoid(x, center, scale):
    sx = 1. / (1 + np.exp(scale * (center-x)))
    return sx

# make all elements between bds[0] and bds[1]
### These bds can be in conversionParam
def clip(v, bds=None):
    if bds == None:
        bds = [0,1]
    v = np.array(v)
    v[v>bds[1]] = bds[1]
    v[v<bds[0]] = bds[0]
    return v
    
# function to warp images with different dimensions
def warpImage_v2(im, vx, R, xx, yy, YY):
    height, width, nchannels = im.shape
    
    XX = xx + vx
    YY = YY
    # The brackets are very important :3
    mask = (XX<1) | (XX>width) | (YY<1) | (YY>height)
    #XX = np.minimum(np.maximum(XX, 1), width)
    
    warpI2 = np.zeros((height, width, nchannels))

    for i in range(0, nchannels):
        foo = cv2.remap(im[:,:,i], XX.astype(float32)-1, YY.astype(float32)-1, \
                        interpolation = cv2.INTER_LINEAR, borderMode=BORDER_TRANSPARENT)
        foo[mask] = 0.6;
        warpI2[:, :, i] = foo
    
    # mask = 1 - mask
    
    return warpI2


    