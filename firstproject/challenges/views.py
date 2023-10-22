from django.shortcuts import render
from django.http import HttpResponse, HttpResponseNotFound, HttpResponseRedirect, Http404
from django.template.loader import render_to_string

meses = {
    "january": "janero",
    "february": None
}

# Create your views here.
def index(request):
    lista_item = ""
    month_key = list(meses.keys())
    return render(request, "challenges/index.html", {
        "months_key": month_key,
    })

def january(request):
    return HttpResponse("that's work")

def february(request, month):
    return HttpResponse("feverero" + month)

def month_number(request, month):
    if(month>len(meses) or month<1):
        return HttpResponseNotFound("Invalid number")
    else:
        mes = list(meses.keys())
        return HttpResponseRedirect(mes[month-1])
    

def month(request, month):
    try:
        text = f"<h1>{meses[month]}</h1>"
        return render(request,"challenges/challenge.html", {
            "text": meses[month],
            "month": month.capitalize()
        })
        # resposta = render_to_string("challenges/challenge.html")
        # return HttpResponse(resposta)
    except:
        raise Http404()
