
import os
class ImageData:
    """
        This is a private class for the database classes representing the image data needed
        
        This class should be serializable to be able to save it to permanent storage
        
        Variables:
            - imagePath
            - depthMapPath
            
        Functions:
            - computeFeatures(profile)
    """
    
    def __init__(self, imagePath, depthMapPath):
        self.imagePath = imagePath
        self.depthMapPath = depthMapPath
        print("Image Data initialized")
    
    def computeFeatures(self, profile):
        """
            1- Read the image and the depthMap
            2- Resize them to the needed resolution and resizeFactor
            3- Compute the ImageFeatures for the given profile
            4- Return the features
        """
        
        print("-- ImageData.computeFeatures")
        resolution = profile.resolution
        resizeFactor = profile.resizeFactor
        #print("Needed profile resolution: " + str(resolution) + " resizeFactor: " + str(resizeFactor))
        image = [] # the image read from self.imagePath after resizing 
        depth = [] # the depthMap read from self.depthMapPath after resizing 
        
        features = ImageFeatures(image, depth)
        
        print("All features computed and returned")
        
        return features

class ImageFeatures:
    """
        Wrapper for all the image features needed Fm, Bm, Gx, Gy
        and the methods needed to compute them from the image and its depth
        
        This class should be serializable to be able to save it to permanent storage
        
        Compute image Features for the given image, depth map
    """
    
    def __init__(self, image, depth):
        print("-- ImageFeatures.init")
        print("1- Compute frame match")
        self.computeFm(image, depth)
        print("2- Compute block match")
        self.computeBm(image, depth)
        print("3- Compute depth gradients")
        self.computeGxGy(image, depth)
        
    def computeFm(self, image, depth):
        """ 
            Compute Fm for the given image and depth map
        """
        Fm = []
        print("-- ImageFeatures.computeFm: Fm computed")
        self.Fm = Fm
    

    def computeBm(self, image, depth):
        """ 
            Compute Bm for the given image and depth map
        """
        Bm = []
        print("-- ImageFeatures.computeBm: Bm computed")
        self.Bm = Bm

    def computeGxGy(self, image, depth):
        """ 
            Compute Gx, Gy for the given image and depth map
        """
        Gx = []
        Gy = []
        print("-- ImageFeatures.computeGxGy: Gx, Gy computed")
        self.Gx = Gx
        self.Gy = Gy
        

class ImageFeaturesList:
    """
        List of image features corresponding to specific profile, this class 
        
        initialize an empty list of image features to the given profile
            
        Next you can call loadImageFeaturesList to check if there is already computed features to this profile
    """
    
    def __init__(self, profile):
        
        self.featuresList = []
        self.profile = profile
     
    def saveImageFeaturesList(self, dirPath):
        """
            save current image feature list in the given dirPath/features_profile.str()
            erasing any previous file with the same name and saving instead the new list
            returns the path where it saves this file
        """   
        path = os.path.join(dirPath, 'features_'+self.profile.str())
        
        f = open(path, 'w')
        f.write("Hello")
        f.close()
        print("-- saveImageFeaturesList: ImageFeaturesList saved")
        
        return path
    
    
    def loadImageFeaturesList(self, dirPath):
        """
            load current image feature list from the given dirPath/features_profile.str()
            if the file is not found it sets the list to empty list
        """ 
        path = os.path.join(dirPath, 'features_'+self.profile.str())
        
        if not os.path.exists(path):
            print("-- loadImageFeaturesList: ImageFeaturesList isn't computed previously for this profile")
            self.featuresList = []
            return []
        else:
            print("-- loadImageFeaturesList")
            f = open(path, 'r')
            readStr = f.read()
            print("read from file: " + readStr)
            f.close()
            self.featuresList = [1]
            return self.featuresList