# chatbot/user_chatbot_views_REAL.py
# 🤖 FIXED: Better fallback when Gemini API fails

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
from django.db.models import Q, Count, Sum
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
        print("⚠️ Gemini AI not available - using smart fallback")
except ImportError:
    GEMINI_AVAILABLE = False
    print("⚠️ google-generativeai not installed - using smart fallback")


@api_view(['POST'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def user_chatbot(request):
    """
    🤖 FIXED INTELLIGENT USER CHATBOT
    - Uses Gemini AI when available
    - Falls back to SMART rule-based responses
    - Has full context of user's bookings
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
            print(f"✅ Existing user found: {customer.email}, Role: {request.user.role}")
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
        
        # ✅ FIXED: Always try smart fallback first, then enhance with Gemini if available
        response_text, actions = generate_smart_response(message, user_context, customer)
        
        # Enhance with Gemini if available
        if GEMINI_AVAILABLE:
            try:
                gemini_response = generate_gemini_enhancement(
                    message,
                    user_context,
                    conversation_history,
                    response_text
                )
                if gemini_response:
                    response_text = gemini_response
            except Exception as e:
                print(f"⚠️ Gemini enhancement failed, using smart fallback: {e}")
                # Keep the smart fallback response
        
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

def detect_user_intent(message):
    msg = message.lower().strip()

    # ===== HIGH PRIORITY (NO GREETING FALLBACK) =====
    if any(k in msg for k in ['my booking', 'booking history', 'past booking', 'my appointment']):
        return 'booking_history'

    if any(k in msg for k in ['popular service', 'trending', 'popular this month']):
        return 'popular_services'

    if any(k in msg for k in ['cancel booking', 'cancel appointment']):
        return 'cancel_booking'

    if any(k in msg for k in ['when should i book', 'avoid crowd', 'best time']):
        return 'best_time_to_book'

    if any(k in msg for k in ['book', 'appointment', 'schedule']):
        return 'booking_help'

    if any(k in msg for k in ['hair tip', 'haircare', 'skin', 'beauty tip']):
        return 'beauty_tips'

    # ===== LOCATION (CITY ONLY MESSAGE) =====
    if msg.isalpha() and len(msg) > 3:
        return 'set_city'

    # ===== LOW PRIORITY =====
    if any(k in msg for k in ['hi', 'hello', 'hey']):
        return 'greeting'

    return 'general'
def get_quick_replies(intent, user_context):
    replies = []

    if intent == 'greeting':
        replies = [
            "Find salons near me",
            "My booking history",
            "Popular services this month",
            "Haircare tips"
        ]

    elif intent == 'booking_history':
        replies = [
            "Show upcoming bookings",
            "Cancel booking",
            "Book new appointment"
        ]

    elif intent == 'popular_services':
        replies = [
            "Book haircut",
            "Show salons near me",
            "Best offers today"
        ]

    elif intent == 'beauty_tips':
        replies = [
            "Haircare tips",
            "Skincare routine",
            "Recommended salons"
        ]

    elif intent == 'booking_help':
        replies = [
            "Find salon",
            "Choose service",
            "Best time to book"
        ]

    elif intent == 'set_city':
        replies = [
            "Show salons",
            "Popular services",
            "Best rated salons"
        ]

    return replies

def build_complete_user_context(customer):
    """Build COMPLETE context about the user from database"""
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
    for booking in upcoming[:10]:
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

def get_service_recommendations(customer):
    from bookings.models import Booking
    from services.models import Service
    from django.db.models import Count

    past_services = (
        Booking.objects
        .filter(user=customer.user, status='COMPLETED')
        .values('service__id', 'service__name')
        .annotate(count=Count('id'))
        .order_by('-count')
    )

    if not past_services:
        return []

    top_service_id = past_services[0]['service__id']

    recommended_services = Service.objects.filter(
        category__in=Service.objects.filter(id=top_service_id)
        .values_list('category', flat=True)
    ).exclude(id=top_service_id)[:3]

    return [s.name for s in recommended_services]

def generate_smart_response(message, user_context, customer):
    """
    ✅ SMART RULE-BASED RESPONSES
    This works WITHOUT Gemini and gives proper contextual responses
    """
    message_lower = message.lower()
    user_name = user_context.get('user_name', 'there')
    
    actions = {'intent': 'general'}
    
    # ==================== GREETINGS ====================
    if any(word in message_lower for word in ['hello', 'hi', 'hey', 'good morning', 'good evening']):
        greeting = f"👋 Hi {user_name}! How can I help you today?\n\n"
        
        if user_context.get('upcoming_bookings'):
            count = len(user_context['upcoming_bookings'])
            greeting += f"📅 You have {count} upcoming appointment{'s' if count > 1 else ''}!\n\n"
        
        greeting += "I can help you with:\n\n" \
                   "🔍 Finding salons\n" \
                   "📅 Booking appointments\n" \
                   "📋 Viewing your bookings\n" \
                   "💅 Beauty tips\n\n" \
                   "What would you like to do?"
        
        actions['intent'] = 'greeting'
        return greeting, actions
    
    # ==================== MY BOOKINGS ====================
    if any(phrase in message_lower for phrase in ['my booking', 'my appointment', 'upcoming', 'show booking', 'view booking', 'past booking']):
        if user_context.get('upcoming_bookings'):
            response = f"📅 **Your Upcoming Appointments** ({len(user_context['upcoming_bookings'])} total)\n\n"
            
            for i, b in enumerate(user_context['upcoming_bookings'], 1):
                response += f"**{i}. {b['salon_name']}**\n"
                response += f"   📅 {b['date']} at {b['time']}\n"
                response += f"   ✂️ {b['service_name']}\n"
                response += f"   💰 ₹{b['price']} | {b['status']}\n"
                response += f"   👤 Staff: {b['staff']}\n\n"
            
            response += "💡 Need to cancel? Just say 'cancel booking'"
            
            actions['intent'] = 'my_bookings'
            actions['bookings'] = user_context['upcoming_bookings']
            return response, actions
        else:
            response = f"📅 Hi {user_name}! You don't have any upcoming appointments.\n\n"
            
            if user_context.get('completed_bookings', 0) > 0:
                response += f"✅ You've completed {user_context['completed_bookings']} bookings so far!\n\n"
            
            response += "Ready to book your next appointment? 💇‍♀️\n" \
                       "Browse salons in the **Explore** tab!"
            
            actions['intent'] = 'my_bookings'
            return response, actions
    
    # ==================== FIND SALONS ====================
    if any(word in message_lower for word in ['find salon', 'show salon', 'near me', 'search salon', 'salon near']):
        city = user_context.get('user_city', 'your area')
        
        response = f"🪒 **Looking for Salons?**\n\n"
        
        if user_context.get('favorite_salon'):
            response += f"💙 Your favorite: **{user_context['favorite_salon']}** " \
                       f"({user_context.get('favorite_salon_visits', 0)} visits)\n\n"
        
        response += f"I can help you find salons{f' in {city}' if city != 'your area' else ''}!\n\n" \
                   "**Quick Actions:**\n" \
                   "• Open the **Explore** tab\n" \
                   "• Browse by ratings & location\n" \
                   "• Check services & prices\n" \
                   "• Read reviews from customers\n\n" \
                   "📍 Or tell me your city to search!"
        
        actions['intent'] = 'find_salon'
        actions['suggest_explore'] = True
        return response, actions
    
    # ==================== BOOKING HELP ====================
    if any(word in message_lower for word in ['book', 'appointment', 'schedule', 'how to book']):
        response = "📅 **Ready to Book Your Appointment?**\n\n" \
                  "It's super easy! Just follow these steps:\n\n" \
                  "1️⃣ Open the **Explore** tab\n" \
                  "2️⃣ Choose your favorite salon\n" \
                  "3️⃣ Select a service\n" \
                  "4️⃣ Pick your preferred date & time\n" \
                  "5️⃣ Confirm your booking!\n\n"
        
        if user_context.get('favorite_service'):
            response += f"💡 **Your favorite:** {user_context['favorite_service']}\n\n"
        
        response += "**Pro Tips:**\n" \
                   "⏰ Morning slots (9-11 AM) are less crowded\n" \
                   "📅 Book 2-3 days in advance for best availability\n" \
                   "💰 Check for special offers!"
        
        actions['intent'] = 'booking_help'
        return response, actions
    
    # ==================== BEAUTY TIPS ====================
    if any(word in message_lower for word in ['tip', 'advice', 'care', 'how to', 'recommend']):
        if 'hair' in message_lower:
            response = "💇‍♀️ **Haircare Tips:**\n\n" \
                      "✨ **Daily Care:**\n" \
                      "• Wash 2-3 times/week to keep natural oils\n" \
                      "• Use conditioner after every shampoo\n" \
                      "• Brush from ends to roots\n\n" \
                      "🔥 **Heat Protection:**\n" \
                      "• Limit heat styling to 2-3 times/week\n" \
                      "• Always use heat protectant spray\n" \
                      "• Use lowest effective temperature\n\n" \
                      "✂️ **Maintenance:**\n" \
                      "• Trim every 6-8 weeks\n" \
                      "• Deep condition weekly\n" \
                      "• Sleep on silk pillowcase"
        elif 'skin' in message_lower or 'face' in message_lower:
            response = "✨ **Skincare Routine:**\n\n" \
                      "🌅 **Morning:**\n" \
                      "1. Cleanser\n" \
                      "2. Toner\n" \
                      "3. Serum (Vitamin C)\n" \
                      "4. Moisturizer\n" \
                      "5. Sunscreen SPF 30+\n\n" \
                      "🌙 **Evening:**\n" \
                      "1. Makeup remover\n" \
                      "2. Cleanser\n" \
                      "3. Toner\n" \
                      "4. Treatment/Serum\n" \
                      "5. Night cream\n\n" \
                      "💧 Drink 8 glasses of water daily!\n" \
                      "😴 Get 7-8 hours of sleep"
        else:
            response = "💅 **General Beauty Tips:**\n\n" \
                      "**Haircare:**\n" \
                      "• Wash 2-3x/week, not daily\n" \
                      "• Trim every 6-8 weeks\n" \
                      "• Use heat protectant\n\n" \
                      "**Skincare:**\n" \
                      "• Cleanse twice daily\n" \
                      "• Always wear sunscreen\n" \
                      "• Stay hydrated (8 glasses/day)\n\n" \
                      "**Salon Visits:**\n" \
                      "• Book 2-3 days ahead\n" \
                      "• Bring reference photos\n" \
                      "• Communicate with your stylist\n\n" \
                      "Want specific advice? Ask about haircare, skincare, or nails!"
        
        actions['intent'] = 'beauty_tips'
        return response, actions
    
    # ==================== PRICING ====================
    if any(word in message_lower for word in ['price', 'cost', 'how much', 'pricing']):
        response = "💰 **Service Pricing Guide**\n\n" \
                  "Prices vary by salon location, reputation, and stylist experience.\n\n" \
                  "**Average Price Ranges:**\n" \
                  "💇 Haircut: ₹200 - ₹800\n" \
                  "🎨 Hair Color: ₹1,500 - ₹5,000\n" \
                  "✨ Hair Spa: ₹800 - ₹2,500\n" \
                  "💆 Spa Treatment: ₹1,000 - ₹3,500\n" \
                  "💅 Manicure: ₹300 - ₹800\n" \
                  "💅 Pedicure: ₹400 - ₹1,200\n\n"
        
        if user_context.get('total_spent', 0) > 0:
            response += f"📊 **Your Stats:**\n" \
                       f"Total spent: ₹{user_context['total_spent']:,.0f}\n" \
                       f"Total visits: {user_context.get('completed_bookings', 0)}\n\n"
        
        response += "💡 Browse salons for exact pricing and special offers!"
        
        actions['intent'] = 'pricing'
        return response, actions
    
    # ==================== CANCEL BOOKING ====================
    if 'cancel' in message_lower:
        if user_context.get('upcoming_bookings'):
            response = f"⚠️ **Cancel Appointment**\n\n" \
                      f"You have {len(user_context['upcoming_bookings'])} upcoming appointment(s):\n\n"
            
            for i, b in enumerate(user_context['upcoming_bookings'], 1):
                response += f"{i}. {b['salon_name']} - {b['date']} at {b['time']}\n"
            
            response += "\n📱 To cancel:\n" \
                       "1. Go to the **Bookings** tab\n" \
                       "2. Select the appointment\n" \
                       "3. Tap 'Cancel Booking'\n\n" \
                       "💡 Note: Check the salon's cancellation policy!"
            
            actions['intent'] = 'cancel_booking'
            actions['cancelable_bookings'] = [b['id'] for b in user_context['upcoming_bookings']]
            return response, actions
        else:
            response = "📅 You don't have any appointments to cancel."
            actions['intent'] = 'cancel_booking'
            return response, actions
    
    # ==================== USER HISTORY ====================
    if 'history' in message_lower or 'past' in message_lower or 'previous' in message_lower:
        response = f"📊 **Your Booking History**\n\n"
        response += f"📈 **Stats:**\n" \
                   f"• Total bookings: {user_context.get('total_bookings', 0)}\n" \
                   f"• Completed: {user_context.get('completed_bookings', 0)}\n"
        
        if user_context.get('total_spent', 0) > 0:
            response += f"• Total spent: ₹{user_context['total_spent']:,.0f}\n"
        
        if user_context.get('favorite_salon'):
            response += f"\n💙 **Favorite Salon:**\n" \
                       f"{user_context['favorite_salon']} ({user_context.get('favorite_salon_visits', 0)} visits)\n"
        
        if user_context.get('favorite_service'):
            response += f"\n✂️ **Most Booked:**\n" \
                       f"{user_context['favorite_service']} ({user_context.get('favorite_service_bookings', 0)}x)\n"
        
        if user_context.get('last_booking'):
            last = user_context['last_booking']
            response += f"\n🕐 **Last Visit:**\n" \
                       f"{last['salon']} - {last['date']}\n" \
                       f"({last['how_long_ago_days']} days ago)\n"
        
        response += "\n🌟 Thanks for being a valued customer!"
        
        actions['intent'] = 'user_history'
        return response, actions
    
    # ==================== DEFAULT HELPFUL ====================
    response = f"👋 Hi {user_name}! I'm your SalonCare AI assistant.\n\n" \
              "**I can help you with:**\n\n" \
              "🔍 **Find Salons**\n" \
              "   \"Show salons near me\"\n" \
              "   \"Find salons in [city]\"\n\n" \
              "📅 **Bookings**\n" \
              "   \"Show my bookings\"\n" \
              "   \"How do I book?\"\n\n" \
              "💅 **Beauty Advice**\n" \
              "   \"Haircare tips\"\n" \
              "   \"Skincare routine\"\n\n" \
              "💰 **Pricing**\n" \
              "   \"How much does a haircut cost?\"\n\n" \
              "What would you like to know?"
    
    if user_context.get('upcoming_bookings'):
        response += f"\n\n📅 BTW, you have {len(user_context['upcoming_bookings'])} upcoming appointment(s)!"
    
    actions['intent'] = 'help'
    return response, actions


def generate_gemini_enhancement(message, user_context, conversation_history, fallback_response):
    """Try to enhance the response with Gemini, but don't fail if it doesn't work"""
    try:
        system_prompt = f"""You are SalonCare AI assistant. The user asked: "{message}"

USER CONTEXT:
- Name: {user_context['user_name']}
- City: {user_context.get('user_city', 'Not specified')}
- Total bookings: {user_context.get('total_bookings', 0)}
- Upcoming: {len(user_context.get('upcoming_bookings', []))}

BASIC RESPONSE (already generated):
{fallback_response}

YOUR TASK: Make this response MORE natural, friendly, and personalized.
Keep it under 200 words. Add relevant emojis. Use user's name."""

        model = genai.GenerativeModel('models/gemini-2.0-flash')
        response = model.generate_content(
            system_prompt,
            generation_config={
                'temperature': 0.8,
                'max_output_tokens': 400,
            }
        )
        
        return response.text.strip()
    except:
        return None  # Use fallback


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
            "How much does a haircut cost?",
            "Cancel an appointment",
        ])
        
        return Response({'suggestions': suggestions[:8]})
        
    except Customer.DoesNotExist:
        return Response({
            'suggestions': [
                "Find salons near me",
                "How do I book?",
                "Beauty tips",
                "Show pricing",
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