import firebase_admin
from firebase_admin import credentials
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

cred = credentials.Certificate(
    os.path.join(BASE_DIR, "firebase", "serviceAccountKey.json")
)

firebase_admin.initialize_app(cred)
