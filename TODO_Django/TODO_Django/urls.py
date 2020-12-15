"""TODO_Django URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.shortcuts import redirect
from django.contrib import admin
from django.urls import path
from login_interface import views as login_views
from login_api import views as login_api
from register_interface import views as register_views
from register_api import views as register_api
from user_profile import views as user_profile_views
from personal_TODO import views as personal_TODO_views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('login/', login_views.default),
    path('login_api/', login_api.login),
    path('register/', register_views.default),
    path('register_api/', register_api.register),
    path('user/<str:uname>/', user_profile_views.default),
    path('setfinished/<str:uname>/<str:ptno>', personal_TODO_views.setFinished),
    path('addPersonal/<str:uname>/', personal_TODO_views.interface),
    path('addpersonal_api/<str:uname>/', personal_TODO_views.addpersonalapi),
]
