# hairstyle_ml/views.py
# 🎨 HAIRSTYLE ML API ENDPOINTS

from rest_framework.decorators import api_view, permission_classes, authentication_classes, parser_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from rest_framework.parsers import MultiPartParser, FormParser
from authentication.firebase_auth import FirebaseAuthentication
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
from datetime import datetime
import os

from .models import HairstyleAnalysis, HairstyleRecommendationFeedback
from .analyzer import get_analyzer


@api_view(['POST'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
@parser_classes([MultiPartParser, FormParser])
def analyze_hairstyle(request):
    """
    🎨 Analyze hairstyle from uploaded image
    
    Expects:
    - image: Image file (multipart/form-data)
    - gender: "male", "female", or "unisex" (optional, default: unisex)
    - preferences: JSON string of preferences (optional)
    """
    try:
        print(f"\n{'='*60}")
        print(f"🎨 HAIRSTYLE ANALYSIS REQUEST")
        print(f"👤 User: {request.user.email}")
        
        # Get image file
        if 'image' not in request.FILES:
            return Response(
                {'error': 'Image file is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        image_file = request.FILES['image']
        
        # Validate image file (check both content type and extension)
        valid_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp']
        file_extension = os.path.splitext(image_file.name.lower())[1]
        
        is_valid_image = (
            image_file.content_type and image_file.content_type.startswith('image/')
        ) or file_extension in valid_extensions
        
        if not is_valid_image:
            return Response(
                {'error': 'File must be an image (jpg, jpeg, png, gif, bmp, or webp)'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Validate file size (max 10MB)
        if image_file.size > 10 * 1024 * 1024:
            return Response(
                {'error': 'Image file too large (max 10MB)'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Get user preferences
        gender = request.data.get('gender', 'unisex')
        if gender not in ['male', 'female', 'unisex']:
            gender = 'unisex'
        
        # Parse preferences if provided
        import json
        preferences_str = request.data.get('preferences', '{}')
        try:
            preferences = json.loads(preferences_str) if isinstance(preferences_str, str) else preferences_str
        except:
            preferences = {}
        
        print(f"📸 Image: {image_file.name} ({image_file.size} bytes)")
        print(f"👤 Gender: {gender}")
        print(f"⚙️ Preferences: {preferences}")
        
        # Create analysis record
        analysis = HairstyleAnalysis.objects.create(
            user=request.user,
            uploaded_image=image_file,
            user_gender=gender,
            user_preferences=preferences
        )
        
        print(f"💾 Analysis record created: ID {analysis.id}")
        
        # Run ML analysis
        try:
            analyzer = get_analyzer()
            
            # Reopen the file for analysis
            image_file.seek(0)
            
            result = analyzer.analyze_from_django_file(
                image_file,
                user_gender=gender,
                user_preferences=preferences
            )
            
            print(f"🔍 Analysis result: {result.get('status')}")
            
            if result['status'] == 'success':
                # Update analysis record with results
                analysis.analysis_successful = True
                analysis.face_shape = result['face_shape']
                analysis.current_hair_length = result['current_hairstyle'].get('length')
                analysis.current_hair_color = result['current_hairstyle'].get('color')
                analysis.recommendations = result['recommendations']
                analysis.styling_tips = result['styling_tips']
                analysis.recommended_products = result['recommended_products']
                analysis.save()
                
                print(f"✅ Analysis saved: Face shape = {result['face_shape']}")
                print(f"{'='*60}\n")
                
                return Response({
                    'success': True,
                    'analysis_id': analysis.id,
                    'face_shape': result['face_shape'],
                    'current_hairstyle': result['current_hairstyle'],
                    'recommendations': result['recommendations'],
                    'styling_tips': result['styling_tips'],
                    'recommended_products': result['recommended_products'],
                    'image_url': request.build_absolute_uri(analysis.uploaded_image.url),
                    'timestamp': datetime.now().isoformat(),
                    'metadata': result.get('metadata', {})
                })
            else:
                # Analysis failed
                analysis.analysis_successful = False
                analysis.error_message = result.get('error', 'Unknown error')
                analysis.save()
                
                print(f"❌ Analysis failed: {result.get('error')}")
                print(f"{'='*60}\n")
                
                return Response({
                    'success': False,
                    'error': result.get('error'),
                    'suggestion': result.get('suggestion', 'Please try again with a clearer photo')
                }, status=status.HTTP_400_BAD_REQUEST)
                
        except Exception as e:
            print(f"❌ ML Analysis error: {e}")
            import traceback
            traceback.print_exc()
            
            analysis.analysis_successful = False
            analysis.error_message = str(e)
            analysis.save()
            
            return Response({
                'success': False,
                'error': 'Failed to analyze image',
                'details': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
    except Exception as e:
        print(f"❌ Request handling error: {e}")
        import traceback
        traceback.print_exc()
        
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def get_analysis_history(request):
    """
    📜 Get user's hairstyle analysis history
    """
    try:
        # Get query parameters
        limit = int(request.GET.get('limit', 10))
        limit = min(limit, 50)  # Max 50 records
        
        analyses = HairstyleAnalysis.objects.filter(
            user=request.user,
            analysis_successful=True
        ).order_by('-created_at')[:limit]
        
        history = []
        for analysis in analyses:
            history.append({
                'id': analysis.id,
                'face_shape': analysis.face_shape,
                'current_hair_length': analysis.current_hair_length,
                'current_hair_color': analysis.current_hair_color,
                'recommendations_count': len(analysis.recommendations),
                'image_url': request.build_absolute_uri(analysis.uploaded_image.url) if analysis.uploaded_image else None,
                'created_at': analysis.created_at.isoformat(),
                'gender': analysis.user_gender
            })
        
        return Response({
            'success': True,
            'count': len(history),
            'history': history
        })
        
    except Exception as e:
        print(f"❌ History fetch error: {e}")
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def get_analysis_detail(request, analysis_id):
    """
    📊 Get detailed analysis by ID
    """
    try:
        analysis = HairstyleAnalysis.objects.get(
            id=analysis_id,
            user=request.user
        )
        
        if not analysis.analysis_successful:
            return Response({
                'error': 'Analysis was not successful',
                'details': analysis.error_message
            }, status=status.HTTP_400_BAD_REQUEST)
        
        return Response({
            'success': True,
            'analysis': {
                'id': analysis.id,
                'face_shape': analysis.face_shape,
                'current_hairstyle': {
                    'length': analysis.current_hair_length,
                    'color': analysis.current_hair_color,
                },
                'recommendations': analysis.recommendations,
                'styling_tips': analysis.styling_tips,
                'recommended_products': analysis.recommended_products,
                'image_url': request.build_absolute_uri(analysis.uploaded_image.url) if analysis.uploaded_image else None,
                'created_at': analysis.created_at.isoformat(),
                'gender': analysis.user_gender,
                'preferences': analysis.user_preferences
            }
        })
        
    except HairstyleAnalysis.DoesNotExist:
        return Response(
            {'error': 'Analysis not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    except Exception as e:
        print(f"❌ Detail fetch error: {e}")
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def submit_feedback(request, analysis_id):
    """
    💬 Submit feedback on a hairstyle recommendation
    
    Expects:
    - recommendation_name: Name of the recommendation
    - liked: Boolean (true/false)
    - tried: Boolean (optional)
    - comment: String (optional)
    """
    try:
        analysis = HairstyleAnalysis.objects.get(
            id=analysis_id,
            user=request.user
        )
        
        recommendation_name = request.data.get('recommendation_name')
        liked = request.data.get('liked')
        
        if not recommendation_name or liked is None:
            return Response(
                {'error': 'recommendation_name and liked are required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        feedback = HairstyleRecommendationFeedback.objects.create(
            analysis=analysis,
            recommendation_name=recommendation_name,
            liked=bool(liked),
            tried=bool(request.data.get('tried', False)),
            comment=request.data.get('comment', '')
        )
        
        return Response({
            'success': True,
            'message': 'Feedback submitted successfully',
            'feedback_id': feedback.id
        })
        
    except HairstyleAnalysis.DoesNotExist:
        return Response(
            {'error': 'Analysis not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    except Exception as e:
        print(f"❌ Feedback error: {e}")
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['DELETE'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def delete_analysis(request, analysis_id):
    """
    🗑️ Delete an analysis record
    """
    try:
        analysis = HairstyleAnalysis.objects.get(
            id=analysis_id,
            user=request.user
        )
        
        # Delete the image file
        if analysis.uploaded_image:
            try:
                default_storage.delete(analysis.uploaded_image.name)
            except:
                pass
        
        # Delete the record
        analysis.delete()
        
        return Response({
            'success': True,
            'message': 'Analysis deleted successfully'
        })
        
    except HairstyleAnalysis.DoesNotExist:
        return Response(
            {'error': 'Analysis not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    except Exception as e:
        print(f"❌ Delete error: {e}")
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )