'''
Created on Jun 22, 2015

@author: qcriadmin
'''
from enum import Enum
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
        pass
    
    @classmethod
    def provision_resources(cls, instances):
        for instance in instances:
            #get the cloud manager and get the provisioner class out of it
            pass
    
    @classmethod
    def deprovision_resources(cls, instances):
        for instance in instances:
            #get the cloud manager and get the provisioner class out of it
            pass
    

    


    

