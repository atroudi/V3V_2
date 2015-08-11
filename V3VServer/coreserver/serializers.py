'''
Created on Jun 22, 2015

@author: qcriadmin
'''

from rest_framework import serializers
from coreserver.models import Segment2D,Account

class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = ('id', 'name', 'password')

class Segment2DSerializer(serializers.ModelSerializer):
    #segment2D=serializers.FileField(required=False) 
    account=AccountSerializer()
    
    class Meta:
        model = Segment2D
        fields = ('name','account')
        
    
    def create(self, validated_data):
        try:
            account = Account.objects.get(name=validated_data['account']['name'], password=validated_data['account']['password'])
        except:
            return None
        segment2D = Segment2D.objects.create(name=validated_data['name'], account=account)
        print("2D Segment created")
        return segment2D
        #return serializers.ModelSerializer.create(self, validated_data)
    
        
        
    