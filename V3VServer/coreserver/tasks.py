'''
Created on Aug 19, 2015

@author: qcriadmin
'''
from celery.app import shared_task
import time
from coreserver.communicator.communicationmanager import CommunicationManager

@shared_task
def print_hi(x, provisioned_instance, segment2D, segment3D):
    for i in range(100000000):
        continue
    print(str(x) + "     hiiiiiiiiiiiiiiiiiiiiiiiiiiiiii")

@shared_task
def comm_manager_work(provisioned_instance, segment2D, segment3D):
    # Communicate with the provisioned resources via communication manager  
    comm_manager = CommunicationManager(provisioned_instance, segment2D, segment3D)
    print("comm manager initialized")   
    
    comm_manager.send_start_signal()
    
    print("finished converting")