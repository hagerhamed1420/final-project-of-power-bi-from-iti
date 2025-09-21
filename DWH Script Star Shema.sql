 
 ---------------------------------------- Dimension Tables
----------------------------Dim_Product

create table Dim_Product 
(
    ProductKey int identity (1,1) primary key,
	ProductID int ,
    Product nvarchar(MAX),
	Unit_Cost_USD decimal (10,2),
    Unit_Price_USD decimal (10,2),
    Brand varchar (100),
    Color varchar (50),
    Subcategory varchar (100),
    Category varchar (100)
)

------------------------------ Dim_Customer

create table Dim_Customer 
(
    CustomerKey int identity(1,1) primary key,
	CustomerID int,
    Customer varchar (100),
    Gender varchar(10),
    Birthday date,
	City varchar(100),
    State varchar(100),
    Country varchar(50),
	TaxRate decimal(5,4),
    Continent varchar(50)  
)

--------------------------------- Dim_Store

create table Dim_Store 
(
    StoreKey int identity(1,1) primary key,
	StoreID int ,
    Square_Meters decimal (10,2),
    Open_Date date,
	State varchar(100),
    Country varchar(50),
	TaxRate decimal(5,4),
    Continent varchar(50)   
)

------------------------------------ Dim_Date
create table Dim_Date 
(
    DateKey int primary key,       
    Date date,
    Year int,
    Quarter int,
    Month int,
    MonthName varchar(20),
    Day int,
    DayOfWeek int,                    
    DayName varchar(20),
    WeekOfYear int,
    IsWeekend bit
)
-----------------------

declare @StartDate date = '2015-01-01';
declare @EndDate date = '2022-01-01';

while @StartDate <= @EndDate
begin
    insert into Dim_Date 
	(
        DateKey,
        Date,
        Year,
        Quarter,
        Month,
        MonthName,
        Day,
        DayOfWeek,
        DayName,
        WeekOfYear,
        IsWeekend
    )
    values (
        convert(int, format(@StartDate, 'yyyyMMdd')),
        @StartDate,
        Year(@StartDate),
        Datepart(Quarter, @StartDate),
        MONTH(@StartDate),
        Datename(Month, @StartDate),
        Day(@StartDate),
        Datepart(weekday, @StartDate),
        Datename(weekday, @StartDate),
        Datepart(Week, @StartDate),
        Case 
            when Datepart(weekday, @StartDate) IN (1, 7) THEN 1 
            else 0 
        end
		
    )

    set @StartDate = Dateadd(Day, 1, @StartDate)
end

----------------------------------- DimCurrency

create table Dim_Currency 
(
    Currencykey int identity (1,1) primary key,
	RateDate date,
    CurrencyCode varchar(10),
    ExchangeRate decimal (10,4),
    
)

 ----------------------------- Fact Table( FactOrderLines )

create table Fact_OrderLines 
(
    Orderlineskey int identity (1,1) primary key,

	OrderNumber int,
    LineItem int,

	OrderDateKey int,
    DeliveryDateKey int ,
	OrderDate date,
    DeliveryDate date,

    ProductKey int,
    CustomerKey int,
    StoreKey int,
	Currencykey int,
    
    Quantity int,
    LineTotal decimal (18,2),
    TaxAmt decimal (10,2),
    FreightAmt decimal (10,2),
	OfflineOrderFlag bit,

	foreign key (ProductKey) references Dim_Product(ProductKey),
    foreign key (CustomerKey) references Dim_Customer(CustomerKey),
    foreign key (StoreKey) references Dim_Store(StoreKey),
    foreign key (CurrencyKey) references Dim_Currency(CurrencyKey),
	foreign key (OrderDateKey) references Dim_Date(DateKey),
	foreign key (DeliveryDateKey) references Dim_Date(DateKey)

)
 -------------------------------------------------------------------
update Fact_OrderLines
set DeliveryDate = null
where OfflineOrderFlag = 1

update Fact_OrderLines
set DeliveryDateKey = null
where OfflineOrderFlag = 1

select *
from Dim_Customer
where CustomerKey=4102 or CustomerKey=3463

update Dim_Customer
set Customer='Stephan Rothstein Jon'
where CustomerKey=3463

select count (distinct CustomerKey)
from Dim_Customer

select count (distinct Customer)
from Dim_Customer

select Customer, count(*) as Num_Repeated
from Dim_Customer
group by Customer
having count(*) > 1

select *
from Dim_Customer
where Customer in (select Customer
                   from Dim_Customer
                   group by Customer
                   having count(*) > 1 )

select * from Dim_Product
select * from Dim_Customer
select * from Dim_Store
select * from Dim_Currency  
select * from dbo.Dim_Date
select * from dbo.Fact_OrderLines