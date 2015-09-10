

class ImageInfo:
    """
        Contains all the data needed for a specific frame image
        
        Parameters:
            - originalImage: the original RGB image (Input)
            - originalImageResized: the Resized original RGB image (Input)
            - leftImage: (now it is just the original image)
            - rightImage: (it is estimated according to the depth at Converter)
            - sideBySide: the stereo image (putting the left and right image side by side in one image)
            - depth: The corresponding greyscale depth map (width x height) (done at Converter)
            - depthResized: the Resized depth map
            - nonPitchMask: 2D boolean array (1 nonPitch, 0 pitch) needed in DGC (done at sceneClassifier)
            - sceneClass: Integer representing the classification of this image (done at sceneClassifier)
            - Gx, Gy: Arrays representing the gradients of the image (estimated at DGC)
            - SS: the resulting Side by side image (3D Image) (done at Converter)
    """
    
    def __init__(self):
        """
            Setting default values for the parameters of the image class
            
            Then these are public parameters can be changed from anywhere
            Also, We can make them private with specific setters and getters
        """
        self.originalImage = None
        self.originalImageResized = None
        self.leftImage = None
        self.rightImage = None
        self.sideBySide = None
        self.depth = None
        self.depthResized = None
        self.nonPitchMask = None
        self.sceneClass = None
        self.Gx = None
        self.Gy = None
