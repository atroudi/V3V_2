
from Converter.StereoCreator import StereoCreator
from Converter.DGC import DGC
from IOHandling.InputInterface import InputInterface
from IOHandling.InputProcessor import InputProcessor
from Converter.SceneClassifier import SceneClassifier
from IOHandling.OutputProcessor import OutputProcessor
from IOHandling.OutputInterface import OutputInterface


class ConversionTask:
    
    @staticmethod
    def convert(inputFilePath, outputFilePath, conversionParam, depthDatabase):
        """ 
            Controls the conversion task
                1) Read the input video and initialize the parameters needed
                2) Divide the video into chunks to allow parallelization
                3) Construct the Image Objects by sampling each chunk
                4) For each Image in each chunk:
                    a) Classify this frame (long, medium, close shot)
                    b) Call the appropriate method for conversion,  \
                    If the method is DGC, then pass to it the needed features \
                    and the needed masks
                5) Save the output video after conversion finishes
        """
        print("-- ConversionTask.convert")
        # According to the profile load the appropriate features
        databaseFeatures = depthDatabase.getFeatures(conversionParam)
        
        print("1- Call the input interface to read the whole video segment")
        video = InputInterface.loadFromDisk(inputFilePath)
        
        print("2- Call the input processor to convert the video into Image objects and divide the frames into segments \
                and each segment has a fixed number of frames to enable parallelization")
        segmentImageList = InputProcessor.processInput(video, conversionParam.segmentSize)
            
        print("3- For each image in each segment:")
        print("a- classify this segment frames (long, medium, close shot)")
        print("b- Call the appropriate method for 3D conversion")      
        dirPatchModel = "" # should be set in the InternalConfiguration class
        for segment in segmentImageList:
            for image in segment:
                SceneClassifier.classifyImage(image, dirPatchModel, conversionParam)
                
            SceneClassifier.smoothSegmentClassification(image, dirPatchModel, conversionParam)
            
            for image in segment:
                if image.sceneClass == SceneClassifier.LONG_SHOT:
                    StereoCreator.convert(image, conversionParam)
                elif image.sceneClass == SceneClassifier.MEDIUM_SHOT:
                    DGC.convert(image, conversionParam, databaseFeatures)
                elif image.sceneClass == SceneClassifier.CLOSE_SHOT:
                    DGC.convert(image, conversionParam, databaseFeatures)
            
        print("4- Call the output processor to convert the segments of image objects to video")  
        OutputProcessor.processOutput(None)
        
        print("5- Call the output interface to save the video to the needed output place")
        OutputInterface.saveToDisk(None)