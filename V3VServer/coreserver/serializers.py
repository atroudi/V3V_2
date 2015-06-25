'''
Created on Jun 22, 2015

@author: qcriadmin
'''

from rest_framework import serializers
from coreserver.models import Segment2D,Account

class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = ('id', 'name')

class Segment2DSerializer(serializers.ModelSerializer):
    #segment2D=serializers.FileField(required=False) 
    account=AccountSerializer()
    def create(self, validated_data):
        return serializers.ModelSerializer.create(self, validated_data)
    
    class Meta:
        model = Segment2D
        fields = ('name','account')
    