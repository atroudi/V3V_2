'''
Created on Aug 6, 2015

@author: qcriadmin
'''
import smtplib
from email.mime.text import MIMEText

class EmailSender(object):
    '''
    classdocs
    '''

    @classmethod
    def send_email(cls, text_msg, sender, sender_password, reciever):
        msg = MIMEText(text_msg)
        msg['Subject'] = 'V3V: Job Status'
        msg['From'] = sender
        msg['To'] = reciever
        
        #s = smtplib.SMTP(host='smtp.gmail.com', port=587)
        s = smtplib.SMTP_SSL('smtp.googlemail.com', 465)
        s.ehlo()
        #s.starttls()
        #s.ehlo()
        s.login(sender, sender_password)
        s.sendmail(sender, reciever, msg.as_string())
        
        # send the conversion task done to Doctor Hefeeda
        s.sendmail(sender, "mhefeeda@qf.org.qa", msg.as_string())
        
        s.quit()

        