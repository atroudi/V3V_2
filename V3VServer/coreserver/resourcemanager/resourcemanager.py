'''
Created on Jun 22, 2015

@author: qcriadmin
'''
from enum import Enum
from coreserver.models import Instance, CloudProvider
from collections import defaultdict
import coreserver.resourcemanager.meezaprovisioner
class ResourceManager(object):
    ''' It manages system resources and provisions 
    resources that finish the task before a deadline 
    while optimizing some criteria (e.g. cost) 
    '''

    def __init__(self):
        '''
        Constructor
        '''
        pass
    @classmethod
    def check_required_resources(cls, deadline, **kwargs):
        ''' Returns a list of Instance objects (see models) that finish the request in specified deadline
        
        Checks the available resources and chooses the ones that finish the task 
        with minimal price or other criteria
        '''
        return Instance.objects.filter(status="Running").order_by('cloud_provider') #return all the running instances
    
    @classmethod
    def provision_resources(cls, instances):
        if not instances:
            return None
        
        # here we split the query set of instances into a dictionary where 
        # the key is the cloud provider name and the value is list of instances      
        instances_dict = defaultdict(list)
        for instance in instances:
            instances_dict[instance.cloud_provider.name].append(instance)
        
        # we get the module and the class name of the cloud provider registered in the system
        provisioned_instances=[]
        for cloud_provider_name, list_instances in instances_dict.items():
            cloud_provider = CloudProvider.objects.get(name=cloud_provider_name)
            try:
                provisioner_module=globals()[cloud_provider.provisioner_modulename]
            except:
                provisioner_module = __import__(__package__ + "." + cloud_provider.provisioner_modulename, fromlist=[__package__])
            provisioner_class = getattr(provisioner_module, str(cloud_provider.provisioner_classname))
            instances_cloud_provider = provisioner_class.provision(list_instances)
            provisioned_instances = provisioned_instances + instances_cloud_provider
        return provisioned_instances
    
    
    @classmethod
    def deprovision_resources(cls, instances):
        for instance in instances:
            #get the cloud manager and get the provisioner class out of it
            pass
    

    


    

