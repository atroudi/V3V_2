'''
Created on Jun 23, 2015

@author: qcriadmin
'''
from enum import Enum

class Status(Enum):
    PROCESSING=1
    SUCCESS=2
    FAIL=3

class RemotePathIdentifier(object):
    instance=object
    file_path=""

class CommunicationManager(object):
    '''
    classdocs
    '''


    def __init__(self, instances):
        '''
        Constructor
        '''
        self.instances=instances

    def send_start_signal(self):
        # call the conversion engine
        return Status.PROCESSING
    
    def check_status(self):
        return Status.SUCCESS
    
    def get_converted_segment_path(self):
        pass
    
