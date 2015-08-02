from django.test import TestCase
from coreserver.models import Segment2D,Account,Instance,CloudProvider,Segment3D,Conversion_task
from coreserver.controller.servicecontroller import ServiceController
import django
import coreserver
django.setup()
#import datetime
# Create your tests here.
if __name__ == '__main__':
    #segment3D=Segment3D.objects.create(name="aaa")
    #segment3D=Segment3D.objects.get(name="aaa")
    Conversion_task.objects.all().delete()
    segment2D=Segment2D.objects.get(id=1)
    #Conversion_task.objects.create(segment2D=segment2D, segment3D=segment3D, status="Initiated")
    ServiceController().register_conversion_task(segment2D)
    #cloud=CloudProvider.objects.create(name="local")
    #cloud=CloudProvider.objects.get(name="local")
    #instance = Instance.objects.create(ipaddress="127.0.0.1", username="qcriadmin", password="123456", status="RUNNING", cloud_provider=cloud)
    #account = Account.objects.get(pk=1)
    #Segment2D.objects.create(name="segment_0001", account=account, instance=instance)