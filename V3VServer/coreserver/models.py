from django.db import models


class Account(models.Model):
    created = models.DateTimeField(auto_now_add=True, null=False)
    name=models.CharField(max_length=255, null=False)
    license_type=models.CharField(max_length=255)
    description=models.TextField()
        
class Segment2D(models.Model):
    created = models.DateTimeField(auto_now_add=True, null=False)
    name=models.CharField(max_length=255, null=False)
    category=models.CharField(max_length=255)
    duration=models.IntegerField()
    frame_rate=models.IntegerField()
    location=models.CharField(max_length=255)
    resolution=models.CharField(max_length=255)
    url=models.CharField(max_length=255)
    upload_date=models.DateTimeField()
    ####Relationships####
    account=models.ForeignKey(Account)
    
class Segment3D(models.Model):
    created = models.DateTimeField(auto_now_add=True, null=False)
    name=models.CharField(max_length=255, null=False)
    category=models.CharField(max_length=255)
    duration=models.IntegerField()
    frame_rate=models.IntegerField()
    location=models.CharField(max_length=255)
    resolution=models.CharField(max_length=255)
    url=models.CharField(max_length=255)
    upload_date=models.DateTimeField()

class Conversion(models.Model):
    created=models.DateTimeField(auto_now_add=True)
    status=models.CharField(max_length=255, null=False)
    description=models.TextField()
    exec_started=models.DateTimeField()
    exec_ended=models.DateTimeField()
    instances=models.TextField() #comma separated
    ####Relationships####
    segment2D=models.OneToOneField(Segment2D)
    segment2D=models.OneToOneField(Segment3D)
    
class Conversion_setting(models.Model):
    created = models.DateTimeField(auto_now_add=True)
    name=models.CharField(max_length=255, null=False)
    value=models.CharField(max_length=255)
    description=models.TextField()
    ####Relationships####
    conversion=models.ForeignKey(Conversion)
    
class Component(models.Model):
    created = models.DateTimeField(auto_now_add=True)
    name=models.CharField(max_length=255, null=False)
    alias=models.CharField(max_length=255)
    
    
class Setting(models.Model):
    created = models.DateTimeField(auto_now_add=True)
    name=models.CharField(max_length=255, null=False)
    value=models.CharField(max_length=255)
    description=models.TextField()
    ####Relationships####
    component=models.ForeignKey(Component)
