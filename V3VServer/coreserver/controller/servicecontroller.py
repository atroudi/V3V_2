'''
Created on Jun 22, 2015

@author: qcriadmin
'''
import time

from coreserver.resourcemanager.resourcemanager import ResourceManager
from coreserver.communicator.communicationmanager import CommunicationManager, Status, RemotePathIdentifier
from coreserver.models import Conversion_task, Segment3D, Email
from coreserver.utils.emailsender import EmailSender
from threading import Thread
import os
import sys
import pysftp
from multiprocessing.context import Process
from celery.app import shared_task
from coreserver.tasks import print_hi, comm_manager_work


class ServiceController(object):
    '''
    classdocs
    '''
    thread_pool_size=10
    sleep_interval=2 # in seconds
    timeout=5000000;
    status=Status.INITIATED
    
    @classmethod
    def register_conversion_task(cls,segment2D):
        
        # register in the database the new 3D segment and the conversion task that will compute it 
        print("Conversion task launched")
        segment3D_name=segment2D.name + "_3D"
        segment3D=Segment3D.objects.create(name=segment3D_name)
        print("3D Segment created")
        Conversion_task.objects.create(segment2D=segment2D, segment3D=segment3D, status="Initiated")
        print("Conversion record created")
        
        # provision resources via a resource manager 
        deadline = segment2D.duration
        print("deadline=" + deadline.__str__())

        provisioned_instance = ResourceManager.provision_resources(deadline, price=10)
        print("Resources provisioned")
        print("########  Instance involved  #####")
        print("ipaddress=" +  provisioned_instance.ipaddress) 
            
        # calling celery task
        comm_manager_work.delay(provisioned_instance.id, segment2D.id, segment3D.id)
        #comm_manager_work.delay(provisioned_instance, segment2D, segment3D)
            
        print ("------------- uploaded and sent to communication manager")
        
        return

