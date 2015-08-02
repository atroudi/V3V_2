'''
Created on Jun 22, 2015

@author: qcriadmin
'''
import time

from coreserver.resourcemanager.resourcemanager import ResourceManager
from coreserver.communicator.communicationmanager import CommunicationManager, Status, RemotePathIdentifier
from coreserver.models import Conversion_task,Segment3D 


class ServiceController(object):
    '''
    classdocs
    '''
    thread_pool_size=10
    sleep_interval=2 # in seconds
    timeout=5000000;
    status=Status.INITIATED
    
    def __init__(self):
        '''
        Constructor
        '''
        pass
    def register_conversion_task(self,segment2D):
        
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
        instances = ResourceManager.check_required_resources(deadline, price=10)
        print("Resources checked")
        print("########  Instances involved  #####")
        for instance in instances:
            print("ipaddress=" +  instance.ipaddress)
        provisioned_instances = ResourceManager.provision_resources(instances)
        print("resources provisioned")
        
        # Communicate with the provisioned resources via communication manager  
        comm_manager = CommunicationManager(provisioned_instances, segment2D)
        print("comm manager initialized")
        comm_manager.copy_segment()
        print("segment copied")
        list_status = comm_manager.send_start_signal()
        self.status=Status.PROCESSING
        print("start signal called, " + "status=" + self.status.__str__())
        
        ###check the status
        time_now = time.process_time()   
        while self.status == Status.PROCESSING:
            time.sleep(self.sleep_interval)
            list_status = comm_manager.check_status()
            if all(status == Status.SUCCESS for status in list_status):
                self.status= Status.SUCCESS
            elif all(status == Status.FAIL for status in list_status):
                self.status= Status.FAIL
            elapsed_time = time.process_time() - time_now
            if elapsed_time >= self.timeout:
                break;
       
        ResourceManager.deprovision_resources(instances)
        if self.status == Status.SUCCESS:
            list_remote_path_identifiers = comm_manager.get_converted_segment_path()
            for remote_path_id in list_remote_path_identifiers:
                segment3D.instance = remote_path_id.instance
                segment3D.location = remote_path_id.file_path
                segment3D.save()
        elif self.status == Status.PROCESSING:
            raise TimeoutError
        elif self.status == Status.FAIL:
            raise Exception
        
        
        