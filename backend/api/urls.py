from django.urls import path
from . import views

urlpatterns = [
    path("save-fcm/", views.save_fcm_token),
    path("test-fcm/", views.test_notification),
]
