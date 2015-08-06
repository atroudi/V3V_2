'''
Created on Jun 22, 2015

@author: qcriadmin
'''
from django.conf.urls import url
from coreserver.views import Segment2DViewSet

segment2D_list = Segment2DViewSet.as_view({
    'post': 'create',
    #'put':'update'
})
segment2D_detail = Segment2DViewSet.as_view({
    'get': 'retrieve',
    'post': 'update'
})


urlpatterns = [
    #url(r'^segment2D/$', views.register_segment2D),
    #url(r'^segment2D/(?P<pk>[0-9]+)/$', views.send_recieve_segment2D),
    url(r'^segment2D/$', segment2D_list),
    url(r'^segment2D/(?P<pk>[0-9]+)/$', segment2D_detail),
]