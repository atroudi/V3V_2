from Converter.BasicConverter import BasicConverter


class StereoCreator(BasicConverter):
    """
        StereoCreator Converter class, a child from Basic Converter class to handle long shots
    """
    @staticmethod
    def convert(image, conversionParam, spcificParameters=None):
        """ 
            Computes right_view of the SS from left_view by simple shifting
            
            This doesn't need any specific parameters
            
            Assumes that the depth is a ramp, and slants the input image accordingly to generate the right view, \
            The input image is taken as the left view
            
            It changes the leftImage and rightImage and sideBySide variables in the given image Object
        """ 
        print("-- StereoCreator.convert")
        image.leftImage = image.originalImage
        image.rightImage = image.originalImage # should be the original image after slanting
        image.sideBySide = image.originalImage # should be leftImage, rightImage concatenation
        