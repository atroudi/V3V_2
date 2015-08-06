'''
Created on Jun 23, 2015

@author: qcriadmin
'''
import os
from enum import Enum
import subprocess

import pysftp

class Status(Enum):
    INITIATED=1
    PROCESSING=2
    SUCCESS=3
    FAIL=4
    

class RemotePathIdentifier(object):
    instance=object
    file_path=""
    
    def __init__(self, instance, file_path):
        self.instance = instance
        self.file_path = file_path
        
class CommunicationManager(object):
    '''
    classdocs
    '''
    def __init__(self, instance, segment2D):
        '''
        Constructor
        '''
        self.instance=instance
        self.segment2D=segment2D
      
        
    def send_start_signal(self):
        try:
            ssh=pysftp.Connection(host=self.instance.ipaddress,username=self.instance.username,password=self.instance.password)
            input_path = self.instance.input_path + "/" +  os.path.basename(self.segment2D.location.__str__())
            output_path = self.instance.output_path + "/" + self.segment2D.id.__str__() + ".mp4"
            self.instance.status = 'PROCESSING'
            self.instance.save()
            command = 'bash -c ' + '"'  + self.instance.executable_path + " " + self.segment2D.profile.__str__()  + " " + input_path + " " + output_path + '"'
            print(command)
            list_output = ssh.execute(command)
            for word in list_output:
                print(word)
            return Status.SUCCESS
        except:
            return Status.FAIL
            #if instance.ipaddress == "127.0.0.1": # localhost
                #subprocess.call("python", self.executable_path,"-i", self.segment2D.location, "-o", self.remote_path , shell=True)      
    def check_status(self):
        return Status.SUCCESS
    
    def get_converted_segment_path(self):
        output_path = self.instance.output_path + "/" + self.segment2D.id.__str__() + ".mp4"
        remote_path_id=RemotePathIdentifier(self.instance, output_path)
        return remote_path_id
    
    def copy_segment(self):
        ssh=pysftp.Connection(host=self.instance.ipaddress,username=self.instance.username,password=self.instance.password)
        ssh.cd(self.instance.input_path)  # temporarily chdir to public
        ssh.put(self.segment2D.location)  # upload file to remote server