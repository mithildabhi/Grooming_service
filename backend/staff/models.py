from django.db import models
from accounts.models import User
from salons.models import Salon

class Employee(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        limit_choices_to={'role': 'EMPLOYEE'}
    )
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    salon = models.ForeignKey(Salon, on_delete=models.CASCADE)

    def __str__(self):
        return self.user.username
