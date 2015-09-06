from DepthDatabase.BasicDepthDatabase import BasicDepthDatabase


class SoccerDepthDatabase(BasicDepthDatabase):
    """
        A child class from BasicDepthDatabase Specific for soccer games
        
        Overriding general methods of computingFeatures to have specific features for this kind of database
        
        for example: in the ImageData class we can have a method called computeFeaturesSoccer specific for soccer databases
        and we use this function instead of the general computeFeatures method
    """
    pass