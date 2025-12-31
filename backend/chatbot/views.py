# chatbot/views.py - FIXED VERSION

from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from authentication.firebase_auth import FirebaseAuthentication
from salons.models import Salon
from staff.models import Employee
from accounts.models import User
from datetime import datetime, timedelta
from django.db.models import Sum, Count, Avg, Q
from django.utils import timezone
import os
import re
from .models import ChatHistory

# Gemini Import
try:
    import google.generativeai as genai
    GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
    if GEMINI_API_KEY:
        genai.configure(api_key=GEMINI_API_KEY)
        GEMINI_AVAILABLE = True
    else:
        GEMINI_AVAILABLE = False
        print("⚠️ GEMINI_API_KEY not found")
except ImportError:
    GEMINI_AVAILABLE = False
    print("⚠️ google-generativeai not installed")


@api_view(['POST'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def admin_chatbot(request):
    """
    AI-Powered Chatbot with Database Operations
    """
    try:
        message = request.data.get('message', '').strip()
        
        if not message:
            return Response(
                {'error': 'Message is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        print(f"[CHATBOT] Received: {message}")
        print(f"[USER] {request.user.email}")
        
        # Get user's salon
        try:
            salon = Salon.objects.get(owner=request.user)
        except Salon.DoesNotExist:
            return Response({
                'response': 'Please create your salon profile first to use the AI assistant.',
                'intent': 'no_salon'
            })
        
        # ✅ STEP 1: Check if user wants to add staff
        add_staff_intent = detect_add_staff_intent(message)
        
        if add_staff_intent:
            # Extract staff details from message
            staff_data = extract_staff_details(message, salon)
            
            if staff_data:
                # Create staff in database
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
                    
                    # Save to history
                    ChatHistory.objects.create(
                        user=request.user,
                        salon=salon,
                        user_message=message,
                        bot_response=response_text,
                        intent='staff_creation'
                    )
                    
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
                # Ask for details
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
        else:
            # Normal chatbot conversation
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
        
        intent = detect_admin_intent(message)
        
        return Response({
            'response': response_text,
            'timestamp': datetime.now().isoformat(),
            'intent': intent,
            'salon_id': salon.id
        })
        
    except Exception as e:
        print(f"[ERROR] {str(e)}")
        import traceback
        traceback.print_exc()
        return Response(
            {'response': 'I apologize, I encountered an error. Please try again.'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


def detect_add_staff_intent(message):
    """
    Detect if user wants to add staff
    """
    message_lower = message.lower()
    keywords = [
        'add staff', 'new staff', 'hire', 'add employee', 
        'new employee', 'create staff', 'register staff',
        'onboard', 'add team member'
    ]
    return any(keyword in message_lower for keyword in keywords)


def extract_staff_details(message, salon):
    """
    Extract staff details from natural language message
    Handles multiple formats
    """
    import random
    
    staff_data = {
        'full_name': None,
        'role': 'stylist',
        'primary_skill': 'hair_styling',
        'email': None,
        'phone': None,
    }
    
    # Split by lines
    lines = message.split('\n')
    
    for line in lines:
        line = line.strip().lower()
        
        # Extract Name
        if 'name:' in line or 'name -' in line or 'name=' in line:
            name = re.split(r'[:=-]', line, 1)[-1].strip()
            name = name.replace('*', '').replace('`', '').strip()
            if name and len(name) > 2:
                staff_data['full_name'] = name.title()
        
        # Extract Role
        if 'role:' in line or 'position:' in line or 'designation:' in line:
            if 'barber' in line:
                staff_data['role'] = 'barber'
            elif 'stylist' in line:
                staff_data['role'] = 'stylist'
            elif 'manager' in line:
                staff_data['role'] = 'manager'
            elif 'receptionist' in line:
                staff_data['role'] = 'receptionist'
            elif 'specialist' in line:
                staff_data['role'] = 'specialist'
        
        # Extract Skill
        if 'skill:' in line or 'specialty:' in line or 'expertise:' in line:
            if 'hair cut' in line or 'haircut' in line or 'cutting' in line:
                staff_data['primary_skill'] = 'hair_cutting'
            elif 'styling' in line or 'hair style' in line:
                staff_data['primary_skill'] = 'hair_styling'
            elif 'color' in line or 'colour' in line:
                staff_data['primary_skill'] = 'coloring'
            elif 'beard' in line:
                staff_data['primary_skill'] = 'beard_trim'
            elif 'spa' in line:
                staff_data['primary_skill'] = 'spa'
            elif 'massage' in line:
                staff_data['primary_skill'] = 'massage'
            elif 'nail' in line:
                staff_data['primary_skill'] = 'nails'
            elif 'makeup' in line or 'make up' in line:
                staff_data['primary_skill'] = 'makeup'
        
        # Extract Email
        if 'email:' in line or 'mail:' in line or '@' in line:
            email_match = re.search(r'[\w\.-]+@[\w\.-]+\.\w+', line)
            if email_match:
                staff_data['email'] = email_match.group(0)
        
        # Extract Phone
        if 'phone:' in line or 'mobile:' in line or 'contact:' in line or 'number:' in line:
            phone_match = re.search(r'\d{10}', line)
            if phone_match:
                staff_data['phone'] = phone_match.group(0)
    
    # Validate required fields
    if not staff_data['full_name']:
        return None
    
    # Auto-generate email if not provided
    if not staff_data['email']:
        name_parts = staff_data['full_name'].lower().replace(' ', '')
        staff_data['email'] = f"{name_parts}@{salon.name.lower().replace(' ', '')}.com"
    
    # Auto-generate phone if not provided
    if not staff_data['phone']:
        staff_data['phone'] = f"{''.join([str(random.randint(0, 9)) for _ in range(10)])}"
    
    return staff_data


def create_staff_member(salon, staff_data):
    """
    Create staff member in database
    """
    try:
        print(f"[STAFF CREATE] Creating: {staff_data}")
        
        # Check if email already exists
        if User.objects.filter(email=staff_data['email']).exists():
            return (False, f"User with email {staff_data['email']} already exists")
        
        # Create user account
        user = User.objects.create_user(
            username=staff_data['email'],
            email=staff_data['email'],
            role='EMPLOYEE'
        )
        print(f"[STAFF CREATE] User created: {user.email}")
        
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
        
        print(f"[STAFF CREATE] ✅ Employee created: {employee.full_name} (ID: {employee.id})")
        return (True, employee)
        
    except Exception as e:
        print(f"[STAFF CREATE] ❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()
        return (False, str(e))


def generate_gemini_response(user_message, salon_context, conversation_history):
    """Generate response using Gemini"""
    try:
        staff_info = ""
        if salon_context.get('total_staff', 0) > 0:
            staff_info = f"- Staff: {salon_context['total_staff']} active employees"
            if salon_context.get('staff_names'):
                staff_info += f"\n  - Team: {', '.join(salon_context['staff_names'])}"
        
        services_info = ""
        if salon_context.get('popular_services'):
            services_info = f"- Popular services: {', '.join([s['name'] for s in salon_context['popular_services']])}"
        
        system_prompt = f"""You are SalonCare AI, helping manage {salon_context['salon_name']}.

CURRENT DATA:
- Today: {salon_context.get('today_bookings_count', 0)} bookings
- Week: {salon_context.get('week_bookings_count', 0)} bookings, ₹{salon_context.get('week_revenue', 0):,.0f}
- Month: {salon_context.get('month_bookings_count', 0)} bookings, ₹{salon_context.get('month_revenue', 0):,.0f}
{staff_info}
{services_info}

Be helpful, use emojis, keep under 250 words.
User: {user_message}
Assistant:"""
        
        model = genai.GenerativeModel('models/gemini-2.5-flash')
        
        response = model.generate_content(
            system_prompt,
            generation_config={
                'temperature': 0.7,
                'max_output_tokens': 500,
            }
        )
        
        return response.text.strip()
        
    except Exception as e:
        print(f"❌ Gemini Error: {str(e)}")
        return generate_fallback_response(user_message, salon_context)


# Keep all other functions (get_salon_data_context, generate_fallback_response, etc.)
def get_salon_data_context(salon):
    """Gather salon data"""
    today = timezone.now().date()
    week_start = today - timedelta(days=today.weekday())
    month_start = today.replace(day=1)
    
    context = {
        'salon_name': salon.name,
        'salon_id': salon.id,
        'salon_location': getattr(salon, 'city', 'N/A'),
        'today_bookings_count': 0,
        'week_bookings_count': 0,
        'month_bookings_count': 0,
        'week_revenue': 0,
        'month_revenue': 0,
    }
    
    try:
        from bookings.models import Booking
        
        today_bookings = Booking.objects.filter(salon=salon, booking_date=today)
        context['today_bookings_count'] = today_bookings.count()
        
        week_bookings = Booking.objects.filter(salon=salon, booking_date__gte=week_start, booking_date__lte=today)
        context['week_bookings_count'] = week_bookings.count()
        context['week_revenue'] = week_bookings.aggregate(total=Sum('total_price'))['total'] or 0
        
        month_bookings = Booking.objects.filter(salon=salon, booking_date__gte=month_start)
        context['month_bookings_count'] = month_bookings.count()
        context['month_revenue'] = month_bookings.aggregate(total=Sum('total_price'))['total'] or 0
    except:
        pass
    
    try:
        employees = Employee.objects.filter(salon=salon, is_active=True)
        context['total_staff'] = employees.count()
        context['staff_names'] = [emp.full_name for emp in employees[:5]]
    except:
        context['total_staff'] = 0
        context['staff_names'] = []
    
    try:
        from services.models import Service
        services = Service.objects.filter(salon=salon).annotate(booking_count=Count('booking')).order_by('-booking_count')[:3]
        context['popular_services'] = [{'name': s.name, 'price': float(s.price) if hasattr(s, 'price') else 0} for s in services]
    except:
        context['popular_services'] = []
    
    return context


def get_conversation_history(user, salon, limit=5):
    """Get chat history"""
    try:
        history = ChatHistory.objects.filter(user=user, salon=salon).order_by('-created_at')[:limit]
        messages = []
        for chat in reversed(history):
            messages.append({'role': 'user', 'content': chat.user_message})
            messages.append({'role': 'assistant', 'content': chat.bot_response})
        return messages
    except:
        return []


def generate_fallback_response(message, context):
    """Fallback responses"""
    message_lower = message.lower()
    
    if any(word in message_lower for word in ['hello', 'hi', 'hey']):
        return f"""👋 Hello! Welcome to **{context['salon_name']}** AI Assistant!

📊 Today: {context.get('today_bookings_count', 0)} bookings
💰 This week: ₹{context.get('week_revenue', 0):,.0f}
👥 Staff: {context.get('total_staff', 0)} members

What would you like to know?"""
    
    if 'today' in message_lower and 'booking' in message_lower:
        return f"""📅 **Today's Bookings**
You have **{context.get('today_bookings_count', 0)} appointments** today."""
    
    if 'staff' in message_lower or 'team' in message_lower:
        if context.get('total_staff', 0) > 0:
            return f"""👥 **Your Team**
Active: {context['total_staff']}
Members: {', '.join(context.get('staff_names', []))}"""
        return "No staff members yet. Use 'Add staff' to add team members!"
    
    return f"""I can help you with:
• Check today's bookings
• View revenue reports
• Manage staff (say "add staff" to add new members)
• Business insights

Ask me anything about {context['salon_name']}!"""


def detect_admin_intent(message):
    """Detect intent"""
    message = message.lower()
    if 'add staff' in message or 'new staff' in message:
        return 'staff_creation'
    elif 'booking' in message and 'today' in message:
        return 'bookings_today'
    elif 'revenue' in message:
        return 'revenue'
    elif 'staff' in message:
        return 'staff_info'
    return 'general'


@api_view(['GET'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def admin_suggestions(request):
    """Get suggestions"""
    return Response({
        'suggestions': [
            "How many bookings today?",
            "Show this week's revenue",
            "Who is on my team?",
            "Add new staff member",
            "Business recommendations",
        ]
    })


@api_view(['DELETE'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def clear_chat_history(request):
    """Clear chat history"""
    try:
        ChatHistory.objects.filter(user=request.user).delete()
        return Response({'message': 'Chat history cleared'})
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)