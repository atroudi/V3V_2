'''
Created on Jun 22, 2015

@author: qcriadmin
'''
import time

from coreserver.resourcemanager.resourcemanager import ResourceManager
from coreserver.communicator.communicationmanager import CommunicationManager, Status, RemotePathIdentifier
from coreserver.models import Conversion,Segment3D 


class ServiceController(object):
    '''
    classdocs
    '''
    thread_pool_size=10
    sleep_interval=2 # in seconds
    timeout=5000000;
    
    def __init__(self):
        '''
        Constructor
        '''
        pass
    def register_conversion_task(self,segment2D):
        
        # register in the database the new 3D segment and the conversion task that will compute it 
        segment3D=Segment3D.objects.create(name=segment2D.name + "_3D")
        Conversion.objects.create(segment2D=segment2D, segment3D=segment3D, status="Initiated")
        
        # provision resources via a resourcemanager 
        deadline = segment2D.duration
        instances = ResourceManager.check_required_resources(deadline, price=10)
        provisioned_instances = ResourceManager.provision_resources(instances)
        
        # Communicate with the provisioned resources via communicationmanager  
        comm_manager = CommunicationManager(provisioned_instances)
        status = comm_manager.send_start_signal()
        time_now = time.process_time()
        while status == Status.PROCESSING:
            time.sleep(self.sleep_interval)
            status = comm_manager.check_status()
            elapsed_time = time.process_time() - time_now
            if elapsed_time >= self.timeout:
                break;
       
        ResourceManager.deprovision_resources(instances)
        if status == status.SUCCESS:
            remote_path_identifier = comm_manager.get_converted_segment_path()
            segment3D.instance = remote_path_identifier.Instance
            segment3D.location = remote_path_identifier.file_path
            segment3D.save()
            
        elif status == Status.PROCESSING:
            raise TimeoutError
        elif status == Status.FAIL:
            raise Exception
        
        
        