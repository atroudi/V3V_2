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
    def __init__(self, instances, segment2D):
        '''
        Constructor
        '''
        self.instances=instances
        self.segment2D=segment2D
      
        
    def send_start_signal(self):
        list_status=[]
        for instance in self.instances:
            try:
                ssh=pysftp.Connection(host=instance.ipaddress,username=instance.username,password=instance.password)
                input_path = instance.input_path + "/" +  os.path.basename(self.segment2D.location.__str__())
                output_path = instance.output_path + "/" + self.segment2D.id.__str__() + ".mp4"
                command = 'bash -c ' + '"'  + instance.executable_path + " " + self.segment2D.profile.__str__()  + " " + input_path + " " + output_path + '"'
                print(command)
                list_output = ssh.execute(command)
                for word in list_output:
                    print(word)
                list_status.append(Status.PROCESSING)
            except:
                list_status.append(Status.FAIL)
            #if instance.ipaddress == "127.0.0.1": # localhost
                #subprocess.call("python", self.executable_path,"-i", self.segment2D.location, "-o", self.remote_path , shell=True)  
        return list_status
    
    def check_status(self):
        list_status=[]
        for instance in self.instances:
            #check the status of the running process
            list_status.append(Status.SUCCESS)
        return list_status
    
    def get_converted_segment_path(self):
        list_paths=[]
        for instance in self.instances:
            output_path = instance.output_path + "/" + self.segment2D.id.__str__() + ".mp4"
            remote_path_id=RemotePathIdentifier(instance, output_path)
            list_paths.append(remote_path_id)
        return list_paths
    
    def copy_segment(self):
        for instance in self.instances:
            ssh=pysftp.Connection(host=instance.ipaddress,username=instance.username,password=instance.password)
            ssh.cd(instance.input_path)              # temporarily chdir to public
            ssh.put(self.segment2D.location)  # upload file to remote server