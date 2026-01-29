# chatbot/urls.py
# ✅ UPDATED: Using REAL Intelligent Chatbot

from django.urls import path
from . import views
from . import user_chatbot_views_REAL as user_views

app_name = 'chatbot'

urlpatterns = [
    # ========================================
    # ADMIN CHATBOT ENDPOINTS
    # ========================================
    
    # Main admin chatbot
    path('admin/', views.admin_chatbot, name='admin-chatbot'),
    path('', views.admin_chatbot, name='chatbot-root'),
    
    # Admin suggestions
    path('admin/suggestions/', views.admin_suggestions, name='admin-suggestions'),
    
    # Clear admin chat history
    path('admin/clear/', views.clear_chat_history, name='admin-clear-chat'),
    
    # Admin analytics summary
    path('admin/analytics/', views.get_salon_analytics_summary, name='admin-analytics'),
    
    # ========================================
    # ✅ USER/CUSTOMER CHATBOT ENDPOINTS (REAL AI)
    # ========================================
    
    # Main user chatbot - REAL intelligent version
    path('user/', user_views.user_chatbot, name='user-chatbot'),
    
    # User suggestions - SMART contextual
    path('user/suggestions/', user_views.user_suggestions_smart, name='user-suggestions'),
    
    # Clear user chat history
    path('user/clear/', user_views.clear_user_chat_history, name='user-clear-chat'),
]


"""
🤖 REAL AI CHATBOT ENDPOINTS

USER ENDPOINTS (Intelligent with Gemini):
- POST /api/chatbot/user/               → Main AI chatbot (knows user context)
- GET  /api/chatbot/user/suggestions/   → Smart suggestions (user-specific)
- DELETE /api/chatbot/user/clear/       → Clear chat history

WHAT'S DIFFERENT:
✅ Uses Gemini AI for natural conversation
✅ Full access to user's booking history
✅ Knows user's favorite salons/services
✅ Can see upcoming appointments
✅ Handles typos and natural language
✅ Provides personalized recommendations
✅ Actually helpful (not pre-defined responses)

EXAMPLE USAGE:

curl -X POST http://localhost:8000/api/chatbot/user/ \
  -H "Authorization: Bearer <FIREBASE_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "show my bookings"
  }'

Response:
{
  "response": "📅 Hi John! You have 2 upcoming appointments:...",
  "actions": {
    "intent": "my_bookings",
    "bookings": [...]
  }
}
"""