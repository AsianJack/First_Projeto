from django.shortcuts import render
from django.http import HttpResponse, HttpResponseNotFound, HttpResponseRedirect, Http404
from django.template.loader import render_to_string

# Create your views here.
def index (request):
    return render(request, "index/index.html")