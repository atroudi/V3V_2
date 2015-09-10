



class Resolution:
    """ 
        This Class contains all the resolutions supported
        The value is the (vertical pixels no., horizontal pixel no.) -- needs updating
    """
    HD = (720, 640)
    FULLHD = 2
    FOURK = 3
 
 
class ResizeFactor:
    """ 
        This Class contains all the resize factors supported
        The value is the resize factor
    """  
    ONE = 1
    HALF = 0.5
    QUARTER = 0.25

class ConversionParameters:
    """
        Contains all the parameters needed for 2D-3D conversion task
        
        Some of them can be defined by users to control the 3D quality and the conversion time
        
        Others are predefined and tuned by developers for best performance
        
        Default values for parameters are set

        There is an array for commonly used profiles that the user can choose from

        Enumerate any variables that has limited number of options
        
        Parameters:
            1) Parameters can be changed by users
                - resolution: one of the Resolution enumeration 
                - resizeFactor: one of the ResizeFactor enumeration
                - maxDisp: maximum disparity controlling pop up factor
            
            2) Predefined, tuned parameters:
                - K: Number of nearest neighbors matched
                - pitchThreshold_1: used in sceneClassification
                - pitchThreshold_2: used in sceneClassification
                - playerThreshold: used in sceneClassification
                - segmentSize: number of image objects in each imageSegment used in InputProcessor
            - All next parameters are used in imageFeatures computations:
                - alpha: used in Gx, Gy computations
                - FmSize: used in Frame Match calculation
                - SIFTSize: used in SIFT calculations in Bm, Fm computations
                - blockSize: used to determine the size of each block in image features (Fm, Bm, Gx, Gy) computations
                - colorWeight: used in SIFT computations
            - All next parameters are used in DGC_StereoCreator from DGC estimated depth  
                - spatialSmoothnessSwitch 
                - temporalSmoothnessWindow 
                - temporalSmoothnessSwitch 
                - gaussianSigma 
                - spatialSmoothCoeff_x 
                - spatialSmoothCoeff_y 
    """
    
    # set default values and make array for common used profile
    # and see which variables should be enumerated
    def __init__(self, resolution=Resolution.HD, resizeFactor=ResizeFactor.QUARTER, maxDisp=20, \
                 K=None, pitchThreshold_1=None, \
                 pitchThreshold_2=None, playerThreshold=None, \
                 segmentSize=None, alpha=None, FmSize=None, SIFTSize=None, blockSize=None, colorWeight=None, \
                 spatialSmoothnessSwitch=True, temporalSmoothnessWindow=4, temporalSmoothnessSwitch=True, \
                 spatialSmoothCoeff_x=20, spatialSmoothCoeff_y=4, gaussianSigma=2):
        """
            set default values and make array for common used profile
            and see which variables should be enumerated
        """
        print("-- ConversionParameters.init")
        self.resolution = resolution
        self.resizeFactor = resizeFactor
        self.maxDisp = maxDisp
        
        self.K = K
        self.pitchThreshold_1 = pitchThreshold_1
        self.pitchThreshold_2 = pitchThreshold_2
        self.playerThreshold = playerThreshold
        self.segmentSize = segmentSize
        
        self.alpha = alpha
        self.FmSize = FmSize
        self.SIFTSize = SIFTSize
        self.blockSize = blockSize
        self.colorWeight = colorWeight
        
        self.spatialSmoothnessSwitch = spatialSmoothnessSwitch
        self.temporalSmoothnessWindow = temporalSmoothnessWindow
        self.temporalSmoothnessSwitch = temporalSmoothnessSwitch
        self.gaussianSigma = gaussianSigma
        self.spatialSmoothCoeff_x = spatialSmoothCoeff_x
        self.spatialSmoothCoeff_y = spatialSmoothCoeff_y

    
    
""" map for all common profiles """
commonProfiles = {}
#commonProfiles['ProfileOne'] = ConversionParameters()
@staticmethod
def getCommonProfile(key):
    """
        - returns the corresponding common profile to input key
        - returns None if key is not found
    """
    print("-- ConversionParameters.getCommonProfile")
    return commonProfiles[key]
    