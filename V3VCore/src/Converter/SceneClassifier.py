
class SceneClassifier:
    """
        Classify each scene as:
            1- LONG_SHOT
            2- MEDIUM_SHOT
            3- CLOSE_SHOT
        
        Also smooth each chunk classification
    """
    LONG_SHOT = 1
    MEDIUM_SHOT = 2
    CLOSE_SHOT = 3
    
    @staticmethod
    def classifyImage(image, dir_patch_model, conversionParam):
        """
            for each image in imageSegment
                1) Calculate pitch percentage
                2) Calculate players percentage
                3) Compare percentages with corresponding thresholds pitchThreshold, playerThreshold
                4) Classify the scene according to previous comparison and set sceneClass in Image object
                5) Compute nonPitch boolean masks and set nonPitchMask in Image object
        """
        print("-- Scene Classifier")
        print("1- Calculating pitch percentage")
        print("2- Calculating players percentage")
        print("3- Comparing percentages with corresponding thresholds pitchThreshold, playerThreshold")
        print("4- Classifying the scene and set sceneClass in Image object")
        print("5- compute nonPitch boolean masks and set nonPitchMask in Image object")
        
        
        image.sceneClass = SceneClassifier.MEDIUM_SHOT
        image.nonPitchMask = [[0], [[1]]]
            
        return
        
    @staticmethod
    def smoothSegmentClassification(image, dir_patch_model, conversionParam):
        """
            Smooth the classification of the images of segment to reduce classification errors
        """
        print("-- SmoothSegmentClassification")
        print("Smoothing the classification of the images of segment")
        return