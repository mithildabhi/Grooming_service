# chatbot/user_chatbot_views_REAL.py
# 🤖 REAL AI CHATBOT - Fully Intelligent with Gemini + Full Database Access

from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from authentication.firebase_auth import FirebaseAuthentication
from salons.models import Salon
from services.models import Service
from bookings.models import Booking
from customers.models import Customer
from django.utils import timezone
from datetime import datetime, timedelta
from django.db.models import Q, Count
import os
import json
import re

from .models import UserChatHistory

# Gemini AI setup
try:
    import google.generativeai as genai
    GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
    if GEMINI_API_KEY:
        genai.configure(api_key=GEMINI_API_KEY)
        GEMINI_AVAILABLE = True
        print("✅ Gemini AI enabled for user chatbot")
    else:
        GEMINI_AVAILABLE = False
        print("⚠️ Gemini AI not available - set GEMINI_API_KEY")
except ImportError:
    GEMINI_AVAILABLE = False
    print("⚠️ google-generativeai not installed")


@api_view(['POST'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def user_chatbot_real(request):
    """
    🤖 REAL INTELLIGENT USER CHATBOT
    - Uses Gemini AI for natural conversation
    - Has full context of user's bookings and preferences
    - Can actually help with booking/canceling
    - Handles typos and natural language
    """
    try:
        message = request.data.get('message', '').strip()
        
        if not message:
            return Response(
                {'error': 'Message is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        print(f"\n{'='*60}")
        print(f"💬 USER MESSAGE: {message}")
        print(f"👤 User: {request.user.email}")
        
        # Get or create customer profile
        try:
            customer = Customer.objects.get(user=request.user)
        except Customer.DoesNotExist:
            customer = Customer.objects.create(
                user=request.user,
                full_name=request.user.get_full_name() or request.user.email.split('@')[0],
            )
            print(f"✅ Created new customer profile for {request.user.email}")
        
        # Build complete user context
        user_context = build_complete_user_context(customer)
        
        # Get conversation history for context
        conversation_history = get_recent_conversation(request.user, limit=5)
        
        # Generate intelligent response
        if GEMINI_AVAILABLE:
            response_text, actions = generate_gemini_intelligent_response(
                message,
                user_context,
                conversation_history,
                customer
            )
        else:
            response_text = "⚠️ AI service temporarily unavailable. Please try: 'find salons', 'show my bookings', or 'help'."
            actions = {}
        
        # Save conversation
        UserChatHistory.objects.create(
            user=request.user,
            user_message=message,
            bot_response=response_text,
            intent=actions.get('intent', 'general')
        )
        
        print(f"🤖 BOT RESPONSE: {response_text[:100]}...")
        print(f"📊 Actions: {actions}")
        print(f"{'='*60}\n")
        
        return Response({
            'response': response_text,
            'timestamp': datetime.now().isoformat(),
            'actions': actions,
        })
        
    except Exception as e:
        print(f"❌ Chatbot error: {e}")
        import traceback
        traceback.print_exc()
        return Response(
            {'response': 'I apologize, I encountered an error. Please try again.'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


def build_complete_user_context(customer):
    """
    Build COMPLETE context about the user from database
    This is what makes the AI truly intelligent
    """
    from bookings.models import Booking
    from django.db.models import Sum
    
    context = {
        'user_name': customer.full_name or 'Guest',
        'user_email': customer.email,
        'user_city': customer.city or None,
        'user_phone': customer.phone or None,
    }
    
    # Get ALL bookings
    all_bookings = Booking.objects.filter(user=customer.user).select_related(
        'salon', 'service', 'staff'
    ).order_by('-booking_date', '-booking_time')
    
    context['total_bookings'] = all_bookings.count()
    
    # Upcoming bookings (DETAILED)
    upcoming = all_bookings.filter(
        booking_date__gte=timezone.now().date(),
        status__in=['PENDING', 'CONFIRMED']
    )
    
    context['upcoming_bookings'] = []
    for booking in upcoming[:5]:
        context['upcoming_bookings'].append({
            'id': booking.id,
            'salon_name': booking.salon.name,
            'service_name': booking.service.name,
            'date': booking.booking_date.strftime('%Y-%m-%d'),
            'time': booking.booking_time.strftime('%H:%M'),
            'price': float(booking.price),
            'status': booking.status,
            'staff': booking.staff.full_name if booking.staff else 'Not assigned'
        })
    
    # Past bookings
    completed = all_bookings.filter(status='COMPLETED')
    context['completed_bookings'] = completed.count()
    
    # Favorite salon (most visited)
    favorite_salon = all_bookings.values(
        'salon__id', 'salon__name', 'salon__city'
    ).annotate(
        visit_count=Count('id')
    ).order_by('-visit_count').first()
    
    if favorite_salon:
        context['favorite_salon'] = favorite_salon['salon__name']
        context['favorite_salon_city'] = favorite_salon['salon__city']
        context['favorite_salon_visits'] = favorite_salon['visit_count']
    
    # Favorite service
    favorite_service = all_bookings.values(
        'service__id', 'service__name', 'service__price'
    ).annotate(
        booking_count=Count('id')
    ).order_by('-booking_count').first()
    
    if favorite_service:
        context['favorite_service'] = favorite_service['service__name']
        context['favorite_service_bookings'] = favorite_service['booking_count']
    
    # Total spent
    total_spent = completed.aggregate(total=Sum('price'))['total'] or 0
    context['total_spent'] = float(total_spent)
    
    # Last booking
    last_booking = completed.first()
    if last_booking:
        context['last_booking'] = {
            'salon': last_booking.salon.name,
            'service': last_booking.service.name,
            'date': last_booking.booking_date.strftime('%Y-%m-%d'),
            'how_long_ago_days': (timezone.now().date() - last_booking.booking_date).days
        }
    
    return context


def generate_gemini_intelligent_response(message, user_context, conversation_history, customer):
    """
    Generate TRULY INTELLIGENT response using Gemini AI
    with FULL user context and conversation history
    """
    
    # Build comprehensive system prompt
    system_prompt = f"""You are a friendly, helpful AI assistant for a salon booking app called SalonCare.

USER PROFILE:
- Name: {user_context['user_name']}
- City: {user_context['user_city'] or 'Not specified'}
- Total Bookings: {user_context['total_bookings']}
- Completed: {user_context['completed_bookings']}
- Total Spent: ₹{user_context.get('total_spent', 0):,.0f}

UPCOMING BOOKINGS ({len(user_context.get('upcoming_bookings', []))}):
"""
    
    if user_context.get('upcoming_bookings'):
        for b in user_context['upcoming_bookings']:
            system_prompt += f"\n- {b['date']} at {b['time']}: {b['service_name']} at {b['salon_name']} (₹{b['price']}, Status: {b['status']})"
    else:
        system_prompt += "\n- No upcoming bookings"
    
    if user_context.get('favorite_salon'):
        system_prompt += f"\n\nFAVORITE SALON: {user_context['favorite_salon']} ({user_context.get('favorite_salon_visits', 0)} visits)"
    
    if user_context.get('favorite_service'):
        system_prompt += f"\nFAVORITE SERVICE: {user_context['favorite_service']} ({user_context.get('favorite_service_bookings', 0)} times)"
    
    if user_context.get('last_booking'):
        lb = user_context['last_booking']
        system_prompt += f"\n\nLAST VISIT: {lb['salon']} for {lb['service']} on {lb['date']} ({lb['how_long_ago_days']} days ago)"
    
    system_prompt += f"""

YOUR CAPABILITIES:
1. Find salons (search by city, type, rating)
2. Show user's bookings (upcoming, past, specific dates)
3. Help book appointments (guide through process)
4. Cancel bookings (if user requests)
5. Give beauty/haircare advice
6. Answer questions about services, pricing, timing
7. Make personalized recommendations based on user history

IMPORTANT INSTRUCTIONS:
- Be conversational and friendly, like talking to a friend
- Use emojis appropriately 😊
- Always call the user by name: "{user_context['user_name']}"
- When user asks about "their bookings", refer to the UPCOMING BOOKINGS list above
- Be specific with dates, times, and salon names from their actual data
- If user makes typos (like "salon" vs "salons"), understand their intent
- If asked to book/cancel, provide SPECIFIC steps with their actual booking IDs
- Keep responses under 250 words but be helpful and complete

USER'S CURRENT QUESTION:
{message}

YOUR HELPFUL RESPONSE:"""
    
    try:
        model = genai.GenerativeModel('models/gemini-2.0-flash')
        
        # Build conversation with history
        chat_messages = []
        for hist in conversation_history[-3:]:  # Last 3 exchanges for context
            if hist['role'] == 'user':
                chat_messages.append({'role': 'user', 'parts': [hist['content']]})
            else:
                chat_messages.append({'role': 'model', 'parts': [hist['content']]})
        
        # Add current message
        chat_messages.append({'role': 'user', 'parts': [system_prompt]})
        
        response = model.generate_content(
            chat_messages,
            generation_config={
                'temperature': 0.9,  # More creative for natural conversation
                'max_output_tokens': 500,
                'top_p': 0.95,
            }
        )
        
        bot_response = response.text.strip()
        
        # Detect actions/intent from response
        actions = detect_actions_from_response(message, bot_response, user_context)
        
        return bot_response, actions
        
    except Exception as e:
        print(f"❌ Gemini error: {e}")
        # Fallback to intelligent rule-based
        return generate_smart_fallback(message, user_context), {'intent': 'fallback'}


def detect_actions_from_response(user_message, bot_response, user_context):
    """Detect what actions the bot is suggesting"""
    actions = {'intent': 'general'}
    
    message_lower = user_message.lower()
    
    # Detect intents
    if any(word in message_lower for word in ['find', 'search', 'show', 'near', 'salon']):
        actions['intent'] = 'find_salon'
        actions['suggest_explore'] = True
    
    if any(word in message_lower for word in ['book', 'appointment', 'schedule']):
        actions['intent'] = 'booking'
        actions['suggest_booking_flow'] = True
    
    if any(word in message_lower for word in ['my booking', 'upcoming', 'appointments']):
        actions['intent'] = 'my_bookings'
        if user_context.get('upcoming_bookings'):
            actions['bookings'] = user_context['upcoming_bookings']
    
    if any(word in message_lower for word in ['cancel', 'delete']):
        actions['intent'] = 'cancel_booking'
        if user_context.get('upcoming_bookings'):
            actions['cancelable_bookings'] = [
                b['id'] for b in user_context['upcoming_bookings']
            ]
    
    if any(word in message_lower for word in ['tip', 'advice', 'care', 'how to']):
        actions['intent'] = 'beauty_tips'
    
    return actions


def generate_smart_fallback(message, user_context):
    """Smart fallback when Gemini is unavailable"""
    message_lower = message.lower()
    user_name = user_context.get('user_name', 'there')
    
    # Greetings
    if any(word in message_lower for word in ['hello', 'hi', 'hey']):
        greeting = f"👋 Hi {user_name}! "
        if user_context.get('upcoming_bookings'):
            greeting += f"You have {len(user_context['upcoming_bookings'])} upcoming appointment(s)! "
        return greeting + "How can I help you today?"
    
    # My bookings
    if 'my booking' in message_lower or 'upcoming' in message_lower:
        if user_context.get('upcoming_bookings'):
            response = f"📅 **Your Upcoming Appointments:**\n\n"
            for b in user_context['upcoming_bookings']:
                response += f"• {b['date']} at {b['time']}\n"
                response += f"  {b['service_name']} at {b['salon_name']}\n"
                response += f"  ₹{b['price']} - {b['status']}\n\n"
            return response
        else:
            return f"📅 Hi {user_name}! You don't have any upcoming appointments. Ready to book one?"
    
    # Default helpful response
    return f"Hi {user_name}! I can help you with:\n\n" \
           "🔍 Finding salons\n" \
           "📅 Booking appointments\n" \
           "📋 Viewing your bookings\n" \
           "💅 Beauty tips\n\n" \
           "What would you like to do?"


def get_recent_conversation(user, limit=5):
    """Get recent conversation for context"""
    try:
        history = UserChatHistory.objects.filter(
            user=user
        ).order_by('-created_at')[:limit]
        
        messages = []
        for chat in reversed(history):
            messages.append({'role': 'user', 'content': chat.user_message})
            messages.append({'role': 'assistant', 'content': chat.bot_response})
        
        return messages
    except:
        return []


@api_view(['GET'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def user_suggestions_smart(request):
    """Generate SMART suggestions based on user's actual state"""
    try:
        customer = Customer.objects.get(user=request.user)
        context = build_complete_user_context(customer)
        
        suggestions = []
        
        # Smart suggestions based on user state
        upcoming_count = len(context.get('upcoming_bookings', []))
        
        if upcoming_count > 0:
            suggestions.append(f"Show my {upcoming_count} upcoming appointment{'s' if upcoming_count > 1 else ''}")
            suggestions.append("When is my next appointment?")
        else:
            suggestions.append("Find salons near me")
            if context.get('favorite_salon'):
                suggestions.append(f"Book at {context['favorite_salon']}")
        
        if context.get('favorite_service'):
            suggestions.append(f"Book a {context['favorite_service']}")
        
        if context.get('last_booking'):
            days_ago = context['last_booking']['how_long_ago_days']
            if days_ago > 30:
                suggestions.append("It's been a while! Time for a visit?")
        
        suggestions.extend([
            "Haircare tips for me",
            "Best time to book?",
            "Cancel an appointment",
        ])
        
        return Response({'suggestions': suggestions[:8]})
        
    except Customer.DoesNotExist:
        return Response({
            'suggestions': [
                "Find salons near me",
                "How do I book?",
                "Beauty tips",
                "Popular services",
            ]
        })


@api_view(['DELETE'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def clear_user_chat_history(request):
    """Clear user's chat history"""
    try:
        deleted_count = UserChatHistory.objects.filter(
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


# Export the real chatbot
user_chatbot = user_chatbot_real