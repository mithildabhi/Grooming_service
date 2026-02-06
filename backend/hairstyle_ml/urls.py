# hairstyle_ml/urls.py

from django.urls import path
from . import views

app_name = 'hairstyle_ml'

urlpatterns = [
    # Main analysis endpoint
    path('analyze/', views.analyze_hairstyle, name='analyze-hairstyle'),
    
    # History and details
    path('history/', views.get_analysis_history, name='analysis-history'),
    path('analysis/<int:analysis_id>/', views.get_analysis_detail, name='analysis-detail'),
    
    # Feedback
    path('analysis/<int:analysis_id>/feedback/', views.submit_feedback, name='submit-feedback'),
    
    # Delete
    path('analysis/<int:analysis_id>/delete/', views.delete_analysis, name='delete-analysis'),
]


"""
🎨 HAIRSTYLE ML API ENDPOINTS

BASE URL: /api/hairstyle/

ENDPOINTS:

1. POST /api/hairstyle/analyze/
   - Upload image and get hairstyle recommendations
   - Body (multipart/form-data):
     * image: Image file (required)
     * gender: "male" | "female" | "unisex" (optional, default: unisex)
     * preferences: JSON string (optional)
   
   Response:
   {
     "success": true,
     "analysis_id": 123,
     "face_shape": "OVAL",
     "current_hairstyle": {
       "length": "medium",
       "color": "dark",
       "description": "medium dark hair"
     },
     "recommendations": [
       {
         "name": "Textured Crop",
         "difficulty": "easy",
         "maintenance": "low",
         "description": "Modern short style..."
       },
       ...
     ],
     "styling_tips": ["tip1", "tip2", ...],
     "recommended_products": ["product1", ...],
     "image_url": "https://..."
   }

2. GET /api/hairstyle/history/
   - Get user's analysis history
   - Query params:
     * limit: Number of records (default: 10, max: 50)
   
   Response:
   {
     "success": true,
     "count": 5,
     "history": [
       {
         "id": 123,
         "face_shape": "OVAL",
         "current_hair_length": "medium",
         "recommendations_count": 5,
         "image_url": "https://...",
         "created_at": "2025-01-15T10:30:00Z"
       },
       ...
     ]
   }

3. GET /api/hairstyle/analysis/{analysis_id}/
   - Get detailed analysis by ID
   
   Response:
   {
     "success": true,
     "analysis": {
       "id": 123,
       "face_shape": "OVAL",
       "current_hairstyle": {...},
       "recommendations": [...],
       "styling_tips": [...],
       "recommended_products": [...],
       "image_url": "https://...",
       "created_at": "..."
     }
   }

4. POST /api/hairstyle/analysis/{analysis_id}/feedback/
   - Submit feedback on recommendation
   - Body:
     {
       "recommendation_name": "Textured Crop",
       "liked": true,
       "tried": false,
       "comment": "Looks great!"
     }

5. DELETE /api/hairstyle/analysis/{analysis_id}/delete/
   - Delete an analysis record

EXAMPLE USAGE (Flutter/Dart):

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

// Upload image for analysis
Future<Map<String, dynamic>> analyzeHairstyle(File imageFile, String gender) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/hairstyle/analyze/');
  final request = http.MultipartRequest('POST', uri);
  
  // Add headers
  final token = await FirebaseAuth.instance.currentUser?.getIdToken();
  request.headers['Authorization'] = 'Bearer $token';
  
  // Add image
  request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
  
  // Add gender
  request.fields['gender'] = gender;
  
  final response = await request.send();
  final responseData = await response.stream.bytesToString();
  
  return jsonDecode(responseData);
}

// Get history
Future<List> getAnalysisHistory() async {
  final token = await FirebaseAuth.instance.currentUser?.getIdToken();
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/hairstyle/history/?limit=10'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  
  final data = jsonDecode(response.body);
  return data['history'];
}
```
"""