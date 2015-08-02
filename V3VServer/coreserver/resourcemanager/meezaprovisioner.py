'''
Created on Jul 29, 2015

@author: qcriadmin
'''
from coreserver.resourcemanager.provisioner import AbstractProvisioner

class MeezaProvisioner(AbstractProvisioner):
    '''
    Provisioner for the Meeza cluster
    '''
    @classmethod
    def provision(cls,instances):
        for instance in instances:
            # do some checks that the code is there,
            # otherwise copy the code to the remote server
            pass
        return instances
    
    @classmethod
    def deprovision(cls,instances):
        pass
        