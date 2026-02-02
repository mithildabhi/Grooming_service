# reviews/urls.py
# 🌟 REVIEW SYSTEM URL ROUTING

from django.urls import path
from . import views

app_name = 'reviews'

urlpatterns = [
    # ========================================
    # PUBLIC ENDPOINTS (No Auth)
    # ========================================
    
    # Salon Reviews
    path(
        'salon/<int:salon_id>/',
        views.salon_reviews_list,
        name='salon-reviews-list'
    ),
    path(
        'salon/<int:salon_id>/stats/',
        views.salon_review_stats,
        name='salon-review-stats'
    ),
    
    # Service Reviews
    path(
        'service/<int:service_id>/',
        views.service_reviews_list,
        name='service-reviews-list'
    ),
    path(
        'service/<int:service_id>/stats/',
        views.service_review_stats,
        name='service-review-stats'
    ),
    
    # Single Review
    path(
        '<int:review_id>/',
        views.review_detail,
        name='review-detail'
    ),
    
    # ========================================
    # CUSTOMER ENDPOINTS (Auth Required)
    # ========================================
    
    # Create/Manage Reviews
    path(
        'create/',
        views.create_review,
        name='create-review'
    ),
    path(
        '<int:review_id>/update/',
        views.update_review,
        name='update-review'
    ),
    path(
        '<int:review_id>/delete/',
        views.delete_review,
        name='delete-review'
    ),
    
    # User's Reviews
    path(
        'my-reviews/',
        views.my_reviews,
        name='my-reviews'
    ),
    
    # Helpfulness
    path(
        '<int:review_id>/helpful/',
        views.mark_review_helpful,
        name='mark-review-helpful'
    ),
    
    # Report
    path(
        '<int:review_id>/report/',
        views.report_review,
        name='report-review'
    ),
    
    # ========================================
    # SALON OWNER ENDPOINTS
    # ========================================
    
    # Owner Reply
    path(
        '<int:review_id>/reply/',
        views.owner_reply_to_review,
        name='owner-reply'
    ),
    
    # Owner's Salon Reviews
    path(
        'my-salon-reviews/',
        views.my_salon_reviews,
        name='my-salon-reviews'
    ),
]

"""
📚 API ENDPOINTS DOCUMENTATION

PUBLIC (No Authentication):
============================

GET  /api/reviews/salon/<id>/
     → Get all reviews for a salon
     Query params: rating, service_id, verified_only, sort, page, page_size
     Example: /api/reviews/salon/1/?rating=5&sort=helpful&page=1

GET  /api/reviews/salon/<id>/stats/
     → Get review statistics for a salon
     Returns: total, average rating, distribution, verified count

GET  /api/reviews/service/<id>/
     → Get all reviews for a specific service
     
GET  /api/reviews/service/<id>/stats/
     → Get review statistics for a service

GET  /api/reviews/<review_id>/
     → Get detailed view of a single review


CUSTOMER (Authentication Required):
====================================

POST /api/reviews/create/
     → Create a new review
     Body: {
       "booking_id": 123,  // OR service_id
       "rating": 5,
       "title": "Great!",
       "comment": "Loved it...",
       "service_quality_rating": 5,  // Optional
       "staff_behavior_rating": 5,   // Optional
       "ambiance_rating": 4,          // Optional
       "value_for_money_rating": 5,  // Optional
       "images": []                   // Optional
     }

PUT  /api/reviews/<review_id>/update/
     → Update your own review

DELETE /api/reviews/<review_id>/delete/
       → Delete your own review

GET  /api/reviews/my-reviews/
     → Get all your reviews

POST /api/reviews/<review_id>/helpful/
     → Mark review as helpful/not helpful
     Body: {"is_helpful": true}

POST /api/reviews/<review_id>/report/
     → Report inappropriate review
     Body: {"reason": "spam", "description": "..."}


SALON OWNER (Authentication Required):
=======================================

POST /api/reviews/<review_id>/reply/
     → Reply to a review on your salon
     Body: {"reply": "Thank you..."}

GET  /api/reviews/my-salon-reviews/
     → Get all reviews for your salon
     Query params: pending_reply (true/false)


SORTING OPTIONS:
================
- recent: Latest reviews first (default)
- helpful: Most helpful reviews first
- rating_high: Highest rated first
- rating_low: Lowest rated first


FILTERS:
========
- rating: Filter by star rating (1-5)
- service_id: Filter by service
- verified_only: Show only verified reviews


EXAMPLE USAGE:
==============

# Get all 5-star reviews for a salon, sorted by helpfulness
GET /api/reviews/salon/1/?rating=5&sort=helpful

# Get verified reviews only
GET /api/reviews/salon/1/?verified_only=true

# Get reviews for specific service
GET /api/reviews/salon/1/?service_id=5

# Get salon owner's reviews needing reply
GET /api/reviews/my-salon-reviews/?pending_reply=true

"""