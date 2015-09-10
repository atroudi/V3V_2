import cv2
import numpy as np
from scipy.sparse.construct import spdiags

"""
vres,hres: vertical and horizontal resolutions of the original left frame 
R: resize factor
"""
def WarpingInitialization(vres, hres, R):

    # Make new image (flows) of size vres*hres resized by factor (R) initialized by all zeroes
    Gx, Gy = getVideoGradients_noMotion(int(vres * R), int(hres * R))
    #Gx, Gy = getVideoGradients_noMotion(int(vres), int(hres))
    
    xx, yy = np.meshgrid(np.arange(1, hres+1), np.arange(1, vres+1))
    YY = yy
    # set min limit to 1 ??? no elements less than 1 in YY
    # set max limit to vres ??? no elements more than vres in YY
    YY = np.minimum(np.maximum(YY, 1), vres)
    
    return Gx, Gy, np.array(xx), np.array(yy), np.array(YY)

def getVideoGradients_noMotion(h, w):
    
    # Get height (h) and width (w) of the given image
    # What is ~, K (They are normally ones) [may be color and video frames]
    K = 1
    
    # Calculate Number of pixels in entire video (N)
    N = h * w * K
    
    ## Calculate Horizontal adjacencies (Gx)
    # left: 1D array of size N filled by -1
    left = -np.ones((N, 1), dtype=np.int64)
    # a: 2D array h*k each row(i) w*h*(i+1)
    a = w * h * np.transpose(np.tile(np.arange(1, K+1), (h, 1)))
    # b: produce 2D array h*k each row(i) from 1 to h
    b = np.tile(np.arange(1, h+1), (K, 1))
    # set some indices in left by 0 (indices in a-b)
    left[a - b] = 0
    d = np.concatenate((left, np.ones((N, 1), dtype=np.int64)), axis=1)
    # Gx: sparse matrix of left on diagonal -h and ones on diagonal 0
    Gx = spdiags(np.transpose(d), np.array([-h, 0]), N, N, "csc") # we can also try "csc"
    # for spdiags number of columns must be equal to the number of diagonals to be extracted :3 
    
    ## Calculate Vertical adjacencies (Gy)
    # top: 1D array of size N filled by -1
    top = -np.ones((N, 1), dtype=np.int64)
    # set some indices in top by 0 (each h element)
    top[h-1::h] = 0;
    e = np.concatenate((top, np.ones((N, 1), dtype=np.int64)), axis=1)
    # Gy: sparse matrix of top on diagonal -1 and ones on diagonal 0
    Gy = spdiags(np.transpose(e), np.array([-1, 0]), N, N, "csc") # we can also try "csr"
    
    return Gx, Gy
