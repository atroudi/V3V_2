'''
Created on Jun 23, 2015

@author: qcriadmin
'''
from enum import Enum
import subprocess

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


    def __init__(self, instances, segment2D):
        '''
        Constructor
        '''
        self.instances=instances
        self.segment2D=segment2D
        self.executable_path="/home/qcriadmin/workspace/V3V/V3VCore/engine/conversionengine.py"
        self.remote_path="output_segments/" + segment2D.id.__str__() + ".mp4"
        
    def send_start_signal(self):
        for instance in self.instances:
            if instance.ipaddress == "127.0.0.1": # localhost
                subprocess.call("python", self.executable_path,"-i", self.segment2D.location, "-o", self.remote_path , shell=True)  
        return Status.PROCESSING
    
    def check_status(self):
        return Status.SUCCESS
    
    def get_converted_segment_path(self):
        return self.remote_path
    
