# chatbot/user_chatbot_views_OPTIMIZED.py
# 🚀 FULLY OPTIMIZED USER CHATBOT with Perfect Intent Detection

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
from django.core.cache import cache
import os
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
        print("⚠️ Gemini AI not available - using optimized fallback")
except ImportError:
    GEMINI_AVAILABLE = False
    print("⚠️ google-generativeai not installed - using optimized fallback")


@api_view(['POST'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def user_chatbot(request):
    """
    🚀 FULLY OPTIMIZED USER CHATBOT
    ✅ Better intent detection
    ✅ Personalized responses
    ✅ Cached user context
    ✅ Gemini AI integration
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
                email=request.user.email,
            )
        
        # ✅ OPTIMIZED: Cache user context for 60 seconds
        cache_key = f'user_context_{customer.user.id}'
        user_context = cache.get(cache_key)
        if not user_context:
            user_context = build_complete_user_context(customer)
            cache.set(cache_key, user_context, 60)
        
        # ✅ IMPROVED: Better intent detection
        intent = detect_user_intent_improved(message, user_context)
        print(f"🎯 Detected intent: {intent}")
        
        # Generate response
        if GEMINI_AVAILABLE:
            try:
                response_text, actions = generate_gemini_response(
                    message, user_context, intent, customer
                )
            except Exception as e:
                print(f"⚠️ Gemini failed, using smart fallback: {e}")
                response_text, actions = generate_smart_response_improved(
                    message, user_context, intent, customer
                )
        else:
            response_text, actions = generate_smart_response_improved(
                message, user_context, intent, customer
            )
        
        # Save conversation
        UserChatHistory.objects.create(
            user=request.user,
            user_message=message,
            bot_response=response_text,
            intent=intent
        )
        
        print(f"🤖 BOT RESPONSE: {response_text[:100]}...")
        print(f"📊 Actions: {actions}")
        print(f"{'='*60}\n")
        
        return Response({
            'response': response_text,
            'timestamp': datetime.now().isoformat(),
            'intent': intent,
            'actions': actions,
        })
        
    except Exception as e:
        print(f"❌ Chatbot error: {e}")
        import traceback
        traceback.print_exc()
        return Response(
            {
                'response': '😔 Sorry, I encountered an error. Please try again or contact support.',
                'error': str(e)
            },
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


def detect_user_intent_improved(message, user_context):
    """
    🎯 IMPROVED Intent Detection with Better Pattern Matching
    Fixed: No longer defaults to 'greeting' for everything
    """
    msg = message.lower().strip()
    
    # ===== EXACT MATCHES (HIGHEST PRIORITY) =====
    exact_patterns = {
        'my bookings': 'my_bookings',
        'my appointments': 'my_bookings',
        'show my bookings': 'my_bookings',
        'upcoming bookings': 'my_bookings',
        'my booking history': 'booking_history',
        'booking history': 'booking_history',
        'past bookings': 'booking_history',
        'cancel booking': 'cancel_booking',
        'cancel appointment': 'cancel_booking',
        'popular services': 'popular_services',
        'trending services': 'popular_services',
        'haircare tips': 'beauty_tips',
        'skincare tips': 'beauty_tips',
        'beauty tips': 'beauty_tips',
        'find salons': 'find_salon',
        'salons near me': 'find_salon',
        'nearby salons': 'find_salon',
        'how to book': 'booking_help',
        'book appointment': 'booking_help',
    }
    
    for pattern, intent in exact_patterns.items():
        if pattern in msg:
            return intent
    
    # ===== KEYWORD-BASED DETECTION =====
    
    # My bookings / appointments
    if any(k in msg for k in ['my booking', 'my appointment', 'upcoming', 'next appointment']):
        return 'my_bookings'
    
    # Booking history
    if ('history' in msg or 'past' in msg or 'previous' in msg) and ('booking' in msg or 'visit' in msg):
        return 'booking_history'
    
    # Popular/trending services
    if ('popular' in msg or 'trending' in msg or 'best' in msg) and 'service' in msg:
        return 'popular_services'
    
    # Popular services this month (specific pattern from logs)
    if 'popular' in msg and 'month' in msg:
        return 'popular_services'
    
    # Cancel booking
    if 'cancel' in msg and ('booking' in msg or 'appointment' in msg):
        return 'cancel_booking'
    
    # Best time to book / avoid crowds
    if any(k in msg for k in ['when should i book', 'avoid crowd', 'best time', 'busy', 'quiet']):
        return 'best_time_to_book'
    
    # Beauty tips
    if any(k in msg for k in ['hair tip', 'haircare', 'skin', 'beauty', 'care tip']):
        return 'beauty_tips'
    
    # Find salons
    if any(k in msg for k in ['find salon', 'search salon', 'near me', 'nearby', 'show salon']):
        return 'find_salon'
    
    # City-based search (single word city names)
    known_cities = ['surat', 'ahmedabad', 'vadodara', 'rajkot', 'gandhinagar', 
                    'mumbai', 'delhi', 'bangalore', 'pune', 'hyderabad']
    if msg in known_cities or (msg.replace(' ', '') in known_cities):
        return 'find_salon_city'
    
    # Booking help
    if ('book' in msg or 'appointment' in msg or 'schedule' in msg) and not 'cancel' in msg:
        return 'booking_help'
    
    # Pricing
    if any(k in msg for k in ['price', 'cost', 'how much', 'pricing', 'expensive', 'cheap']):
        return 'pricing'
    
    # Salon hours
    if any(k in msg for k in ['open', 'close', 'hours', 'timing', 'time']):
        return 'salon_hours'
    
    # Recommendations
    if any(k in msg for k in ['recommend', 'suggest', 'which salon', 'best salon']):
        return 'recommendations'
    
    # Greetings (only if actually a greeting)
    greeting_words = ['hi', 'hello', 'hey', 'good morning', 'good afternoon', 'good evening']
    if msg in greeting_words or any(msg.startswith(g) and len(msg) < 20 for g in greeting_words):
        return 'greeting'
    
    # Help / What can you do
    if any(k in msg for k in ['help', 'what can you', 'how can you', 'capabilities']):
        return 'help'
    
    # Default to general (NOT greeting)
    return 'general_query'


def build_complete_user_context(customer):
    """
    🔍 OPTIMIZED: Build complete user context with caching
    """
    context = {
        'user_name': customer.full_name or 'there',
        'user_email': customer.email,
        'user_city': customer.city or None,
        'user_phone': customer.phone or None,
    }
    
    try:
        # Get ALL bookings (optimized query)
        all_bookings = Booking.objects.filter(
            user=customer.user
        ).select_related('salon', 'service', 'staff').order_by('-booking_date', '-booking_time')
        
        context['total_bookings'] = all_bookings.count()
        
        # Upcoming bookings
        upcoming = all_bookings.filter(
            booking_date__gte=timezone.now().date()
        ).exclude(status__iexact='CANCELLED')[:10]
        
        context['upcoming_bookings'] = [{
            'id': b.id,
            'salon_name': b.salon.name,
            'service_name': b.service.name,
            'date': b.booking_date.strftime('%b %d, %Y'),
            'time': b.booking_time.strftime('%I:%M %p') if b.booking_time else 'TBD',
            'status': b.status,
            'price': float(b.price) if b.price else 0,
        } for b in upcoming]
        
        # Completed bookings
        completed = all_bookings.filter(status__iexact='COMPLETED')
        context['completed_bookings'] = completed.count()
        
        # Total spent
        total_spent = completed.aggregate(total=Sum('price'))['total'] or 0
        context['total_spent'] = float(total_spent)
        
        # Favorite salon
        fav_salon = completed.values('salon__id', 'salon__name').annotate(
            visits=Count('id')
        ).order_by('-visits').first()
        
        if fav_salon:
            context['favorite_salon'] = fav_salon['salon__name']
            context['favorite_salon_visits'] = fav_salon['visits']
        
        # Favorite service
        fav_service = completed.values('service__id', 'service__name').annotate(
            count=Count('id')
        ).order_by('-count').first()
        
        if fav_service:
            context['favorite_service'] = fav_service['service__name']
            context['favorite_service_bookings'] = fav_service['count']
        
        # Last booking
        last = completed.first()
        if last:
            days_ago = (timezone.now().date() - last.booking_date).days
            context['last_booking'] = {
                'salon': last.salon.name,
                'service': last.service.name,
                'date': last.booking_date.strftime('%b %d, %Y'),
                'how_long_ago_days': days_ago,
            }
        
    except Exception as e:
        print(f"⚠️ Error building user context: {e}")
    
    return context


def generate_smart_response_improved(message, user_context, intent, customer):
    """
    🚀 IMPROVED Smart Response Generator
    ✅ Better organized by intent
    ✅ More personalized
    ✅ Actionable responses
    """
    user_name = user_context.get('user_name', 'there')
    actions = {'intent': intent}
    
    # ==================== GREETING ====================
    if intent == 'greeting':
        response = f"👋 Hi {user_name}! Welcome to SalonCare!\n\n"
        
        upcoming_count = len(user_context.get('upcoming_bookings', []))
        if upcoming_count > 0:
            response += f"📅 You have **{upcoming_count} upcoming appointment{'s' if upcoming_count > 1 else ''}**!\n\n"
        
        response += "I can help you with:\n" \
                   "• 🔍 Finding nearby salons\n" \
                   "• 📅 Managing bookings\n" \
                   "• 💅 Beauty & haircare tips\n" \
                   "• 💰 Service pricing info\n\n" \
                   "What would you like to do today?"
        
        return response, actions
    
    # ==================== MY BOOKINGS ====================
    if intent == 'my_bookings':
        upcoming = user_context.get('upcoming_bookings', [])
        
        if upcoming:
            response = f"📅 **Your Upcoming Appointments** ({len(upcoming)})\n\n"
            
            for i, booking in enumerate(upcoming[:5], 1):
                response += f"**{i}. {booking['salon_name']}**\n" \
                           f"   📍 Service: {booking['service_name']}\n" \
                           f"   📅 {booking['date']} at {booking['time']}\n" \
                           f"   💰 ₹{booking['price']:,.0f}\n" \
                           f"   ✅ Status: {booking['status']}\n\n"
            
            response += "💡 Tip: Arrive 5 minutes early for best service!"
            
            actions['bookings'] = upcoming
        else:
            response = "📅 **No Upcoming Appointments**\n\n" \
                      "Looks like you're all clear! Time for a fresh look?\n\n" \
                      "🌟 **Quick Actions:**\n" \
                      "• Browse nearby salons\n" \
                      "• Check popular services\n" \
                      "• See pricing guides\n\n"
            
            if user_context.get('favorite_salon'):
                response += f"💙 Your favorite: **{user_context['favorite_salon']}**"
        
        return response, actions
    
    # ==================== BOOKING HISTORY ====================
    if intent == 'booking_history':
        response = f"📊 **Your Booking History**\n\n"
        response += f"📈 **Overall Stats:**\n" \
                   f"• Total visits: {user_context.get('total_bookings', 0)}\n" \
                   f"• Completed: {user_context.get('completed_bookings', 0)}\n"
        
        if user_context.get('total_spent', 0) > 0:
            response += f"• Total spent: ₹{user_context['total_spent']:,.0f}\n"
        
        if user_context.get('favorite_salon'):
            response += f"\n💙 **Favorite Salon:**\n" \
                       f"{user_context['favorite_salon']} ({user_context.get('favorite_salon_visits', 0)} visits)\n"
        
        if user_context.get('favorite_service'):
            response += f"\n✂️ **Most Booked Service:**\n" \
                       f"{user_context['favorite_service']} ({user_context.get('favorite_service_bookings', 0)}x)\n"
        
        if user_context.get('last_booking'):
            last = user_context['last_booking']
            response += f"\n🕐 **Last Visit:**\n" \
                       f"{last['salon']} - {last['date']}\n" \
                       f"({last['how_long_ago_days']} days ago)\n"
        
        response += "\n🌟 Thanks for being a valued customer!"
        
        return response, actions
    
    # ==================== POPULAR SERVICES ====================
    if intent == 'popular_services':
        try:
            # Get popular services from recent bookings
            month_ago = timezone.now().date() - timedelta(days=30)
            popular = Booking.objects.filter(
                booking_date__gte=month_ago
            ).values('service__name', 'service__price').annotate(
                count=Count('id')
            ).order_by('-count')[:8]
            
            if popular:
                response = "✨ **Trending Services This Month**\n\n"
                
                for i, service in enumerate(popular, 1):
                    name = service['service__name']
                    count = service['count']
                    price = service['service__price'] or 0
                    
                    response += f"**{i}. {name}**\n" \
                               f"   🔥 {count} bookings\n" \
                               f"   💰 ₹{price:,.0f}\n\n"
                
                response += "💡 Ready to try something new?"
                
                actions['popular_services'] = list(popular)
            else:
                response = "📊 No trending data available yet.\n\n" \
                          "Browse salons to see all available services!"
        except Exception as e:
            print(f"Error fetching popular services: {e}")
            response = "💅 **Popular Beauty Services:**\n\n" \
                      "• Haircut & Styling\n" \
                      "• Hair Coloring\n" \
                      "• Hair Spa Treatment\n" \
                      "• Facial & Cleanup\n" \
                      "• Manicure & Pedicure\n\n" \
                      "Browse salons for exact services!"
        
        return response, actions
    
    # ==================== BEAUTY TIPS ====================
    if intent == 'beauty_tips':
        message_lower = message.lower()
        
        if 'hair' in message_lower:
            response = "💇 **Haircare Essentials**\n\n" \
                      "✨ **Daily Care:**\n" \
                      "• Wash 2-3 times/week (not daily!)\n" \
                      "• Use lukewarm water, never hot\n" \
                      "• Apply conditioner to ends only\n" \
                      "• Air dry when possible\n\n" \
                      "🌟 **Pro Tips:**\n" \
                      "• Trim every 6-8 weeks\n" \
                      "• Weekly deep conditioning masks\n" \
                      "• Minimize heat styling\n" \
                      "• Brush from ends to roots\n\n" \
                      "💡 Book a hair spa for deep nourishment!"
        
        elif 'skin' in message_lower or 'face' in message_lower:
            response = "✨ **Skincare Routine**\n\n" \
                      "🌅 **Morning:**\n" \
                      "1. Cleanser\n" \
                      "2. Toner\n" \
                      "3. Serum\n" \
                      "4. Moisturizer\n" \
                      "5. Sunscreen (SPF 30+)\n\n" \
                      "🌙 **Evening:**\n" \
                      "1. Makeup remover\n" \
                      "2. Cleanser\n" \
                      "3. Toner\n" \
                      "4. Treatment\n" \
                      "5. Night cream\n\n" \
                      "💡 Weekly: Exfoliate 2x, Face mask 1x"
        
        else:
            response = "💅 **General Beauty Tips**\n\n" \
                      "✨ **Salon Visits:**\n" \
                      "• Regular appointments maintain your look\n" \
                      "• Book 1-2 weeks in advance\n" \
                      "• Bring reference photos\n" \
                      "• Communicate clearly with stylist\n\n" \
                      "🌟 **At Home:**\n" \
                      "• Stay hydrated (8 glasses/day)\n" \
                      "• Get 7-8 hours sleep\n" \
                      "• Eat fruits & vegetables\n" \
                      "• Remove makeup before bed\n\n" \
                      "💡 Ask about haircare, skincare, or nails for specific tips!"
        
        return response, actions
    
    # ==================== FIND SALON / CITY ====================
    if intent in ['find_salon', 'find_salon_city']:
        city = user_context.get('user_city')
        
        # Try to extract city from message
        if intent == 'find_salon_city':
            city = message.strip().title()
        
        response = "🪒 **Looking for Salons?**\n\n"
        
        if user_context.get('favorite_salon'):
            response += f"💙 Your favorite: **{user_context['favorite_salon']}** ({user_context.get('favorite_salon_visits', 0)} visits)\n\n"
        
        if city:
            response += f"I can help you find the perfect salon in **{city}**!\n\n"
        else:
            response += "I can help you find the perfect salon!\n\n"
        
        response += "📍 **Browse Options:**\n" \
                   "• Head to the **Explore** tab\n" \
                   "• Filter by location & services\n" \
                   "• Check ratings & reviews\n" \
                   "• View photos & prices\n\n" \
                   "💡 **Quick Search:**\n" \
                   "Try: \"Find salons in [city name]\""
        
        actions['suggest_explore'] = True
        if city:
            actions['city'] = city
        
        return response, actions
    
    # ==================== BOOKING HELP ====================
    if intent == 'booking_help':
        response = "📅 **Ready to Book Your Appointment?**\n\n" \
                  "It's super easy! Just follow these steps:\n\n" \
                  "1️⃣ Open the **Explore** tab\n" \
                  "2️⃣ Choose your favorite salon\n" \
                  "3️⃣ Select the service you want\n" \
                  "4️⃣ Pick your preferred date & time\n" \
                  "5️⃣ Confirm your booking!\n\n" \
                  "✨ **Pro Tips:**\n" \
                  "• Morning slots (9-11 AM) are less crowded\n" \
                  "• Book 2-3 days ahead for best times\n" \
                  "• Check for special offers\n\n"
        
        if user_context.get('favorite_salon'):
            response += f"💙 Quick book at your favorite: **{user_context['favorite_salon']}**"
        
        return response, actions
    
    # ==================== BEST TIME TO BOOK ====================
    if intent == 'best_time_to_book':
        response = "🕐 **Best Times to Book**\n\n" \
                  "⏰ **Least Busy Hours:**\n" \
                  "• 9:00 AM - 11:00 AM (Morning fresh!)\n" \
                  "• 2:00 PM - 4:00 PM (Afternoon quiet)\n\n" \
                  "🚫 **Avoid These Times:**\n" \
                  "• 12:00 PM - 2:00 PM (Lunch rush)\n" \
                  "• 6:00 PM - 8:00 PM (Evening peak)\n\n" \
                  "📅 **Best Days:**\n" \
                  "• Weekdays (Tuesday - Thursday)\n" \
                  "• Early weekends (Saturday morning)\n\n" \
                  "💡 Book 2-3 days in advance for your preferred slot!"
        
        return response, actions
    
    # ==================== PRICING ====================
    if intent == 'pricing':
        response = "💰 **Service Pricing Guide**\n\n" \
                  "Prices vary by salon location, reputation & stylist experience.\n\n" \
                  "**Average Ranges:**\n" \
                  "💇 Haircut: ₹200 - ₹800\n" \
                  "🎨 Hair Color: ₹1,500 - ₹5,000\n" \
                  "✨ Hair Spa: ₹800 - ₹2,500\n" \
                  "💆 Full Spa: ₹1,000 - ₹3,500\n" \
                  "💅 Manicure: ₹300 - ₹800\n" \
                  "💅 Pedicure: ₹400 - ₹1,200\n\n"
        
        if user_context.get('total_spent', 0) > 0:
            avg_spent = user_context['total_spent'] / max(user_context.get('completed_bookings', 1), 1)
            response += f"📊 **Your Stats:**\n" \
                       f"• Total spent: ₹{user_context['total_spent']:,.0f}\n" \
                       f"• Avg per visit: ₹{avg_spent:,.0f}\n\n"
        
        response += "💡 Browse salons for exact pricing & special offers!"
        
        return response, actions
    
    # ==================== CANCEL BOOKING ====================
    if intent == 'cancel_booking':
        upcoming = user_context.get('upcoming_bookings', [])
        
        if upcoming:
            response = f"⚠️ **Cancel Appointment**\n\n" \
                      f"You have {len(upcoming)} upcoming appointment(s):\n\n"
            
            for i, b in enumerate(upcoming[:3], 1):
                response += f"**{i}. {b['salon_name']}**\n" \
                           f"   {b['date']} at {b['time']}\n\n"
            
            response += "📱 **To Cancel:**\n" \
                       "1. Open the **Bookings** tab\n" \
                       "2. Select the appointment\n" \
                       "3. Tap 'Cancel Booking'\n\n" \
                       "💡 Note: Check cancellation policy!"
            
            actions['cancelable_bookings'] = [b['id'] for b in upcoming]
        else:
            response = "📅 You don't have any appointments to cancel."
        
        return response, actions
    
    # ==================== SALON HOURS ====================
    if intent == 'salon_hours':
        response = "🕐 **Typical Salon Hours**\n\n" \
                  "Most salons operate:\n" \
                  "• **Weekdays:** 9:00 AM - 8:00 PM\n" \
                  "• **Weekends:** 9:00 AM - 9:00 PM\n\n" \
                  "⏰ **Best Times to Visit:**\n" \
                  "• Morning (9-11 AM) - Less crowded\n" \
                  "• Afternoon (2-4 PM) - Peaceful\n" \
                  "• Avoid lunch (12-2 PM) & evening rush (6-8 PM)\n\n" \
                  "💡 Check specific salon hours in their profile!"
        
        return response, actions
    
    # ==================== RECOMMENDATIONS ====================
    if intent == 'recommendations':
        response = "🌟 **Finding Your Perfect Salon**\n\n"
        
        if user_context.get('favorite_salon'):
            response += f"💙 Based on your history, you love:\n" \
                       f"**{user_context['favorite_salon']}** ({user_context.get('favorite_salon_visits', 0)} visits)\n\n"
        
        response += "✨ **What to Look For:**\n" \
                   "• ⭐ High ratings (4.0+)\n" \
                   "• 📍 Convenient location\n" \
                   "• 💰 Good value for money\n" \
                   "• 👥 Experienced stylists\n\n" \
                   "📱 Browse the **Explore** tab to:\n" \
                   "• Read reviews\n" \
                   "• See photos\n" \
                   "• Compare prices\n" \
                   "• Check availability"
        
        return response, actions
    
    # ==================== HELP ====================
    if intent == 'help':
        response = f"👋 Hi {user_name}! I'm your SalonCare AI assistant.\n\n" \
                  "**I can help you with:**\n\n" \
                  "🔍 **Find Salons**\n" \
                  "   \"Show salons near me\"\n" \
                  "   \"Find salons in [city]\"\n\n" \
                  "📅 **Manage Bookings**\n" \
                  "   \"Show my bookings\"\n" \
                  "   \"Cancel appointment\"\n\n" \
                  "💅 **Beauty Advice**\n" \
                  "   \"Haircare tips\"\n" \
                  "   \"Skincare routine\"\n\n" \
                  "💰 **Pricing Info**\n" \
                  "   \"How much does a haircut cost?\"\n\n" \
                  "What would you like to know?"
        
        if user_context.get('upcoming_bookings'):
            response += f"\n\n📅 BTW, you have {len(user_context['upcoming_bookings'])} upcoming appointment(s)!"
        
        return response, actions
    
    # ==================== GENERAL QUERY ====================
    response = f"👋 Hi {user_name}! I can help you with:\n\n" \
              "• 🔍 Finding salons\n" \
              "• 📅 Managing bookings\n" \
              "• 💅 Beauty tips\n" \
              "• 💰 Pricing info\n\n" \
              "Try asking:\n" \
              "\"Find salons near me\"\n" \
              "\"Show my bookings\"\n" \
              "\"Haircare tips\"\n" \
              "\"Popular services\""
    
    return response, actions


def generate_gemini_response(message, user_context, intent, customer):
    """
    🤖 Generate Gemini AI Response
    Enhanced with user context and intent
    """
    try:
        user_summary = f"""
USER PROFILE:
- Name: {user_context.get('user_name', 'Guest')}
- Email: {user_context.get('user_email')}
- City: {user_context.get('user_city', 'Not specified')}

BOOKING STATS:
- Total bookings: {user_context.get('total_bookings', 0)}
- Completed: {user_context.get('completed_bookings', 0)}
- Upcoming: {len(user_context.get('upcoming_bookings', []))}
- Total spent: ₹{user_context.get('total_spent', 0):,.0f}
"""
        
        if user_context.get('favorite_salon'):
            user_summary += f"\n- Favorite Salon: {user_context['favorite_salon']} ({user_context.get('favorite_salon_visits', 0)} visits)"
        
        if user_context.get('favorite_service'):
            user_summary += f"\n- Most Booked: {user_context['favorite_service']}"
        
        system_prompt = f"""You are SalonCare AI, a friendly beauty & wellness assistant for customers.

{user_summary}

DETECTED INTENT: {intent}
USER QUESTION: "{message}"

YOUR ROLE:
- Help find salons and services
- Answer beauty questions
- Assist with bookings
- Provide personalized recommendations
- Be warm, friendly, and helpful

INSTRUCTIONS:
- Keep responses concise (150-250 words)
- Use emojis to be friendly
- Be personal - use their name: {user_context.get('user_name')}
- Provide actionable next steps
- If finding salons, guide them to the Explore tab
- For bookings, explain the process clearly

YOUR FRIENDLY RESPONSE:"""
        
        model = genai.GenerativeModel('models/gemini-2.0-flash')
        
        response = model.generate_content(
            system_prompt,
            generation_config={
                'temperature': 0.8,
                'max_output_tokens': 500,
            }
        )
        
        return response.text.strip(), {'intent': intent, 'ai_enhanced': True}
        
    except Exception as e:
        print(f"Gemini Error: {e}")
        raise


@api_view(['GET'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def user_suggestions_smart(request):
    """
    💡 OPTIMIZED: Smart contextual suggestions
    """
    try:
        customer = Customer.objects.get(user=request.user)
        
        # Use cached context
        cache_key = f'user_context_{customer.user.id}'
        context = cache.get(cache_key)
        if not context:
            context = build_complete_user_context(customer)
            cache.set(cache_key, context, 60)
        
        suggestions = []
        
        # Dynamic suggestions based on user state
        upcoming_count = len(context.get('upcoming_bookings', []))
        
        if upcoming_count > 0:
            suggestions.append(f"My {upcoming_count} upcoming appointment{'s' if upcoming_count > 1 else ''}")
            suggestions.append("When is my next appointment?")
        else:
            suggestions.append("Find salons near me")
            if context.get('favorite_salon'):
                suggestions.append(f"Book at {context['favorite_salon']}")
        
        if context.get('favorite_service'):
            suggestions.append(f"Book {context['favorite_service']}")
        
        if context.get('last_booking'):
            days_ago = context['last_booking']['how_long_ago_days']
            if days_ago > 30:
                suggestions.append("Time for a salon visit?")
        
        # Standard helpful suggestions
        suggestions.extend([
            "Popular services this month",
            "Haircare tips for my hair",
            "How much does a haircut cost?",
            "When should I book to avoid crowds?",
        ])
        
        return Response({'suggestions': suggestions[:8]})
        
    except Customer.DoesNotExist:
        return Response({
            'suggestions': [
                "Find salons near me",
                "How do I book an appointment?",
                "Beauty & haircare tips",
                "Service pricing guide",
                "Popular services",
                "Best time to book",
            ]
        })


@api_view(['DELETE'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def clear_user_chat_history(request):
    """Clear user chat history"""
    try:
        deleted_count = UserChatHistory.objects.filter(
            user=request.user
        ).delete()[0]
        
        # Clear cached context
        cache_key = f'user_context_{request.user.id}'
        cache.delete(cache_key)
        
        return Response({
            'message': f'Chat history cleared ({deleted_count} messages deleted)',
            'success': True
        })
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )