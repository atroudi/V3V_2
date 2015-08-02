import mimetypes
import os
import pysftp

from rest_framework import status,viewsets
from rest_framework.response import Response
from django.http.response import HttpResponse
from django.core.servers.basehttp import FileWrapper

from coreserver.models import Segment2D,Segment3D,Instance,Conversion_task
from coreserver.serializers import Segment2DSerializer
from coreserver.controller.servicecontroller import ServiceController
from coreserver.videoprocessers.simplevideoprocessor import SimpleVideoProcessor

class Segment2DViewSet(viewsets.ModelViewSet):
    """
    Segment2D resource.
    """
    serializer_class = Segment2DSerializer
    model = Segment2D
    queryset = Segment2D.objects.all()

    def create(self, request, *args, **kwargs):
        """
        Register a new 2D Segment
        """
        serializer = Segment2DSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def update(self, request, pk):
        """
        Upload a new 2D Segment
        """
        try:
            segment2D = Segment2D.objects.get(pk=pk)
        except:
            return Response(status=status.HTTP_404_NOT_FOUND) #segment ID not found
        try:
            inp_file = request.data['file']
            filename_tokens = inp_file.__str__().split('.')
            if len(filename_tokens) <= 1: #no extension in the file name
                extension=""
            else:
                extension = filename_tokens[len(filename_tokens)-1]
            new_file_path = "/home/qcriadmin/workspace/V3V/V3VServer/input_segments/"+ pk.__str__() + "." + extension #TODO extension should not hardcoded
            new_file = open(new_file_path,"wb")
            # download the binary file sent in the request
            while 1:
                byte = inp_file.read(1)
                new_file.write(byte)
                if not byte:
                    break;
            new_file.close()
            localhost_instance = Instance.objects.get(ipaddress="127.0.0.1")
            segment2D.instance = localhost_instance
            segment2D.location = new_file_path
            
            ## TODO
            # get the met data of the video from the video container
            segment2D = SimpleVideoProcessor.update_meta_data(new_file_path, segment2D)
            segment2D.save()
            
            # register a conversion task in the system to be discovered by execution thread
            ServiceController.register_conversion_task(self, segment2D)
            return Response(status=status.HTTP_202_ACCEPTED)
        except:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        
    def retrieve(self, request, pk):
        """
        Check the status of the converted segment and download it when ready
        """
        try:
            segment2D = Segment2D.objects.get(pk=pk)
        except:
            return Response(status=status.HTTP_404_NOT_FOUND) #segment ID not found
        try:
            segment3D = Conversion_task.objects.get(segment2D=segment2D).segment3D
            if(segment2D.instance and segment2D.location):
                instance = segment3D.instance
                file_path = segment3D.location
                ssh=pysftp.Connection(host=instance.ipaddress,username=instance.username,password=instance.password)
                file=ssh.open(file_path);
                response = HttpResponse(FileWrapper(file), content_type=mimetypes.guess_type(file_path)[0])
                response['Content-Disposition'] = "attachment; filename=%s" % os.path.basename(file_path)
                return response
            else:
                return Response(status=status.HTTP_100_CONTINUE) # segment not yet converted
        except:
            return Response(status=status.HTTP_400_BAD_REQUEST)
       
