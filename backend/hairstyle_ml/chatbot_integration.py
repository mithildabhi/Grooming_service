# hairstyle_ml/chatbot_integration.py
# 🎨 INTEGRATION WITH USER CHATBOT FOR HAIRSTYLE RECOMMENDATIONS

from .models import HairstyleAnalysis
from django.utils import timezone
from datetime import timedelta


def detect_hairstyle_intent(message):
    """
    Detect if user is asking about hairstyle analysis or recommendations
    """
    message_lower = message.lower()
    
    keywords = [
        'hairstyle', 'haircut', 'hair style', 'hair cut',
        'face shape', 'faceshape', 'hair recommend',
        'which hairstyle', 'what hairstyle', 'hair suggestion',
        'analyze my face', 'analyze face', 'hair analysis',
        'upload photo', 'send photo', 'my photo'
    ]
    
    return any(keyword in message_lower for keyword in keywords)


def get_user_hairstyle_context(user):
    """
    Get user's hairstyle analysis history for context
    """
    try:
        # Get most recent successful analysis
        recent_analysis = HairstyleAnalysis.objects.filter(
            user=user,
            analysis_successful=True
        ).order_by('-created_at').first()
        
        if not recent_analysis:
            return None
        
        # Check if analysis is recent (within 30 days)
        days_ago = (timezone.now() - recent_analysis.created_at).days
        
        return {
            'has_analysis': True,
            'face_shape': recent_analysis.face_shape,
            'current_hair_length': recent_analysis.current_hair_length,
            'current_hair_color': recent_analysis.current_hair_color,
            'recommendations_count': len(recent_analysis.recommendations),
            'days_ago': days_ago,
            'analysis_id': recent_analysis.id,
            'is_recent': days_ago <= 30,
            'top_recommendations': recent_analysis.recommendations[:3] if recent_analysis.recommendations else []
        }
    except Exception as e:
        print(f"❌ Error getting hairstyle context: {e}")
        return None


def generate_hairstyle_response(message, user_context, hairstyle_context):
    """
    Generate hairstyle-specific response
    """
    user_name = user_context.get('user_name', 'there')
    
    # No previous analysis
    if not hairstyle_context or not hairstyle_context.get('has_analysis'):
        return f"""💇 **Hairstyle Recommendations Just for You!**

Hi {user_name}! I can help you find the perfect hairstyle for your face shape using AI-powered analysis! 🎨

**How it works:**
1️⃣ Upload a clear front-facing photo
2️⃣ Our AI analyzes your face shape
3️⃣ Get personalized hairstyle recommendations
4️⃣ See styling tips & product suggestions

**Ready to get started?**
Tap the camera icon 📷 or attachment button and upload your photo!

💡 **Tips for best results:**
• Good lighting
• Face clearly visible
• No sunglasses or hats
• Front-facing photo

Your photo stays private and secure! 🔒"""
    
    # Has previous analysis
    face_shape = hairstyle_context['face_shape']
    days_ago = hairstyle_context['days_ago']
    is_recent = hairstyle_context['is_recent']
    
    response = f"""💇 **Your Hairstyle Profile**

Hi {user_name}! I analyzed your face shape {days_ago} {'day' if days_ago == 1 else 'days'} ago.

**Your Face Shape:** {face_shape}
**Current Hair:** {hairstyle_context['current_hair_length']} {hairstyle_context['current_hair_color']}

"""
    
    if hairstyle_context['top_recommendations']:
        response += "**✨ Top Recommendations for You:**\n"
        for i, rec in enumerate(hairstyle_context['top_recommendations'], 1):
            response += f"{i}. **{rec['name']}** - {rec.get('description', '')}\n"
        
        response += "\n"
    
    if is_recent:
        response += "**Your analysis is recent!** View full details with all styling tips and product recommendations.\n\n"
        response += "Want to try a new photo or update your preferences? Just upload a new image! 📷"
    else:
        response += "**💡 Your analysis is over 30 days old.**\n"
        response += "Hairstyles change! Upload a new photo to get updated recommendations tailored to your current look! 📷"
    
    return response


def format_hairstyle_for_gemini(hairstyle_context):
    """
    Format hairstyle context for Gemini AI prompt
    """
    if not hairstyle_context or not hairstyle_context.get('has_analysis'):
        return "\n🎨 HAIRSTYLE STATUS: User has NOT uploaded a photo for analysis yet\n"
    
    return f"""
🎨 HAIRSTYLE ANALYSIS HISTORY:
- Face Shape: {hairstyle_context['face_shape']}
- Current Hair: {hairstyle_context['current_hair_length']} {hairstyle_context['current_hair_color']}
- Analysis Date: {hairstyle_context['days_ago']} days ago
- Is Recent: {hairstyle_context['is_recent']}
- Recommendations Available: {hairstyle_context['recommendations_count']}
"""


# Integration functions for chatbot views

def should_handle_hairstyle_query(message):
    """
    Check if chatbot should handle this as hairstyle query
    """
    return detect_hairstyle_intent(message)


def handle_hairstyle_chatbot_query(message, user, user_context):
    """
    Main handler for hairstyle queries in chatbot
    
    Returns: (response_text, actions_dict)
    """
    # Get user's hairstyle analysis context
    hairstyle_context = get_user_hairstyle_context(user)
    
    # Generate response
    response = generate_hairstyle_response(message, user_context, hairstyle_context)
    
    # Build actions
    actions = {
        'intent': 'hairstyle_recommendation',
        'has_analysis': bool(hairstyle_context and hairstyle_context.get('has_analysis')),
        'needs_upload': not (hairstyle_context and hairstyle_context.get('is_recent')),
    }
    
    if hairstyle_context and hairstyle_context.get('analysis_id'):
        actions['analysis_id'] = hairstyle_context['analysis_id']
        actions['face_shape'] = hairstyle_context['face_shape']
    
    return response, actions


def get_hairstyle_suggestions(hairstyle_context):
    """
    Get quick suggestions based on hairstyle context
    """
    if not hairstyle_context or not hairstyle_context.get('has_analysis'):
        return [
            "📷 Get hairstyle recommendations",
            "What hairstyle suits my face?",
        ]
    
    suggestions = [
        "Show my hairstyle recommendations",
        "📷 Update my hairstyle analysis",
    ]
    
    if hairstyle_context.get('face_shape'):
        suggestions.append(f"Tips for {hairstyle_context['face_shape'].lower()} face")
    
    return suggestions


# Response formatting helpers

def format_recommendations_for_chat(recommendations):
    """
    Format recommendations list for chat display
    """
    if not recommendations:
        return "No recommendations available"
    
    response = "**✨ Recommended Hairstyles:**\n\n"
    
    for i, rec in enumerate(recommendations, 1):
        response += f"**{i}. {rec['name']}**\n"
        response += f"   {rec.get('description', '')}\n"
        response += f"   • Difficulty: {rec.get('difficulty', 'N/A')}\n"
        response += f"   • Maintenance: {rec.get('maintenance', 'N/A')}\n\n"
    
    return response


def format_styling_tips_for_chat(tips):
    """
    Format styling tips for chat display
    """
    if not tips:
        return "No tips available"
    
    response = "**💡 Styling Tips:**\n\n"
    for tip in tips:
        response += f"• {tip}\n"
    
    return response


def format_products_for_chat(products):
    """
    Format product recommendations for chat display
    """
    if not products:
        return "No products recommended"
    
    response = "**🛍️ Recommended Products:**\n\n"
    for product in products:
        response += f"• {product}\n"
    
    return response