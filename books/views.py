from rest_framework import generics, status
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.response import Response
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from django.db.models import Q
from datetime import datetime, timedelta
from .models import Book, BookLoan, Wishlist, Cart
from .serializers import BookSerializer, BookLoanSerializer, WishlistSerializer, CartSerializer


class BookListView(generics.ListAPIView):
    """
    API endpoint to list and search for books.
    
    GET /api/books/
    Query parameters:
        - search: Search in title, author, genre
        - title: Filter by title
        - author: Filter by author
        - genre: Filter by genre
        - isbn: Filter by ISBN
        - available: Filter by availability (true/false)
    """
    serializer_class = BookSerializer

    def get_queryset(self):
        queryset = Book.objects.all()
        
        # General search across multiple fields
        search = self.request.query_params.get('search', None)
        if search:
            queryset = queryset.filter(
                Q(title__icontains=search) |
                Q(author__icontains=search) |
                Q(genre__icontains=search) |
                Q(isbn__icontains=search)
            )
        
        # Specific field filters
        title = self.request.query_params.get('title', None)
        if title:
            queryset = queryset.filter(title__icontains=title)
        
        author = self.request.query_params.get('author', None)
        if author:
            queryset = queryset.filter(author__icontains=author)
        
        genre = self.request.query_params.get('genre', None)
        if genre:
            queryset = queryset.filter(genre__icontains=genre)
        
        isbn = self.request.query_params.get('isbn', None)
        if isbn:
            queryset = queryset.filter(isbn__icontains=isbn)
        
        # Availability filter
        available = self.request.query_params.get('available', None)
        if available is not None:
            if available.lower() == 'true':
                queryset = queryset.filter(available_copies__gt=0)
            elif available.lower() == 'false':
                queryset = queryset.filter(available_copies=0)
        
        return queryset


class BookDetailView(generics.RetrieveAPIView):
    """
    API endpoint to view detailed information about a specific book.
    
    GET /api/books/<id>/
    """
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    lookup_field = 'id'


@api_view(['POST'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def borrow_book(request, book_id):
    """
    API endpoint to borrow a book.
    
    POST /api/books/<id>/borrow/
    Headers:
        Authorization: Token <your_token>
    """
    try:
        book = Book.objects.get(id=book_id)
    except Book.DoesNotExist:
        return Response(
            {'error': 'Book not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Check if book is available
    if book.available_copies <= 0:
        return Response(
            {'error': 'Book is not available for borrowing'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Check if user already has this book borrowed and not returned
    existing_loan = BookLoan.objects.filter(
        user=request.user,
        book=book,
        is_returned=False
    ).first()
    
    if existing_loan:
        return Response(
            {'error': 'You already have this book borrowed'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Create loan record with 14-day loan period
    due_date = datetime.now() + timedelta(days=14)
    loan = BookLoan.objects.create(
        user=request.user,
        book=book,
        due_date=due_date
    )
    
    # Update book available copies
    book.available_copies -= 1
    book.save()
    
    serializer = BookLoanSerializer(loan)
    return Response(
        {
            'message': 'Book borrowed successfully',
            'loan': serializer.data
        },
        status=status.HTTP_201_CREATED
    )


@api_view(['POST'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def return_book(request, book_id):
    """
    API endpoint to return a borrowed book.
    
    POST /api/books/<id>/return/
    Headers:
        Authorization: Token <your_token>
    """
    try:
        book = Book.objects.get(id=book_id)
    except Book.DoesNotExist:
        return Response(
            {'error': 'Book not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Find the active loan for this user and book
    loan = BookLoan.objects.filter(
        user=request.user,
        book=book,
        is_returned=False
    ).first()
    
    if not loan:
        return Response(
            {'error': 'You do not have this book borrowed'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Update loan record
    loan.is_returned = True
    loan.returned_date = datetime.now()
    loan.save()
    
    # Update book available copies
    book.available_copies += 1
    book.save()
    
    serializer = BookLoanSerializer(loan)
    return Response(
        {
            'message': 'Book returned successfully',
            'loan': serializer.data
        },
        status=status.HTTP_200_OK
    )


class BookCreateView(generics.CreateAPIView):
    """
    API endpoint for admins to create new books.
    
    POST /api/books/admin/create/
    Headers:
        Authorization: Token <your_token>
    """
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAdminUser]


class BookUpdateView(generics.UpdateAPIView):
    """
    API endpoint for admins to update existing books.
    
    PUT /api/books/admin/<id>/update/
    Headers:
        Authorization: Token <your_token>
    """
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    lookup_field = 'id'
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAdminUser]


class BookDeleteView(generics.DestroyAPIView):
    """
    API endpoint for admins to delete books.
    
    DELETE /api/books/admin/<id>/delete/
    Headers:
        Authorization: Token <your_token>
    """
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    lookup_field = 'id'
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAdminUser]


class WishlistListView(generics.ListAPIView):
    """
    API endpoint to list user's wishlist.
    
    GET /api/wishlist/
    Headers:
        Authorization: Token <your_token>
    """
    serializer_class = WishlistSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Wishlist.objects.filter(user=self.request.user)


@api_view(['POST'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def add_to_wishlist(request, book_id):
    """
    API endpoint to add a book to wishlist.
    
    POST /api/books/<id>/wishlist/add/
    Headers:
        Authorization: Token <your_token>
    """
    try:
        book = Book.objects.get(id=book_id)
    except Book.DoesNotExist:
        return Response(
            {'error': 'Book not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Check if book is already in wishlist
    existing_wishlist = Wishlist.objects.filter(
        user=request.user,
        book=book
    ).first()
    
    if existing_wishlist:
        return Response(
            {'error': 'Book is already in your wishlist'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Add to wishlist
    wishlist = Wishlist.objects.create(
        user=request.user,
        book=book
    )
    
    serializer = WishlistSerializer(wishlist)
    return Response(
        {
            'message': 'Book added to wishlist successfully',
            'wishlist_item': serializer.data
        },
        status=status.HTTP_201_CREATED
    )


@api_view(['POST'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def remove_from_wishlist(request, book_id):
    """
    API endpoint to remove a book from wishlist.
    
    POST /api/books/<id>/wishlist/remove/
    Headers:
        Authorization: Token <your_token>
    """
    try:
        book = Book.objects.get(id=book_id)
    except Book.DoesNotExist:
        return Response(
            {'error': 'Book not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Find the wishlist item
    wishlist_item = Wishlist.objects.filter(
        user=request.user,
        book=book
    ).first()
    
    if not wishlist_item:
        return Response(
            {'error': 'Book is not in your wishlist'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Remove from wishlist
    wishlist_item.delete()
    
    return Response(
        {'message': 'Book removed from wishlist successfully'},
        status=status.HTTP_200_OK
    )


class CartListView(generics.ListAPIView):
    """
    API endpoint to list user's cart.
    
    GET /api/cart/
    Headers:
        Authorization: Token <your_token>
    """
    serializer_class = CartSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Cart.objects.filter(user=self.request.user)


@api_view(['POST'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def add_to_cart(request, book_id):
    """
    API endpoint to add a book to cart.
    
    POST /api/books/<id>/cart/add/
    Headers:
        Authorization: Token <your_token>
    """
    try:
        book = Book.objects.get(id=book_id)
    except Book.DoesNotExist:
        return Response(
            {'error': 'Book not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Check if book is available
    if book.available_copies <= 0:
        return Response(
            {'error': 'Book is not available'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Check if book is already in cart
    existing_cart = Cart.objects.filter(
        user=request.user,
        book=book
    ).first()
    
    if existing_cart:
        return Response(
            {'error': 'Book is already in your cart'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Add to cart
    cart = Cart.objects.create(
        user=request.user,
        book=book
    )
    
    serializer = CartSerializer(cart)
    return Response(
        {
            'message': 'Book added to cart successfully',
            'cart_item': serializer.data
        },
        status=status.HTTP_201_CREATED
    )


@api_view(['POST'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def remove_from_cart(request, book_id):
    """
    API endpoint to remove a book from cart.
    
    POST /api/books/<id>/cart/remove/
    Headers:
        Authorization: Token <your_token>
    """
    try:
        book = Book.objects.get(id=book_id)
    except Book.DoesNotExist:
        return Response(
            {'error': 'Book not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Find the cart item
    cart_item = Cart.objects.filter(
        user=request.user,
        book=book
    ).first()
    
    if not cart_item:
        return Response(
            {'error': 'Book is not in your cart'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Remove from cart
    cart_item.delete()
    
    return Response(
        {'message': 'Book removed from cart successfully'},
        status=status.HTTP_200_OK
    )


@api_view(['POST'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def clear_cart(request):
    """
    API endpoint to clear all items from cart.
    
    POST /api/cart/clear/
    Headers:
        Authorization: Token <your_token>
    """
    cart_items = Cart.objects.filter(user=request.user)
    count = cart_items.count()
    cart_items.delete()
    
    return Response(
        {
            'message': f'{count} items removed from cart successfully'
        },
        status=status.HTTP_200_OK
    )


@api_view(['POST'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def checkout_cart(request):
    """
    API endpoint to checkout cart (borrow all books in cart).
    
    POST /api/cart/checkout/
    Headers:
        Authorization: Token <your_token>
    """
    cart_items = Cart.objects.filter(user=request.user)
    
    if not cart_items.exists():
        return Response(
            {'error': 'Your cart is empty'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    successful_loans = []
    failed_items = []
    
    for cart_item in cart_items:
        book = cart_item.book
        
        # Check if book is available
        if book.available_copies <= 0:
            failed_items.append({
                'book_id': book.id,
                'title': book.title,
                'reason': 'Book not available'
            })
            continue
        
        # Check if user already has this book borrowed
        existing_loan = BookLoan.objects.filter(
            user=request.user,
            book=book,
            is_returned=False
        ).first()
        
        if existing_loan:
            failed_items.append({
                'book_id': book.id,
                'title': book.title,
                'reason': 'You already have this book borrowed'
            })
            continue
        
        # Create loan record with 14-day loan period
        due_date = datetime.now() + timedelta(days=14)
        loan = BookLoan.objects.create(
            user=request.user,
            book=book,
            due_date=due_date
        )
        
        # Update book available copies
        book.available_copies -= 1
        book.save()
        
        successful_loans.append(BookLoanSerializer(loan).data)
    
    # Clear cart after checkout
    cart_items.delete()
    
    return Response(
        {
            'message': 'Checkout completed',
            'successful_loans': successful_loans,
            'failed_items': failed_items,
            'total_success': len(successful_loans),
            'total_failed': len(failed_items)
        },
        status=status.HTTP_200_OK
    )

