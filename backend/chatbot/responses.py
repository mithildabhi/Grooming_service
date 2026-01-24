# chatbot/responses.py
# 🎯 AI Response Generation Logic

from django.utils import timezone
import os

try:
    import google.generativeai as genai
    GEMINI_AVAILABLE = bool(os.getenv('GEMINI_API_KEY'))
except ImportError:
    GEMINI_AVAILABLE = False


def generate_gemini_response(user_message, salon_context, conversation_history):
    """Generate intelligent response using Gemini AI"""
    try:
        analytics_summary = f"""
SALON: {salon_context['salon_name']} (ID: {salon_context['salon_id']})
LOCATION: {salon_context['salon_location']}

📊 TODAY'S PERFORMANCE:
- Bookings: {salon_context.get('today_bookings_count', 0)}
- Revenue: ₹{salon_context.get('today_revenue', 0):,.0f}
- Confirmed: {salon_context.get('today_confirmed', 0)} | Pending: {salon_context.get('today_pending', 0)}
- Completed: {salon_context.get('today_completed', 0)} | Cancelled: {salon_context.get('today_cancelled', 0)}

📈 WEEKLY METRICS:
- Total Bookings: {salon_context.get('week_bookings_count', 0)}
- Revenue: ₹{salon_context.get('week_revenue', 0):,.0f}
- Avg Booking Value: ₹{salon_context.get('week_avg_booking_value', 0):,.0f}
- Peak Hours: {', '.join(salon_context.get('peak_hours', []))}
- Busiest Days: {', '.join(salon_context.get('busiest_days', []))}

💰 MONTHLY OVERVIEW:
- Bookings: {salon_context.get('month_bookings_count', 0)}
- Revenue: ₹{salon_context.get('month_revenue', 0):,.0f}
- Growth: {salon_context.get('revenue_growth_percentage', 0):+.1f}%
- Cancellation Rate: {salon_context.get('cancellation_rate', 0):.1f}%
- Unique Customers: {salon_context.get('monthly_unique_customers', 0)}
- Repeat Rate: {salon_context.get('repeat_customer_rate', 0):.1f}%

👥 STAFF ({salon_context.get('total_staff', 0)} members):
Team: {', '.join(salon_context.get('staff_names', []))}
"""
        
        if salon_context.get('top_staff'):
            analytics_summary += "\nTop Performers:\n"
            for staff in salon_context['top_staff']:
                analytics_summary += f"  • {staff['name']} ({staff['role']}): {staff['bookings']} bookings\n"
        
        if salon_context.get('popular_services'):
            analytics_summary += "\n✂️ POPULAR SERVICES:\n"
            for service in salon_context['popular_services'][:3]:
                analytics_summary += f"  • {service['name']}: {service['bookings']} bookings, ₹{service['revenue']:,.0f}\n"
        
        system_prompt = f"""You are SalonCare AI, an intelligent business assistant for {salon_context['salon_name']}.

{analytics_summary}

INSTRUCTIONS:
- Provide actionable insights and recommendations
- Use emojis appropriately
- Be conversational but professional
- Keep responses under 300 words
- Highlight trends, opportunities, and concerns
- Suggest specific actions when relevant

USER QUESTION: {user_message}

YOUR RESPONSE:"""
        
        model = genai.GenerativeModel('models/gemini-2.0-flash')
        
        response = model.generate_content(
            system_prompt,
            generation_config={
                'temperature': 0.7,
                'max_output_tokens': 600,
            }
        )
        
        return response.text.strip()
        
    except Exception as e:
        print(f"Gemini Error: {str(e)}")
        return generate_intelligent_fallback(user_message, salon_context)


def generate_intelligent_fallback(message, context):
    """Smart fallback with comprehensive data"""
    message_lower = message.lower()
    
    # Greetings
    if any(word in message_lower for word in ['hello', 'hi', 'hey']):
        return f"""👋 Hello! Welcome to **{context['salon_name']}** AI Assistant!

📊 **Quick Overview:**
• Today: {context.get('today_bookings_count', 0)} bookings, ₹{context.get('today_revenue', 0):,.0f}
• This Week: {context.get('week_bookings_count', 0)} bookings, ₹{context.get('week_revenue', 0):,.0f}
• Growth: {context.get('revenue_growth_percentage', 0):+.1f}% vs last month
• Team: {context.get('total_staff', 0)} active members

What would you like to explore?"""
    
    # Today's performance
    if 'today' in message_lower:
        return f"""📅 **Today's Performance** ({timezone.now().strftime('%B %d, %Y')})

✅ Confirmed: {context.get('today_confirmed', 0)}
⏳ Pending: {context.get('today_pending', 0)}
✓ Completed: {context.get('today_completed', 0)}
❌ Cancelled: {context.get('today_cancelled', 0)}

💰 Revenue: ₹{context.get('today_revenue', 0):,.0f}

{f"🌟 Keep it up! You're on track for a great day!" if context.get('today_bookings_count', 0) > 5 else "💡 Tip: Promote services on social media to boost bookings!"}"""
    
    # Weekly analysis
    if 'week' in message_lower or 'weekly' in message_lower:
        peak_info = f"\n⏰ Peak Hours: {', '.join(context.get('peak_hours', []))}" if context.get('peak_hours') else ""
        busy_info = f"\n📆 Busiest Days: {', '.join(context.get('busiest_days', []))}" if context.get('busiest_days') else ""
        
        return f"""📈 **This Week's Performance**

📊 Bookings: {context.get('week_bookings_count', 0)}
💰 Revenue: ₹{context.get('week_revenue', 0):,.0f}
💵 Avg Value: ₹{context.get('week_avg_booking_value', 0):,.0f}{peak_info}{busy_info}

💡 **Insight:** {_generate_weekly_insight(context)}"""
    
    # Monthly report
    if 'month' in message_lower or 'monthly' in message_lower:
        growth_emoji = "📈" if context.get('revenue_growth_percentage', 0) > 0 else "📉"
        return f"""📊 **Monthly Report**

📅 Bookings: {context.get('month_bookings_count', 0)}
💰 Revenue: ₹{context.get('month_revenue', 0):,.0f}
{growth_emoji} Growth: {context.get('revenue_growth_percentage', 0):+.1f}%
👥 Customers: {context.get('monthly_unique_customers', 0)}
🔄 Repeat Rate: {context.get('repeat_customer_rate', 0):.1f}%
❌ Cancellation: {context.get('cancellation_rate', 0):.1f}%

💡 **Recommendation:** {_generate_monthly_insight(context)}"""
    
    # Staff queries
    if 'staff' in message_lower or 'team' in message_lower or 'employee' in message_lower:
        staff_msg = f"""👥 **Your Team** ({context.get('total_staff', 0)} members)

{', '.join(context.get('staff_names', [])[:10]) if context.get('staff_names') else 'No staff added yet'}
"""
        if context.get('top_staff'):
            staff_msg += "\n🌟 **Top Performers This Month:**\n"
            for staff in context['top_staff']:
                staff_msg += f"• {staff['name']} - {staff['bookings']} bookings\n"
        
        staff_msg += "\n💡 Say 'Add staff' to add new team members!"
        return staff_msg
    
    # Revenue queries
    if 'revenue' in message_lower or 'earning' in message_lower or 'income' in message_lower:
        return f"""💰 **Revenue Overview**

📅 Today: ₹{context.get('today_revenue', 0):,.0f}
📊 This Week: ₹{context.get('week_revenue', 0):,.0f}
📈 This Month: ₹{context.get('month_revenue', 0):,.0f}
📊 Growth: {context.get('revenue_growth_percentage', 0):+.1f}% vs last month

💵 Average booking value: ₹{context.get('week_avg_booking_value', 0):,.0f}

{_generate_revenue_insight(context)}"""
    
    # Services
    if 'service' in message_lower or 'popular' in message_lower:
        if context.get('popular_services'):
            services_msg = "✂️ **Most Popular Services:**\n\n"
            for i, service in enumerate(context['popular_services'][:5], 1):
                services_msg += f"{i}. **{service['name']}**\n"
                services_msg += f"   📊 {service['bookings']} bookings | ₹{service['revenue']:,.0f}\n\n"
            return services_msg
        return "📋 No service data available yet."
    
    # Customers
    if 'customer' in message_lower or 'client' in message_lower:
        return f"""👥 **Customer Insights**

📊 This Month:
• Total Customers: {context.get('monthly_unique_customers', 0)}
• Repeat Customers: {context.get('repeat_customer_rate', 0):.1f}%
• Avg Visits: {context.get('avg_visits_per_customer', 0):.1f}

💡 **Tip:** {_generate_customer_insight(context)}"""
    
    # Default
    return f"""🤖 I can help you with detailed insights about **{context['salon_name']}**!

📊 **Ask me about:**
• Today's bookings and performance
• Weekly/monthly revenue reports
• Staff performance and scheduling
• Popular services analysis
• Customer retention metrics
• Business recommendations

Or try: "Show monthly report", "Who's top staff?", "Revenue analysis"

What would you like to know?"""


def _generate_weekly_insight(context):
    """Generate weekly insight"""
    if context.get('week_revenue', 0) > 50000:
        return "Excellent week! Consider offering loyalty rewards to top customers."
    elif context.get('week_bookings_count', 0) < 10:
        return "Bookings are low. Try running a weekend special offer!"
    return "Steady performance. Focus on customer retention strategies."


def _generate_monthly_insight(context):
    """Generate monthly insight"""
    if context.get('revenue_growth_percentage', 0) > 10:
        return "Strong growth! This is a great time to expand services or hire more staff."
    elif context.get('cancellation_rate', 0) > 15:
        return "High cancellation rate detected. Consider implementing a cancellation policy."
    elif context.get('repeat_customer_rate', 0) < 30:
        return "Focus on customer loyalty programs to increase repeat visits."
    return "Maintain current strategies and track performance trends."


def _generate_revenue_insight(context):
    """Generate revenue insight"""
    avg_value = context.get('week_avg_booking_value', 0)
    if avg_value < 500:
        return "💡 **Tip:** Consider upselling premium services to increase booking value."
    elif avg_value > 1000:
        return "🌟 **Excellent!** Your average booking value is above market standards."
    return "💡 **Suggestion:** Bundle services together for better value and higher revenue."


def _generate_customer_insight(context):
    """Generate customer insight"""
    repeat_rate = context.get('repeat_customer_rate', 0)
    if repeat_rate < 25:
        return "Launch a loyalty program to increase repeat visits."
    elif repeat_rate > 50:
        return "Great retention! Consider a referral program to grow your customer base."
    return "Engage customers with personalized follow-ups and special offers."