# chatbot/views.py
# 🎯 OPTIMIZED - Clean API Endpoints Only

from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from authentication.firebase_auth import FirebaseAuthentication
from salons.models import Salon
from staff.models import Employee
from accounts.models import User
from datetime import datetime
from django.utils import timezone
import os
import re
from .models import ChatHistory
from .analytics import (
    get_comprehensive_salon_analytics,
    get_conversation_history,
    clear_salon_cache
)
from .responses import (
    generate_intelligent_fallback,
    generate_gemini_response
)
from .staff_management import (
    detect_add_staff_intent,
    extract_staff_details,
    create_staff_member
)

# Gemini AI setup
try:
    import google.generativeai as genai
    GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
    if GEMINI_API_KEY:
        genai.configure(api_key=GEMINI_API_KEY)
        GEMINI_AVAILABLE = True
    else:
        GEMINI_AVAILABLE = False
except ImportError:
    GEMINI_AVAILABLE = False


@api_view(['POST'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def admin_chatbot(request):
    """
    ✅ OPTIMIZED AI-Powered Chatbot
    ✅ FIXED: Now shows correct revenue from 'price' field
    """
    try:
        message = request.data.get('message', '').strip()
        
        if not message:
            return Response(
                {'error': 'Message is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Get salon
        try:
            salon = Salon.objects.get(owner=request.user)
        except Salon.DoesNotExist:
            return Response({
                'response': '🏪 Please create your salon profile first.',
                'intent': 'no_salon'
            })
        
        # Check for staff addition intent
        if detect_add_staff_intent(message):
            return handle_staff_creation(request, salon, message)
        
        # Get analytics and generate response
        salon_context = get_comprehensive_salon_analytics(salon)
        conversation_history = get_conversation_history(request.user, salon)
        
        if GEMINI_AVAILABLE:
            response_text = generate_gemini_response(
                message, 
                salon_context, 
                conversation_history
            )
        else:
            response_text = generate_intelligent_fallback(message, salon_context)
        
        # Save to history
        ChatHistory.objects.create(
            user=request.user,
            salon=salon,
            user_message=message,
            bot_response=response_text
        )
        
        return Response({
            'response': response_text,
            'timestamp': datetime.now().isoformat(),
            'intent': detect_admin_intent(message),
            'salon_id': salon.id
        })
        
    except Exception as e:
        print(f"❌ Chatbot error: {e}")
        import traceback
        traceback.print_exc()
        return Response(
            {'response': 'I apologize, I encountered an error. Please try again.'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


def handle_staff_creation(request, salon, message):
    """Handle staff member creation"""
    staff_data = extract_staff_details(message, salon)
    
    if staff_data:
        success, result = create_staff_member(salon, staff_data)
        
        if success:
            employee = result
            response_text = f"""✅ **Staff Member Added Successfully!**

I've added **{employee.full_name}** to your team at {salon.name}! 🎉

**Details:**
👤 Name: {employee.full_name}
💼 Role: {employee.get_role_display()}
✂️ Skill: {employee.get_primary_skill_display()}
📧 Email: {employee.email}
📱 Phone: {employee.phone}
✓ Status: Active

**Your Team:** {Employee.objects.filter(salon=salon, is_active=True).count()} active members

Would you like to add another staff member?"""
            
            ChatHistory.objects.create(
                user=request.user,
                salon=salon,
                user_message=message,
                bot_response=response_text,
                intent='staff_creation'
            )
            
            # Clear cache after adding staff
            clear_salon_cache(salon.id)
            
            return Response({
                'response': response_text,
                'timestamp': datetime.now().isoformat(),
                'intent': 'staff_created',
                'salon_id': salon.id,
                'staff_created': True,
                'employee_id': employee.id
            })
        else:
            response_text = f"""❌ **Failed to Add Staff Member**

Error: {result}

Please try again with this format:
```
Add staff
Name: John Doe
Role: Barber
Skill: Hair Cutting
Phone: 9876543210
Email: john@example.com
```"""
    else:
        response_text = """📝 **Add New Staff Member**

Please provide the staff details in this format:

**Name:** [Full Name]
**Role:** [Stylist/Barber/Manager/Receptionist/Specialist]
**Skill:** [Hair Cutting/Hair Styling/Coloring/Beard Trim/Spa/Massage/Nails/Makeup]
**Phone:** [10-digit number]
**Email:** [email address]

Example:
```
Name: John Doe
Role: Barber
Skill: Hair Cutting
Phone: 9876543210
Email: john@salon.com
```"""
    
    return Response({
        'response': response_text,
        'timestamp': datetime.now().isoformat(),
        'intent': 'staff_creation_prompt',
        'salon_id': salon.id
    })


def detect_admin_intent(message):
    """Detect user intent from message"""
    message = message.lower()
    
    intents = {
        'staff_creation': ['add staff', 'new staff', 'hire'],
        'bookings_today': ['today', 'bookings today'],
        'revenue': ['revenue', 'earning', 'income'],
        'staff_info': ['staff', 'team', 'employee'],
        'services': ['service', 'popular service'],
        'customers': ['customer', 'client'],
        'analytics': ['report', 'analytics', 'insights', 'performance'],
        'weekly': ['week', 'weekly'],
        'monthly': ['month', 'monthly'],
    }
    
    for intent, keywords in intents.items():
        if any(keyword in message for keyword in keywords):
            return intent
    
    return 'general'


@api_view(['GET'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def admin_suggestions(request):
    """Get contextual quick suggestions"""
    try:
        salon = Salon.objects.get(owner=request.user)
        analytics = get_comprehensive_salon_analytics(salon)
        
        suggestions = [
            "How many bookings today?",
            "Show this week's revenue",
            "Who are my top performers?",
        ]
        
        # Dynamic suggestions
        if analytics.get('today_pending', 0) > 0:
            suggestions.append(
                f"Review {analytics['today_pending']} pending bookings"
            )
        
        if analytics.get('cancellation_rate', 0) > 15:
            suggestions.append("Why is my cancellation rate high?")
        
        if analytics.get('revenue_growth_percentage', 0) > 10:
            suggestions.append("What's driving my revenue growth?")
        
        if analytics.get('total_staff', 0) < 3:
            suggestions.append("Should I hire more staff?")
        
        suggestions.extend([
            "Popular services analysis",
            "Customer retention tips",
            "Add new staff member",
        ])
        
        return Response({'suggestions': suggestions[:8]})
        
    except Salon.DoesNotExist:
        return Response({
            'suggestions': [
                "Create your salon profile",
                "How do I get started?",
                "What can you help with?",
            ]
        })


@api_view(['DELETE'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def clear_chat_history(request):
    """Clear chat history for authenticated user"""
    try:
        deleted_count = ChatHistory.objects.filter(
            user=request.user
        ).delete()[0]
        
        return Response({
            'message': f'Chat history cleared ({deleted_count} messages deleted)',
            'success': True
        })
    except Exception as e:
        return Response(
            {'error': str(e)}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def get_salon_analytics_summary(request):
    """
    ✅ Get comprehensive analytics summary
    ✅ FIXED: Now returns correct revenue from 'price' field
    """
    try:
        salon = Salon.objects.get(owner=request.user)
        analytics = get_comprehensive_salon_analytics(salon)
        
        return Response({
            'success': True,
            'salon_id': salon.id,
            'salon_name': salon.name,
            'analytics': analytics,
            'timestamp': datetime.now().isoformat()
        })
        
    except Salon.DoesNotExist:
        return Response(
            {'error': 'No salon found for this user'},
            status=status.HTTP_404_NOT_FOUND
        )
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )