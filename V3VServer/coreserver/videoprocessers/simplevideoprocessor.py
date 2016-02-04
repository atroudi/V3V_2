'''
Created on Jun 24, 2015

@author: qcriadmin
'''

import subprocess
import re

class SimpleVideoProcessor(object):
    '''
    Gets the metadata from the video
    '''


    def __init__(self, params):
        '''
        Constructor
        '''
        pass
    
    @classmethod
    def update_meta_data(cls, video_path, segment2D):
        '''
        Gets the duration resolution and other video related meta data
        '''
        duration = cls.get_video_duration(video_path)
        if duration:
            segment2D.duration = duration
        return segment2D
    
    @classmethod
    def get_video_duration(cls, video_path):
        # run bash script
        result = subprocess.Popen(["ffprobe", video_path], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        # stdout of the script
        out = result.communicate()[0]
        re_compiler = re.compile(r'Duration: (\d*):(\d*):(\d*)')
        re_mathcer = re_compiler.search(str(out))
        if re_mathcer:
            print(re_mathcer.group())
            duration = int(re_mathcer.group(1)) * 60 * 60 # hours
            duration += int(re_mathcer.group(2)) * 60 # minutes 
            duration += int(re_mathcer.group(3)) # seconds
            return duration 
        
