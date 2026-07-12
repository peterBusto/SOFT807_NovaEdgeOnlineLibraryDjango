from rest_framework import serializers
from .models import Book, BookLoan, Wishlist, Cart


class BookSerializer(serializers.ModelSerializer):
    """Serializer for Book model."""
    availability_status = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Book
        fields = [
            'id',
            'title',
            'author',
            'isbn',
            'publication_date',
            'genre',
            'description',
            'total_copies',
            'available_copies',
            'availability_status',
            'cover_image_url',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at', 'availability_status']

    def get_availability_status(self, obj):
        """Return availability status based on available copies."""
        if obj.available_copies > 0:
            return 'available'
        return 'unavailable'


class BookLoanSerializer(serializers.ModelSerializer):
    """Serializer for BookLoan model."""
    book_title = serializers.CharField(source='book.title', read_only=True)
    book_author = serializers.CharField(source='book.author', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = BookLoan
        fields = [
            'id',
            'user',
            'username',
            'book',
            'book_title',
            'book_author',
            'borrowed_date',
            'due_date',
            'returned_date',
            'is_returned'
        ]
        read_only_fields = ['borrowed_date', 'returned_date', 'is_returned']


class WishlistSerializer(serializers.ModelSerializer):
    """Serializer for Wishlist model."""
    book_title = serializers.CharField(source='book.title', read_only=True)
    book_author = serializers.CharField(source='book.author', read_only=True)
    book_genre = serializers.CharField(source='book.genre', read_only=True)
    book_cover_image_url = serializers.CharField(source='book.cover_image_url', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = Wishlist
        fields = [
            'id',
            'user',
            'username',
            'book',
            'book_title',
            'book_author',
            'book_genre',
            'book_cover_image_url',
            'added_date'
        ]
        read_only_fields = ['added_date']


class CartSerializer(serializers.ModelSerializer):
    """Serializer for Cart model."""
    book_title = serializers.CharField(source='book.title', read_only=True)
    book_author = serializers.CharField(source='book.author', read_only=True)
    book_genre = serializers.CharField(source='book.genre', read_only=True)
    book_cover_image_url = serializers.CharField(source='book.cover_image_url', read_only=True)
    book_available_copies = serializers.IntegerField(source='book.available_copies', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = Cart
        fields = [
            'id',
            'user',
            'username',
            'book',
            'book_title',
            'book_author',
            'book_genre',
            'book_cover_image_url',
            'book_available_copies',
            'added_date'
        ]
        read_only_fields = ['added_date']
