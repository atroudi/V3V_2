'''
Created on Jun 22, 2015

@author: qcriadmin
'''
from abc import abstractmethod,ABCMeta



class AbstractProvisioner(object):
    '''
    classdocs
    '''
    __metaclass__ = ABCMeta

    @classmethod   
    def provision(cls,instances):
        pass
    
    @classmethod
    def deprovision(cls, instances):
        pass
        