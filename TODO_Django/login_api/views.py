from django.shortcuts import render, redirect
from TODO_Django.settings import BASE_DIR
from TODO_Django.dbconnect import dbconn
import os

# Create your views here.
def login(request):
    dbconnection = dbconn()
    dbconnection.connect()
    if request.method == "POST":
        user = request.POST.get("user")
        pwd = request.POST.get("pwd")
        is_logged = (pwd,) in dbconnection.exec("SELECT upassword FROM userlist WHERE uname = '%s';" % user)
        dbconnection.close()

        if is_logged:
            dbconnection = dbconn()
            dbconnection.connect()
            ((uno,),) = dbconnection.exec("SELECT uno FROM userlist WHERE uname = '%s';" % user)
            dbconnection.close()

            obj = redirect("/user/%s/" % user)
            obj.set_cookie('uname', user, max_age=600)
            obj.set_cookie('uno', uno, max_age=600)
        else:
            obj = render(request, os.path.join(BASE_DIR ,"login_interface/templates/Login.html"), {"messages": ['Error login']})
        return obj
            
