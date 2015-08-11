import sys
import os
sys.path.append("/home/qcriadmin/workspace/V3V/V3VServer")
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "V3VServer.settings")
import pysftp
from django.test import TestCase
from coreserver.models import Segment2D,Account,Instance,CloudProvider,Segment3D,Conversion_task,Email
from coreserver.controller.servicecontroller import ServiceController
import django
import coreserver
from coreserver.utils.emailsender import EmailSender
from coreserver.views import Segment2DViewSet
from django.core.handlers.wsgi import WSGIRequest
from django.test.client import RequestFactory
from django.http.request import QueryDict
from coreserver import views
import yagmail


django.setup()
#import datetime
# Create your tests here.
if __name__ == '__main__':
#     instance = Instance.objects.get(ipaddress='10.2.0.9')
#     instance.status = "Idle"
#     instance.save()
#     Conversion_task.objects.all().delete()
#     segment2D = Segment2D.objects.get(id=1)
#     ServiceController().register_conversion_task(segment2D)
    #yagmail.register('qcricloud', 'qcrispider')
    #yag = yagmail.Connect('me@gmail.com', password)
    yag = yagmail.SMTP('qcricloud@gmail.com')
    yag.send('qcricloud@gmail.com', subject = None, contents = 'Hello')
    #EmailSender.send_email('hellooooooooooo', 'qcricloud@gmail.com', 'qcrispider', 'tarek.elgamal@gmail.com')
    #Email.objects.create(address='qcricloud@gmail.com',password='qcrispider')
    
#     request = RequestFactory().post('api/segment2D')
#     views.upload_and_convert_segment(request)
#     data = QueryDict('', mutable=True)
#     data['name']="seg"
#     data['account.name']="Live Demo"
#     data['account.password']="demo_123"
#     request.data = data
#     Segment2DViewSet().create(request)  
    
      
    #segment3D=Segment3D.objects.create(name="aaa")
    #segment3D=Segment3D.objects.get(name="aaa")
   
    #Conversion_task.objects.create(segment2D=segment2D, segment3D=segment3D, status="Initiated")
    
    #cloud=CloudProvider.objects.create(name="local")
    #cloud=CloudProvider.objects.get(name="local")
    #instance = Instance.objects.create(ipaddress="127.0.0.1", username="qcriadmin", password="123456", status="RUNNING", cloud_provider=cloud)
    #account = Account.objects.get(pk=1)
    #Segment2D.objects.create(name="segment_0001", account=account, instance=instance)
    
#     ssh=pysftp.Connection(host='10.2.0.9',username='QCRI\kcalagari',password='Kcal@1367')
#     ssh.cd('/home/local/QCRI/kcalagari')              # temporarily chdir to public
#     ssh.put('/home/qcriadmin/workspace/V3V/V3VServer/input_segments/1.mp4')