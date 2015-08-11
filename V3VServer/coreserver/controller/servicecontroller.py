'''
Created on Jun 22, 2015

@author: qcriadmin
'''
import time

from coreserver.resourcemanager.resourcemanager import ResourceManager
from coreserver.communicator.communicationmanager import CommunicationManager, Status, RemotePathIdentifier
from coreserver.models import Conversion_task, Segment3D, Email
from coreserver.utils.emailsender import EmailSender


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
        
        # Communicate with the provisioned resources via communication manager  
        comm_manager = CommunicationManager(provisioned_instance, segment2D)
        print("comm manager initialized")
        comm_manager.copy_segment()
        print("segment copied")
        cls.status = comm_manager.send_start_signal()
        
        ResourceManager.deprovision_resources(provisioned_instance)
        print("resources deprovisioned")
        sender = Email.objects.get(active=1)
        sender_address = sender.address
        sender_password = sender.password
        reciever = segment2D.email;
        if cls.status == Status.SUCCESS:
            print("status is Success")
            remote_path_id = comm_manager.get_converted_segment_path()
            print("remote_path_instance=" +  remote_path_id.instance.ipaddress  + " ,remote_path_file= " + remote_path_id.file_path) 
            segment3D.instance = remote_path_id.instance
            segment3D.location = remote_path_id.file_path
            segment3D.save()
            text_msg="Segment " + segment2D.id.__str__() + " has been converted to 3D and it can be downloaded by clicking v3v.qcri.org:8000/api/segment2D/" + segment2D.id.__str__()
            EmailSender.send_email(text_msg, sender_address,sender_password, reciever)
        elif cls.status == Status.PROCESSING:
            text_msg='Segment processing failed, timeout error'
            EmailSender.send_email(text_msg, sender_address,sender_password, reciever)            
            raise TimeoutError
        elif cls.status == Status.FAIL:
            text_msg='Segment processing failed, process failed'
            EmailSender.send_email(text_msg, sender_address,sender_password, reciever)
            raise Exception
        
        
        