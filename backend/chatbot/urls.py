# chatbot/urls.py

from django.urls import path
from . import views

app_name = 'chatbot'

urlpatterns = [
    # ✅ Root endpoint - what your Flutter app calls
    path('', views.admin_chatbot, name='chatbot-root'),
    
    # Alternative admin endpoint (keeps old path working too)
    path('admin/', views.admin_chatbot, name='admin-chatbot'),
    
    # Quick suggestions
    path('suggestions/', views.admin_suggestions, name='chatbot-suggestions'),
    
    # Clear chat history
    path('clear/', views.clear_chat_history, name='clear-chat'),
]