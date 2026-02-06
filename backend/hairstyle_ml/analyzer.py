# hairstyle_ml/analyzer.py
# 🎨 ML-BASED HAIRSTYLE ANALYZER
# Integrated with Django for image uploads and storage

import cv2
import numpy as np
from PIL import Image
from typing import Dict, List, Tuple, Optional
import io

try:
    import mediapipe as mp
    MEDIAPIPE_AVAILABLE = True
except ImportError:
    MEDIAPIPE_AVAILABLE = False


class HairstyleAnalyzer:
    """
    Local ML-based hairstyle analyzer
    Works with Django file uploads
    """
    
    def __init__(self):
        """Initialize analyzer with OpenCV and MediaPipe fallback"""
        self.use_opencv_fallback = True
        
        # Try to initialize MediaPipe if available
        if MEDIAPIPE_AVAILABLE:
            try:
                # Check if mp.solutions exists (old API)
                if hasattr(mp, 'solutions'):
                    self.mp_face_mesh = mp.solutions.face_mesh
                    self.face_mesh = self.mp_face_mesh.FaceMesh(
                        static_image_mode=True,
                        max_num_faces=1,
                        refine_landmarks=True,
                        min_detection_confidence=0.5
                    )
                    self.use_opencv_fallback = False
                    print("✅ MediaPipe Face Mesh initialized")
            except Exception as e:
                print(f"⚠️ MediaPipe init failed: {e}")
        
        # Initialize OpenCV fallback
        if self.use_opencv_fallback:
            try:
                self.face_cascade = cv2.CascadeClassifier(
                    cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
                )
                print("✅ OpenCV face detection initialized")
            except Exception as e:
                print(f"❌ OpenCV init failed: {e}")
    
    def analyze_from_django_file(
        self,
        uploaded_file,
        user_gender: str = "unisex",
        user_preferences: Optional[Dict] = None
    ) -> Dict:
        """
        Analyze hairstyle from Django uploaded file
        
        Args:
            uploaded_file: Django UploadedFile object
            user_gender: "male", "female", or "unisex"
            user_preferences: Optional preferences
            
        Returns:
            Complete analysis with recommendations
        """
        try:
            # Read image from uploaded file
            image_bytes = uploaded_file.read()
            
            # Convert to PIL Image
            pil_image = Image.open(io.BytesIO(image_bytes))
            
            # Convert to OpenCV format (BGR)
            image = cv2.cvtColor(np.array(pil_image), cv2.COLOR_RGB2BGR)
            
            if image is None:
                raise ValueError("Could not read image")
            
            # Convert to RGB for MediaPipe
            image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            
            # Analyze face
            if hasattr(self, 'face_mesh') and not self.use_opencv_fallback:
                face_shape, current_style = self._analyze_with_mediapipe(image, image_rgb)
            else:
                face_shape, current_style = self._analyze_with_opencv(image, image_rgb)
            
            if face_shape is None:
                return {
                    'status': 'failed',
                    'error': 'No face detected in image',
                    'suggestion': 'Please upload a clear front-facing photo with your face visible'
                }
            
            # Generate recommendations
            recommendations = self._get_recommendations(
                face_shape,
                user_gender,
                user_preferences or {}
            )
            
            # Get styling tips
            styling_tips = self._get_styling_tips(face_shape, user_gender)
            
            # Get product recommendations
            products = self._get_product_recommendations(face_shape, current_style)
            
            # Compile results
            result = {
                'status': 'success',
                'face_shape': face_shape,
                'current_hairstyle': current_style,
                'recommendations': recommendations,
                'styling_tips': styling_tips,
                'recommended_products': products,
                'metadata': {
                    'gender': user_gender,
                    'analyzer': 'opencv' if self.use_opencv_fallback else 'mediapipe',
                }
            }
            
            return result
            
        except Exception as e:
            print(f"❌ Analysis error: {e}")
            import traceback
            traceback.print_exc()
            return {
                'status': 'failed',
                'error': str(e)
            }
    
    def _analyze_with_opencv(self, image: np.ndarray, image_rgb: np.ndarray) -> Tuple[Optional[str], Dict]:
        """Analyze face using OpenCV (fallback method)"""
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        faces = self.face_cascade.detectMultiScale(gray, 1.3, 5)
        
        if len(faces) == 0:
            return None, {}
        
        # Get the largest face
        x, y, w, h = max(faces, key=lambda f: f[2] * f[3])
        
        # Calculate face shape based on width/height ratio
        aspect_ratio = h / w if w > 0 else 1.0
        
        # Simple face shape detection
        if aspect_ratio < 1.2:
            face_shape = "ROUND"
        elif aspect_ratio > 1.5:
            face_shape = "LONG"
        elif 1.2 <= aspect_ratio <= 1.35:
            # Check if more square or oval
            mid_y = y + h // 2
            face_region = gray[y:y+h, x:x+w]
            
            upper_width = np.mean(face_region[0:h//3, :])
            lower_width = np.mean(face_region[2*h//3:h, :])
            
            if abs(upper_width - lower_width) < 20:
                face_shape = "SQUARE"
            else:
                face_shape = "OVAL"
        else:
            face_shape = "OVAL"
        
        # Analyze current hairstyle
        current_style = self._analyze_current_hairstyle_simple(image, y, h)
        
        return face_shape, current_style
    
    def _analyze_with_mediapipe(self, image: np.ndarray, image_rgb: np.ndarray) -> Tuple[Optional[str], Dict]:
        """Analyze face using MediaPipe"""
        results = self.face_mesh.process(image_rgb)
        
        if not results.multi_face_landmarks:
            return None, {}
        
        face_landmarks = results.multi_face_landmarks[0]
        face_shape = self._detect_face_shape(face_landmarks, image.shape)
        current_style = self._analyze_current_hairstyle(image, face_landmarks)
        
        return face_shape, current_style
    
    def _detect_face_shape(self, face_landmarks, image_shape: Tuple[int, int, int]) -> str:
        """Detect face shape using MediaPipe landmarks"""
        height, width, _ = image_shape
        landmarks = face_landmarks.landmark
        
        # Key landmark indices
        forehead_top = landmarks[10]
        chin = landmarks[152]
        left_face = landmarks[234]
        right_face = landmarks[454]
        left_jaw = landmarks[172]
        right_jaw = landmarks[397]
        left_cheek = landmarks[123]
        right_cheek = landmarks[352]
        
        # Calculate dimensions
        face_length = abs(forehead_top.y - chin.y)
        face_width = abs(right_face.x - left_face.x)
        jaw_width = abs(right_jaw.x - left_jaw.x)
        cheek_width = abs(right_cheek.x - left_cheek.x)
        
        # Calculate ratios
        length_to_width = face_length / face_width if face_width > 0 else 0
        jaw_to_face = jaw_width / face_width if face_width > 0 else 0
        cheek_to_face = cheek_width / face_width if face_width > 0 else 0
        
        # Classify face shape
        if length_to_width < 1.15:
            if jaw_to_face > 0.8:
                return "SQUARE"
            else:
                return "ROUND"
        elif length_to_width > 1.4:
            if jaw_to_face < 0.65:
                return "HEART"
            else:
                return "LONG"
        elif cheek_to_face < 0.85:
            return "DIAMOND"
        else:
            return "OVAL"
    
    def _analyze_current_hairstyle_simple(
        self,
        image: np.ndarray,
        face_y: int,
        face_h: int
    ) -> Dict:
        """Simple hairstyle analysis using face position"""
        height, width, _ = image.shape
        
        # Analyze hair region (above face)
        hair_y = max(0, face_y - 50)
        hair_region = image[hair_y:face_y, :]
        
        if hair_region.size > 0:
            avg_color = hair_region.mean(axis=(0, 1))
            brightness = avg_color.mean()
            
            if brightness < 80:
                hair_color = "dark"
            elif brightness > 170:
                hair_color = "light/blonde"
            else:
                hair_color = "medium/brown"
        else:
            hair_color = "medium"
        
        # Estimate length
        if face_y < height * 0.15:
            hair_length = "short"
        elif face_y < height * 0.3:
            hair_length = "medium"
        else:
            hair_length = "long"
        
        return {
            'length': hair_length,
            'color': hair_color,
            'description': f"{hair_length} {hair_color} hair"
        }
    
    def _analyze_current_hairstyle(self, image: np.ndarray, face_landmarks) -> Dict:
        """Analyze current hairstyle from landmarks"""
        height, width, _ = image.shape
        landmarks = face_landmarks.landmark
        
        forehead = landmarks[10]
        forehead_y = int(forehead.y * height)
        
        hair_region = image[max(0, forehead_y - 100):forehead_y, :]
        
        if hair_region.size > 0:
            avg_color = hair_region.mean(axis=(0, 1))
            brightness = avg_color.mean()
            
            if brightness < 80:
                hair_color = "dark"
            elif brightness > 170:
                hair_color = "light/blonde"
            else:
                hair_color = "medium/brown"
        else:
            hair_color = "unknown"
        
        hair_height = forehead_y
        
        if hair_height < height * 0.15:
            hair_length = "short"
        elif hair_height < height * 0.3:
            hair_length = "medium"
        else:
            hair_length = "long"
        
        return {
            'length': hair_length,
            'color': hair_color,
            'description': f"{hair_length} {hair_color} hair"
        }
    
    def _get_recommendations(self, face_shape: str, gender: str, preferences: Dict) -> List[Dict]:
        """Get hairstyle recommendations"""
        recommendations_db = {
            'OVAL': {
                'male': [
                    {'name': 'Textured Crop', 'difficulty': 'easy', 'maintenance': 'low', 'description': 'Modern short style with textured top'},
                    {'name': 'Side Part', 'difficulty': 'easy', 'maintenance': 'medium', 'description': 'Classic professional look'},
                    {'name': 'Quiff', 'difficulty': 'medium', 'maintenance': 'medium', 'description': 'Stylish swept-back top'},
                    {'name': 'Slicked Back', 'difficulty': 'medium', 'maintenance': 'high', 'description': 'Elegant formal style'},
                    {'name': 'French Crop', 'difficulty': 'easy', 'maintenance': 'low', 'description': 'Short fringe style'},
                ],
                'female': [
                    {'name': 'Long Layers', 'difficulty': 'medium', 'maintenance': 'medium', 'description': 'Versatile flowing layers'},
                    {'name': 'Blunt Bob', 'difficulty': 'easy', 'maintenance': 'low', 'description': 'Chic shoulder-length cut'},
                    {'name': 'Beach Waves', 'difficulty': 'medium', 'maintenance': 'medium', 'description': 'Relaxed wavy texture'},
                    {'name': 'Pixie Cut', 'difficulty': 'easy', 'maintenance': 'low', 'description': 'Short and edgy'},
                    {'name': 'Center Part', 'difficulty': 'easy', 'maintenance': 'low', 'description': 'Balanced symmetrical style'},
                ]
            },
            'ROUND': {
                'male': [
                    {'name': 'High Fade with Quiff', 'difficulty': 'medium', 'maintenance': 'high', 'description': 'Volume on top, short sides'},
                    {'name': 'Pompadour', 'difficulty': 'hard', 'maintenance': 'high', 'description': 'Dramatic height and volume'},
                    {'name': 'Faux Hawk', 'difficulty': 'medium', 'maintenance': 'medium', 'description': 'Edgy center spike'},
                    {'name': 'Textured Top', 'difficulty': 'easy', 'maintenance': 'medium', 'description': 'Messy textured look'},
                ],
                'female': [
                    {'name': 'Long Layers', 'difficulty': 'medium', 'maintenance': 'medium', 'description': 'Elongating layers'},
                    {'name': 'Side-Swept Bangs', 'difficulty': 'easy', 'maintenance': 'medium', 'description': 'Flattering side fringe'},
                    {'name': 'Angled Bob', 'difficulty': 'medium', 'maintenance': 'low', 'description': 'Longer front, shorter back'},
                    {'name': 'High Ponytail', 'difficulty': 'easy', 'maintenance': 'low', 'description': 'Lifts facial features'},
                ]
            },
            'SQUARE': {
                'male': [
                    {'name': 'Textured Quiff', 'difficulty': 'medium', 'maintenance': 'medium', 'description': 'Soft textured volume'},
                    {'name': 'Side Part', 'difficulty': 'easy', 'maintenance': 'medium', 'description': 'Classic softening style'},
                    {'name': 'Longer on Top', 'difficulty': 'easy', 'maintenance': 'medium', 'description': 'Length adds softness'},
                    {'name': 'Messy Fringe', 'difficulty': 'easy', 'maintenance': 'low', 'description': 'Relaxed front texture'},
                ],
                'female': [
                    {'name': 'Soft Waves', 'difficulty': 'medium', 'maintenance': 'medium', 'description': 'Gentle curves soften angles'},
                    {'name': 'Layered Cut', 'difficulty': 'medium', 'maintenance': 'medium', 'description': 'Movement and texture'},
                    {'name': 'Side-Swept Bangs', 'difficulty': 'easy', 'maintenance': 'medium', 'description': 'Diagonal softening'},
                    {'name': 'Chin-Length Bob', 'difficulty': 'easy', 'maintenance': 'low', 'description': 'Balance and harmony'},
                ]
            },
            'HEART': {
                'male': [
                    {'name': 'Short Sides, Long Top', 'difficulty': 'easy', 'maintenance': 'medium', 'description': 'Balances forehead width'},
                    {'name': 'Textured Crop', 'difficulty': 'easy', 'maintenance': 'low', 'description': 'Even proportions'},
                    {'name': 'Side Part', 'difficulty': 'easy', 'maintenance': 'medium', 'description': 'Classic balanced look'},
                ],
                'female': [
                    {'name': 'Chin-Length Bob', 'difficulty': 'easy', 'maintenance': 'low', 'description': 'Widens narrow chin'},
                    {'name': 'Side-Swept Bangs', 'difficulty': 'easy', 'maintenance': 'medium', 'description': 'Minimizes forehead'},
                    {'name': 'Layers Starting at Chin', 'difficulty': 'medium', 'maintenance': 'medium', 'description': 'Adds width below'},
                    {'name': 'Soft Curls at Ends', 'difficulty': 'medium', 'maintenance': 'medium', 'description': 'Volume at jawline'},
                ]
            },
            'LONG': {
                'male': [
                    {'name': 'Short on Sides, Volume on Top', 'difficulty': 'medium', 'maintenance': 'medium', 'description': 'Creates width'},
                    {'name': 'Layered Cut', 'difficulty': 'medium', 'maintenance': 'medium', 'description': 'Adds horizontal volume'},
                    {'name': 'Textured Fringe', 'difficulty': 'easy', 'maintenance': 'low', 'description': 'Shortens face visually'},
                ],
                'female': [
                    {'name': 'Blunt Cut at Shoulders', 'difficulty': 'easy', 'maintenance': 'low', 'description': 'Horizontal line breaks length'},
                    {'name': 'Side-Swept Bangs', 'difficulty': 'easy', 'maintenance': 'medium', 'description': 'Shortens forehead'},
                    {'name': 'Layers Throughout', 'difficulty': 'medium', 'maintenance': 'medium', 'description': 'Creates width'},
                    {'name': 'Wispy Bangs', 'difficulty': 'easy', 'maintenance': 'medium', 'description': 'Soft face-framing'},
                ]
            },
            'DIAMOND': {
                'male': [
                    {'name': 'Side Part with Volume', 'difficulty': 'medium', 'maintenance': 'medium', 'description': 'Balances cheekbones'},
                    {'name': 'Textured Quiff', 'difficulty': 'medium', 'maintenance': 'medium', 'description': 'Forehead width'},
                    {'name': 'Slicked Back', 'difficulty': 'medium', 'maintenance': 'high', 'description': 'Smooth elegant look'},
                ],
                'female': [
                    {'name': 'Side-Swept Bangs', 'difficulty': 'easy', 'maintenance': 'medium', 'description': 'Widens forehead'},
                    {'name': 'Chin-Length Bob', 'difficulty': 'easy', 'maintenance': 'low', 'description': 'Adds chin width'},
                    {'name': 'Long Layers', 'difficulty': 'medium', 'maintenance': 'medium', 'description': 'Softens cheekbones'},
                    {'name': 'Soft Waves', 'difficulty': 'medium', 'maintenance': 'medium', 'description': 'Gentle balance'},
                ]
            }
        }
        
        if gender.lower() in ['male', 'female']:
            recs = recommendations_db.get(face_shape, {}).get(gender.lower(), [])
        else:
            male_recs = recommendations_db.get(face_shape, {}).get('male', [])
            female_recs = recommendations_db.get(face_shape, {}).get('female', [])
            recs = male_recs + female_recs
        
        return recs[:5]
    
    def _get_styling_tips(self, face_shape: str, gender: str) -> List[str]:
        """Get styling tips"""
        tips_db = {
            'OVAL': [
                "You have the most versatile face shape!",
                "Almost any hairstyle will suit you",
                "Experiment with different lengths and styles",
                "Balance is key - avoid extreme styles"
            ],
            'ROUND': [
                "Add height on top to elongate your face",
                "Side parts work better than center parts",
                "Avoid blunt bangs",
                "Volume at the crown creates balance"
            ],
            'SQUARE': [
                "Soften angles with layered cuts",
                "Side-swept styles work great",
                "Avoid blunt, straight-across cuts",
                "Add texture for a softer look"
            ],
            'HEART': [
                "Balance your forehead with width at chin level",
                "Side-swept bangs are flattering",
                "Avoid volume at the crown",
                "Chin-length cuts work wonderfully"
            ],
            'LONG': [
                "Add width with layers",
                "Bangs can shorten the appearance",
                "Avoid long, straight styles without layers",
                "Volume on sides balances face length"
            ],
            'DIAMOND': [
                "Add width at forehead and chin",
                "Side-swept bangs are flattering",
                "Avoid too much volume at cheekbones",
                "Soft, wispy styles work best"
            ]
        }
        
        return tips_db.get(face_shape, [
            "Consult with a professional stylist",
            "Consider your lifestyle and maintenance",
            "Choose styles that make you feel confident"
        ])
    
    def _get_product_recommendations(self, face_shape: str, current_style: Dict) -> List[str]:
        """Get product recommendations"""
        products = [
            "Quality shampoo and conditioner",
            "Heat protectant spray",
            "Wide-tooth comb"
        ]
        
        length = current_style.get('length', 'medium')
        
        if length == 'short':
            products.extend([
                "Texturizing paste",
                "Matte pomade",
                "Sea salt spray"
            ])
        elif length == 'medium':
            products.extend([
                "Styling cream",
                "Light hold gel",
                "Blow dryer with diffuser"
            ])
        else:
            products.extend([
                "Leave-in conditioner",
                "Argan oil",
                "Curl defining cream"
            ])
        
        return products[:6]


# Global analyzer instance
_analyzer_instance = None

def get_analyzer():
    """Get or create global analyzer instance"""
    global _analyzer_instance
    if _analyzer_instance is None:
        _analyzer_instance = HairstyleAnalyzer()
    return _analyzer_instance