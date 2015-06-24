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

    def __init__(self, params):
        '''
        Constructor
        '''
    
    def provision(self,instances):
        pass
    
    
    def deprovision(self, instances):
        pass
        