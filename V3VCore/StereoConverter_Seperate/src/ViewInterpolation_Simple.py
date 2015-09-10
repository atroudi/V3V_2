import cv2
import numpy as np
from numpy import float64, float32
import time
from cv2 import BORDER_TRANSPARENT
"""
RAW: Original Left image
D: Depth Image (2D)
Thresh: Disparity range...set to 20
R: resize factor. Set to 0.25
Gx,Gy: See GetGxGy. Estimate ONLY ONCE for entire sequence and save in RAM (saves time)
Output SS: Side by Side output
"""
def ViewInterpolation_Simple(RAW, D, Thresh, R, xx, yy, YY):
    
    # Make sure RAW and D is in the range of 0-1 (you can convert them using im2double) done in the start
    # Why these lines !!!
    I = cv2.resize(RAW, (0, 0), fx=R, fy=R, interpolation=cv2.INTER_CUBIC)
    D = cv2.resize(D, (I.shape[1], I.shape[0]), interpolation=cv2.INTER_CUBIC)

    # Warping
    lefts, rights, disparity = stereoWarpK_noMotion_singleSided_Simple(I, RAW, D, Thresh, R, xx, yy, YY);

    #Create SS Side by Side image
    vres, hres, u = lefts.shape
    SS = np.zeros((vres, hres*2, 3))
    SS[:, 0:hres, :]  = lefts
    SS[:, hres:, :] = rights
    
    cv2.imwrite('/Users/OmarEltobgy/Dropbox/WarpingTest1/RGB/20.png', SS*255)
    
    return SS

"""
This function warps an image sequence (with corresponding flow and depth) to a stereo sequence
Assuming [h,w] are the video dimensions and K is the number of frames
# Input
imgs is of size [h,w,3,K] - video frames
depths of size [h,w,1,K] - depth frames (grayscale)
flows of size [h,w,2,K] - optical flow results [????]
displevels - maximum amount of disparity between resulting stereo frames (in pixels) [????]
# Output:
lefts/rights - estimated stereo frames (same size as imgs)
anaglyphs - stereo frames converted to anaglyph [Where ????]
disparity - estimated disparity frames
"""
def stereoWarpK_noMotion_singleSided_Simple(imgs, imgs_RAW, depths, displevels, R, xx, yy, YY):
    ## Spatial + temporal [????] smoothness parameters (higher => smoother)
    # smoothCoeff_x = 20
    # smoothCoeff_y = 4
    # smoothCoeff_tem = 0
    
    ## Prepare optimization
    h, w, u = imgs.shape
    K = 1
    """if( ~exist('displevels','var') )
        displevels = floor(sqrt(h*w)/30);)"""
    N = h*w*K
    # gr = np.mean(imgs, 2) # not 3 as it is zero based :3
    # grs = cv2.GaussianBlur(gr, (5,5), 1)
    # eps = 1e-4
    
    # One heuristic for converting depth to disparity
    disparity0 = imnormalize(1/(1+imnormalize(depths)))*displevels - displevels/2;
    
    """
    # Vertical and Horizontal Edges
    dx = cv2.filter2D(grs, -1, np.transpose(np.array([[-1, 1, 0]])))
    dy = cv2.filter2D(grs, -1, np.array([[-1, 1, 0]]))
    
    W = ( imnormalize(disparity0) + sigmoid(np.sqrt(np.power(dx, 2) + np.power(dy, 2)), 0.01, 500) ) / 2    

    t2 = smoothCoeff_x * Gx.transpose() * Gx
    t3 = smoothCoeff_y * Gy.transpose() * Gy
    A = np.transpose(spdiags(np.transpose(W).flatten(), 0, N, N, "csc") + t2 + t3)

    b = np.transpose(W).flatten() * np.transpose(disparity0).flatten()
    
    # not the modified version
    # M = np.linalg.cholesky(A.todense())
    [x, flag] = cg(A, b, np.transpose(disparity0).flatten(), 5e-1, 150)
    disparity = np.transpose(np.reshape(x, (w, h))) # remove (h, w, 1, K)
    """
    
    disparity = disparity0
    warpright = -disparity
    
    lefts = imgs_RAW;
    
    warpright = cv2.resize(warpright, (imgs_RAW.shape[1], imgs_RAW.shape[0]), interpolation=cv2.INTER_CUBIC)
    
    rights = (clip(warpImage_v2((imgs_RAW), (warpright), R, xx, yy, YY)))
    
    return lefts, rights, disparity
    
def imnormalize(img, low_prc=None, up_prc=None):
    I = np.array(img)
    if type(I) != float64:
        I = float64(I)
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
def clip(v, bds=None):
    if bds == None:
        bds = [0,1]
    cv = np.array(v)
    cv[np.array(v)>bds[1]] = bds[1]
    cv[np.array(v)<bds[0]] = bds[0]
    return cv
    
# function to warp images with different dimensions
def warpImage_v2(im, vx, R, xx, yy, YY):

    height, width, nchannels = im.shape
    
    XX = np.array(xx + vx);
    YY = np.array(YY)
    # The brackets are very important :3
    mask = (XX<1) | (XX>width) | (YY<1) | (YY>height)
    XX = np.minimum(np.maximum(XX, 1), width)

    warpI2 = np.empty(im.shape)
    for i in range(0, nchannels):
        foo = cv2.remap(im[:,:,i], XX.astype(float32)-1, YY.astype(float32)-1, interpolation = cv2.INTER_LINEAR, borderMode=BORDER_TRANSPARENT)
        foo[mask] = 0.6;
        warpI2[:, :, i] = foo
        
    mask = 1 - mask;
    
    return warpI2


    