from django.shortcuts import render
from TODO_Django.settings import BASE_DIR
import TODO_Django.dbconnect as dbconnect
import os

# Create your views here.
def default(request):
    return render(request, os.path.join(BASE_DIR ,"register_interface/templates/Register.html"))