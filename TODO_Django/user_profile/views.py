from django.shortcuts import render, redirect
from django.contrib import messages
from TODO_Django.settings import BASE_DIR
from TODO_Django.dbconnect import dbconn
import os
# Create your views here.

def get_personal(uno):
    dbconnection = dbconn()
    dbconnection.connect()
    render_data = []
    raw_result = dbconnection.exec('select ptfinishflag, ptno, ptname, ptbegintime, ptendtime, ptfinishtime, ptimportance from ptasklist where pt_uno = %s' % uno)
    for item in raw_result:
        temp_dict = {}
        if item[0] == '0':
            temp_dict['checked'] = ''
        elif item[0] == '1':
            temp_dict['checked'] = 'checked="checked"'
        temp_dict['ptno'] = item[1]
        temp_dict['data'] = item[1:]
        render_data.append(temp_dict)
    return render_data


def default(request, uname):
    cookie_username = request.COOKIES.get('uname', None)
    uno = request.COOKIES.get('uno', None)
    if(cookie_username == uname):
        return render(request, os.path.join(BASE_DIR ,"user_profile/templates/User_Profile.html"), {'uname': uname, 'personal': get_personal(uno)})
    else:
        return redirect('/login')

def changeprofile(request, uname):
    cookie_username = request.COOKIES.get('uname', None)
    uno = request.COOKIES.get('uno', None)
    if(cookie_username == uname) and request.method == "POST":
        dbconnection = dbconn()
        dbconnection.connect()

        
        olduemail = request.POST.get("olduemail")
        uname = request.POST.get("unamebox")
        upwd = request.POST.get("upwdbox")
        uemail = request.POST.get("uemail")

        ((olduemail_,),) = dbconnection.exec(f'select email from userlist where uno={uno}')
        if olduemail != olduemail_:
            messages.success(request,"邮箱验证失败")
            return redirect(f'/user/{cookie_username}/#profile')
        for each in ["%", "&", "*", "_", "?", "/", "\\", "|", "!", "~"]:
            if each in upwd:
                messages.success(request,'密码内含有非法字符')   
                return redirect(f'/user/{cookie_username}/#profile')
            if each in uname:
                messages.success(request,'用户名内含有非法字符')   
                return redirect(f'/user/{cookie_username}/#profile')    
        if not 5 <= len(uname)<=20:
            messages.success(request,'用户名长度非法')   
            return redirect(f'/user/{cookie_username}/#profile')  
        if not 5 <= len(upwd)<=20:
            messages.success(request,'密码长度非法')   
            return redirect(f'/user/{cookie_username}/#profile')  
        if '@' not in uemail or '@' == uemail[0] or '@' == uemail[-1]:
            messages.success(request,'邮箱格式非法')   
            return redirect(f'/user/{cookie_username}/#profile')  
        if len(dbconnection.exec("SELECT * FROM userlist WHERE uname='%s' and uno!='%s';" % (uname, uno))):
            messages.success(request,'用户名已经存在')   
            return redirect(f'/user/{cookie_username}/#profile')  
        dbconnection.do(f"update userlist set uname='{uname}', upassword='{upwd}', email='{uemail}' where uno={uno}")
        messages.success(request,'真不错 修改已经完成了')
        return redirect('/login')
    else:
        return redirect(f'/user/{cookie_username}/#profile')