import cv2
import numpy as np
from scipy.misc.pilutil import imfilter
from numpy import float64, float32
from scipy.sparse.construct import spdiags
from scipy.sparse.linalg.isolve.iterative import cg
from cv2 import BORDER_TRANSPARENT
from StereoConverter import average_before_remap, average_cg, average_prepare_cg, average_remap, average_clip, average_ss
import time
"""
RAW: Original Left image
RAW2: Left image resized by R
D: Depth Image (2D) resized by R
Thresh: Disparity range...set to 20
R: resize factor. Set to 0.25
Gx,Gy: See GetGxGy. Estimate ONLY ONCE for entire sequence and save in RAM (saves time)
Output SS: Side by Side output
"""
def ViewInterpolation(RAW, RAW2, D, Thresh, R, Gx, Gy, xx, yy, YY):
    
    # Warping
    lefts, rights, disparity = stereoWarpK_noMotion_singleSided(RAW2, RAW, D, Gx, Gy, Thresh, R, xx, yy, YY);
    
    aa = time.time()
    #Create SS Side by Side image
    vres, hres, u = lefts.shape
    SS = np.zeros((vres, hres*2, 3), dtype=np.float32)
    SS[:, 0:hres, :]  = lefts
    SS[:, hres: , :]  = rights
    bb = time.time()
    average_ss(bb-aa)
            
    return SS

"""
This function warps an image sequence (with corresponding flow and depth) to a stereo sequence
Assuming [h,w] are the video dimensions and K is the number of frames
# Input
imgs is of size [h,w,3,K] - video frames resized by R
imgs_RAW: video frames with original size
depths of size [h,w,1,K] - depth frames (grayscale) resized by R
flows of size [h,w,2,K] - optical flow results [????]
displevels - maximum amount of disparity between resulting stereo frames (in pixels) [????]
# Output:
lefts/rights - estimated stereo frames (same size as imgs)
anaglyphs - stereo frames converted to anaglyph [Where ????]
disparity - estimated disparity frames
"""
def stereoWarpK_noMotion_singleSided(imgs, imgs_RAW, depths, Gx, Gy, displevels, R, xx, yy, YY):
    ## Spatial smoothness parameters (higher => smoother)
    smoothCoeff_x = 20
    smoothCoeff_y = 4
    
    ## Prepare optimization
    
    h, w, u = imgs.shape # shape after resize
    K = 1
    N = h * w * K
    gr = np.mean(imgs, 2) # not 3 as it is zero based :3
    grs = cv2.GaussianBlur(gr, (5, 5), 1)
    
    # One heuristic for converting depth to disparity
    disparity0 = imnormalize(1/(1+imnormalize(depths)))*displevels - displevels/2;
    
    # Vertical and Horizontal Edges
    dx = cv2.filter2D(grs, -1, np.transpose(np.array([[-1, 1, 0]])))
    dy = cv2.filter2D(grs, -1, np.array([[-1, 1, 0]]))
    
    W = ( imnormalize(disparity0) + sigmoid(np.sqrt(np.power(dx, 2) + np.power(dy, 2)), 0.01, 500) ) / 2  
    
    aa = time.time()
###
    A = np.transpose(spdiags(np.transpose(W).flatten(), 0, N, N, "csc") + (smoothCoeff_x * Gx.transpose() * Gx) + (smoothCoeff_y * Gy.transpose() * Gy))
    bb = time.time()
    average_prepare_cg(bb-aa)
    
    b = np.transpose(W).flatten() * np.transpose(disparity0).flatten()
    
    # not the modified version
    # M = np.linalg.cholesky(A.todense())
    aa = time.time()
    [x, flag] = cg(A, b, np.transpose(disparity0).flatten(), 5e-1, 50)
    bb = time.time()
    average_cg(bb-aa)
    
    disparity = np.transpose(np.reshape(x, (w, h))) # remove (h, w, 1, K)

    warpright = -disparity
    
    lefts = imgs_RAW;
    
    warpright = cv2.resize(warpright, (imgs_RAW.shape[1], imgs_RAW.shape[0]), interpolation=cv2.INTER_LINEAR)
    
    rights = (clip(warpImage_v2((imgs_RAW), (warpright), R, xx, yy, YY)))
    
    #rights = (clip(warpImage_v2((imgs), (warpright), R, xx, yy, YY)))
    #rights = cv2.resize(rights, (imgs_RAW.shape[1], imgs_RAW.shape[0]), interpolation=cv2.INTER_LINEAR)
    
    return lefts, rights, disparity
    
def imnormalize(img, low_prc=None, up_prc=None):
    I = np.array(img)
    if type(I) != float32:
        I = float32(I)
    if abs(np.max(I)-np.min(I)) < 1e-8:
        I_norm = img
    else:
###
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
def clip(v, bds=None):
    aa = time.time()
    if bds == None:
        bds = [0,1]
###
    v = np.array(v)
    v[v>bds[1]] = bds[1]
    v[v<bds[0]] = bds[0]
    bb = time.time()
    average_clip(bb-aa)
    return v
    
# function to warp images with different dimensions
def warpImage_v2(im, vx, R, xx, yy, YY):
    
    aa = time.time()

    height, width, nchannels = im.shape
    
    XX = xx + vx
    YY = YY
    # The brackets are very important :3
    mask = (XX<1) | (XX>width) | (YY<1) | (YY>height)
    #XX = np.minimum(np.maximum(XX, 1), width)
    bb = time.time()
    average_before_remap(bb-aa)
    
    aa = time.time()
    warpI2 = np.zeros((height, width, nchannels))
###
    for i in range(0, nchannels):
        foo = cv2.remap(im[:,:,i], XX.astype(float32)-1, YY.astype(float32)-1, interpolation = cv2.INTER_LINEAR, borderMode=BORDER_TRANSPARENT)
        foo[mask] = 0.6;
        warpI2[:, :, i] = foo
    bb = time.time()
    average_remap(bb-aa)
    
    # mask = 1 - mask
    
    return warpI2


    