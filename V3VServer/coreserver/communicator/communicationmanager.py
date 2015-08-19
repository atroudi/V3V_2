'''
Created on Jun 23, 2015

@author: qcriadmin
'''
import os
from enum import Enum
import subprocess

import pysftp
from coreserver.resourcemanager.resourcemanager import ResourceManager
from coreserver.models import Email
from coreserver.utils.emailsender import EmailSender
import time
from coreserver.resourcemanager.meezaprovisioner import MeezaProvisioner

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
    def __init__(self, instance, segment2D, segment3D):
        '''
        Constructor
        '''
        self.instance=instance
        self.segment2D=segment2D
        self.segment3D = segment3D
      
    def send_start_signal(self):
        while 1:
            while self.instance.status == 'PROCESSING':
                # sleep for 1 second till this processing finishes
                print("waiting for resource")
                print ("########" + str(self.instance.status) + str(self.instance.id))

                time.sleep(1)
                
            # possible thread synchronization threats
            if self.instance.status == 'Idle':
                print("got the resource")
                self.instance.status = 'PROCESSING'
                self.instance.save()
                break
                       
        # when the thread takes the processing instance
        self.copy_segment()
        print("segment copied")

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
            
            self.finalize()
        except:
            # send error email
            self.error_email()
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
        
    def finalize(self):
        ResourceManager.deprovision_resources(self.instance)
        print("resources deprovisioned")
        print("######## " + str(self.instance.status) + " " + str(self.instance.id))
        sender = Email.objects.get(active=1)
        sender_address = sender.address
        sender_password = sender.password
        print("sender")
        reciever = self.segment2D.email
        print("reciever")
        
        print("status is Success")
        remote_path_id = self.get_converted_segment_path()
        print("remote_path_instance=" +  remote_path_id.instance.ipaddress  + " ,remote_path_file= " + remote_path_id.file_path) 
        self.segment3D.instance = remote_path_id.instance
        self.segment3D.location = remote_path_id.file_path
        self.segment3D.save()
        text_msg = "Your video has been converted to 3D and it can be downloaded by clicking v3v.qcri.org/api/segment2D/" + self.segment2D.id.__str__()
   
        if reciever:
            EmailSender.send_email(text_msg, sender_address,sender_password, reciever)
            
    def error_email(self):
        sender = Email.objects.get(active=1)
        sender_address = sender.address
        sender_password = sender.password
        reciever = self.segment2D.email;
        text_msg = "Unfortunately, There have been errors so the conversion hasn't finished successfully so, please try again"
        if reciever:
            EmailSender.send_email(text_msg, sender_address,sender_password, reciever)