# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Account',
            fields=[
                ('id', models.AutoField(serialize=False, primary_key=True)),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('name', models.CharField(max_length=255)),
                ('license_type', models.CharField(max_length=255)),
                ('description', models.TextField()),
            ],
            options={
                'db_table': 'account',
            },
        ),
        migrations.CreateModel(
            name='CloudProvider',
            fields=[
                ('id', models.AutoField(serialize=False, primary_key=True)),
                ('name', models.CharField(max_length=255)),
                ('provisioner_modulename', models.CharField(max_length=255)),
                ('provisioner_classname', models.CharField(max_length=255)),
            ],
            options={
                'db_table': 'cloudprovider',
            },
        ),
        migrations.CreateModel(
            name='Conversion',
            fields=[
                ('id', models.AutoField(serialize=False, primary_key=True)),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('status', models.CharField(max_length=255)),
                ('description', models.TextField()),
                ('exec_started', models.DateTimeField()),
                ('exec_ended', models.DateTimeField()),
            ],
            options={
                'db_table': 'conversion',
            },
        ),
        migrations.CreateModel(
            name='Conversion_setting',
            fields=[
                ('id', models.AutoField(serialize=False, primary_key=True)),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('name', models.CharField(max_length=255)),
                ('value', models.CharField(max_length=255)),
                ('description', models.TextField()),
                ('conversion', models.ForeignKey(to='coreserver.Conversion')),
            ],
            options={
                'db_table': 'conversion_setting',
            },
        ),
        migrations.CreateModel(
            name='Instance',
            fields=[
                ('id', models.AutoField(serialize=False, primary_key=True)),
                ('ipaddress', models.CharField(max_length=255)),
                ('dns', models.CharField(max_length=255)),
                ('username', models.CharField(max_length=255)),
                ('password', models.CharField(max_length=255)),
                ('port', models.IntegerField(default=22)),
                ('ssh_key', models.CharField(max_length=255)),
                ('number_of_cpus', models.IntegerField(default=0)),
                ('number_of_cores_percpu', models.IntegerField(default=0)),
                ('aggregate_memory', models.IntegerField(default=0)),
                ('speed_per_core', models.IntegerField(default=0)),
                ('price', models.IntegerField(default=0)),
                ('status', models.CharField(max_length=255)),
                ('cloud_provider', models.ForeignKey(to='coreserver.CloudProvider')),
            ],
            options={
                'db_table': 'instance',
            },
        ),
        migrations.CreateModel(
            name='Segment2D',
            fields=[
                ('id', models.AutoField(serialize=False, primary_key=True)),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('name', models.CharField(max_length=255)),
                ('category', models.CharField(max_length=255, null=True)),
                ('duration', models.IntegerField(null=True)),
                ('frame_rate', models.IntegerField(null=True)),
                ('location', models.CharField(max_length=255)),
                ('resolution', models.CharField(max_length=255)),
                ('url', models.CharField(max_length=255)),
                ('upload_date', models.DateTimeField(null=True)),
                ('account', models.ForeignKey(to='coreserver.Account')),
                ('instance', models.ForeignKey(to='coreserver.Instance')),
            ],
            options={
                'db_table': 'segment2D',
            },
        ),
        migrations.CreateModel(
            name='Segment3D',
            fields=[
                ('id', models.AutoField(serialize=False, primary_key=True)),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('name', models.CharField(max_length=255)),
                ('category', models.CharField(max_length=255)),
                ('duration', models.IntegerField()),
                ('frame_rate', models.IntegerField()),
                ('location', models.CharField(max_length=255)),
                ('resolution', models.CharField(max_length=255)),
                ('url', models.CharField(max_length=255)),
                ('upload_date', models.DateTimeField()),
                ('instance', models.ForeignKey(to='coreserver.Instance')),
            ],
            options={
                'db_table': 'segment3D',
            },
        ),
        migrations.AddField(
            model_name='conversion',
            name='instances',
            field=models.ManyToManyField(to='coreserver.Instance'),
        ),
        migrations.AddField(
            model_name='conversion',
            name='segment2D',
            field=models.OneToOneField(to='coreserver.Segment2D'),
        ),
        migrations.AddField(
            model_name='conversion',
            name='segment3D',
            field=models.OneToOneField(to='coreserver.Segment3D'),
        ),
    ]
