'''
Created on Jun 22, 2015

@author: qcriadmin
'''

class DiscoveryEngine(object):
    '''
    classdocs
    '''
    DISCOVERY_INTERVAL_SECONDS = "discovery.interval.seconds";
    OPERATION_EXPIRY_SECONDS = "operation.expiry.seconds";
    SHUTDOWN_TIMEOUT_SECONDS = "shutdown.timeout.seconds";

    def __init__(self, params):
        '''
        Constructor
        '''
        
    
    def start(self):
        '''
        Start the an engine thread that discovers new conversion records
        that has been added to the database and continues to call the 
        core conversion engine to do the 2D-3D conversion task
        '''
        