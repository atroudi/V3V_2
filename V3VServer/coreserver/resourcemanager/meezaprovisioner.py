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
    def provision(cls, deadline, **kwargs):
        pass
    
    @classmethod
    def deprovision(cls, instance):
        instance.status = "Idle"
        instance.save()
        