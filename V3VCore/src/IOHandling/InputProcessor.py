
from Converter.Image import ImageInfo

class InputProcessor:
    """
        This is a library for processing the input file
        
        Now we only have one method for processing the input (processInput) 
        
        Later on there can be other processing methods implemented
    """
    
    @staticmethod
    def processInput(video, segmentSize):
        """
            Processing the given video as follows:
                1) Decoding the video
                2) Sampling the video to get list of images
                3) Converting each image to an object of the Image class
                4) Dividing the images into segments, each segment has predefined number of images 
                  (check conversionParameters)
                5) Returning a 2D list of Image objects one dimension for each segment 
                   and the other for the image objects of each segment
                
                Note that these segments is to enable parallelization
        """
        
        print("-- Input Processor")
        
        print("1- Decoding the video")
        
        print("2- Sampling the video to get list of images")
        frameList = [1, 2] # [test] should be images
        
        print("3- Converting each image to an object of the Image class")
        print("4- Dividing the images into segments, each segment has predefined number of images \
              (check conversionParameters)")
        segmentImageList = [[]]
        nowBlockIndex = 0
        for frame in frameList:
            if len(segmentImageList[nowBlockIndex]) == segmentSize:
                nowBlockIndex += 1
                segmentImageList.append([])
            
            image = ImageInfo()
            image.originalImage = frame
            segmentImageList[nowBlockIndex].append(image)
            
        print("5- Returning a 2D list of Image objects one dimension for each segment  \
               and the other for the image objects of each segment")
        return segmentImageList
