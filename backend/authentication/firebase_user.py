class FirebaseUser:
    def __init__(self, uid, email=None, claims=None):
        self.uid = uid
        self.email = email
        self.claims = claims or {}

    @property
    def is_authenticated(self):
        return True

    @property
    def is_staff(self):
        return False

    @property
    def is_superuser(self):
        return False

    def __str__(self):
        return self.email or self.uid
