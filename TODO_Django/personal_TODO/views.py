from django.shortcuts import render, redirect
from TODO_Django.dbconnect import dbconn
from datetime import datetime
from TODO_Django.settings import BASE_DIR
import os

# Create your views here.
def setFinished(request, uname, ptno):
    cookie_username = request.COOKIES.get('uname', None)
    uno = request.COOKIES.get('uno', None)
    if(cookie_username == uname):
        dbconnection = dbconn()
        dbconnection.connect()
        dbconnection.exec(f"CALL PERSONFINISH ({ptno})")
        dbconnection.close()
        return redirect('/user/%s/#personal' % uname)
    else:
        return redirect('/login')

def interface(request, uname):
    cookie_username = request.COOKIES.get('uname', None)
    uno = request.COOKIES.get('uno', None)
    if(cookie_username == uname):
        return render(request, os.path.join(BASE_DIR ,"personal_TODO/templates/Add_Personal.html"),{'uname': uname})
    else:
        return redirect('/login')   

def addpersonalapi(request, uname):
    cookie_username = request.COOKIES.get('uname', None)
    uno = request.COOKIES.get('uno', None)
    if(cookie_username == uname):
        dbconnection = dbconn()
        dbconnection.connect()

        ptreptype = request.POST.get('ptreptype')
        ptname = request.POST.get('ptname')
        ptend = request.POST.get('ptend').replace('T', ' ')
        ptrep = request.POST.get('ptrep')
        ptimp = request.POST.get('ptimp')

        ptbegintime = datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')
        if ptreptype == '0':
            dbconnection.doing("INSERT INTO PTaskList (ptno,pt_uno,ptname,ptbegintime,ptendtime,ptimportance) VALUES(NULL, %s, '%s', '%s', '%s', %s);" % (uno, ptname, ptbegintime, ptend, ptimp))
        else:
            dbconnection.doing(f"CALL P_{ptreptype}REP({ptrep},'{ptbegintime}','{ptend}',{uno},'{ptname}',{ptimp});")
        dbconnection.close()
        return redirect('/user/%s/#personal' % uname)
    else:
        return redirect('/login') 
# datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')