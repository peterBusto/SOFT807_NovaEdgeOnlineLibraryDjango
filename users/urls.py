from django.urls import path
from .views import (
    register_user, login_user, logout_user, borrowing_history,
    UserListView, UserUpdateView, UserDeleteView
)

urlpatterns = [
    path('register/', register_user, name='register_user'),
    path('login/', login_user, name='login_user'),
    path('logout/', logout_user, name='logout_user'),
    path('borrowing-history/', borrowing_history, name='borrowing_history'),
    path('admin/users/', UserListView.as_view(), name='user_list'),
    path('admin/users/<int:id>/', UserUpdateView.as_view(), name='user_update'),
    path('admin/users/<int:id>/delete/', UserDeleteView.as_view(), name='user_delete'),
]
