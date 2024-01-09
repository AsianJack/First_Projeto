from django.urls import path
from . import views #. only mean that from the same folder take views
urlpatterns = [
    path("", views.index, name="index"),
    # path("<int:month>", views.month_number),
    # path("<str:month>", views.month, name="month_challenger"), #this is the dynamic form, and the str means the django transform the month in string if I use int so will tranform in integer
    #the django works in order so if i try to use the str first it will give me the month doesnt exist
]