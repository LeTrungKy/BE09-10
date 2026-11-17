
USE master;
GO

IF DB_ID(N'MyStore') IS NOT NULL
BEGIN
    ALTER DATABASE [MyStore] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [MyStore];
END;
GO

CREATE DATABASE [MyStore];
GO
USE [MyStore];
GO

/* ------------------------------ TABLES ------------------------------ */

CREATE TABLE dbo.[User]
(
    Username   nvarchar(255) NOT NULL CONSTRAINT PK_User PRIMARY KEY,
    [Password] nvarchar(50)  NOT NULL,
    UserRole   nchar(1)      NOT NULL CONSTRAINT CK_User_UserRole CHECK (UserRole IN (N'A', N'C'))  -- A = Admin, C = Customer
);
GO

CREATE TABLE dbo.Customer
(
    CustomerID      int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Customer PRIMARY KEY,
    CustomerName    nvarchar(255) NOT NULL,
    CustomerPhone   nvarchar(15)  NOT NULL,
    CustomerEmail   nvarchar(255) NULL,
    CustomerAddress nvarchar(500) NULL,
    Username        nvarchar(255) NOT NULL,
    CONSTRAINT UQ_Customer_Username UNIQUE (Username),
    CONSTRAINT FK_Customer_User FOREIGN KEY (Username) REFERENCES dbo.[User](Username)
);
GO

CREATE TABLE dbo.Category
(
    CategoryID   int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Category PRIMARY KEY,
    CategoryName nvarchar(255) NOT NULL,
    CONSTRAINT UQ_Category_CategoryName UNIQUE (CategoryName)
);
GO

CREATE TABLE dbo.Product
(
    ProductID          int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Product PRIMARY KEY,
    CategoryID         int            NOT NULL,
    ProductName        nvarchar(255)  NOT NULL,
    ProductDescription nvarchar(max)  NOT NULL,
    ProductPrice       decimal(18,2)  NOT NULL CONSTRAINT CK_Product_Price CHECK (ProductPrice >= 0),
    ProductImage       nvarchar(500)  NULL,
    ProductStock       int            NOT NULL CONSTRAINT DF_Product_Stock DEFAULT (0),   -- so luong ton kho
    CONSTRAINT CK_Product_Stock CHECK (ProductStock >= 0),
    CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryID) REFERENCES dbo.Category(CategoryID)
);
GO

CREATE TABLE dbo.[Order]
(
    OrderID         int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Order PRIMARY KEY,
    CustomerID      int            NOT NULL,
    OrderDate       datetime       NOT NULL CONSTRAINT DF_Order_OrderDate DEFAULT (GETDATE()),
    TotalAmount     decimal(18,2)  NOT NULL CONSTRAINT DF_Order_TotalAmount DEFAULT (0),
    PaymentStatus   nvarchar(100)  NULL,
    OrderStatus     nvarchar(50)   NOT NULL CONSTRAINT DF_Order_OrderStatus DEFAULT (N'Đang xử lý'),
    ShippingAddress nvarchar(500)  NOT NULL,
    DeliveryMethod  nvarchar(100)  NULL,
    PaymentMethod   nvarchar(100)  NULL,
    CONSTRAINT CK_Order_OrderStatus CHECK (OrderStatus IN
        (N'Chờ thanh toán', N'Đang xử lý', N'Đang vận chuyển', N'Đã giao', N'Đã hủy')),
    CONSTRAINT FK_Order_Customer FOREIGN KEY (CustomerID) REFERENCES dbo.Customer(CustomerID)
);
GO

CREATE TABLE dbo.OrderDetail
(
    ID         int IDENTITY(1,1) NOT NULL CONSTRAINT PK_OrderDetail PRIMARY KEY,
    ProductID  int           NOT NULL,
    OrderID    int           NOT NULL,
    Quantity   int           NOT NULL CONSTRAINT CK_OrderDetail_Quantity CHECK (Quantity > 0),
    UnitPrice  decimal(18,2) NOT NULL CONSTRAINT CK_OrderDetail_UnitPrice CHECK (UnitPrice >= 0),
    TotalPrice AS (Quantity * UnitPrice) PERSISTED,
    CONSTRAINT FK_OrderDetail_Product FOREIGN KEY (ProductID) REFERENCES dbo.Product(ProductID),
    CONSTRAINT FK_OrderDetail_Order   FOREIGN KEY (OrderID)   REFERENCES dbo.[Order](OrderID) ON DELETE CASCADE
);
GO

/* --------------------------- FK INDEXES ----------------------------- */
CREATE INDEX IX_Product_CategoryID     ON dbo.Product(CategoryID);
CREATE INDEX IX_Order_CustomerID       ON dbo.[Order](CustomerID);
CREATE INDEX IX_OrderDetail_OrderID    ON dbo.OrderDetail(OrderID);
CREATE INDEX IX_OrderDetail_ProductID  ON dbo.OrderDetail(ProductID);
GO

/* ---------------------------- SAMPLE DATA --------------------------- */

-- Passwords are plain text because the course project stores them that way.
INSERT INTO dbo.[User] (Username, [Password], UserRole) VALUES
(N'admin',  N'123', N'A'),
(N'khach1', N'123', N'C'),
(N'khach2', N'123', N'C');
GO

INSERT INTO dbo.Customer (CustomerName, CustomerPhone, CustomerEmail, CustomerAddress, Username) VALUES
(N'Nguyễn Văn A', N'0901234567', N'khach1@example.com', N'12 Lê Lợi, Quận 1, TP.HCM',       N'khach1'),
(N'Trần Thị B',   N'0912345678', N'khach2@example.com', N'45 Nguyễn Huệ, Quận 1, TP.HCM',    N'khach2');
GO

INSERT INTO dbo.Category (CategoryName) VALUES
(N'Văn học'), (N'Kinh tế'), (N'Kỹ năng sống');
GO

INSERT INTO dbo.Product (CategoryID, ProductName, ProductDescription, ProductPrice, ProductImage, ProductStock) VALUES
(1, N'Đồi Gió Hú',                                    N'Tiểu thuyết kinh điển của Emily Brontë.',                     102600, N'~/Content/images/default_img.png', 50),
(1, N'Cây Cam Ngọt Của Tôi',                          N'Câu chuyện cảm động về tuổi thơ.',                             70200, N'~/Content/images/default_img.png', 40),
(1, N'Cuộc Phiêu Lưu Của Thuyền Trưởng Corcoran',     N'Truyện phiêu lưu hấp dẫn.',                                    29600, N'~/Content/images/default_img.png', 30),
(1, N'Nhà Giả Kim',                                   N'Hành trình đi tìm vận mệnh của chàng chăn cừu.',               65000, N'~/Content/images/default_img.png', 60),
(2, N'Kinh Doanh Thời Trang',                         N'8 bước xây dựng, vận hành và phát triển shop quần áo.',       142000, N'~/Content/images/default_img.png', 25),
(2, N'Khởi Nghiệp Bán Lẻ',                            N'Bí quyết thành công và giàu có bằng những cửa hàng đông khách.',120000, N'~/Content/images/default_img.png', 25),
(2, N'Đọc Vị Bất Kỳ Ai',                              N'Để không bị lợi dụng.',                                        66800, N'~/Content/images/default_img.png', 45),
(2, N'Quản Trị Doanh Nghiệp Nhỏ',                     N'Những nguyên tắc căn bản để vận hành doanh nghiệp.',           98000, N'~/Content/images/default_img.png', 35),
(3, N'Nghệ Thuật Từ Chối',                            N'Cách nói không mà vẫn có được đồng thuận.',                    55900, N'~/Content/images/default_img.png', 70),
(3, N'Nói Chuyện Là Bản Năng, Giữ Miệng Là Tu Dưỡng', N'Im lặng là trí tuệ.',                                         109620, N'~/Content/images/default_img.png', 20),
(3, N'Tư Duy Bằng Con Số',                            N'Cuộc sống rực rỡ qua lăng kính toán học.',                    119000, N'~/Content/images/default_img.png', 15),
(3, N'Đắc Nhân Tâm',                                  N'Nghệ thuật đối nhân xử thế.',                                  86000, N'~/Content/images/default_img.png', 80);
GO

-- One order per status so every tab of the "My orders" page has data.
INSERT INTO dbo.[Order] (CustomerID, OrderDate, TotalAmount, PaymentStatus, OrderStatus, ShippingAddress, DeliveryMethod, PaymentMethod) VALUES
(1, DATEADD(DAY, -30, GETDATE()), 0, N'Đã thanh toán',   N'Đã giao',          N'12 Lê Lợi, Quận 1, TP.HCM',    N'Giao hàng tiêu chuẩn', N'Paypal'),
(1, DATEADD(DAY, -5,  GETDATE()), 0, N'Chưa thanh toán', N'Đang vận chuyển',  N'12 Lê Lợi, Quận 1, TP.HCM',    N'Giao hàng nhanh',      N'Tiền mặt'),
(1, DATEADD(DAY, -2,  GETDATE()), 0, N'Đã thanh toán',   N'Đang xử lý',       N'12 Lê Lợi, Quận 1, TP.HCM',    N'Giao hàng tiêu chuẩn', N'Paypal'),
(1, DATEADD(DAY, -1,  GETDATE()), 0, N'Chờ thanh toán',  N'Chờ thanh toán',   N'12 Lê Lợi, Quận 1, TP.HCM',    N'Giao hàng tiêu chuẩn', N'Mua trước trả sau'),
(1, DATEADD(DAY, -10, GETDATE()), 0, N'Chưa thanh toán', N'Đã hủy',           N'12 Lê Lợi, Quận 1, TP.HCM',    N'Giao hàng tiêu chuẩn', N'Tiền mặt'),
(2, DATEADD(DAY, -7,  GETDATE()), 0, N'Đã thanh toán',   N'Đã giao',          N'45 Nguyễn Huệ, Quận 1, TP.HCM',N'Giao hàng nhanh',      N'Paypal');
GO

INSERT INTO dbo.OrderDetail (ProductID, OrderID, Quantity, UnitPrice) VALUES
(1, 1, 2, 102600),
(5, 1, 1, 142000),
(2, 2, 1,  70200),
(9, 2, 1,  55900),
(6, 3, 2, 120000),
(4, 4, 1,  65000),
(12,4, 1,  86000),
(7, 5, 1,  66800),
(1, 6, 1, 102600),
(11,6, 1, 119000);
GO

UPDATE o
SET    o.TotalAmount = x.Total
FROM   dbo.[Order] AS o
JOIN  (SELECT OrderID, SUM(TotalPrice) AS Total FROM dbo.OrderDetail GROUP BY OrderID) AS x
       ON x.OrderID = o.OrderID;
GO

SELECT N'Database MyStore created successfully.' AS Result;
SELECT N'admin / 123 (Admin)   -   khach1 / 123, khach2 / 123 (Customer)' AS TestAccounts;
GO
