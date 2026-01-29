# chatbot/user_responses.py
# 🎯 USER AI RESPONSE GENERATION

import os
from django.utils import timezone

try:
    import google.generativeai as genai
    GEMINI_AVAILABLE = bool(os.getenv('GEMINI_API_KEY'))
except ImportError:
    GEMINI_AVAILABLE = False


def generate_user_gemini_response(user_message, user_context, conversation_history, intent):
    """Generate intelligent response using Gemini AI for users"""
    try:
        user_summary = f"""
USER PROFILE:
- Name: {user_context.get('customer_name', 'Guest')}
- Location: {user_context.get('customer_city', 'Not specified')}
- Total Bookings: {user_context.get('total_bookings', 0)}
- Completed: {user_context.get('completed_bookings', 0)}
- Upcoming: {user_context.get('upcoming_bookings', 0)}
"""

        if user_context.get('favorite_salon'):
            user_summary += f"\n- Favorite Salon: {user_context['favorite_salon']} ({user_context.get('favorite_salon_visits', 0)} visits)"
        
        if user_context.get('favorite_service'):
            user_summary += f"\n- Favorite Service: {user_context['favorite_service']}"
        
        if user_context.get('last_visit_salon'):
            user_summary += f"\n- Last Visit: {user_context['last_visit_salon']} for {user_context.get('last_visit_service', 'service')}"
        
        system_prompt = f"""You are SalonCare AI, a friendly and helpful beauty assistant for customers.

{user_summary}

INTENT: {intent}

YOUR ROLE:
- Help users find salons and services
- Answer beauty and haircare questions
- Assist with bookings and appointments
- Provide personalized recommendations
- Be warm, friendly, and encouraging

INSTRUCTIONS:
- Keep responses concise (under 200 words)
- Use emojis to make it friendly
- Provide actionable suggestions
- Be personal and use their name when appropriate
- For salon searches, guide them to explore the app
- For bookings, explain the simple steps

USER QUESTION: {user_message}

YOUR FRIENDLY RESPONSE:"""
        
        model = genai.GenerativeModel('models/gemini-2.0-flash')
        
        response = model.generate_content(
            system_prompt,
            generation_config={
                'temperature': 0.8,  # More creative for customer interactions
                'max_output_tokens': 400,
            }
        )
        
        return response.text.strip()
        
    except Exception as e:
        print(f"Gemini Error (User): {str(e)}")
        return generate_user_intelligent_fallback(user_message, user_context, intent)


def generate_user_intelligent_fallback(message, context, intent):
    """Smart fallback responses for users"""
    message_lower = message.lower()
    customer_name = context.get('customer_name', 'there')
    
    # Greetings
    if intent == 'greeting' or any(word in message_lower for word in ['hello', 'hi', 'hey']):
        greeting_text = f"👋 Hi {customer_name}! Welcome to SalonCare!\n\n"
        
        if context.get('upcoming_bookings', 0) > 0:
            greeting_text += f"📅 You have {context['upcoming_bookings']} upcoming appointment(s)!\n\n"
        
        greeting_text += """I can help you with:
• 🔍 Finding nearby salons
• 📅 Booking appointments
• 💇 Beauty & haircare tips
• ⭐ Salon recommendations

What would you like to do today?"""
        
        return greeting_text
    
    # Find salons
    if intent == 'find_salon':
        city = context.get('customer_city', 'your area')
        return f"""🏪 **Looking for Salons?**

I can help you find the perfect salon{f' in {city}' if city != 'your area' else ''}!

**Try asking:**
• "Show salons near me"
• "Find salons in [city name]"
• "Best rated salons"

Or explore the **Explore** tab to browse all available salons with:
✨ Ratings & Reviews
📍 Locations & Directions
💰 Services & Prices
📅 Real-time Availability

What type of salon are you looking for?"""
    
    # Booking queries
    if intent == 'booking_query':
        return """📅 **Ready to Book Your Appointment?**

**It's super easy!**
1️⃣ Browse salons in the **Explore** tab
2️⃣ Choose your favorite salon
3️⃣ Select a service
4️⃣ Pick date & time
5️⃣ Confirm booking!

**Pro Tips:**
⏰ Morning slots (9-11 AM) are less crowded
📅 Book 2-3 days in advance for best availability
💰 Check for special offers on services

Ready to start? Head to the Explore tab!"""
    
    # My bookings
    if intent == 'my_bookings':
        if context.get('upcoming_bookings', 0) > 0:
            return f"""📋 **Your Appointments**

You have **{context['upcoming_bookings']} upcoming appointment(s)**!

View full details in the **Appointments** tab:
• Date & Time
• Salon Location
• Services Booked
• Total Amount
• Booking Status

💡 Set reminders so you don't miss them!"""
        else:
            return """📅 **No Upcoming Appointments**

Looks like you're all caught up! Ready for a fresh look?

🌟 **Popular Services:**
• Haircut & Styling
• Hair Coloring
• Spa & Massage
• Manicure & Pedicure

Tap **Explore** to browse salons and book now!"""
    
    # Beauty tips
    if intent == 'beauty_tips' or any(word in message_lower for word in ['tip', 'advice', 'care', 'recommend']):
        tips = []
        
        if 'hair' in message_lower:
            tips = [
                "🌟 **Haircare Essentials:**",
                "• Wash 2-3 times/week to keep natural oils",
                "• Always use conditioner after shampoo",
                "• Get trims every 6-8 weeks",
                "• Limit heat styling to prevent damage",
                "• Weekly hair masks for deep conditioning",
                "",
                "💡 Pro tip: Brush from ends to roots to avoid breakage!"
            ]
        elif 'skin' in message_lower or 'face' in message_lower:
            tips = [
                "✨ **Skincare Routine:**",
                "• Cleanse twice daily (morning & night)",
                "• Apply sunscreen every day (SPF 30+)",
                "• Stay hydrated (8 glasses water/day)",
                "• Get 7-8 hours of sleep",
                "• Eat fruits & veggies for natural glow",
                "",
                "💡 Pro tip: Remove makeup before bed always!"
            ]
        else:
            tips = [
                "💅 **General Beauty Tips:**",
                "• Regular salon visits maintain your look",
                "• Book appointments 1-2 weeks ahead",
                "• Bring reference photos for best results",
                "• Communicate clearly with your stylist",
                "• Ask about product recommendations",
                "",
                "Want specific advice? Ask about haircare, skincare, or any beauty concern!"
            ]
        
        return "\n".join(tips)
    
    # Pricing
    if intent == 'pricing':
        return """💰 **Service Pricing**

Prices vary by:
• Salon location & reputation
• Service type & complexity
• Stylist experience level

**Average Price Ranges:**
💇 Haircut: ₹200 - ₹800
🎨 Hair Color: ₹1,500 - ₹5,000
💆 Spa: ₹800 - ₹3,000
💅 Nails: ₹300 - ₹1,200

**See Exact Prices:**
Browse salons → View services → Check pricing

💡 Many salons offer first-time customer discounts!"""
    
    # Salon hours
    if intent == 'salon_hours':
        return """🕐 **Salon Timings**

Most salons operate:
• **Weekdays:** 9:00 AM - 8:00 PM
• **Weekends:** 9:00 AM - 9:00 PM

**Best Times to Visit:**
🌅 Morning (9-11 AM) - Less crowded, fresh stylists
🌆 Afternoon (2-4 PM) - Quiet period
❌ Avoid: Lunch rush (12-2 PM) & evenings (6-8 PM)

Check specific salon hours in their profile!"""
    
    # User history insights
    if context.get('total_bookings', 0) > 0:
        if 'history' in message_lower or 'past' in message_lower:
            response = f"""📊 **Your Booking History**

Total Visits: {context['total_bookings']}
Completed: {context.get('completed_bookings', 0)}
"""
            if context.get('favorite_salon'):
                response += f"💙 Favorite Salon: {context['favorite_salon']}\n"
            
            if context.get('favorite_service'):
                response += f"✂️ Most Booked: {context['favorite_service']}\n"
            
            if context.get('total_spent', 0) > 0:
                response += f"💰 Total Spent: ₹{context['total_spent']:,.0f}\n"
            
            response += "\n🌟 Thanks for being a valued customer!"
            return response
    
    # Default helpful response
    return f"""👋 Hi {customer_name}!

I'm here to help you with:

🔍 **Finding Salons**
"Show salons near me"
"Find salons in [city]"

📅 **Booking Help**
"How do I book?"
"Show my appointments"

💅 **Beauty Advice**
"Haircare tips"
"Skincare routine"

💰 **Pricing Info**
"How much does a haircut cost?"

What can I help you with today?"""


def get_beauty_knowledge_base():
    """Comprehensive beauty tips knowledge base"""
    return {
        'haircare_general': [
            "Wash hair 2-3 times weekly, not daily",
            "Use lukewarm water, not hot",
            "Apply conditioner to ends, not roots",
            "Air dry when possible",
            "Trim every 6-8 weeks",
        ],
        'hair_types': {
            'dry': "Use moisturizing shampoo, deep condition weekly, avoid heat",
            'oily': "Clarifying shampoo, light conditioner, wash more frequently",
            'normal': "Balanced routine, regular conditioning, occasional masks",
            'curly': "Sulfate-free products, wide-tooth comb, leave-in conditioner",
        },
        'skincare_routine': [
            "Morning: Cleanser → Toner → Serum → Moisturizer → Sunscreen",
            "Evening: Cleanser → Toner → Treatment → Moisturizer",
            "Weekly: Exfoliate 1-2x, Face mask 1x",
        ],
        'pre_salon': [
            "Arrive on time or 5 minutes early",
            "Bring reference photos",
            "Communicate clearly with stylist",
            "Mention any allergies or sensitivities",
            "Ask questions about maintenance",
        ],
        'post_salon': [
            "Follow stylist's product recommendations",
            "Wait 48 hours before washing colored hair",
            "Book next appointment before leaving",
            "Take a selfie to remember the style!",
        ]
    }