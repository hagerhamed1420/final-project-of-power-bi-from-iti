
--------------------script

-----------------------------Region

create table Continents 
(
    ContinentID int primary key ,
    Continent varchar(50)
)

create table Countries 
(
    CountryID int primary key,
    Country varchar(50),
	TaxRate decimal (5,4),
    ContinentID int,
    foreign key (ContinentID) references Continents(ContinentID)
)

create table States 
(
    StateID int primary key,
    State varchar(100),
    CountryID int,
    foreign key (CountryID) references Countries(CountryID)
)

create table Cities 
(
    CityID int primary key,
    City varchar(100),
    StateID int,
    foreign key (StateID) references States(StateID)
)

----------------------- Customers

create table Customers 
(
    CustomerID int primary key,
    Customer varchar(100),
    Gender varchar(10),
    Birthday date,
    CityID int,
    foreign key (CityID) references Cities(CityID)
)

 ------Products

create table Categories 
(
    CategoryID int primary key,
    Category varchar(100)
)

create table Subcategories 
(
    SubcategoryID int primary key,
    Subcategory varchar(100),
    CategoryID int,
    foreign key (CategoryID) references Categories(CategoryID)
)

create table Brands 
(
    BrandID int primary key,
    Brand varchar(100)
)

create table Colors 
(
    ColorID int primary key,
    Color varchar(50)
)

create table Products 
(
    ProductID int primary key,
    Product nvarchar(MAX),
	Unit_Cost_USD decimal (10,2),
    Unit_Price_USD decimal (10,2),
	BrandID int,
    ColorID int,
    SubcategoryID int,
    foreign key (SubcategoryID) references Subcategories(SubcategoryID),
    foreign key (BrandID) references Brands(BrandID),
    foreign key (ColorID) references Colors(ColorID)
)

EXEC sp_help 'Products'

--------------Stores


create table Stores 
(
    StoreID int primary key,
    Square_Meters decimal (10,2),
    Open_Date date ,
	StateID int,
    foreign key (StateID) references States(StateID)
)

------Currencies

create table Currencies 
(
    CurrencyCode varchar(10) primary key
)


create table ExchangeRates 
(
    RateDate date,
    CurrencyCode varchar(10),
    ExchangeRate decimal (10,4),
    primary key (RateDate, CurrencyCode),
    foreign key (CurrencyCode) references Currencies(CurrencyCode)
)

-------- Orders & OrderLines


create table Orders 
(
    OrderNumber int primary key,
    OrderDate date,
    DeliveryDate date,
    CustomerID int,
    StoreID int,
    CurrencyCode varchar(10),
	OfflineOrderFlag as (case when StoreID = 0 then 0 else 1 end) persisted,
    foreign key (CustomerID) references Customers(CustomerID),
    foreign key (StoreID) references Stores(StoreID),
    foreign key (CurrencyCode) references Currencies(CurrencyCode)
)

create table OrderLines 
(
    OrderNumber int,
    LineItem int,
    ProductID int,
    Quantity int ,
   
    primary key (OrderNumber, LineItem),
    foreign key (OrderNumber) references Orders(OrderNumber),
    foreign key (ProductID) references Products(ProductID)
)


----------------------------------------------

alter table OrderLines add 
    LineTotal decimal(18,2),   -- Quantity * Unit_Price_USD
    TaxAmt decimal(18,4),      -- LineTotal * TaxRate
    FreightAmt decimal(18,2)   -- If order is offline = 80 / # LineItems

-------------------------------------------------------------------------------

----------------------------- LineTotal

update ol
set ol.LineTotal = ol.Quantity * p.Unit_Price_USD
from OrderLines ol Join Products p 
on ol.ProductID = p.ProductID

----------------------------- TaxAmt

update ol
set ol.TaxAmt = ol.LineTotal * c.TaxRate
from OrderLines ol Join Orders o on ol.OrderNumber = o.OrderNumber
Join Customers cu on o.CustomerID = cu.CustomerID
Join Cities ci on cu.CityID = ci.CityID
Join States s on ci.StateID = s.StateID
Join Countries c on s.CountryID = c.CountryID

----------------------------- FreightAmt

update ol
set ol.FreightAmt = 
    case 
        when o.StoreID = 0 then 80.0 / LineItemCount.TotalLines
        else 0
    end
from OrderLines ol Join Orders o on ol.OrderNumber = o.OrderNumber
Join (
    select OrderNumber, count(*) as TotalLines
    from OrderLines
    Group by OrderNumber
) as LineItemCount on ol.OrderNumber = LineItemCount.OrderNumber;

--------------------------------display
select *
from Continents

select *
from Countries

select *
from States

select *
from Cities

select *
from Customers

select *
from Brands

select *
from Colors

select *
from Categories

select *
from Subcategories

select *
from Products

select *
from Stores

select *
from Currencies

select *
from ExchangeRates

select *
from Orders

select *
from OrderLines









