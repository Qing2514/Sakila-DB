-- 题目1
CREATE VIEW the_first_five_dvd AS
SELECT film.film_id, film.title, count(*) count
FROM rental, inventory, film
where rental.inventory_id = inventory.inventory_id 
and inventory.film_id = film.film_id
and rental_date between '2005-01-01 00:00:00' and '2005-12-31 23:59:59'
GROUP BY film_id
ORDER BY count DESC limit 5

-- 题目2
CREATE VIEW dvd_order_by_country AS
SELECT customer.customer_id, count(*) count, city, country
FROM rental, customer, address, city, country
where rental.customer_id = customer.customer_id
and customer.address_id = address.address_id
and address.city_id = city.city_id
and city.country_id = country.country_id
and rental_date between '2005-01-01 00:00:00' and '2005-12-31 23:59:59'
GROUP BY customer_id
ORDER BY country, count DESC, city

-- 题目3
CREATE VIEW dvd_order_by_rating AS
SELECT rating, count(*) count
FROM film, rental, inventory
where rental.inventory_id = inventory.inventory_id 
and inventory.film_id = film.film_id
and rental_date between '2005-01-01 00:00:00' and '2005-12-31 23:59:59'
GROUP BY rating
ORDER BY count DESC

-- 题目4
delimiter //
create procedure customer_payment
(in in_lastname varchar(45),
out out_pay decimal(5, 2))
begin
	select sum(amount)
	from payment, customer
	where last_name = in_lastname
	and payment.customer_id = customer.customer_id
    group by payment.customer_id
	into out_pay;
	select out_pay;
end //
delimiter ;
call customer_payment('SMITH', @pay)

-- 题目5
create view staff_worktime as
select store_id, staff.staff_id, min(rental_date) begintime, max(rental_date) endtime
from rental, staff
where staff.staff_id = rental.staff_id
group by staff_id
    
select staff_id, timestampdiff(month , begintime, endtime) duration
from staff_worktime
    
create view store_income as
select store_id, sum(amount) income
from staff, payment
where payment.staff_id = staff.staff_id
group by payment.staff_id
    
delimiter //
create procedure store_profit
(in in_store_id tinyint(3),
out out_profit decimal(10, 2))
begin
	select income - timestampdiff(month , begintime, endtime) * 10
	from store_income, staff_worktime
	where store_income.store_id = in_store_id
    and store_income.store_id = staff_worktime.store_id
	into out_profit;
	select out_profit;
end //
delimiter ;

call store_profit(1, @profit)

-- 题目6
DELIMITER ||
CREATE TRIGGER film_delete BEFORE DELETE ON film FOR EACH ROW
BEGIN
    DELETE FROM film_text WHERE film_id = old.film_id;
    DELETE FROM film_actor WHERE film_id = old.film_id;
    DELETE FROM film_category WHERE film_id = old.film_id;
    DELETE FROM inventory WHERE film_id = old.film_id;
END ||
DELIMITER ;
drop TRIGGER film_delete

-- 题目7
create table alter_rental(
rental_id int(11),
alter_field varchar(45),
old_value varchar(45),
new_value varchar(45),
update_time datetime)

DELIMITER ||
CREATE TRIGGER alter_rental AFTER UPDATE ON rental FOR EACH ROW
BEGIN
declare fieldName varchar(45);declare oldValue varchar(45);declare newValue varchar(45);
    if(old.rental_id <> new.rental_id) then
		set fieldName = 'rental_id';set oldValue = cast(old.rental_id as char);set newValue = cast(new.rental_id as char);
	elseif(old.rental_date <> new.rental_date) then
		set fieldName = 'rental_date';set oldValue = cast(old.rental_date as char);set newValue = cast(new.rental_date as char);
	elseif(old.inventory_id <> new.inventory_id) then
		set fieldName = 'inventory_id';set oldValue = cast(old.inventory_id as char);set newValue = cast(new.inventory_id as char);
	elseif(old.customer_id <> new.customer_id) then
		set fieldName = 'customer_id';set oldValue = cast(old.customer_id as char);set newValue = cast(new.customer_id as char);
    elseif(old.return_date <> new.return_date) then
		set fieldName = 'return_date';set oldValue = cast(old.return_date as char);set newValue = cast(new.return_date as char);
    elseif(old.staff_id <> new.staff_id) then
		set fieldName = 'staff_id';set oldValue = cast(old.staff_id as char);set newValue = cast(new.staff_id as char);
	end if;
	insert into alter_rental values(new.rental_id, fieldName, oldValue, newValue, now());
END ||
DELIMITER ;

update rental set inventory_id = 367 where rental_id = 1;

-- 题目8
create view film_daily as
select rental_id, title, count(*) count, date_format(rental_date, '%Y-%m-%d') rental_date
from film, inventory, rental
where film.film_id = inventory.film_id
and inventory.inventory_id = rental.inventory_id
group by title

create table statistic_rental(
title varchar(255),
count smallint(5),
income decimal(10, 2),
rental_date datetime)

delimiter ||
create procedure daily_rental
(in time date)
begin
	insert into statistic_rental
	select title, count, amount * count income, rental_date
	from payment, film_daily
	where payment.rental_id = film_daily.rental_id
    and rental_date = time;
end ||
delimiter ;
drop procedure daily_rental
call daily_rental('2005-07-08')

create event update_rental_daily
on schedule every 1 day starts '2021-10-23 00:00:00'
on completion not preserve enable do call daily_rental(now()); 

drop event update_rental_daily