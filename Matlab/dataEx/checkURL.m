function checkURL(obj,event, str1,str2)

global fl
% Looks for the removal of str1
% And addition of str2
% send mail flag 'fl'
if nargin<2
    fl=1;
    return;
else
    % setup emailing
    myaddress = 'sharathbs76@comcast.net';
    mypassword = 'Cbuntytumby117';
    
    setpref('Internet','E_mail',myaddress);
    setpref('Internet','SMTP_Server','smtp.comcast.net');
    setpref('Internet','SMTP_Username',myaddress);
    setpref('Internet','SMTP_Password',mypassword);
    
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', ...
        'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    
    wp = urlread('https://play.google.com/store/devices');
    s1 = regexp(wp,str1,'once');
    s2 = regexp(wp,str2,'once');
    
    if ~isempty(s1) & mod(fl,12)==1
        % disp(strcat(str1,'_',' is still there'));
        sendmail(myaddress, strcat(str1,'_',' is still there'));
    elseif isempty(s1)
        sendmail(myaddress, strcat(str1,'_',' is GONE!!'));
    elseif isempty(s2) & mod(fl,12)==1
        % disp(strcat('Still waiting for the ',str2));
        sendmail(myaddress, strcat('Still waiting for the ',str2));
    elseif ~isempty(s2)
        sendmail(myaddress, strcat(str2,'_',' is now online!!'));
    end
    fl = fl+1;
    disp(strcat(num2str(fl),': Timer and webcheck running'))
end