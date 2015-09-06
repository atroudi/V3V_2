
class BasicConverter:
    """
        This is a parent basic class for any 2D to 3D conversion method
    """
    
    @staticmethod
    def convert(image, conversionParam, spcificParameters):
        """ 
            This is the API for any other conversion method class
            
            It puts the result side by side image in the Image class given as input
            
            Input:
                - image: object from Image class that contains input and output parameters describing a specific frame
    
                - conversionParam: conversion parameters
                
                - specificParameters: any additional information needed for conversion, \
                    this can be a list of parameters \
                    or can be a class for each conversion method
                
        """
        print("-- BasicConverter.convert")
        pass