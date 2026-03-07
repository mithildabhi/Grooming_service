"""
URL configuration for backend project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/6.0/topics/http/urls/
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
from django.contrib import admin
from django.urls import path , include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),  # 🔥 THIS LINE

    path('api/auth/', include('accounts.urls')),
    path('api/salons/', include('salons.urls')),
    path('api/services/', include('services.urls')),
    path('api/bookings/', include('bookings.urls')),
    path('api/staff/', include('staff.urls')),
    path('api/chatbot/', include('chatbot.urls')),
    path('api/customers/', include('customers.urls')),
    path('api/reviews/', include('reviews.urls')),
    path('api/hairstyle/', include('hairstyle_ml.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)


from django.http import HttpResponse
from django.core.management import call_command
from django.contrib.auth import get_user_model

def run_migrate(request):
    call_command('migrate')
    return HttpResponse("Migration done!")

def create_super(request):
    User = get_user_model()
    if not User.objects.filter(username='admin').exists():
        User.objects.create_superuser(
            username='admin',
            password='admin123',
            email='admin@admin.com'
        )
        return HttpResponse("Superuser created!")
    return HttpResponse("Superuser already exists!")

urlpatterns = [
    # ...your existing urls...
    path('run-migrate/', run_migrate),
    path('create-super/', create_super),
]