-- =============================================
-- NovaEdge Online Library Database Schema
-- MS SQL Server Script
-- =============================================

-- Create Database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'NovaEdgeLibraryDB')
BEGIN
    CREATE DATABASE NovaEdgeLibraryDB;
END
GO

USE NovaEdgeLibraryDB;
GO

-- =============================================
-- Custom User Table (auth_user)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'auth_user')
BEGIN
    CREATE TABLE auth_user (
        id INT IDENTITY(1,1) PRIMARY KEY,
        password NVARCHAR(128) NOT NULL,
        last_login DATETIME NULL,
        is_superuser BIT NOT NULL DEFAULT 0,
        username NVARCHAR(150) NOT NULL UNIQUE,
        first_name NVARCHAR(150) NOT NULL,
        last_name NVARCHAR(150) NOT NULL,
        email NVARCHAR(254) NOT NULL UNIQUE,
        is_staff BIT NOT NULL DEFAULT 0,
        is_active BIT NOT NULL DEFAULT 1,
        date_joined DATETIME NOT NULL DEFAULT GETDATE(),
        phone_number NVARCHAR(20) NULL,
        date_of_birth DATE NULL,
        created_at DATETIME NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME NOT NULL DEFAULT GETDATE()
    );
    
    CREATE INDEX idx_auth_user_username ON auth_user(username);
    CREATE INDEX idx_auth_user_email ON auth_user(email);
END
GO

-- =============================================
-- Book Table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'books_book')
BEGIN
    CREATE TABLE books_book (
        id INT IDENTITY(1,1) PRIMARY KEY,
        title NVARCHAR(255) NOT NULL,
        author NVARCHAR(255) NOT NULL,
        isbn NVARCHAR(13) NOT NULL UNIQUE,
        publication_date DATE NOT NULL,
        genre NVARCHAR(100) NOT NULL,
        description NVARCHAR(MAX) NULL,
        total_copies INT NOT NULL DEFAULT 1,
        available_copies INT NOT NULL DEFAULT 1,
        cover_image_url NVARCHAR(MAX) NULL,
        created_at DATETIME NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME NOT NULL DEFAULT GETDATE()
    );
    
    CREATE INDEX idx_books_book_title ON books_book(title);
    CREATE INDEX idx_books_book_author ON books_book(author);
    CREATE INDEX idx_books_book_genre ON books_book(genre);
    CREATE INDEX idx_books_book_isbn ON books_book(isbn);
END
GO

-- =============================================
-- Book Loan Table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'books_bookloan')
BEGIN
    CREATE TABLE books_bookloan (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        book_id INT NOT NULL,
        borrowed_date DATETIME NOT NULL DEFAULT GETDATE(),
        due_date DATETIME NOT NULL,
        returned_date DATETIME NULL,
        is_returned BIT NOT NULL DEFAULT 0,
        CONSTRAINT fk_bookloan_user FOREIGN KEY (user_id) REFERENCES auth_user(id) ON DELETE CASCADE,
        CONSTRAINT fk_bookloan_book FOREIGN KEY (book_id) REFERENCES books_book(id) ON DELETE CASCADE
    );
    
    CREATE INDEX idx_bookloan_user ON books_bookloan(user_id);
    CREATE INDEX idx_bookloan_book ON books_bookloan(book_id);
    CREATE INDEX idx_bookloan_returned ON books_bookloan(is_returned);
END
GO

-- =============================================
-- Django Authtoken Table (for token authentication)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'authtoken_token')
BEGIN
    CREATE TABLE authtoken_token (
        [key] NVARCHAR(40) PRIMARY KEY,
        created DATETIME NOT NULL DEFAULT GETDATE(),
        user_id INT NOT NULL UNIQUE,
        CONSTRAINT fk_token_user FOREIGN KEY (user_id) REFERENCES auth_user(id) ON DELETE CASCADE
    );
    
    CREATE INDEX idx_authtoken_user ON authtoken_token(user_id);
END
GO

-- =============================================
-- Wishlist Table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'books_wishlist')
BEGIN
    CREATE TABLE books_wishlist (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        book_id INT NOT NULL,
        added_date DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT fk_wishlist_user FOREIGN KEY (user_id) REFERENCES auth_user(id) ON DELETE CASCADE,
        CONSTRAINT fk_wishlist_book FOREIGN KEY (book_id) REFERENCES books_book(id) ON DELETE CASCADE,
        CONSTRAINT unique_user_book UNIQUE (user_id, book_id)
    );
    
    CREATE INDEX idx_wishlist_user ON books_wishlist(user_id);
    CREATE INDEX idx_wishlist_book ON books_wishlist(book_id);
END
GO

-- =============================================
-- Cart Table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'books_cart')
BEGIN
    CREATE TABLE books_cart (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        book_id INT NOT NULL,
        added_date DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT fk_cart_user FOREIGN KEY (user_id) REFERENCES auth_user(id) ON DELETE CASCADE,
        CONSTRAINT fk_cart_book FOREIGN KEY (book_id) REFERENCES books_book(id) ON DELETE CASCADE,
        CONSTRAINT unique_cart_user_book UNIQUE (user_id, book_id)
    );
    
    CREATE INDEX idx_cart_user ON books_cart(user_id);
    CREATE INDEX idx_cart_book ON books_cart(book_id);
END
GO

-- =============================================
-- Django Auth Group Table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'auth_group')
BEGIN
    CREATE TABLE auth_group (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(150) NOT NULL UNIQUE
    );
END
GO

-- =============================================
-- Django Auth Permission Table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'auth_permission')
BEGIN
    CREATE TABLE auth_permission (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(255) NOT NULL,
        content_type_id INT NOT NULL,
        codename NVARCHAR(100) NOT NULL,
        CONSTRAINT unique_permission_content_type_codename UNIQUE (content_type_id, codename),
        CONSTRAINT fk_permission_content_type FOREIGN KEY (content_type_id) REFERENCES django_content_type(id) ON DELETE CASCADE
    );
    
    CREATE INDEX idx_permission_content_type ON auth_permission(content_type_id);
END
GO

-- =============================================
-- Django Auth User Groups Table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'auth_user_groups')
BEGIN
    CREATE TABLE auth_user_groups (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        group_id INT NOT NULL,
        CONSTRAINT unique_user_group UNIQUE (user_id, group_id),
        CONSTRAINT fk_user_group_user FOREIGN KEY (user_id) REFERENCES auth_user(id) ON DELETE CASCADE,
        CONSTRAINT fk_user_group_group FOREIGN KEY (group_id) REFERENCES auth_group(id) ON DELETE CASCADE
    );
    
    CREATE INDEX idx_user_groups_user ON auth_user_groups(user_id);
    CREATE INDEX idx_user_groups_group ON auth_user_groups(group_id);
END
GO

-- =============================================
-- Django Auth Group Permissions Table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'auth_group_permissions')
BEGIN
    CREATE TABLE auth_group_permissions (
        id INT IDENTITY(1,1) PRIMARY KEY,
        group_id INT NOT NULL,
        permission_id INT NOT NULL,
        CONSTRAINT unique_group_permission UNIQUE (group_id, permission_id),
        CONSTRAINT fk_group_permission_group FOREIGN KEY (group_id) REFERENCES auth_group(id) ON DELETE CASCADE,
        CONSTRAINT fk_group_permission_permission FOREIGN KEY (permission_id) REFERENCES auth_permission(id) ON DELETE CASCADE
    );
    
    CREATE INDEX idx_group_permissions_group ON auth_group_permissions(group_id);
    CREATE INDEX idx_group_permissions_permission ON auth_group_permissions(permission_id);
END
GO

-- =============================================
-- Django Auth User Permissions Table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'auth_user_user_permissions')
BEGIN
    CREATE TABLE auth_user_user_permissions (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        permission_id INT NOT NULL,
        CONSTRAINT unique_user_permission UNIQUE (user_id, permission_id),
        CONSTRAINT fk_user_permission_user FOREIGN KEY (user_id) REFERENCES auth_user(id) ON DELETE CASCADE,
        CONSTRAINT fk_user_permission_permission FOREIGN KEY (permission_id) REFERENCES auth_permission(id) ON DELETE CASCADE
    );
    
    CREATE INDEX idx_user_permissions_user ON auth_user_user_permissions(user_id);
    CREATE INDEX idx_user_permissions_permission ON auth_user_user_permissions(permission_id);
END
GO

-- =============================================
-- Django Content Type Table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'django_content_type')
BEGIN
    CREATE TABLE django_content_type (
        id INT IDENTITY(1,1) PRIMARY KEY,
        app_label NVARCHAR(100) NOT NULL,
        model NVARCHAR(100) NOT NULL,
        CONSTRAINT unique_app_label_model UNIQUE (app_label, model)
    );
    
    CREATE INDEX idx_content_type_app_label ON django_content_type(app_label);
END
GO

-- =============================================
-- Django Admin Log Table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'django_admin_log')
BEGIN
    CREATE TABLE django_admin_log (
        id INT IDENTITY(1,1) PRIMARY KEY,
        action_time DATETIME NOT NULL,
        object_id NVARCHAR(2000) NULL,
        object_repr NVARCHAR(200) NOT NULL,
        action_flag SMALLINT NOT NULL,
        change_message NVARCHAR(MAX) NOT NULL,
        content_type_id INT NULL,
        user_id INT NOT NULL,
        CONSTRAINT fk_admin_log_user FOREIGN KEY (user_id) REFERENCES auth_user(id) ON DELETE NO ACTION,
        CONSTRAINT fk_admin_log_content_type FOREIGN KEY (content_type_id) REFERENCES django_content_type(id) ON DELETE SET NULL
    );
    
    CREATE INDEX idx_admin_log_user ON django_admin_log(user_id);
    CREATE INDEX idx_admin_log_content_type ON django_admin_log(content_type_id);
    CREATE INDEX idx_admin_log_object_id ON django_admin_log(object_id);
END
GO

-- =============================================
-- Insert Sample Data (Optional)
-- =============================================

-- Insert Sample Users
IF NOT EXISTS (SELECT * FROM auth_user WHERE username = 'admin')
BEGIN
    INSERT INTO auth_user (password, username, first_name, last_name, email, is_staff, is_superuser, is_active)
    VALUES (
        'pbkdf2_sha256$1200000$xnRW9MFxj1fRaG3rQH9cXc$9KoVA+GUbU2KKmrJC6UazCvSQN/1tUzN+ITVpbwRBHY=', -- Replace with actual hashed password
        'admin',
        'Admin',
        'User',
        'admin@novaedge.com',
        1,
        1,
        1
    );
END
GO

-- Insert Sample Books
IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780743273565')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'The Great Gatsby',
        'F. Scott Fitzgerald',
        '9780743273565',
        '1925-04-10',
        'Fiction',
        'A story of the Jazz Age',
        5,
        5
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780451524935')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        '1984',
        'George Orwell',
        '9780451524935',
        '1949-06-08',
        'Dystopian Fiction',
        'A dystopian social science fiction novel',
        3,
        3
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780061120084')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'To Kill a Mockingbird',
        'Harper Lee',
        '9780061120084',
        '1960-07-11',
        'Fiction',
        'A novel about racial injustice',
        4,
        4
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780345391803')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'The Hitchhiker''s Guide to the Galaxy',
        'Douglas Adams',
        '9780345391803',
        '1979-10-12',
        'Science Fiction',
        'A comedic science fiction series',
        3,
        3
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780140283297')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'The Lord of the Rings',
        'J.R.R. Tolkien',
        '9780140283297',
        '1954-07-29',
        'Fantasy',
        'An epic high fantasy novel',
        4,
        4
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780743477109')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'Romeo and Juliet',
        'William Shakespeare',
        '9780743477109',
        '1597-01-01',
        'Drama',
        'A tragedy about two young star-crossed lovers',
        5,
        5
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780307474278')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'The Catcher in the Rye',
        'J.D. Salinger',
        '9780307474278',
        '1951-07-16',
        'Fiction',
        'A story of teenage alienation',
        3,
        3
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780451524936')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'Brave New World',
        'Aldous Huxley',
        '9780451524936',
        '1932-01-01',
        'Dystopian Fiction',
        'A futuristic society with advanced technology',
        2,
        2
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780141439518')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'Pride and Prejudice',
        'Jane Austen',
        '9780141439518',
        '1813-01-28',
        'Romance',
        'A romantic novel of manners',
        4,
        4
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780316769488')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'The Alchemist',
        'Paulo Coelho',
        '9780316769488',
        '1988-01-01',
        'Fiction',
        'A philosophical novel about following dreams',
        5,
        5
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780060883287')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'The Da Vinci Code',
        'Dan Brown',
        '9780060883287',
        '2003-03-18',
        'Mystery',
        'A mystery thriller novel',
        3,
        3
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780743273566')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'The Hobbit',
        'J.R.R. Tolkien',
        '9780743273566',
        '1937-09-21',
        'Fantasy',
        'A fantasy novel about a hobbit''s adventure',
        4,
        4
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780307277770')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'The Kite Runner',
        'Khaled Hosseini',
        '9780307277770',
        '2003-05-29',
        'Fiction',
        'A story of friendship and redemption',
        3,
        3
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780385490818')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'The Hunger Games',
        'Suzanne Collins',
        '9780385490818',
        '2008-09-14',
        'Science Fiction',
        'A dystopian novel about a survival contest',
        5,
        5
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780747532699')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'Harry Potter and the Philosopher''s Stone',
        'J.K. Rowling',
        '9780747532699',
        '1997-06-26',
        'Fantasy',
        'A young wizard''s first year at Hogwarts',
        6,
        6
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780307387899')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'Life of Pi',
        'Yann Martel',
        '9780307387899',
        '2001-09-11',
        'Adventure',
        'A survival story about a boy and a tiger',
        3,
        3
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780307477279')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'The Road',
        'Cormac McCarthy',
        '9780307477279',
        '2006-09-26',
        'Post-Apocalyptic',
        'A father and son journey through a post-apocalyptic world',
        2,
        2
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780140186824')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'The Odyssey',
        'Homer',
        '9780140186824',
        '-800-01-01',
        'Epic Poetry',
        'An ancient Greek epic poem',
        3,
        3
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780140449136')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'Crime and Punishment',
        'Fyodor Dostoevsky',
        '9780140449136',
        '1866-01-01',
        'Psychological Fiction',
        'A psychological novel about morality',
        2,
        2
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780140283334')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'The Fellowship of the Ring',
        'J.R.R. Tolkien',
        '9780140283334',
        '1954-07-29',
        'Fantasy',
        'The first volume of The Lord of the Rings',
        4,
        4
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780140157376')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'Slaughterhouse-Five',
        'Kurt Vonnegut',
        '9780140157376',
        '1969-01-01',
        'Science Fiction',
        'A satirical novel about war and time',
        3,
        3
    );
END
GO

IF NOT EXISTS (SELECT * FROM books_book WHERE isbn = '9780140268867')
BEGIN
    INSERT INTO books_book (title, author, isbn, publication_date, genre, description, total_copies, available_copies)
    VALUES (
        'The Two Towers',
        'J.R.R. Tolkien',
        '9780140268867',
        '1954-11-11',
        'Fantasy',
        'The second volume of The Lord of the Rings',
        4,
        4
    );
END
GO

PRINT 'Database schema created successfully!';
PRINT 'Sample data inserted!';
GO
