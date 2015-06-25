from django.db import models
from django.db.models.fields.related import ForeignKey

class CloudProvider(models.Model):
    id=models.AutoField(primary_key=True)
    name=models.CharField(max_length=255, null=False)
    provisioner_modulename=models.CharField(max_length=255)
    provisioner_classname=models.CharField(max_length=255)
    class Meta:
        db_table = "cloudprovider"
    
class Instance(models.Model):
    id = models.AutoField(primary_key=True)
    ipaddress = models.CharField(max_length=255, null=False)
    dns = models.CharField(max_length=255)
    username=models.CharField(max_length=255)
    password=models.CharField(max_length=255)
    port=models.IntegerField(default=22)
    ssh_key=models.CharField(max_length=255)
    number_of_cpus = models.IntegerField(default=0)
    number_of_cores_percpu = models.IntegerField(default=0)
    aggregate_memory = models.IntegerField(default=0)
    speed_per_core = models.IntegerField(default=0)
    price = models.IntegerField(default=0)
    status = models.CharField(max_length=255) #running, stopped, terminated
    cloud_provider = models.ForeignKey(CloudProvider)
    class Meta:
        db_table = "instance"

class Account(models.Model):
    id = models.AutoField(primary_key=True)
    created = models.DateTimeField(auto_now_add=True, null=False)
    name=models.CharField(max_length=255, null=False)
    license_type=models.CharField(max_length=255)
    description=models.TextField()
    class Meta:
        db_table = "account"
        
class Segment2D(models.Model):
    id=models.AutoField(primary_key=True)
    created = models.DateTimeField(auto_now_add=True, null=False)
    name=models.CharField(max_length=255, null=False)
    category=models.CharField(max_length=255, null=True)
    duration=models.IntegerField(null=True)
    frame_rate=models.IntegerField(null=True)
    location=models.CharField(max_length=255)
    resolution=models.CharField(max_length=255)
    url=models.CharField(max_length=255)
    upload_date=models.DateTimeField(null=True)
    # Relationships
    account=models.ForeignKey(Account)
    instance=ForeignKey(Instance)
    class Meta:
        db_table = "segment2D"
        
class Segment3D(models.Model):
    id=models.AutoField(primary_key=True)
    created = models.DateTimeField(auto_now_add=True, null=False)
    name=models.CharField(max_length=255, null=False)
    category=models.CharField(max_length=255)
    duration=models.IntegerField()
    frame_rate=models.IntegerField()
    location=models.CharField(max_length=255)
    resolution=models.CharField(max_length=255)
    url=models.CharField(max_length=255)
    upload_date=models.DateTimeField()
    # Relationships
    instance=ForeignKey(Instance)
    class Meta:
        db_table = "segment3D"
    
class Conversion(models.Model):
    id=models.AutoField(primary_key=True)
    created=models.DateTimeField(auto_now_add=True)
    status=models.CharField(max_length=255, null=False)
    description=models.TextField()
    exec_started=models.DateTimeField()
    exec_ended=models.DateTimeField()
    # Relationships
    instances=models.ManyToManyField(Instance)
    segment2D=models.OneToOneField(Segment2D)
    segment2D=models.OneToOneField(Segment3D)
    class Meta:
        db_table = "conversion"
    
class Conversion_setting(models.Model):
    id=models.AutoField(primary_key=True)
    created = models.DateTimeField(auto_now_add=True)
    name=models.CharField(max_length=255, null=False)
    value=models.CharField(max_length=255)
    description=models.TextField()
    # Relationships
    conversion=models.ForeignKey(Conversion)
    class Meta:
        db_table = "conversion_setting"
    
# class Component(models.Model):
#     id=models.AutoField(primary_key=True)
#     created = models.DateTimeField(auto_now_add=True)
#     name=models.CharField(max_length=255, null=False)
#     alias=models.CharField(max_length=255)
#     
#     
# class Setting(models.Model):
#     id=models.AutoField(primary_key=True)
#     created = models.DateTimeField(auto_now_add=True)
#     name=models.CharField(max_length=255, null=False)
#     value=models.CharField(max_length=255)
#     description=models.TextField()
#     ####Relationships####
#     component=models.ForeignKey(Component)
    


