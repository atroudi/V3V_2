'''
Created on Jun 22, 2015

@author: qcriadmin
'''
from enum import Enum
from coreserver.models import Instance, CloudProvider
from collections import defaultdict
from coreserver.resourcemanager.awsprovisioner import AwsProvisioner
from V3VServer.democonfg import default_instance_resource_fields, default_instance_query

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
    def provision_resources(cls, deadline, **kwargs):
        ''' Returns an instance object (see models) that finish the request in specified deadline
        Checks if the default instance is idle or not, if not it calls the
        aws provisioner to choose the instance that finish the task 
        with minimal price or other criteria
        '''
        
        # first check the default server is busy or not 
        try:   
            default_instance = Instance.objects.get(**default_instance_query).update(**default_instance_resource_fields)
            default_instance.save()
        except:
            default_instance = Instance.objects.create(**default_instance_resource_fields)
        print ("instance fetched successfully!")
        #if default_instance.status=="PROCESSING":
        #   aws_instance = AwsProvisioner.provision(deadline, **kwargs)
        #  return aws_instance
        return default_instance
        
    @classmethod
    def deprovision_resources(cls, instance):
            #get the cloud manager and get the provisioner class out of it
            cloud_provider = CloudProvider.objects.get(id=instance.cloud_provider.id)
            try:
                provisioner_module = globals()[cloud_provider.provisioner_modulename]
            except:
                provisioner_module = __import__(__package__ + "." + cloud_provider.provisioner_modulename, fromlist=[__package__])
            provisioner_class = getattr(provisioner_module, str(cloud_provider.provisioner_classname))
            provisioner_class.deprovision(instance)
    

    


    

