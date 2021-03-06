"""
    V3VServer URL Configuration
    
    The `urlpatterns` list routes URLs to views. For more information please see:
        https://docs.djangoproject.com/en/1.8/topics/http/urls/
    Examples:
    Function views
        1. Add an import:  from my_app import views
        2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
    Class-based views
        1. Add an import:  from other_app.views import Home
        2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
    Including another URLconf
        1. Add an import:  from blog import urls as blog_urls
        2. Add a URL to urlpatterns:  url(r'^blog/', include(blog_urls))
"""
from django.conf.urls import include, url
from django.contrib import admin
from coreserver import views
from rest_framework.urlpatterns import format_suffix_patterns

urlpatterns = [
    url(r'^admin/', include(admin.site.urls)),
    url(r'^api/', include('coreserver.urls')),
    url(r'^docs/', include('rest_framework_swagger.urls')),
    url(r'^$', views.index, name='index'),
    url(r'^statistics', views.get_statistics, name='Get the statistics of the conversion tasks'),
    url(r'^upload_and_convert_segment', views.upload_and_convert_segment, name='Upload segment'),
    url(r'^upload_segment', views.upload_segment, name='Upload segment'),
    url(r'^register_segment', views.register_segment, name='Register segment'),
    url(r'^get_videos_per_day', views.get_videos_per_day, name='Video statistics per day'),
    url(r'^get_users_per_day', views.get_users_per_day, name='users statistics per day'),
    url(r'^get_video_duration_count', views.get_video_duration_count, name='get_video_duration_count'),
]

urlpatterns = format_suffix_patterns(urlpatterns)