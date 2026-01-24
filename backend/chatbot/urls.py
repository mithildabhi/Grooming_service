# chatbot/urls.py
# ✅ OPTIMIZED URL Configuration

from django.urls import path
from . import views

app_name = 'chatbot'

urlpatterns = [
    # Main chatbot endpoint
    path('', views.admin_chatbot, name='chatbot-root'),
    path('admin/', views.admin_chatbot, name='admin-chatbot'),
    
    # Quick suggestions
    path('suggestions/', views.admin_suggestions, name='chatbot-suggestions'),
    
    # Clear chat history
    path('clear/', views.clear_chat_history, name='clear-chat'),
    
    # Comprehensive analytics summary
    path('analytics/', views.get_salon_analytics_summary, name='salon-analytics'),
]