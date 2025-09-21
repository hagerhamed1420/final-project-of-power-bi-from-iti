--------------------------------- TRIGGERS
--------------------------- trigger OrderLines_updated_column

create or alter trigger OrderLines_updated_column
on OrderLines
After insert
as
begin
    
    update ol
    set ol.LineTotal = i.Quantity * p.Unit_Price_USD
    from OrderLines ol
    Join inserted i on ol.OrderNumber = i.OrderNumber and ol.LineItem = i.LineItem
    Join Products p on i.ProductID = p.ProductID

    update ol
    set ol.TaxAmt = ol.LineTotal * c.TaxRate
    from OrderLines ol
    Join inserted i on ol.OrderNumber = i.OrderNumber and ol.LineItem = i.LineItem
    Join Orders o on ol.OrderNumber = o.OrderNumber
    Join Customers cu on o.CustomerID = cu.CustomerID
    Join Cities ci on cu.CityID = ci.CityID
    Join States s on ci.StateID = s.StateID
    Join Countries c on s.CountryID = c.CountryID

    update ol
    set ol.FreightAmt = 
        case 
            when o.StoreID = 0 then 80.0 / LineItemCount.TotalLines
            else 0
        end
    from OrderLines ol
    Join inserted i on ol.OrderNumber = i.OrderNumber and ol.LineItem = i.LineItem
    Join Orders o on ol.OrderNumber = o.OrderNumber
    Join (
        select OrderNumber, count(*) as TotalLines
        from OrderLines
        group by OrderNumber
    ) as LineItemCount on ol.OrderNumber = LineItemCount.OrderNumber
end
----- if Unit_Price_USD or Unit_Cost_USD changed → LineTotal و TaxAmt changed for OrderLines

create trigger trg_Products_Update
on Products
after update
as
begin
    set nocount on;

    if update(Unit_Price_USD) or update(Unit_Cost_USD)
    begin
        update ol
        set 
            ol.LineTotal = ol.Quantity * p.Unit_Price_USD,
            ol.TaxAmt = (ol.Quantity * p.Unit_Price_USD) * co.TaxRate
        from OrderLines ol
        join Products p on ol.ProductID = p.ProductID
        join Orders o on ol.OrderNumber = o.OrderNumber
        join Customers cu on o.CustomerID = cu.CustomerID
        join Cities ci on cu.CityID = ci.CityID
        join States s on ci.StateID = s.StateID
        join Countries co on s.CountryID = co.CountryID
        join inserted i on p.ProductID = i.ProductID
    end
end

update Products         ----example
set Unit_Price_USD = 1200
where ProductID = 101

--------------------- if CityID changed →  (TaxAmt) changed.

create trigger trg_Customers_Update
on Customers
after update
as
begin
    set nocount on;

    if update(CityID)
    begin
        update ol
        set 
            ol.TaxAmt = ol.LineTotal * co.TaxRate
        from OrderLines ol
        join Orders o on ol.OrderNumber = o.OrderNumber
        join Customers cu on o.CustomerID = cu.CustomerID
        join Cities ci on cu.CityID = ci.CityID
        join States s on ci.StateID = s.StateID
        join Countries co on s.CountryID = co.CountryID
        join inserted i on cu.CustomerID = i.CustomerID
    end
end

---------------------- If StoreID changed → FreightAmt changed

create trigger trg_Orders_Update
on Orders
after update
as
begin
    set nocount on;

    if update(StoreID)
    begin
        update ol
        set ol.FreightAmt = 
            case 
                when o.StoreID = 0 
                    then 80.0 / cnt.TotalLines
                else 0
            end
        from OrderLines ol
        join Orders o on ol.OrderNumber = o.OrderNumber
        join (
            select OrderNumber, count(*) as TotalLines
            from OrderLines
            group by OrderNumber
        ) cnt on ol.OrderNumber = cnt.OrderNumber
        join inserted i on o.OrderNumber = i.OrderNumber
    end
end

------------------------------ Stored Procedure

---------------------------- insert new customer

create procedure sp_AddCustomer
    @CustomerName varchar(100),
    @Gender varchar(10),
    @Birthday date,
    @CityID int
as
begin
    insert into Customers (CustomerID, Customer, Gender, Birthday, CityID)
    values (
        (select isnull(max(CustomerID),0)+1 from Customers),
        @CustomerName, @Gender, @Birthday, @CityID
    )
end

--example 
exec sp_AddCustomer 
    @CustomerName = 'Sara Ali', 
    @Gender = 'Female', 
    @Birthday = '1995-05-10', 
    @CityID = 3

exec sp_AddCustomer 'Sara Ali', 'Female', '1995-05-10', 3 -- without @

--------------------------- update customer data

create procedure sp_UpdateCustomer
    @CustomerID int,
    @CustomerName varchar(100),
    @Gender varchar(10),
    @Birthday date,
    @CityID int
as
begin
    update Customers
    set Customer = @CustomerName,
        Gender = @Gender,
        Birthday = @Birthday,
        CityID = @CityID
    where CustomerID = @CustomerID
end

exec sp_UpdateCustomer 
    @CustomerID = 1,
    @CustomerName = 'Ali Mohamed',
    @Gender = 'Male',
    @Birthday = '1999-12-31',
    @CityID = 3; 

--------------------------- insert new product
create procedure sp_AddProduct
    @ProductName nvarchar(max),
    @UnitCost decimal(10,2),
    @UnitPrice decimal(10,2),
    @BrandID int,
    @ColorID int,
    @SubcategoryID int
as
begin
    insert into Products (ProductID, Product, Unit_Cost_USD, Unit_Price_USD, BrandID, ColorID, SubcategoryID)
    values (
        (select isnull(max(ProductID),0)+1 from Products),
        @ProductName, @UnitCost, @UnitPrice, @BrandID, @ColorID, @SubcategoryID
    )
end

----------------------------- update product data

create procedure sp_UpdateProduct
    @ProductID int,
    @ProductName nvarchar(max),
    @UnitCost decimal(10,2),
    @UnitPrice decimal(10,2),
    @BrandID int,
    @ColorID int,
    @SubcategoryID int
as
begin
    update Products
    set Product = @ProductName,
        Unit_Cost_USD = @UnitCost,
        Unit_Price_USD = @UnitPrice,
        BrandID = @BrandID,
        ColorID = @ColorID,
        SubcategoryID = @SubcategoryID
    where ProductID = @ProductID
end

------------------------------- insert new Order

create procedure sp_AddOrder
    @OrderDate date,
    @DeliveryDate date,
    @CustomerID int,
    @StoreID int,
    @CurrencyCode varchar(10)
as
begin
    insert into Orders (OrderNumber, OrderDate, DeliveryDate, CustomerID, StoreID, CurrencyCode)
    values (
        (select isnull(max(OrderNumber),0)+1 from Orders),
        @OrderDate, @DeliveryDate, @CustomerID, @StoreID, @CurrencyCode
    )
end

--------------------------------- insert new Orderline

create procedure sp_AddOrderLine
    @OrderNumber int,
    @ProductID int,
    @Quantity int
as
begin
    declare @LineItem int

    select @LineItem = isnull(max(LineItem),0)+1 
    from OrderLines 
    where OrderNumber = @OrderNumber;

    insert into OrderLines (OrderNumber, LineItem, ProductID, Quantity)
    values (@OrderNumber, @LineItem, @ProductID, @Quantity)
end

----------------------------------VIEWS
-----------------------all Customers Data View

create view vw_Customers
as
select 
    cu.CustomerID,
    cu.Customer,
    cu.Gender,
    cu.Birthday,
    ci.City,
    s.State,
    co.Country,
    co.TaxRate,
    con.Continent
from Customers cu
join Cities ci on cu.CityID = ci.CityID
join States s on ci.StateID = s.StateID
join Countries co on s.CountryID = co.CountryID
join Continents con on co.ContinentID = con.ContinentID

select * from vw_Customers

--------------------------------- all Products Data View

create view vw_Products
as
select 
    p.ProductID,
    p.Product,
    p.Unit_Cost_USD,
    p.Unit_Price_USD,
    b.Brand,
    c.Color,
    sc.Subcategory,
    cat.Category
from Products p
join Brands b on p.BrandID = b.BrandID
join Colors c on p.ColorID = c.ColorID
join Subcategories sc on p.SubcategoryID = sc.SubcategoryID
join Categories cat on sc.CategoryID = cat.CategoryID

select * from vw_Products

-------------------------------- all Orders Data View

create view vw_Orders
as
select 
    o.OrderNumber,
    o.OrderDate,
    o.DeliveryDate,
    cu.Customer,
    st.StoreID,
    st.Square_Meters,
    st.Open_Date,
    curr.CurrencyCode,
    o.OfflineOrderFlag
from Orders o
join Customers cu on o.CustomerID = cu.CustomerID
left join Stores st on o.StoreID = st.StoreID
join Currencies curr on o.CurrencyCode = curr.CurrencyCode

select * from vw_Orders

------------------------------ all OrderLines Data View

create view vw_OrderLines
as
select 
    ol.OrderNumber,
    ol.LineItem,
    p.Product,
    ol.Quantity,
    ol.LineTotal,
    ol.TaxAmt,
    ol.FreightAmt
from OrderLines ol
join Products p on ol.ProductID = p.ProductID

select * from vw_OrderLines

----------------------------- all Data View

create view vw_All
as
select 
    o.OrderNumber,
    o.OrderDate,
    o.DeliveryDate,
    cu.Customer,
    cu.Gender,
    ci.City,
    s.State,
    co.Country,
    con.Continent,
    p.Product,
    b.Brand,
    c.Color,
    cat.Category,
    sc.Subcategory,
    ol.Quantity,
    ol.LineTotal,
    ol.TaxAmt,
    ol.FreightAmt,
    curr.CurrencyCode
from OrderLines ol
join Orders o on ol.OrderNumber = o.OrderNumber
join Customers cu on o.CustomerID = cu.CustomerID
join Cities ci on cu.CityID = ci.CityID
join States s on ci.StateID = s.StateID
join Countries co on s.CountryID = co.CountryID
join Continents con on co.ContinentID = con.ContinentID
join Products p on ol.ProductID = p.ProductID
join Brands b on p.BrandID = b.BrandID
join Colors c on p.ColorID = c.ColorID
join Subcategories sc on p.SubcategoryID = sc.SubcategoryID
join Categories cat on sc.CategoryID = cat.CategoryID
join Currencies curr on o.CurrencyCode = curr.CurrencyCode

select * from vw_All

---------------------------- sales for product

create or alter view vw_Product_sales
as
    select Category, Product, sum (LineTotal) as TotalSales
    from Products p
    JOIN OrderLines ol on ol.ProductID = p.ProductID
	JOIN Subcategories s  on p.SubcategoryID = s.SubcategoryID
	JOIN categories c  on s.CategoryID = c.CategoryID
    group by Category, Product
	
drop view dbo.vw_Product_sales




