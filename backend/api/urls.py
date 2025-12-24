# backend/api/urls.py
from django.urls import path
from .views import TestProtectedView
from .views import SyncUserView


urlpatterns = [
    path('test-auth/', TestProtectedView.as_view(), name='test-auth'),
    path('sync-user/', SyncUserView.as_view()),

]
