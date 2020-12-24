from django.shortcuts import render
from TODO_Django.settings import BASE_DIR
import os

# Create your views here.
def default(request):
    return render(request, os.path.join(BASE_DIR ,"login_interface/templates/Login.html"))