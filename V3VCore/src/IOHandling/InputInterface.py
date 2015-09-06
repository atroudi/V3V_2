
class InputInterface:
    """
        This is a library for interfacing input files
        It should load the input file from different sources 
        as: storage_disk, memory, wireless network, internet, ....
        
        Now this class should implement the basic source which is loading videos
        from the disk from specific input file path
        
        Later on this class can be expanded to other sources
        by adding more methods and calling the appropriate input interface
    """
    
    @staticmethod
    def loadFromDisk(inputFilePath):
        """
            load the video from disk from the given inputFilePath
        """
        print("-- Input interface")
        print("1- Read the video from disk from the given inputFilePath and returning the video read")
        return []