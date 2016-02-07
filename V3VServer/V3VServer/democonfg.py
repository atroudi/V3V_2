'''
Created on Feb 7, 2016

@author: hazemsamir
'''


'''
These are demo configurations and should not be used in production
'''

#list of e-mails to send debugging mails to
v3vteam_emails = [
    ("hazem.s.ashmawy@gmail.com", True), 
    ("mhefeeda@qf.org.qa", False), 
    ("atroudi@qf.org.qa", False)
    ]

# this part for easily update database -- for developing only 
# this part assumes using one default resource only

# field by which the instance queried from the database
default_instance_query = dict(id=3)
# instance model fields used to update every time query made 
default_instance_resource_fields = dict(
    ip = '10.2.0.9', 
    username = 'qcri\\kcalagari', 
    password = 'Qatar123',  
    port = 22,  
    executable_path = '/export/ds/KianaCalagari/Fast2D-3D/V3V_demo/V3V_run.sh',   
    output_path = '/export/ds/KianaCalagari/output_segments',
    input_path = '/home/local/QCRI/kcalagari',
    cloud_provider_id = 2)

