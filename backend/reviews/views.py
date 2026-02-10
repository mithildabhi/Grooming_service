# reviews/views.py
# 🌟 COMPLETE REVIEW API - E-COMMERCE GRADE

from rest_framework import status
from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework.pagination import PageNumberPagination
from django.db.models import Avg, Count, Q, F
from django.utils import timezone
from django.shortcuts import get_object_or_404

from authentication.firebase_auth import FirebaseAuthentication
from .models import Review, ReviewHelpfulness, ReviewReport
from .serializers import (
    ReviewListSerializer,
    ReviewDetailSerializer,
    ReviewCreateSerializer,
    ReviewUpdateSerializer,
    OwnerReplySerializer,
    ReviewHelpfulnessSerializer,
    ReviewReportSerializer,
    ReviewStatsSerializer,
    ServiceReviewStatsSerializer,
)
from salons.models import Salon
from services.models import Service
from bookings.models import Booking


class ReviewPagination(PageNumberPagination):
    page_size = 10
    page_size_query_param = 'page_size'
    max_page_size = 50


# ========================================
# PUBLIC ENDPOINTS (No Auth Required)
# ========================================

@api_view(['GET'])
@permission_classes([AllowAny])
def salon_reviews_list(request, salon_id):
    """
    Get all reviews for a salon with filters and sorting
    
    Query params:
    - rating: Filter by rating (1-5)
    - service_id: Filter by service
    - verified_only: Show only verified reviews (true/false)
    - sort: Sort by (recent, helpful, rating_high, rating_low)
    - page: Page number
    - page_size: Items per page
    """
    try:
        salon = get_object_or_404(Salon, id=salon_id)
        
        # Base query - only approved reviews
        reviews = Review.objects.filter(
            salon=salon,
            is_approved=True
        ).select_related('user', 'service', 'booking')
        
        # Filters
        rating_filter = request.query_params.get('rating')
        if rating_filter:
            reviews = reviews.filter(rating=int(rating_filter))
        
        service_id = request.query_params.get('service_id')
        if service_id:
            reviews = reviews.filter(service_id=int(service_id))
        
        verified_only = request.query_params.get('verified_only', '').lower() == 'true'
        if verified_only:
            reviews = reviews.filter(is_verified=True)
        
        # Sorting
        sort_by = request.query_params.get('sort', 'recent')
        
        if sort_by == 'helpful':
            reviews = reviews.order_by('-helpful_count', '-created_at')
        elif sort_by == 'rating_high':
            reviews = reviews.order_by('-rating', '-created_at')
        elif sort_by == 'rating_low':
            reviews = reviews.order_by('rating', '-created_at')
        else:  # recent (default)
            reviews = reviews.order_by('-created_at')
        
        # Paginate
        paginator = ReviewPagination()
        page = paginator.paginate_queryset(reviews, request)
        
        serializer = ReviewListSerializer(
            page,
            many=True,
            context={'request': request}
        )
        
        return paginator.get_paginated_response(serializer.data)
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([AllowAny])
def salon_review_stats(request, salon_id):
    """
    Get review statistics for a salon
    
    Returns:
    - Total reviews
    - Average rating
    - Rating distribution (1-5 stars breakdown)
    - Verified reviews count
    - Detailed rating averages
    """
    try:
        salon = get_object_or_404(Salon, id=salon_id)
        
        reviews = Review.objects.filter(
            salon=salon,
            is_approved=True
        )
        
        total_reviews = reviews.count()
        
        if total_reviews == 0:
            return Response({
                'total_reviews': 0,
                'average_rating': 0.0,
                'rating_distribution': {
                    '5': 0, '4': 0, '3': 0, '2': 0, '1': 0
                },
                'verified_reviews_count': 0,
                'avg_service_quality': 0.0,
                'avg_staff_behavior': 0.0,
                'avg_ambiance': 0.0,
                'avg_value_for_money': 0.0,
            })
        
        # Average rating
        avg_rating = reviews.aggregate(avg=Avg('rating'))['avg'] or 0.0
        
        # Rating distribution
        rating_dist = {}
        for i in range(1, 6):
            count = reviews.filter(rating=i).count()
            percentage = (count / total_reviews) * 100
            rating_dist[str(i)] = {
                'count': count,
                'percentage': round(percentage, 1)
            }
        
        # Verified reviews
        verified_count = reviews.filter(is_verified=True).count()
        
        # Detailed ratings
        detailed_ratings = reviews.exclude(
            service_quality_rating__isnull=True
        ).aggregate(
            avg_service=Avg('service_quality_rating'),
            avg_staff=Avg('staff_behavior_rating'),
            avg_ambiance=Avg('ambiance_rating'),
            avg_value=Avg('value_for_money_rating'),
        )
        
        stats = {
            'total_reviews': total_reviews,
            'average_rating': round(avg_rating, 1),
            'rating_distribution': rating_dist,
            'verified_reviews_count': verified_count,
            'avg_service_quality': round(detailed_ratings['avg_service'] or 0, 1),
            'avg_staff_behavior': round(detailed_ratings['avg_staff'] or 0, 1),
            'avg_ambiance': round(detailed_ratings['avg_ambiance'] or 0, 1),
            'avg_value_for_money': round(detailed_ratings['avg_value'] or 0, 1),
        }
        
        return Response(stats)
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([AllowAny])
def service_reviews_list(request, service_id):
    """Get all reviews for a specific service"""
    try:
        service = get_object_or_404(Service, id=service_id)
        
        reviews = Review.objects.filter(
            service=service,
            is_approved=True
        ).select_related('user', 'salon').order_by('-created_at')
        
        # Paginate
        paginator = ReviewPagination()
        page = paginator.paginate_queryset(reviews, request)
        
        serializer = ReviewListSerializer(
            page,
            many=True,
            context={'request': request}
        )
        
        return paginator.get_paginated_response(serializer.data)
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([AllowAny])
def service_review_stats(request, service_id):
    """Get review statistics for a specific service"""
    try:
        service = get_object_or_404(Service, id=service_id)
        
        reviews = Review.objects.filter(
            service=service,
            is_approved=True
        )
        
        total_reviews = reviews.count()
        
        if total_reviews == 0:
            return Response({
                'service_id': service.id,
                'service_name': service.name,
                'total_reviews': 0,
                'average_rating': 0.0,
                'rating_distribution': {
                    '5': {'count': 0, 'percentage': 0},
                    '4': {'count': 0, 'percentage': 0},
                    '3': {'count': 0, 'percentage': 0},
                    '2': {'count': 0, 'percentage': 0},
                    '1': {'count': 0, 'percentage': 0},
                }
            })
        
        avg_rating = reviews.aggregate(avg=Avg('rating'))['avg'] or 0.0
        
        # Rating distribution
        rating_dist = {}
        for i in range(1, 6):
            count = reviews.filter(rating=i).count()
            percentage = (count / total_reviews) * 100
            rating_dist[str(i)] = {
                'count': count,
                'percentage': round(percentage, 1)
            }
        
        return Response({
            'service_id': service.id,
            'service_name': service.name,
            'total_reviews': total_reviews,
            'average_rating': round(avg_rating, 1),
            'rating_distribution': rating_dist,
        })
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([AllowAny])
def review_detail(request, review_id):
    """Get detailed view of a single review"""
    try:
        review = get_object_or_404(
            Review,
            id=review_id,
            is_approved=True
        )
        
        serializer = ReviewDetailSerializer(
            review,
            context={'request': request}
        )
        
        return Response(serializer.data)
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_404_NOT_FOUND
        )


# ========================================
# CUSTOMER ENDPOINTS (Auth Required)
# ========================================

@api_view(['POST'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def create_review(request):
    """
    Create a new review
    
    Body:
    {
        "booking_id": 123,  // OR service_id OR salon_id
        "rating": 5,
        "title": "Great experience!",  // Optional
        "comment": "Loved the service...",
        "service_quality_rating": 5,  // Optional
        "staff_behavior_rating": 5,   // Optional
        "ambiance_rating": 4,          // Optional
        "value_for_money_rating": 5,  // Optional
        "images": []                   // Optional
    }
    
    Returns:
        201 — review created
        400 — validation error (missing fields, invalid booking, etc.)
        409 — duplicate review for this booking
        500 — only for unexpected server errors
    """
    from django.db import IntegrityError
    from rest_framework.exceptions import ValidationError
    import traceback
    
    try:
        serializer = ReviewCreateSerializer(
            data=request.data,
            context={'request': request}
        )
        
        if not serializer.is_valid():
            print(f"⚠️ Review validation errors: {serializer.errors}")
            return Response(
                {'error': _flatten_errors(serializer.errors)},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            review = serializer.save()
        except ValidationError as ve:
            # ValidationError raised inside create() for business logic:
            # - "already reviewed this booking"
            # - "can only review completed bookings"
            # - "booking not found"
            error_msg = ve.detail if hasattr(ve, 'detail') else str(ve)
            if isinstance(error_msg, list):
                error_msg = error_msg[0] if error_msg else str(ve)
            error_str = str(error_msg)
            print(f"⚠️ Review business error: {error_str}")
            
            # Return 409 for duplicate review
            if 'already reviewed' in error_str.lower():
                return Response(
                    {'error': error_str},
                    status=status.HTTP_409_CONFLICT
                )
            
            return Response(
                {'error': error_str},
                status=status.HTTP_400_BAD_REQUEST
            )
        except IntegrityError as ie:
            # DB constraint: unique_review_per_booking
            print(f"⚠️ Review IntegrityError: {ie}")
            return Response(
                {'error': 'You have already submitted a review for this booking.'},
                status=status.HTTP_409_CONFLICT
            )
        
        # Return created review
        detail_serializer = ReviewDetailSerializer(
            review,
            context={'request': request}
        )
        
        return Response(
            detail_serializer.data,
            status=status.HTTP_201_CREATED
        )
        
    except Exception as e:
        print(f"❌ UNEXPECTED create_review error: {e}")
        traceback.print_exc()
        return Response(
            {'error': 'An unexpected error occurred. Please try again.'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


def _flatten_errors(errors):
    """Flatten DRF error dict into a single human-readable string."""
    messages = []
    if isinstance(errors, dict):
        for field, field_errors in errors.items():
            if isinstance(field_errors, list):
                for err in field_errors:
                    messages.append(f"{field}: {err}" if field != 'non_field_errors' else str(err))
            else:
                messages.append(f"{field}: {field_errors}")
    elif isinstance(errors, list):
        messages = [str(e) for e in errors]
    else:
        messages = [str(errors)]
    return '; '.join(messages) if messages else 'Validation error'


@api_view(['PUT', 'PATCH'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def update_review(request, review_id):
    """Update user's own review"""
    try:
        review = get_object_or_404(
            Review,
            id=review_id,
            user=request.user
        )
        
        serializer = ReviewUpdateSerializer(
            review,
            data=request.data,
            partial=True
        )
        
        if serializer.is_valid():
            serializer.save()
            
            detail_serializer = ReviewDetailSerializer(
                review,
                context={'request': request}
            )
            
            return Response({
                'message': 'Review updated successfully',
                'review': detail_serializer.data
            })
        
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['DELETE'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def delete_review(request, review_id):
    """Delete user's own review"""
    try:
        review = get_object_or_404(
            Review,
            id=review_id,
            user=request.user
        )
        
        salon = review.salon
        review.delete()
        
        # Recalculate salon rating
        avg_rating = Review.objects.filter(
            salon=salon,
            is_approved=True
        ).aggregate(avg=Avg('rating'))['avg']
        
        if avg_rating:
            salon.rating = round(avg_rating, 1)
        else:
            salon.rating = 0.0
        salon.save()
        
        return Response({
            'message': 'Review deleted successfully'
        })
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def my_reviews(request):
    """Get all reviews by current user"""
    try:
        reviews = Review.objects.filter(
            user=request.user
        ).select_related('salon', 'service').order_by('-created_at')
        
        # Paginate
        paginator = ReviewPagination()
        page = paginator.paginate_queryset(reviews, request)
        
        serializer = ReviewDetailSerializer(
            page,
            many=True,
            context={'request': request}
        )
        
        return paginator.get_paginated_response(serializer.data)
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def mark_review_helpful(request, review_id):
    """
    Mark a review as helpful or not helpful
    
    Body:
    {
        "is_helpful": true  // or false
    }
    """
    try:
        review = get_object_or_404(Review, id=review_id, is_approved=True)
        
        serializer = ReviewHelpfulnessSerializer(data=request.data)
        
        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
        
        is_helpful = serializer.validated_data['is_helpful']
        
        # Check if user already voted
        vote, created = ReviewHelpfulness.objects.get_or_create(
            review=review,
            user=request.user,
            defaults={'is_helpful': is_helpful}
        )
        
        if not created:
            # Update existing vote
            old_vote = vote.is_helpful
            vote.is_helpful = is_helpful
            vote.save()
            
            # Update counts
            if old_vote != is_helpful:
                if is_helpful:
                    review.helpful_count += 1
                    review.not_helpful_count -= 1
                else:
                    review.helpful_count -= 1
                    review.not_helpful_count += 1
                review.save()
        else:
            # New vote
            if is_helpful:
                review.helpful_count += 1
            else:
                review.not_helpful_count += 1
            review.save()
        
        return Response({
            'message': 'Vote recorded successfully',
            'helpful_count': review.helpful_count,
            'not_helpful_count': review.not_helpful_count,
        })
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def report_review(request, review_id):
    """
    Report an inappropriate review
    
    Body:
    {
        "reason": "spam",  // spam, offensive, irrelevant, personal, duplicate, other
        "description": "Details..."  // Optional
    }
    """
    try:
        review = get_object_or_404(Review, id=review_id)
        
        # Check if user already reported this review
        if ReviewReport.objects.filter(
            review=review,
            reported_by=request.user
        ).exists():
            return Response(
                {'error': 'You have already reported this review'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        serializer = ReviewReportSerializer(
            data=request.data,
            context={'request': request}
        )
        
        if serializer.is_valid():
            report = serializer.save(review=review)
            
            return Response({
                'message': 'Review reported successfully. We will review it soon.',
                'report_id': report.id
            })
        
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


# ========================================
# SALON OWNER ENDPOINTS
# ========================================

@api_view(['POST'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def owner_reply_to_review(request, review_id):
    """
    Salon owner reply to a review
    
    Body:
    {
        "reply": "Thank you for your feedback..."
    }
    """
    try:
        review = get_object_or_404(Review, id=review_id)
        
        # Check if user owns the salon
        if not hasattr(request.user, 'salon') or request.user.salon.id != review.salon.id:
            return Response(
                {'error': 'You can only reply to reviews for your own salon'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        serializer = OwnerReplySerializer(data=request.data)
        
        if serializer.is_valid():
            review.owner_reply = serializer.validated_data['reply']
            review.owner_replied_at = timezone.now()
            review.save()
            
            return Response({
                'message': 'Reply posted successfully',
                'owner_reply': review.owner_reply,
                'owner_replied_at': review.owner_replied_at,
            })
        
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def my_salon_reviews(request):
    """Get all reviews for salon owner's salon"""
    try:
        if not hasattr(request.user, 'salon'):
            return Response(
                {'error': 'You do not own a salon'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        salon = request.user.salon
        
        reviews = Review.objects.filter(
            salon=salon
        ).select_related('user', 'service', 'booking').order_by('-created_at')
        
        # Filters
        pending_reply = request.query_params.get('pending_reply', '').lower() == 'true'
        if pending_reply:
            reviews = reviews.filter(owner_reply='')
        
        # Paginate
        paginator = ReviewPagination()
        page = paginator.paginate_queryset(reviews, request)
        
        serializer = ReviewDetailSerializer(
            page,
            many=True,
            context={'request': request}
        )
        
        return paginator.get_paginated_response(serializer.data)
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )