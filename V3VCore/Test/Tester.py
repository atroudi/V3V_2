from DepthDatabase.BasicDepthDatabase import BasicDepthDatabase
from Configuration.ConversionParameters import ConversionParameters, Resolution,\
    ResizeFactor
from Converter.ConversionTask import ConversionTask
from Converter.Image import ImageInfo
import os
from cv2 import imread, resize, INTER_CUBIC, imwrite, INTER_LINEAR
from Converter.DGC_StereoConverter import DGC_StereoConvertor
from numpy import float32

#database = BasicDepthDatabase("SoccerDatabase")

#database.addImageData("/Users/OmarEltobgy/Documents/V3V/V3VCore/TestData/RGB/", \
#                      "/Users/OmarEltobgy/Documents/V3V/V3VCore/TestData/Depth/", 1, 31)
#database.loadImageData()

#conversionParam = ConversionParameters(resolution=Resolution.HD, resizeFactor=ResizeFactor.EIGHT)
#database.computeFeatures(conversionParam)

#database.addImageData("/Users/OmarEltobgy/Documents/V3V/V3VCore/TestData/RGB/", \
#                      "/Users/OmarEltobgy/Documents/V3V/V3VCore/TestData/Depth/", 1, 31)

#databaseFeatures = database.getFeatures(conversionParam)



### Testing DGC_StereoCreator
# Pathes to the input files 
RGB_Path = '/Users/OmarEltobgy/Documents/V3V/V3VCore/TestData/RGB/'
Depth_Path = '/Users/OmarEltobgy/Documents/V3V/V3VCore/TestData/Depth/'
imageInfoObjects = []

conversionParam = ConversionParameters()
R = conversionParam.resizeFactor

for i in xrange(1, 32):
    newImageInfo = ImageInfo()
    
    # RGB images are divided by 255
    imageFilePath = os.path.join(RGB_Path, str(i)+".png")
    newImageInfo.originalImage = float32(imread(imageFilePath)) / 255
    newImageInfo.originalImageResized = resize(newImageInfo.originalImage, (0, 0),
                                               fx=R, fy=R, interpolation=INTER_LINEAR)
    
    # Depth images: take only one index from 3rd dimension RGB (0) as it's grey scale and all indices has same value
    # and don't divide by 255
    depthFilePath = os.path.join(Depth_Path, str(i)+".png")
    newImageInfo.depth = float32(imread(depthFilePath))
    newImageInfo.depth = newImageInfo.depth[:, :, 0]
    newImageInfo.depthResized = resize(newImageInfo.depth, (0, 0), fx=R, fy=R, interpolation=INTER_LINEAR)
    
    imageInfoObjects.append(newImageInfo)

# you should change the path to save the result
DGC_StereoConvertor(imageInfoObjects, conversionParam)
