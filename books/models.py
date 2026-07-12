from django.db import models
from django.conf import settings


class Book(models.Model):
    """Book model for the Online Library application."""
    title = models.CharField(max_length=255)
    author = models.CharField(max_length=255)
    isbn = models.CharField(max_length=13, unique=True)
    publication_date = models.DateField()
    genre = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    total_copies = models.PositiveIntegerField(default=1)
    available_copies = models.PositiveIntegerField(default=1)
    cover_image_url = models.URLField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['title']
        verbose_name = 'Book'
        verbose_name_plural = 'Books'

    def __str__(self):
        return f"{self.title} by {self.author}"


class BookLoan(models.Model):
    """BookLoan model to track book borrowings."""
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='loans'
    )
    book = models.ForeignKey(
        Book,
        on_delete=models.CASCADE,
        related_name='loans'
    )
    borrowed_date = models.DateTimeField(auto_now_add=True)
    due_date = models.DateTimeField()
    returned_date = models.DateTimeField(blank=True, null=True)
    is_returned = models.BooleanField(default=False)

    class Meta:
        ordering = ['-borrowed_date']
        verbose_name = 'Book Loan'
        verbose_name_plural = 'Book Loans'

    def __str__(self):
        return f"{self.user.username} - {self.book.title}"


class Wishlist(models.Model):
    """Wishlist model for users to save books they like."""
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='wishlist'
    )
    book = models.ForeignKey(
        Book,
        on_delete=models.CASCADE,
        related_name='wishlists'
    )
    added_date = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ['user', 'book']
        ordering = ['-added_date']
        verbose_name = 'Wishlist'
        verbose_name_plural = 'Wishlists'

    def __str__(self):
        return f"{self.user.username} - {self.book.title}"


class Cart(models.Model):
    """Cart model for users to manage books they want to borrow."""
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='cart'
    )
    book = models.ForeignKey(
        Book,
        on_delete=models.CASCADE,
        related_name='carts'
    )
    added_date = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ['user', 'book']
        ordering = ['-added_date']
        verbose_name = 'Cart'
        verbose_name_plural = 'Carts'

    def __str__(self):
        return f"{self.user.username} - {self.book.title}"
