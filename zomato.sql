create database zomato
use zomato;

CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;


1. What is the total amount each customer spent on zomato??

select s.userid,sum(p.price) as total  from sales s inner join product p on s.product_id=p.product_id 
group by s.userid;



2. How many days has each customer spent on zomato?

select userid,COUNT(distinct created_date)as no_of_days from sales group by userid



3.What was the first product purchased by each of the customer?

select * from(
select * ,rank() over(partition by userid order by created_date)rank from sales) a where a.rank=1



4.What is the most purchased item on zomato and how many times each customer purchased it?

select userid,count(product_id) as cnt from sales where product_id=
(select top 1 product_id from sales group by product_id order by count(product_id) desc)
group by userid;



5.Most favorite item by each customer?

select * from(
select *,rank() over(partition by userid order by cnt desc)as rank from(
select userid,product_id,count(product_id)cnt from sales group by userid,product_id)a)b
where rank=1



6.Which item was purchased first by each customer after they became a member

select b.userid,b.created_date,b.product_id from
(select a.*,rank() over(partition by userid order by created_date asc)as rank from 
(select s.userid,s.created_date,s.product_id from sales s inner join goldusers_signup g on s.userid=g.userid 
and created_date>=g.gold_signup_date)a)b 
where rank=1



7.Which item was purchased just before the customer became a member?

select b.userid,b.product_id from(
select a.*,rank() over(partition by userid order by created_date asc)as rank from
(select s.userid,s.created_date,g.gold_signup_date,s.product_id from sales s inner join goldusers_signup g on s.userid=g.userid 
and created_date<=gold_signup_date)a)b where rank=1



8.What is the orders and total amount spent by each customer before they became a member?

select userid,count(created_date)order_purchased,sum(price)total_amount from
(select a.*,b.price from
(select s.userid,s.created_date,g.gold_signup_date,s.product_id from sales s inner join goldusers_signup g on s.userid=g.userid 
and created_date<=gold_signup_date)a inner join  product b on a.product_id=b.product_id)c group by userid


9.If buying each products generates points for eg 5rs=2 zomato points (1 zomato points=2.5rs) and each product have different purchase points for eg for p1,5Rs=1 zomato point,
   for p2,10Rs=5 zomato points (1 zomato point=2rs) for p3,5rs=1 zomato point.
   Calculate the points collected by each customer and for which product most points have been till now?

   select userid,sum(points)*2.5 as total_cashbacks from 
   (select c.*,total/amt_for_1_zomato_point as points from
   (select b.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as amt_for_1_zomato_point from 
   (select a.userid,a.product_id,sum(a.price)as total from
   (select s.*,p.price from sales s inner join product p on s.product_id=p.product_id)a group by userid,product_id)b)c)d group by userid;


   select * from
   (select *,rank() over(order by total_points desc)rank from
   (select product_id,sum(points)*2.5 as total_points from 
   (select c.*,total/amt_for_1_zomato_point as points from
   (select b.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as amt_for_1_zomato_point from 
   (select a.userid,a.product_id,sum(a.price)as total from
   (select s.*,p.price from sales s inner join product p on s.product_id=p.product_id)a group by userid,product_id)b)c)d group by product_id)e)f where rank=1;



10.In the first one year after a customer joins the gold program irrespective of what customer has purchased 
they earn 5 zomato points for every 10 rs spent who earned more 1 or 3 and what was their point earnings in their first year?
	note:	1zp=2rs


(select a.*,p.price*.5 total_points from
(select s.userid,s.created_date,g.gold_signup_date,s.product_id from sales s inner join goldusers_signup g on s.userid=g.userid 
and created_date>=gold_signup_date and created_date<=DATEADD(year,1,gold_signup_date))a
inner join product p on a.product_id=p.product_id);

11.Rank all transactions of each customer?

	select *,rank() over(partition by userid order by created_date)rank from sales;

	
12.Rank all transactions of each member whenever they are a zomato gold member for every no gold member transactions mark as na

select b.*,case when rank=0 then 'NA' else rank end as rnk from
(select a.*,cast((case when gold_signup_date is null then 0 else rank() over(partition by userid order by gold_signup_date desc)end)as varchar) as rank from 
(select s.userid,s.created_date,g.gold_signup_date,s.product_id from sales s left join goldusers_signup g on s.userid=g.userid 
and created_date>=gold_signup_date)a)b;
