# chatbot/views.py

from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from authentication.firebase_auth import FirebaseAuthentication
from salons.models import Salon
from staff.models import Employee
from datetime import datetime, timedelta
from django.db.models import Sum, Count, Avg, Q
from django.utils import timezone
import os
from .models import ChatHistory

# ✅ GEMINI IMPORT (instead of OpenAI)
try:
    import google.generativeai as genai
    
    # Configure Gemini with API key
    GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
    if GEMINI_API_KEY:
        genai.configure(api_key=GEMINI_API_KEY)
        GEMINI_AVAILABLE = True
    else:
        GEMINI_AVAILABLE = False
        print("⚠️ GEMINI_API_KEY not found in environment")
except ImportError:
    GEMINI_AVAILABLE = False
    print("⚠️ google-generativeai not installed. Run: pip install google-generativeai")


@api_view(['POST'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def admin_chatbot(request):
    """
    AI-Powered Chatbot for Salon Owners with Gemini Integration
    """
    try:
        message = request.data.get('message', '').strip()
        
        if not message:
            return Response(
                {'error': 'Message is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        print(f"[CHATBOT] Received: {message}")
        print(f"[USER] From: {request.user.email}")
        
        # Get user's salon
        try:
            salon = Salon.objects.get(owner=request.user)
        except Salon.DoesNotExist:
            return Response({
                'response': 'Please create your salon profile first to use the AI assistant.',
                'intent': 'no_salon'
            })
        
        # ✅ NEW: Check if user wants to add staff
        should_create, staff_data = handle_staff_creation_intent(message, salon, request.user)
        
        if should_create:
            success, result = create_staff_member(salon, staff_data)
            
            if success:
                # Staff created successfully
                employee = result
                response_text = f"""✅ **Staff Member Added Successfully!**

I've added **{employee.full_name}** to your team at {salon.name}! 🎉

**Details:**
- Name: {employee.full_name}
- Role: {employee.get_role_display()}
- Primary Skill: {employee.get_primary_skill_display()}
- Email: {employee.email}
- Status: Active ✓

Your team now has {Employee.objects.filter(salon=salon, is_active=True).count()} active members!

Would you like to add another staff member or check your team?"""
            else:
                # Failed to create
                response_text = f"""❌ I encountered an error while adding the staff member.

Error: {result}

Please try adding them manually through the Staff section, or provide the details again."""
        else:
            # Normal chatbot flow
            salon_context = get_salon_data_context(salon)
            conversation_history = get_conversation_history(request.user, salon)
            
            if GEMINI_AVAILABLE:
                response_text = generate_gemini_response(
                    message, 
                    salon_context, 
                    conversation_history
                )
            else:
                response_text = generate_fallback_response(message, salon_context)
        
        # Save chat to history
        ChatHistory.objects.create(
            user=request.user,
            salon=salon,
            user_message=message,
            bot_response=response_text
        )
        
        # Detect intent
        intent = detect_admin_intent(message)
        
        print(f"[BOT] Responding: {response_text[:100]}...")
        
        return Response({
            'response': response_text,
            'timestamp': datetime.now().isoformat(),
            'intent': intent,
            'salon_id': salon.id,
            'staff_created': should_create  # ✅ NEW: Flag for frontend
        })
        
    except Exception as e:
        print(f"[ERROR] Chatbot error: {str(e)}")
        import traceback
        traceback.print_exc()
        return Response(
            {'response': 'I apologize, I encountered an error. Please try again.'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


def handle_staff_creation_intent(user_message, salon, user):
    """
    Detect if user wants to add staff and extract details
    Returns: (should_create, staff_data) tuple
    """
    message_lower = user_message.lower()
    
    # Check if user wants to add staff
    if not any(phrase in message_lower for phrase in ['add staff', 'new staff', 'hire', 'add employee', 'new employee']):
        return (False, None)
    
    # Try to extract staff details from message
    # This is a simple parser - you can make it more sophisticated
    lines = user_message.split('\n')
    
    staff_data = {
        'full_name': None,
        'role': 'stylist',  # default
        'primary_skill': 'hair_styling',  # default
        'email': None,
        'phone': None,
    }
    
    # Look for patterns like "Name: John Doe"
    for line in lines:
        line = line.strip()
        
        # Extract name
        if 'name:' in line.lower() or 'name -' in line.lower():
            name = line.split(':', 1)[-1].split('-', 1)[-1].strip().strip('*')
            staff_data['full_name'] = name
        
        # Extract role
        if 'role:' in line.lower() or 'role -' in line.lower():
            role_text = line.lower()
            if 'barber' in role_text:
                staff_data['role'] = 'barber'
            elif 'stylist' in role_text:
                staff_data['role'] = 'stylist'
            elif 'manager' in role_text:
                staff_data['role'] = 'manager'
            elif 'receptionist' in role_text:
                staff_data['role'] = 'receptionist'
            elif 'specialist' in role_text:
                staff_data['role'] = 'specialist'
        
        # Extract skills
        if 'skill' in line.lower():
            skill_text = line.lower()
            if 'hair' in skill_text or 'haircut' in skill_text:
                staff_data['primary_skill'] = 'hair_cutting'
            elif 'color' in skill_text:
                staff_data['primary_skill'] = 'coloring'
            elif 'beard' in skill_text:
                staff_data['primary_skill'] = 'beard_trim'
            elif 'spa' in skill_text:
                staff_data['primary_skill'] = 'spa'
            elif 'massage' in skill_text:
                staff_data['primary_skill'] = 'massage'
            elif 'nail' in skill_text:
                staff_data['primary_skill'] = 'nails'
            elif 'makeup' in skill_text:
                staff_data['primary_skill'] = 'makeup'
    
    # Check if we have minimum required data
    if staff_data['full_name']:
        # Generate email if not provided
        if not staff_data['email']:
            # Create email from name
            name_parts = staff_data['full_name'].lower().split()
            staff_data['email'] = f"{''.join(name_parts)}@{salon.name.lower().replace(' ', '')}.com"
        
        # Generate phone if not provided
        if not staff_data['phone']:
            import random
            staff_data['phone'] = f"{''.join([str(random.randint(0, 9)) for _ in range(10)])}"
        
        return (True, staff_data)
    
    return (False, None)


def create_staff_member(salon, staff_data):
    """
    Actually create a staff member in the database
    """
    try:
        # Import here to avoid circular imports
        from staff.models import Employee
        from accounts.models import User
        
        # Create user account
        user = User.objects.create_user(
            username=staff_data['email'],
            email=staff_data['email'],
            role='EMPLOYEE'
        )
        
        # Create employee
        employee = Employee.objects.create(
            user=user,
            salon=salon,
            full_name=staff_data['full_name'],
            email=staff_data['email'],
            phone=staff_data['phone'],
            role=staff_data['role'],
            primary_skill=staff_data['primary_skill'],
            is_active=True
        )
        
        return (True, employee)
        
    except Exception as e:
        print(f"[ERROR] Failed to create staff: {str(e)}")
        return (False, str(e))

# ✅ NEW FUNCTION: Generate response using Gemini
def generate_gemini_response(user_message, salon_context, conversation_history):
    """
    Generate response using Google Gemini API with salon-specific data
    """
    try:
        # Build staff info string
        staff_info = ""
        if salon_context.get('total_staff', 0) > 0:
            staff_info = f"- Staff: {salon_context['total_staff']} active employees"
            if salon_context.get('staff_names'):
                staff_info += f"\n  - Team: {', '.join(salon_context['staff_names'])}"
            if salon_context.get('staff_by_role'):
                role_breakdown = ', '.join([f"{count} {role}" for role, count in salon_context['staff_by_role'].items()])
                staff_info += f"\n  - Roles: {role_breakdown}"
            if salon_context.get('staff_skills'):
                skill_breakdown = ', '.join([f"{count} {skill}" for skill, count in salon_context['staff_skills'].items()])
                staff_info += f"\n  - Skills: {skill_breakdown}"
        
        # Build services info
        services_info = ""
        if salon_context.get('popular_services'):
            services_info = f"- Popular services: {', '.join([s['name'] for s in salon_context['popular_services']])}"
        
        # Build system prompt with salon context
        system_prompt = f"""You are SalonCare AI, an intelligent assistant for salon management. 

You are helping manage {salon_context['salon_name']} located in {salon_context.get('salon_location', 'N/A')}.

CURRENT SALON DATA:
- Today's bookings: {salon_context.get('today_bookings_count', 0)} appointments
  - Confirmed: {salon_context.get('today_bookings_confirmed', 0)}
  - Pending: {salon_context.get('today_bookings_pending', 0)}
  - Completed: {salon_context.get('today_bookings_completed', 0)}
  
- This week: {salon_context.get('week_bookings_count', 0)} bookings, Revenue: ₹{salon_context.get('week_revenue', 0):,.0f}

- This month: {salon_context.get('month_bookings_count', 0)} bookings, Revenue: ₹{salon_context.get('month_revenue', 0):,.0f}

{staff_info}

{services_info}

INSTRUCTIONS:
1. Always use the REAL data provided above in your responses
2. Be specific with numbers and names from the actual salon data
3. Provide actionable insights and recommendations based on the data
4. Use emojis to make responses engaging (📊 💰 📅 👥 ✂️ 💡)
5. Keep responses concise but informative (max 300 words)
6. If asked about data not available, politely mention it and suggest tracking it
7. Always be professional yet friendly and conversational
8. Focus on business growth, efficiency, and customer satisfaction
9. When giving recommendations, be specific and actionable

Remember: You're helping a real salon owner manage their business better!

CONVERSATION HISTORY:
"""
        
        # Add conversation history
        for msg in conversation_history[-6:]:
            role = "User" if msg['role'] == 'user' else "Assistant"
            system_prompt += f"\n{role}: {msg['content']}"
        
        # Add current question
        full_prompt = f"{system_prompt}\n\nUser: {user_message}\n\nAssistant:"
        
        # ✅✅✅ CRITICAL FIX HERE ✅✅✅
        model = genai.GenerativeModel('models/gemini-2.5-flash')  # ← CHANGED
        
        # Configure generation settings
        generation_config = {
            'temperature': 0.7,
            'top_p': 0.95,
            'top_k': 40,
            'max_output_tokens': 1000,
            'stop_sequences': None,
        }
        
        response = model.generate_content(
            full_prompt,
            generation_config=generation_config
        )
        
        return response.text.strip()
        
    except Exception as e:
        print(f"❌ Gemini Error: {str(e)}")
        import traceback
        traceback.print_exc()
        return generate_fallback_response(user_message, salon_context)

# Keep all the other functions the same (get_salon_data_context, get_conversation_history, etc.)
def get_salon_data_context(salon):
    """
    Gather real salon data for context
    """
    today = timezone.now().date()
    week_start = today - timedelta(days=today.weekday())
    month_start = today.replace(day=1)
    
    context = {
        'salon_name': salon.name,
        'salon_id': salon.id,
    }
    
    # Add location if available
    if hasattr(salon, 'city'):
        context['salon_location'] = f"{salon.city}, {salon.state}"
    elif hasattr(salon, 'address'):
        context['salon_location'] = salon.address
    else:
        context['salon_location'] = 'N/A'
    
    # Get bookings data
    try:
        from bookings.models import Booking
        
        # ✅ FIXED: booking_date instead of date
        today_bookings = Booking.objects.filter(
            salon=salon,
            booking_date=today  # ← CHANGED
        )
        context['today_bookings_count'] = today_bookings.count()
        
        # Check different possible status fields
        if hasattr(Booking, 'status'):
            context['today_bookings_confirmed'] = today_bookings.filter(status='confirmed').count()
            context['today_bookings_pending'] = today_bookings.filter(status='pending').count()
            context['today_bookings_completed'] = today_bookings.filter(status='completed').count()
        
        # ✅ FIXED: booking_date instead of date
        week_bookings = Booking.objects.filter(
            salon=salon,
            booking_date__gte=week_start,  # ← CHANGED
            booking_date__lte=today         # ← CHANGED
        )
        context['week_bookings_count'] = week_bookings.count()
        
        # Try to get revenue
        if hasattr(Booking, 'total_price'):
            context['week_revenue'] = week_bookings.aggregate(
                total=Sum('total_price')
            )['total'] or 0
            # ✅ FIXED: booking_date instead of date
            context['month_revenue'] = Booking.objects.filter(
                salon=salon,
                booking_date__gte=month_start  # ← CHANGED
            ).aggregate(total=Sum('total_price'))['total'] or 0
        elif hasattr(Booking, 'price'):
            context['week_revenue'] = week_bookings.aggregate(
                total=Sum('price')
            )['total'] or 0
            # ✅ FIXED: booking_date instead of date
            context['month_revenue'] = Booking.objects.filter(
                salon=salon,
                booking_date__gte=month_start  # ← CHANGED
            ).aggregate(total=Sum('price'))['total'] or 0
        
        # ✅ FIXED: booking_date instead of date
        context['month_bookings_count'] = Booking.objects.filter(
            salon=salon,
            booking_date__gte=month_start  # ← CHANGED
        ).count()
            
    except ImportError:
        print("⚠️ Booking model not found")
        context['today_bookings_count'] = 0
        context['week_bookings_count'] = 0
        context['month_bookings_count'] = 0
        context['week_revenue'] = 0
        context['month_revenue'] = 0
    except Exception as e:
        print(f"⚠️ Error fetching bookings: {e}")
        context['today_bookings_count'] = 0
        context['week_bookings_count'] = 0
        context['month_bookings_count'] = 0
        context['week_revenue'] = 0
        context['month_revenue'] = 0
    
    # Get staff/employee information
    try:
        employees = Employee.objects.filter(salon=salon, is_active=True)
        context['total_staff'] = employees.count()
        context['staff_names'] = [emp.full_name for emp in employees[:5]]
        
        # Get staff by role
        context['staff_by_role'] = {}
        for role, role_name in Employee.ROLE_CHOICES:
            count = employees.filter(role=role).count()
            if count > 0:
                context['staff_by_role'][role_name] = count
        
        # Get staff by skills
        context['staff_skills'] = {}
        for skill, skill_name in Employee.SKILL_CHOICES:
            count = employees.filter(primary_skill=skill).count()
            if count > 0:
                context['staff_skills'][skill_name] = count
                
    except Exception as e:
        print(f"⚠️ Error fetching staff: {e}")
        context['total_staff'] = 0
        context['staff_names'] = []
        context['staff_by_role'] = {}
        context['staff_skills'] = {}
    
    # Get popular services
    try:
        from services.models import Service
        popular_services = Service.objects.filter(
            salon=salon
        ).annotate(
            booking_count=Count('booking')
        ).order_by('-booking_count')[:3]
        
        context['popular_services'] = [
            {
                'name': service.name,
                'price': float(service.price) if hasattr(service, 'price') else 0,
                'bookings': service.booking_count
            }
            for service in popular_services
        ]
    except ImportError:
        print("⚠️ Service model not found")
        context['popular_services'] = []
    except Exception as e:
        print(f"⚠️ Error fetching services: {e}")
        context['popular_services'] = []
    
    return context

def get_conversation_history(user, salon, limit=5):
    """
    Get recent conversation history for context
    """
    try:
        history = ChatHistory.objects.filter(
            user=user,
            salon=salon
        ).order_by('-created_at')[:limit]
        
        messages = []
        for chat in reversed(history):
            messages.append({
                'role': 'user',
                'content': chat.user_message
            })
            messages.append({
                'role': 'assistant',
                'content': chat.bot_response
            })
        
        return messages
    except Exception as e:
        print(f"⚠️ Error loading history: {e}")
        return []

def generate_fallback_response(message, context):
    """
    Fallback responses using salon data when ChatGPT is unavailable
    """
    message_lower = message.lower()
    
    # Greetings
    if any(word in message_lower for word in ['hello', 'hi', 'hey', 'start']):
        return f"""👋 Hello! Welcome to **{context['salon_name']}** AI Assistant!

**Quick Stats:**
📊 Today's bookings: {context.get('today_bookings_count', 0)} appointments
💰 This week: {context.get('week_bookings_count', 0)} bookings, ₹{context.get('week_revenue', 0):,.0f}
👥 Active staff: {context.get('total_staff', 0)} members

What would you like to know?"""
    
    # Today's bookings
    if 'today' in message_lower and 'booking' in message_lower:
        return f"""📅 **Today's Schedule at {context['salon_name']}**

You have **{context.get('today_bookings_count', 0)} appointments** today.

**Status:**
✅ Confirmed: {context.get('today_bookings_confirmed', 0)}
⏳ Pending: {context.get('today_bookings_pending', 0)}
✓ Completed: {context.get('today_bookings_completed', 0)}

Need details on specific appointments?"""
    
    # Weekly revenue
    if 'week' in message_lower and any(word in message_lower for word in ['revenue', 'earning', 'money', 'sales']):
        week_count = context.get('week_bookings_count', 0)
        week_rev = context.get('week_revenue', 0)
        avg = (week_rev / week_count) if week_count > 0 else 0
        return f"""💰 **This Week's Performance**

**Total Bookings:** {week_count}
**Revenue:** ₹{week_rev:,.2f}
**Average per booking:** ₹{avg:,.0f}

{f"📈 Great performance! Keep it up! 🎉" if week_count > 10 else "💡 Consider promotions to boost bookings!"}"""
    
    # Monthly revenue
    if 'month' in message_lower and any(word in message_lower for word in ['revenue', 'earning', 'money', 'sales']):
        month_count = context.get('month_bookings_count', 0)
        month_rev = context.get('month_revenue', 0)
        avg = (month_rev / month_count) if month_count > 0 else 0
        return f"""💵 **This Month's Performance**

**Total Bookings:** {month_count}
**Revenue:** ₹{month_rev:,.2f}
**Average per booking:** ₹{avg:,.0f}

Keep tracking your progress! 📊"""
    
    # Staff queries
    if any(word in message_lower for word in ['staff', 'employee', 'team', 'stylist', 'worker', 'who', 'working']):
        staff_names = context.get('staff_names', [])
        total_staff = context.get('total_staff', 0)
        
        if total_staff > 0:
            response = f"""👥 **Your Team at {context['salon_name']}**

**Active Employees:** {total_staff}
**Team Members:** {', '.join(staff_names)}

"""
            if context.get('staff_by_role'):
                response += "**Roles:**\n"
                for role, count in context['staff_by_role'].items():
                    response += f"• {count} {role}{'s' if count > 1 else ''}\n"
            
            if context.get('staff_skills'):
                response += "\n**Skills:**\n"
                for skill, count in list(context['staff_skills'].items())[:3]:
                    response += f"• {skill}: {count} expert{'s' if count > 1 else ''}\n"
            
            return response
        else:
            return "You haven't added any staff members yet. Go to Staff section to add your team!"
    
    # Services
    if any(word in message_lower for word in ['service', 'popular', 'best']):
        services = context.get('popular_services', [])
        if services:
            response = f"""✂️ **Popular Services at {context['salon_name']}**\n\n"""
            for i, service in enumerate(services, 1):
                response += f"{i}. **{service['name']}** - ₹{service['price']:.0f} ({service['bookings']} bookings)\n"
            response += "\nThese are your top performers! 🌟"
            return response
        else:
            return "Add services to your salon to track their popularity!"
    
    # Recommendations
    if any(word in message_lower for word in ['recommend', 'suggest', 'advice', 'tip', 'improve']):
        tips = []
        
        if context.get('today_bookings_count', 0) < 3:
            tips.append("📢 Low bookings today - consider sending promotional SMS to regular customers")
        
        if context.get('week_bookings_count', 0) > 20:
            tips.append("🎉 Great week! Consider adding peak hour pricing for high-demand slots")
        
        if context.get('total_staff', 0) < 2:
            tips.append("👥 Hire more staff to handle increased demand")
        
        if not tips:
            tips.append("📊 Track your daily metrics to identify growth opportunities")
            tips.append("💡 Offer loyalty programs to increase customer retention")
            tips.append("📱 Enable online booking to capture more customers")
        
        return f"""💡 **Business Recommendations**\n\n""" + '\n\n'.join(tips)
    
    # Default
    return f"""I'm your salon management assistant! I can help you with:

**Quick Actions:**
• Check today's bookings and schedule
• View revenue and earnings reports
• Monitor staff and team
• Analyze service performance
• Get business recommendations

Try asking: "How many bookings today?" or "Show me this week's revenue"

Currently managing: **{context['salon_name']}** 🏪"""


def detect_admin_intent(message):
    """Detect user intent from message"""
    message = message.lower()
    
    if any(word in message for word in ['booking', 'appointment']) and 'today' in message:
        return 'bookings_today'
    elif any(word in message for word in ['revenue', 'earning', 'money']) and 'week' in message:
        return 'revenue_week'
    elif any(word in message for word in ['staff', 'employee', 'team']):
        return 'staff_info'
    elif any(word in message for word in ['service', 'popular']):
        return 'services'
    elif any(word in message for word in ['recommend', 'suggest', 'advice']):
        return 'recommendations'
    else:
        return 'general'


@api_view(['GET'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def admin_suggestions(request):
    """Get conversation history and suggestions"""
    try:
        salon = Salon.objects.get(owner=request.user)
        history = ChatHistory.objects.filter(
            user=request.user,
            salon=salon
        ).order_by('-created_at')[:10]
        
        messages = [
            {
                'user_message': chat.user_message,
                'bot_response': chat.bot_response,
                'timestamp': chat.created_at.isoformat()
            }
            for chat in history
        ]
        
        suggestions = [
            "How many bookings do I have today?",
            "Show me this week's revenue",
            "Who is working today?",
            "What are my most popular services?",
            "Give me business recommendations",
        ]
        
        return Response({
            'suggestions': suggestions,
            'history': messages
        })
    except Salon.DoesNotExist:
        return Response({
            'suggestions': [],
            'history': [],
            'error': 'No salon found'
        })
    except Exception as e:
        print(f"Error in suggestions: {e}")
        return Response({'suggestions': [], 'history': []})


@api_view(['DELETE'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def clear_chat_history(request):
    """Clear user's chat history"""
    try:
        ChatHistory.objects.filter(user=request.user).delete()
        return Response({'message': 'Chat history cleared successfully'})
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
        
        