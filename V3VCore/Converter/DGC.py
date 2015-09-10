from Converter.BasicConverter import BasicConverter

class DGC(BasicConverter):
    """
        Depth Gradient Converter class, a child from Basic Converter class to handle medium and close shots
    """

    @staticmethod
    def convert(image, conversionParam, databaseFeatures):
        """ 
            DGC Conversion consists of 3 sequential steps: 
                1) Depth gradient estimator: estimating Gx, Gy using the given databaseFeatures
                2) Depth reconstructor: estimating the depth map
                3) Stereo creator from V+D: creating the leftImage, rightImage, and sideBySide 
            
            It changes the leftImage and rightImage and sideBySide variables in the given image Object
            
            It uses a machine learning K Nearest Neighbors (KNN) classification algorithm \
            to estimate the depthMap from the database of images and their depthMaps and their features
        """ 
        print("-- DGC.convert")
        
        print("1- Depth gradient estimator: estimating Gx, Gy using the given databaseFeatures")
        DGC.DepthGradientEstimator(image, conversionParam, databaseFeatures)
        print("2- Depth reconstructor: estimating the depth map")
        DGC.DepthConstructor(image, conversionParam)
        print("3- Stereo creator from V+D: creating the leftImage, rightImage, and sideBySide")
        DGC.StereoCreatorFromDepth(image, conversionParam)
    
    
    @staticmethod
    def DepthGradientEstimator(image, conversionParam, databaseFeatures):
        """
            In this step we find the K Nearest Neighbors (KNN) for the query from the database \
            Searching block by block through the KNN we then find the best matching block for each block of the query \ 
            and copy the depth gradients (Gx, Gy) from the best matching block to the query
            
            it sets Gx, Gy parameters of the Image object to the calculated Gx, Gy
        """
        print("-- DepthGradientEstimator")
        image.Gx = []
        image.Gy = []
    
    @staticmethod
    def DepthConstructor(image, conversionParam):
        """
            Having the estimated depth gradients for the query, \
            we use poisson reconstruction to reconstruct the depth image using its gradients \
            In addition we should detect the object boundaries from image.nonPitchMask \
            to cut the poisson equation on object boundaries
            
            1) Detecting object boundaries from image.nonPitchMask 
            2) Solving Poisson
            
            it sets depth parameter of the Image object to the calculated depth
        """
        print("-- DepthConstructor")
        print("1- Detecting object boundaries from image.nonPitchMask")
        print("2- Solving Poisson")
        image.depth = []
        

    @staticmethod
    def StereoCreatorFromDepth(image, conversionParam):
        """
            Using the original frame (with the original size) and the generated depth image we now generate stereo image
            
            There should be 4 stages:
                1) Global parameters initialization
                2) FrameSpecific parameters
                3) Depth refinement
                4) View interpolation
            
            it sets leftImage, rightImage, sideBySide parameters of the Image object to the calculated ones
        """
        print("-- StereoCreatorFromDepth")
        print("1- Global parameters initialization")
        print("2- FrameSpecific parameters")
        print("3- Depth refinement")
        print("4- View interpolation")
        image.leftImage = []
        image.rightImage = []
        image.sideBySide = []
    
    