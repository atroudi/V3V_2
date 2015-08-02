'''
Created on Jun 23, 2015

@author: qcriadmin
'''
import paramiko
import pysftp
import requests
class SimpleClient(object):
    '''
    classdocs
    '''
    import pysftp

    def __init__(self, params):
        '''
        Constructor
        '''
        pass
    
    @classmethod
    def check_status(cls):
        url="http://127.0.0.1:8000/api/segment2D/1"
        response=requests.get(url)
        with open("converted.mp4", 'wb') as f:
            for chunk in response.iter_content():
                f.write(chunk)
#         while 1:
#                 byte=downloaded_file.read(1)
#                 recieved_file.write(byte)
#                 if not byte:
#                     break;
#         recieved_file.close()
        
        
    @classmethod
    def upload_segment(cls):
        files={'file':open('/home/qcriadmin/workspace/V3V/V3VServer/out.mp4','rb')}
        url="http://127.0.0.1:8000/api/segment2D/1/"
        response=requests.put(url,files=files)
        print(response.json())
        
if __name__ == '__main__':
    SimpleClient.check_status()
    #SimpleClient.upload_segment()
#     ssh=pysftp.Connection(host='10.2.0.124',username='qcri',password='1qaz2wsx')
#     file=ssh.open('/home/qcri/hello.txt');
#     for line in file:
#         print(line)
#     x=open('/home/qcriadmin/workspace/V3V/V3VServer/clip.mp4','rb')
#     other=open('/home/qcriadmin/workspace/V3V/V3VServer/shadow.mp4','wb');
#     other.write(x)