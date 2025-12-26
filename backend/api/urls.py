# backend/api/urls.py
from django.urls import path
from .views import  WhoAmI

urlpatterns = [
    # path('test-auth/', TestProtectedView.as_view(), name='test-auth'),
    # path('sync-user/', SyncUserView.as_view(), name='sync-user'),
    path('me/', WhoAmI.as_view()),

]
