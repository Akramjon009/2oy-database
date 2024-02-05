create table product_manufacturers(
    manufacturer_id int,
    manufacturer_name varchar(255)
)

create table product_suppliers(
    supplier_id int,
    supplier_name varchar(255)
)

create table product_titles(
    product_title_id int,
    product_title varchar(255),
    product_category_id int
)
create table product_categories(
    category_id int,
    category_name varchar(255)
)
create table shop_products(
    product_id int,
    product_title_id int,
    product_manufacturer_id int,
    product_supplier_id int,
    unit_price money,
    comment text
)
create table customer_orders(
    customer_order_id int,
    operation_time timestamp,
    supermarket_location_id int,
    customer_id int
)

create table customer_order_details(
    customer_order_detail_id int,
    customer_order_id int,
    product_id int,
    price money,
    price_with_discount decimal,
    product_amount int
)



create table person_contacts(
    person_contact_id int,
    person_id int,
    contact_type_id int,
    contact_value varchar(255)
)

create table persons(
    person_id int,
    person_first_name varchar(255),
    person_last_name varchar(255),
    person_birth_date date
)
create table customers(
    customer_id int,
    card_number char(16),
    discount int
)
create table contact_types(
    contact_type_id int,
    contact_type_name varchar(255)
)

create table supermarket_locations(
    supermarket_location_id  int,
    supermarket_id int,
    location_id int
)

create table locations(
    location_id int,
    location_address varchar(255),
    location_city_id int
)

create table loction_city(
    city_id int,
    city varchar(255),
    country varchar(255)
)
create table supermarkets(
    supermarket_id int,
    supermarket_name varchar(255)
)



ALTER TABLE shop_products
ADD CONSTRAINT shop_products_PK
PRIMARY KEY(product_id);

ALTER TABLE product_manufacturers
ADD CONSTRAINT product_manufacturers_PK
PRIMARY KEY(manufacturer_id);


ALTER TABLE product_suppliers
ADD CONSTRAINT product_suppliers_PK
PRIMARY KEY(supplier_id);


ALTER TABLE product_titles
ADD CONSTRAINT product_titles_PK
PRIMARY KEY(product_title_id);


ALTER TABLE product_categories
ADD CONSTRAINT product_categories_PK
PRIMARY KEY(category_id);


ALTER TABLE customer_orders
ADD CONSTRAINT customer_orders_PK
PRIMARY KEY(customer_order_id);


ALTER TABLE persons
ADD CONSTRAINT persons_PK
PRIMARY KEY(persons_id);

ALTER TABLE contact_types
ADD CONSTRAINT contact_types_PK
PRIMARY KEY(contact_type_id);



ALTER TABLE supermarket_locations
ADD CONSTRAINT supermarket_locations_PK
PRIMARY KEY(supermarket_location_id);

ALTER TABLE locations
ADD CONSTRAINT locations_PK
PRIMARY KEY(location_id);




ALTER TABLE location_city
ADD CONSTRAINT location_city_PK
PRIMARY KEY(city_id);

ALTER TABLE supermarkets
ADD CONSTRAINT supermarkets_PK
PRIMARY KEY(supermarket_id);

ALTER TABLE customers
ADD CONSTRAINT customers_PK
PRIMARY KEY(customer_id);










ALTER TABLE shop_products
ADD CONSTRAINT shop_products_product_title FOREIGN KEY(product_title_id)
    REFERENCES product_title(product_title_id)

ALTER TABLE shop_products
ADD CONSTRAINT shop_products_product_suppliers FOREIGN KEY(product_supplier_id)
    REFERENCES product_suppliers(supplier_id)

ALTER TABLE shop_products
ADD CONSTRAINT shop_products_product_manufacturers FOREIGN KEY(product_manufacturer_id)
    REFERENCES product_manufacturers(manufacturer_id)    


ALTER TABLE product_titles
ADD CONSTRAINT product_titles_product_categories FOREIGN KEY(product_category_id)
    REFERENCES product_categories(category_id)


    ALTER TABLE customer_orders
ADD CONSTRAINT customer_orders_supermarket_locations FOREIGN KEY(supermarket_location_id)
    REFERENCES supermarket_locations(supermarket_location_id)

ALTER TABLE customer_orders
ADD CONSTRAINT customer_orders_customers FOREIGN KEY(customer_id)
    REFERENCES customers(customer_id)




ALTER TABLE customer_order_details
ADD CONSTRAINT customer_order_details_customer_orders FOREIGN KEY(customer_order_id)
    REFERENCES customer_orders(customer_order_id)

ALTER TABLE customer_order_details
ADD CONSTRAINT customer_order_details_shop_products FOREIGN KEY(product_id)
    REFERENCES shop_products(product_id)



ALTER TABLE customers
ADD CONSTRAINT customers_persons FOREIGN KEY(customer_id)
    REFERENCES persons(person_id)






    ALTER TABLE person_contacts
ADD CONSTRAINT person_contacts_persons FOREIGN KEY(person_id)
    REFERENCES persons(person_id)




    ALTER TABLE person_contacts
ADD CONSTRAINT person_contacts_persons FOREIGN KEY(contact_type_id)
    REFERENCES contact_types(contact_type_id)

    ALTER TABLE supermarket_locations
ADD CONSTRAINT supermarket_locations_supermarkets FOREIGN KEY(supermarket_id)
    REFERENCES supermarkets(supermarket_id)

    ALTER TABLE supermarket_locations
ADD CONSTRAINT supermarket_locations_locations FOREIGN KEY(location_id)
    REFERENCES locations(location_id)



13-test

UPDATE shop_products
SET unit_price = unit_price*1.1
where product_title_id  in (select product_title_id from product_titles inner join 
product_categories as pc on product_category_id=category_id  where pc.category_name = 'grocery') 
and product_manufacturer_id = (select manufacturer_id from product_manufacturers where manufacturer_name = 'Orbit')

14-test
select person_first_name || '   ' || person_last_name as fullname,avg((price_with_discount::decimal)*product_amount) as avg_sum from customer_order_details
inner join customer_orders using(customer_order_id)
inner join customers using(customer_id)
inner join persons on customers.customer_id=persons.person_id
group by person_id
having avg((price_with_discount::decimal)*product_amount)>200000
order by avg((price_with_discount::decimal)*product_amount) desc,fullname asc
  


15-test
select persons.person_first_name,persons.person_last_name,product_titles.product_title from customer_order_details
inner join customer_orders  using(customer_order_id) 
inner join product_titles on product_id=product_title_id
inner join customers on customer_orders.customer_order_id=customers.customer_id
inner join persons on customers.customer_id=persons.person_id
where  persons.person_birth_date between '01-01-2000' and '01-01-2005'


17-test
insert into product_categories(category_id,category_name) values(19,'unusual')

insert into product_titles(product_title_id,product_title,product_category_id) values(365,'zor narsa bu',19)

insert into product_suppliers(supplier_id,supplier_name) values(27,'Elyor')

insert into product_manufacturers(manufacturer_id,manufacturer_name) values(39,'Sirdaryolik')

insert into shop_products(product_id,product_title_id,product_manufacturer_id,product_supplier_id,unit_price,comment) 
values(99001,365,39,27,'$200000','menimcha qoshildi')

18-test
SELECT
  product_title_id,
  comment,
  CASE
    WHEN unit_price::decimal < 300 THEN 'very cheap'
    WHEN unit_price::decimal > 300 AND unit_price::decimal <= 750 THEN 'affordable'
    ELSE 'expensive'
  END AS type
FROM  shop_products;

20-test
CREATE or replace FUNCTION GETPRODUCTLISTBYOPERATIONDATE11(OPERATIONDATE date) RETURNS TABLE (P VARCHAR(255)) LANGUAGE PlpgSql AS $$
begin
return query select product_titles.product_title from customer_order_details
inner join customer_orders using(customer_order_id)
inner join product_titles on product_titles.product_title_id= customer_order_details.product_id
where DATE(operation_time)=operationDate;
end;$$;

select * from GETPRODUCTLISTBYOPERATIONDATE11('2011-03-24');

24 -test
create view product_details  as
select pt.product_title, pc.category_name, sup.supplier_name, pm.manufacturer_name  
from shop_products as sp inner join product_titles as pt
on sp.product_title_id=pt.product_title_id inner join product_categories as pc
on pt.product_category_id = pc.category_id inner join product_suppliers as sup on 
sp.product_supplier_id=sup.supplier_id inner join product_manufacturers as pm on
sp.product_manufacturer_id = pm.manufacturer_id


25-test 
create view Customer_details as
select person_first_name|| ' ' || person_last_name as Full_name,
person_birth_date, cu.card_number
from persons inner join customers as cu on person_id=customer_id

