from django.shortcuts import render, redirect
from TODO_Django.settings import BASE_DIR
import os
from TODO_Django.dbconnect import dbconn
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
