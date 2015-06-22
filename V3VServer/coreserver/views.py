from django.shortcuts import render

# Create your views here.
from rest_framework import status,viewsets
from rest_framework.decorators import api_view
from rest_framework.response import Response
from coreserver.models import Segment2D,Segment3D
from coreserver.serializers import Segment2DSerializer


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
        segment2D = Segment2D.objects.get(pk=pk)
        serializer = Segment2DSerializer(segment2D, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
    def retrieve(self, request, pk):
        """
        Check the status of the converted segment and download it when ready
        """
        segment2D = Segment2D.objects.get(pk=pk)
        serializer = Segment2DSerializer(segment2D)
        return Response(serializer.data)



