import mimetypes
import os
from threading import Thread
import datetime

import pysftp
from ipware.ip import get_ip
from rest_framework import status,viewsets
from rest_framework.response import Response
from django.http.response import HttpResponse
from django.core.servers.basehttp import FileWrapper
from django.views.decorators.csrf import csrf_exempt
from django.template import RequestContext, loader
from django.shortcuts import render_to_response, render

from coreserver.models import Segment2D,Segment3D,Instance,Conversion_task
from coreserver.serializers import Segment2DSerializer
from coreserver.controller.servicecontroller import ServiceController
from coreserver.videoprocessers.simplevideoprocessor import SimpleVideoProcessor
from django.http.request import QueryDict
from rest_framework.decorators import renderer_classes
from rest_framework.renderers import TemplateHTMLRenderer

import traceback

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
        print(request.data)
        serializer = Segment2DSerializer(data=request.data)
        print("serializer created")
        if serializer.is_valid():
            print("serializer is valid")
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def update(self, request, pk):
        """
        Upload a new 2D Segment
        """
        print('Entered Update')
        try:
            segment2D = Segment2D.objects.get(pk=pk)
        except:
            return Response(status=status.HTTP_404_NOT_FOUND) #segment ID not found
        try:
            inp_file = request.FILES['file_source']#request.data['file']
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
            #ServiceController.register_conversion_task(segment2D)
            t = Thread(target=ServiceController.register_conversion_task, args=(segment2D,))
            t.start()
            return Response(status=status.HTTP_202_ACCEPTED)
        except:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        
    def retrieve(self, request, pk):
        """
        Check the status of the converted segment and download it when ready
        """
        print("Entered retrieve")
        try:
            segment2D = Segment2D.objects.get(pk=pk)
        except:
            print("Error: HTTP_404_NOT_FOUND")
            return Response(status=status.HTTP_404_NOT_FOUND) #segment ID not found
        try:
            segment3D = Conversion_task.objects.get(segment2D=segment2D).segment3D
            if(segment2D.instance and segment2D.location):
                instance = segment3D.instance
                file_path = segment3D.location
                ssh=pysftp.Connection(host=instance.ipaddress,username=instance.username,password=instance.password)
                print ("opening path:"+file_path)
                file=ssh.open(file_path);
                response = HttpResponse(FileWrapper(file), content_type=mimetypes.guess_type(file_path)[0])
                response['Content-Disposition'] = "attachment; filename=%s" % os.path.basename(file_path)
                return response
            else:
                print("HTTP_100_CONTINUE")
                return Response(status=status.HTTP_100_CONTINUE) # segment not yet converted
        except:
            print("HTTP_400_BAD_REQUEST")
            traceback.print_exc()
            return Response(status=status.HTTP_400_BAD_REQUEST)


### GUI related
@csrf_exempt
def index(request):
    statiscs_context = calculate_statistics()
    context = RequestContext(request, statiscs_context)
    return render_to_response('coreserver/hazem.html', context)
    # return render_to_response('coreserver/v3v_demo.html', context)

@csrf_exempt
def upload_segment(request):
    """
       Calls the rest request (update) that does the uploading and the conversion
       and it returns a message to the GUI
    """
    segment_id=request.POST['segment_id']
    Segment2DViewSet().update(request, segment_id)
    context_dict=dict()
    template = loader.get_template('coreserver/v3v_home.html')
    message="Segment " + segment_id.__str__() + " has been submitted and you will recieve an email on your registered email once the conversion is done" 
    context_dict["notification"] = message
    context_dict["url"] = 'api/segment2D/' + segment_id.__str__()
    context_dict["finished"] = True
    context = RequestContext(request, context_dict )     
    return HttpResponse(template.render(context));

def register_segment(request):
    pass
##################################Demo Part################################
@csrf_exempt
def get_statistics(request):
    pass

@csrf_exempt
@renderer_classes((TemplateHTMLRenderer,))
def upload_and_convert_segment(request):
        """
        Upload a new 2D Segment for the demo
        """
        print('Entered Demo Upload and convert')
        
        # adding a new 2D segment 
        print(request.POST['email'])
        data = QueryDict('', mutable=True)
        data['name'] = datetime.datetime.now().strftime('%s')
        data['account.name'] = "Live Demo"
        data['account.password'] = "demo_123"
        request.data = data
        response = Segment2DViewSet().create(request)
        
        # preparing the options that can be sent as conversion result 
        context_dict=dict()
        context_dict.update(calculate_statistics())
        template = loader.get_template('coreserver/hazem.html')
        message_fail = "*** Problem happened while converting the segment, please try again after few minutes."
        message_success = '*** Your video has been uploaded successfully and we will send the converted 3D video to your email when it is ready,\n Thanks for using our 2D-3D Conversion Service'
        context_dict["finished"] = True   
        
        if response.status_code != 201:
            print("Something wrong happened with the creation")
            context_dict["notification"] = message_fail
            context = RequestContext(request, context_dict )
            return HttpResponse(template.render(context));
        else:
            try:
                segment_name = data['name']
                email_to_notify = request.POST['email']
                ipaddress = get_ip(request)
                segment2D = Segment2D.objects.get(name=segment_name)
                segment2D.email = email_to_notify
                segment2D.ipaddress = ipaddress
                segment2D.save()
                
            except:
                context_dict["notification"] = message_fail
                context = RequestContext(request, context_dict )
                return HttpResponse(template.render(context));
            try:
                print("before reading inputfile")
                inp_file = request.FILES['file_source']#request.data['file']
                print("pass")
                print("input file=" + inp_file.__str__())
                filename_tokens = inp_file.__str__().split('.')
                if len(filename_tokens) <= 1: #no extension in the file name
                    extension=""
                else:
                    print("valid file")
                    extension = filename_tokens[len(filename_tokens)-1]
                new_file_path = "/home/qcriadmin/workspace/V3V/V3VServer/input_segments/"+ segment2D.id.__str__() + "." + extension 
                # TODO extension should not hardcoded
                print("before opening file to write")
                new_file = open(new_file_path,"wb")
                print("starting writing")
                # download the binary file sent in the request
                """while 1:
                    byte = inp_file.read(1)
                    new_file.write(byte)
                    if not byte:
                        break;"""
                for chunk in inp_file.chunks():
                    new_file.write(chunk)
                    
                new_file.close()
                print("file uploaded")
                
                localhost_instance = Instance.objects.get(ipaddress="127.0.0.1")
                segment2D.instance = localhost_instance
                segment2D.location = new_file_path
                  
                ## TODO
                # get the met data of the video from the video container
                segment2D = SimpleVideoProcessor.update_meta_data(new_file_path, segment2D)
                segment2D.save()
                                  
                # register a conversion task in the system to be discovered by execution thread
                ServiceController.register_conversion_task(segment2D)
                print("#### returned ###")
                
                # display "uploading finished" on the webpage
                context_dict["notification"] = message_success
                context = RequestContext(request, context_dict)
                print("#### returned 222 ###")
                return HttpResponse(template.render(context));
                    
            except:
                traceback.print_exc()
                context_dict["notification"] = message_fail
                context = RequestContext(request, context_dict )
                return HttpResponse(template.render(context));

def calculate_statistics():
    context = dict()
    print("adding statistics:")
    context['has_statistics'] = True
    context['videos'] = str(Segment3D.objects.count())
    print("number of videos:"+context['videos'])
    context['users'] = str(10)
    print("number of videos:" + context['users'])
    return context
    