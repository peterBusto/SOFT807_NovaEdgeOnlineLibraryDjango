from rest_framework import status, generics
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from .serializers import UserRegistrationSerializer, UserLoginSerializer, UserSerializer
from .models import User
from books.models import BookLoan
from books.serializers import BookLoanSerializer


@api_view(['POST'])
def register_user(request):
    """
    API endpoint for user registration.
    
    POST /api/register/
    Request body:
    {
        "username": "string",
        "email": "string",
        "first_name": "string",
        "last_name": "string",
        "phone_number": "string (optional)",
        "date_of_birth": "date (optional)",
        "password": "string",
        "password_confirm": "string"
    }
    """
    serializer = UserRegistrationSerializer(data=request.data)
    
    if serializer.is_valid():
        user = serializer.save()
        response_data = {
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'message': 'User registered successfully'
        }
        return Response(response_data, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
def login_user(request):
    """
    API endpoint for user login.
    
    POST /api/login/
    Request body:
    {
        "email": "string",
        "password": "string"
    }
    
    Note: For JWT tokens, use /api/token/ endpoint instead.
    This endpoint is kept for backward compatibility.
    """
    serializer = UserLoginSerializer(data=request.data, context={'request': request})
    
    if serializer.is_valid():
        user = serializer.validated_data['user']
        response_data = {
            'user': {
                'id': user.id,
                'username': user.username,
                'email': user.email,
                'first_name': user.first_name,
                'last_name': user.last_name,
                'is_staff': user.is_staff,
                'is_superuser': user.is_superuser,
            },
            'message': 'Login successful. Use /api/token/ to get JWT tokens.'
        }
        return Response(response_data, status=status.HTTP_200_OK)
    
    return Response(serializer.errors, status=status.HTTP_401_UNAUTHORIZED)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_user(request):
    """
    API endpoint for user logout.
    
    POST /api/logout/
    Headers:
        Authorization: Bearer <your_access_token>
    
    Note: With JWT, logout is handled client-side by discarding tokens.
    For token blacklisting, implement additional logic if needed.
    """
    return Response(
        {'message': 'Logout successful. Please discard your tokens on the client side.'},
        status=status.HTTP_200_OK
    )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def borrowing_history(request):
    """
    API endpoint to view user's borrowing history.
    
    GET /api/borrowing-history/
    Headers:
        Authorization: Bearer <your_access_token>
    Query parameters:
        - status: Filter by status (active/returned)
    """
    loans = BookLoan.objects.filter(user=request.user)
    
    # Filter by status if provided
    status_filter = request.query_params.get('status', None)
    if status_filter:
        if status_filter.lower() == 'active':
            loans = loans.filter(is_returned=False)
        elif status_filter.lower() == 'returned':
            loans = loans.filter(is_returned=True)
    
    serializer = BookLoanSerializer(loans, many=True)
    return Response(
        {
            'borrowing_history': serializer.data,
            'total_loans': loans.count()
        },
        status=status.HTTP_200_OK
    )


class UserListView(generics.ListAPIView):
    """
    API endpoint for admins to list all users.
    
    GET /api/admin/users/
    Headers:
        Authorization: Bearer <admin_access_token>
    """
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAdminUser]


class UserUpdateView(generics.UpdateAPIView):
    """
    API endpoint for admins to update user accounts.
    
    PUT /api/admin/users/<id>/
    Headers:
        Authorization: Bearer <admin_access_token>
    """
    queryset = User.objects.all()
    serializer_class = UserSerializer
    lookup_field = 'id'
    permission_classes = [IsAdminUser]


class UserDeleteView(generics.DestroyAPIView):
    """
    API endpoint for admins to delete user accounts.
    
    DELETE /api/admin/users/<id>/
    Headers:
        Authorization: Bearer <admin_access_token>
    """
    queryset = User.objects.all()
    serializer_class = UserSerializer
    lookup_field = 'id'
    permission_classes = [IsAdminUser]
