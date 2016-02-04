'''
Created on Feb 4, 2016

@author: hazemsamir
'''

from coreserver.utils.emailsender import EmailSender
from coreserver.models import Email, Segment2D
from matplotlib.testing.jpl_units.Duration import Duration
from V3VServer.settings import v3vteam_emails

class EmailsTemplates(object):
    
    task_info_email_template = """
Dear %(receiver)s,
    We received your video to be converted to 3D video. You will receive an e-mail with the download link as soon as the video converted.
        
    video info:
        date received: %(date)s
        duration: %(duration)s seconds
        conversion task id: %(id)s
        
thanks for using our service,
        
V3V team
"""
    debug_message_header = """
this message is sent to V3V team email list concerning task assigned by %(receiver)s

--------------------------------
%(text_msg)s
"""
    
    @classmethod
    def send_task_info_email(cls, segment2D):
        '''
            sends email with uploaded video information
        '''
        sender = Email.objects.get(active=1)
        subject = "V3V: video uploaded"
        sender_address = sender.address
        sender_password = sender.password
        receiver = segment2D.email;
        data = {'receiver':segment2D.email, 'date':segment2D.upload_date, 'id':segment2D.id, 
                'duration':segment2D.duration
                }
        text_msg = cls.task_info_email_template % data
        if receiver:
            EmailSender.send_email(text_msg, sender_address,sender_password, receiver, subject)
            cls.send_email_to_team(text_msg, sender_address, sender_password, receiver, subject)

    @classmethod            
    def send_email_to_team(cls, text_msg, sender_address,sender_password, receiver, subject, with_header=True):
        if with_header:
            text_msg = cls.debug_message_header % {'receiver':receiver, 'text_msg':text_msg}
        if receiver:
            for t in v3vteam_emails:
                if t[1]: # True set to receive
                    EmailSender.send_email(text_msg, sender_address,sender_password, t[0], subject)

    