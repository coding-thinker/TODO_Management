from django.shortcuts import render, redirect
from TODO_Django.settings import BASE_DIR
from TODO_Django.dbconnect import dbconn
import os

# Create your views here.
def register(request):
    dbconnection = dbconn()
    dbconnection.connect()
    if request.method == "POST":
        user = request.POST.get("user")
        pwd = request.POST.get("pwd")
        pwd2 = request.POST.get("pwd2")
        email = request.POST.get("email")
        if pwd != pwd2:
            return render(request, os.path.join(BASE_DIR ,"register_interface/templates/Register.html"), {"messages": ['二次密码输入错误']})
        for each in ["%", "&", "*", "_", "?", "/", "\\", "|", "!", "~"]:
            if each in pwd:
                return render(request, os.path.join(BASE_DIR ,"register_interface/templates/Register.html"), {"messages": ['密码内含有非法字符']})     
            if each in user:
                return render(request, os.path.join(BASE_DIR ,"register_interface/templates/Register.html"), {"messages": ['用户名内含有非法字符']})     
        if not 5 <= len(user)<=20:
            return render(request, os.path.join(BASE_DIR ,"register_interface/templates/Register.html"), {"messages": ['用户名长度非法']})     
        if not 5 <= len(pwd)<=20:
            return render(request, os.path.join(BASE_DIR ,"register_interface/templates/Register.html"), {"messages": ['密码长度非法']})     
        if '@' not in email:
            return render(request, os.path.join(BASE_DIR ,"register_interface/templates/Register.html"), {"messages": ['邮箱格式非法']})     
        if len(dbconnection.exec("SELECT * FROM userlist WHERE uname='%s';" % user)):
            return render(request, os.path.join(BASE_DIR ,"register_interface/templates/Register.html"), {"messages": ['用户名已经存在']})  
        dbconnection.do("INSERT INTO userlist VALUES(NULL,'%s','%s','%s');" % (user, pwd, email))
        return render(request, os.path.join(BASE_DIR ,"login_interface/templates/Login.html"), {"messages": ['注册成功']})  


        