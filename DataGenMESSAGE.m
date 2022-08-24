function DataGenMESSAGE(df) 
    % Author: Adam J Hepworth
    % LastModified: 2022-08-10
    % Explanaton: Template for sending email for error checking 
    
    mail = 'skyshepherdunsw'; % 'birthday' = 1 January 1970 
    password = '47buVL7zcspe9Z2'; % there is no 'recovery' phone number
    recipients = {'z3215428@ad.unsw.edu.au', 'daniel.baxter@unsw.edu.au', 'skyshepherdunsw@gmail.com'}; 
    host = 'smtp.gmail.com';
    Subject = 'test subject';
    Message = 'test message';
  
    % preferences
    setpref('Internet','SMTP_Server', host);
    setpref('Internet','E_mail',mail);
    setpref('Internet','SMTP_Username',mail);
    setpref('Internet','SMTP_Password',password);
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');

    sendmail(recipients,Subject,Message)

    % Gmail won't work for this - I tihnk we'll need a log 
    % Need to delete the email account now! 

    % On Windows® systems with Microsoft® Outlook®, you can send email directly through O
    % utlook by accessing the COM server with actxserver. For an example, see Solution 1-RTY6J.
    % https://www.mathworks.com/matlabcentral/answers/94446-can-i-send-e-mail-through-matlab-using-microsoft-outlook