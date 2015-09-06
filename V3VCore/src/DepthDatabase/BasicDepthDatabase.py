from Configuration.InternalConfiguration import InternalConfiguration
from PIL.ImageCms import profileToProfile


class Profile():
    """
        It is just a resolution, resizeFactor pair to identify different profiles to which features are calculated
    """
    
    def __init__(self, resolution, resizeFactor):
        self.resolution = resolution
        self.resizeFactor = resizeFactor
        
    def str(self):
        return str(self.resolution) + "_" + str(self.resizeFactor)
    
import os
from DepthDatabase.Data import ImageData, ImageFeaturesList
from cv2 import imread

class BasicDepthDatabase:
    """ 
        Parent (Basic) class for all the depth databases used to estimate the depth
        
        There are features for each image, depth pair calculated to help in 3D conversion
        
        These features are calculated for multiple profiles (resolution, resizeFactor) pairs
        
        Variables:
            - name: the database folder name
            - imageDataList: array of ImageData class describing the data needed from the images
                ImageData Class contains the path to the raw images and their depths
            - computedProfilesTuple: the previously computed profiles (resolution, resizeFactor) pairs
                We use tuple data structure instead of using an object reference to Profile class which can change
            - featuresPathList: maps the key profile to the path of the corresponding features
            - saveSerializedPath: the directory where we save all the serialized data (meta data, features of each profile)
            
            ### The serialized path directory structure:
                - ImageData: containing the variables of this class which is mainly the paths of database images, depthmaps
                - features_profile.str(): A folder for each Image features calculated for specific profile
            
        Functions:
            - addImageData(imagePath, depthMapPath)
            - saveImageData(imageDataPath)
            - loadImageData(imageDataPath)
            - computeFeatures(conversionParam)
            - updateFeatures(startIndex, conversionParam)
            - getFeatures(conversionParam)
    """
    
    def __init__(self, name):
        print("-- BasicDepthDatabase initialize")
        self.imageDataList = []
        self.name = name
        self.saveSerializedPath = os.path.join(InternalConfiguration.dataBasePath, self.name)
        if not os.path.exists(self.saveSerializedPath):
            os.mkdir(self.saveSerializedPath)
        self.computedProfilesTuple = set()
        self.featuresPathList = {}
        
    def addImageData(self, imagePath, depthMapPath):
        """ 
            1- Add new imageData to the database 
            2- Update the features computed before by computing these feature to the new images
            3- Update the metadata file saved on disk
                
            The input path can be a file path \
            or it can be a directory path (loop on all files in this directory)
            
            The corresponding files of images and depth maps should have the same name
            e.g in the directory, the first image file corresponds to the first depth map file
        """

        print("-- BasicDepthDatabase.addImageData")
        startIndex = len(self.imageDataList)
        
        if os.path.isfile(imagePath) and os.path.isfile(depthMapPath):
            if imread(imagePath) == None or imread(depthMapPath) == None:
                print("Warning: One of the 2 files isn't an image [skipped]")
                return
            self.imageDataList.append(ImageData(imagePath, depthMapPath))
            print("New Image appended")   
            print(imagePath)
            print(depthMapPath)
        elif os.path.isdir(imagePath) and os.path.isdir(depthMapPath):
            print("Reading directory files")
            # get the names of all files in the two directories
            imageFilesList = os.listdir(imagePath)
            sorted(imageFilesList)
            depthMapFilesList = os.listdir(depthMapPath)
            sorted(depthMapFilesList)
            
            i = 0
            j = 0
            while i < len(imageFilesList) and j < len(depthMapFilesList):
                # make sure that both files have the same name
                if imageFilesList[i] < depthMapFilesList[j]:
                    print("Warning: Non matching names [skipped]")
                    i+=1
                    continue
                elif imageFilesList[i] > depthMapFilesList[j]:
                    print("Warning: Non matching names [skipped]")
                    j+=1
                    continue
                
                # calculate the full path to open for the image and depth map
                imageFilePath = os.path.join(imagePath, imageFilesList[i])
                depthMapFilePath = os.path.join(depthMapPath, depthMapFilesList[j])
                # check if both imageFilePath and depthMapFilePath are both images
                # otherwise skip both of them and advance the pointer
                if imread(imageFilePath) == None or imread(depthMapFilePath) == None:
                    print("Warning: One of the 2 files isn't an image [skipped]")
                    i+=1
                    j+=1
                    continue

                self.imageDataList.append(ImageData(imageFilePath, depthMapFilePath))
                print("New Image appended")
                print(imageFilePath)
                print(depthMapFilePath)
                
                i+=1
                j+=1
        else:
            raise Exception("Error: The two paths should be both files or folders")
        
        # Calculate features for the newly added images for the previously computed profiles self.computedProfiles)
        print("Calculate features for the newly added images for the previously computed profiles self.computedProfiles")
        for profileTuple in self.computedProfilesTuple:
            self.updateFeatures(startIndex, Profile(profileTuple[0], profileTuple[1]))
        # Update the meta data of the database
        print("Update the meta data of the database")
        self.saveImageData()
    
    def saveImageData(self):
        """ 
            Save the image data to the given self.saveSerializedPath
        """
        filePath_ImageData = os.path.join(self.saveSerializedPath, 'ImageData')
        f = open(filePath_ImageData, 'w')
        f.write("Hello")
        f.close()
        print("-- saveImageData: Image Data saved")
    

    def loadImageData(self):
        """
            Load the image data from the given self.saveSerializedPath
        """
        filePath_ImageData = os.path.join(self.saveSerializedPath, 'ImageData')
        if not os.path.exists(filePath_ImageData):
            print("-- loadImageData: No Image Data saved before")
        else:
            print("-- loadImageData")
            f = open(filePath_ImageData, 'r')
            readStr = f.read()
            print("read from file: " + readStr)
            f.close()

    def computeFeatures(self, conversionParam):     
        """
            Compute features corresponding to given conversionParam profile to all the images in the database
        """
        print("-- BasicDepthDatabase.computeFeatures")
        
        profile = Profile(conversionParam.resolution, conversionParam.resizeFactor)
        # compute imageFeatures for each image
        imageFeaturesList = ImageFeaturesList(profile)
        for img in self.imageDataList:
            imageFeaturesList.featuresList.append(img.computeFeatures(profile))
        # save the list of the image features
        path = imageFeaturesList.saveImageFeaturesList(self.saveSerializedPath)
        
        profileTuple = (profile.resolution, profile.resizeFactor)
        self.computedProfilesTuple.add(profileTuple)
        self.featuresPathList[profileTuple] = path
        print("Features computed and saved and returned")
        return imageFeaturesList
    
    def updateFeatures(self, startIndex, conversionParam):
        """
            compute features corresponding to given conversionParam profile to the images 
            that isn't included in the previously computed features 
        """
        print("-- BasicDepthDatabase.updateFeatures")
        
        profile = Profile(conversionParam.resolution, conversionParam.resizeFactor)
        imageFeaturesList = ImageFeaturesList(profile)
        # load previously computed features if found
        imageFeaturesList.loadImageFeaturesList(self.saveSerializedPath)
        # compute features for new images added
        for img in self.imageDataList[startIndex:]:
            imageFeaturesList.featuresList.append(img.computeFeatures(profile))
        # save the list of the image features
        imageFeaturesList.saveImageFeaturesList(self.saveSerializedPath)
        print("Features updated and saved and returned")
        return imageFeaturesList
    
    def getFeatures(self, conversionParam):
        """ 
            check if the filePath to the features of conversionParam profile exists 
            then return the featuresList read else compute the features and return it
        """
        print("-- BasicDepthDatabase.getFeatures")
        
        profile = Profile(conversionParam.resolution, conversionParam.resizeFactor)
        # if file found return the data read from
        imageFeaturesList = ImageFeaturesList(profile)
        imageFeaturesList.loadImageFeaturesList(self.saveSerializedPath)
        
        if len(imageFeaturesList.featuresList) == 0:
            print("Features not computed before for this profile")
            return self.computeFeatures(profile)
        else:
            print("Features loaded and returned")
            return imageFeaturesList
    
if __name__ == '__main__':
    print("Hello World!")
