
class OutputProcessor:
    """
        This is a Library for processing the output file
        
        Now we only have one method for processing the output (processOutput) 
        
        Later on there can be other processing methods implemented
    """
    
    @staticmethod
    def processOutput(video):
        """
            The input is a list of Image objects containing a left and right view and a side by side image
            
            It processes the given list of images converting them to a video of specific format
            and returning the video
        """
        print("-- Output Processor")
        print("1- Process the given list of images converting them to a video of specific format and returning the resulting video")
        return