'''
Created on Feb 4, 2016

@author: hazemsamir
'''

from coreserver.utils.emailsender import EmailSender
from coreserver.models import Email, Segment2D

class EmailsTemplates(object):
    
    task_info_email_template = """
        Dear %(receiver)s,
        A video submitted by %(receiver)s to be converted to 3D video. You will receive an e-mail with the download link as soon as the video converted.
        
        info:
            date received: %(date)s
            duration: %(duration)s
            conversion task id: %(id)s
        
        thanks for using our service,
        
        V3V team
    """
    
    
    @classmethod
    def send_task_info_email(cls, segment2D):
        sender = Email.objects.get(active=1)
        sender_address = sender.address
        sender_password = sender.password
        receiver = segment2D.email;
        data = {'receiver':segment2D.email, 'date':segment2D.upload_date, 'id':segment2D.id, 
                'duration':segment2D.duration 
                }
        text_msg = cls.task_info_email_template % data
        if receiver:
            EmailSender.send_email(text_msg, sender_address,sender_password, receiver)

    