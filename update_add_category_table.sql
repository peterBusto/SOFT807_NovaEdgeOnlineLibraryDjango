-- =============================================
-- Add Category Table to NovaEdge Library Database
-- MS SQL Server Migration Script
-- =============================================

USE NovaEdgeLibraryDB;
GO

-- =============================================
-- Category Table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'books_category')
BEGIN
    CREATE TABLE books_category (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(255) NOT NULL UNIQUE,
        description NVARCHAR(MAX) NULL,
        created_at DATETIME NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME NOT NULL DEFAULT GETDATE()
    );
    
    CREATE INDEX idx_category_name ON books_category(name);
    
    PRINT 'Category table created successfully!';
END
ELSE
BEGIN
    PRINT 'Category table already exists!';
END
GO

-- =============================================
-- Insert Sample Categories (Optional)
-- =============================================
IF NOT EXISTS (SELECT * FROM books_category WHERE name = 'Fiction')
BEGIN
    INSERT INTO books_category (name, description)
    VALUES ('Fiction', 'Literary fiction novels and stories');
END
GO

IF NOT EXISTS (SELECT * FROM books_category WHERE name = 'Science Fiction')
BEGIN
    INSERT INTO books_category (name, description)
    VALUES ('Science Fiction', 'Science fiction and futuristic novels');
END
GO

IF NOT EXISTS (SELECT * FROM books_category WHERE name = 'Fantasy')
BEGIN
    INSERT INTO books_category (name, description)
    VALUES ('Fantasy', 'Fantasy novels and magical stories');
END
GO

IF NOT EXISTS (SELECT * FROM books_category WHERE name = 'Mystery')
BEGIN
    INSERT INTO books_category (name, description)
    VALUES ('Mystery', 'Mystery and detective novels');
END
GO

IF NOT EXISTS (SELECT * FROM books_category WHERE name = 'Romance')
BEGIN
    INSERT INTO books_category (name, description)
    VALUES ('Romance', 'Romantic novels and love stories');
END
GO

IF NOT EXISTS (SELECT * FROM books_category WHERE name = 'Non-Fiction')
BEGIN
    INSERT INTO books_category (name, description)
    VALUES ('Non-Fiction', 'Non-fiction and educational books');
END
GO

IF NOT EXISTS (SELECT * FROM books_category WHERE name = 'Biography')
BEGIN
    INSERT INTO books_category (name, description)
    VALUES ('Biography', 'Biographies and autobiographies');
END
GO

IF NOT EXISTS (SELECT * FROM books_category WHERE name = 'History')
BEGIN
    INSERT INTO books_category (name, description)
    VALUES ('History', 'Historical books and documents');
END
GO

PRINT 'Sample categories inserted successfully!';
GO

-- =============================================
-- Add category_id column to books_book table
-- =============================================
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('books_book') AND name = 'category_id'
)
BEGIN
    ALTER TABLE books_book 
    ADD category_id INT NULL;
    
    -- Add foreign key constraint
    ALTER TABLE books_book 
    ADD CONSTRAINT fk_book_category 
    FOREIGN KEY (category_id) REFERENCES books_category(id) 
    ON DELETE SET NULL;
    
    -- Create index for category_id
    CREATE INDEX idx_book_category ON books_book(category_id);
    
    PRINT 'category_id column added to books_book table successfully!';
END
ELSE
BEGIN
    PRINT 'category_id column already exists in books_book table!';
END
GO
