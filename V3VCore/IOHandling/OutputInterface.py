
class OutputInterface:
    """
        This is a Library for interfacing output files
        It should save the output file to different sources 
        as: storage_disk, memory, wireless network, internet, ....
        
        Now this class should implement the basic source which is saving videos
        to the disk to specific output file path
        
        Later on this class can be expanded to other sources
        by adding more methods and calling the appropriate input interface
    """
    
    @staticmethod
    def saveToDisk(outputFilePath):
        """
            Save the video to disk to the given outputFilePath
        """
        print("-- Output Interface")
        print("1- Save the video to disk to the given outputFilePath")
        return