from django.urls import path
from .views import (
    BookListView, BookDetailView, borrow_book, return_book,
    BookCreateView, BookUpdateView, BookDeleteView,
    WishlistListView, add_to_wishlist, remove_from_wishlist,
    CartListView, add_to_cart, remove_from_cart, clear_cart, checkout_cart
)

urlpatterns = [
    path('', BookListView.as_view(), name='book_list'),
    path('<int:id>/', BookDetailView.as_view(), name='book_detail'),
    path('<int:book_id>/borrow/', borrow_book, name='borrow_book'),
    path('<int:book_id>/return/', return_book, name='return_book'),
    path('<int:book_id>/wishlist/add/', add_to_wishlist, name='add_to_wishlist'),
    path('<int:book_id>/wishlist/remove/', remove_from_wishlist, name='remove_from_wishlist'),
    path('<int:book_id>/cart/add/', add_to_cart, name='add_to_cart'),
    path('<int:book_id>/cart/remove/', remove_from_cart, name='remove_from_cart'),
    path('admin/create/', BookCreateView.as_view(), name='book_create'),
    path('admin/<int:id>/update/', BookUpdateView.as_view(), name='book_update'),
    path('admin/<int:id>/delete/', BookDeleteView.as_view(), name='book_delete'),
    path('wishlist/', WishlistListView.as_view(), name='wishlist_list'),
    path('cart/', CartListView.as_view(), name='cart_list'),
    path('cart/clear/', clear_cart, name='clear_cart'),
    path('cart/checkout/', checkout_cart, name='checkout_cart'),
]
