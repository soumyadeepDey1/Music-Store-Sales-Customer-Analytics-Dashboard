SQL PROJECT- MUSIC STORE DATA ANALYSIS

Question Set 1 - Easy 
1. Who is the senior most employee based on job title? 
	select * from employee
	select * from employee order by levels desc limit 1
2. Which countries have the most Invoices? 
	select * from invoice;
	
	select billing_country, count(*) as c
	from invoice
	group by billing_country
	order by c desc
	limit 1;
3. What are top 3 values of total invoice? 
	select total 
	from invoice 
	order by total desc 
	limit 3;
4. Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals 
	select billing_city, sum(total) as invoice_total 
	from invoice 
	group by billing_city 
	order by invoice_total desc 
	limit 1
5. Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money 
	select * from customer

	select c.customer_id,concat(c.first_name,' ',c.last_name) as name, sum(i.total) total_invoice 
	from customer as c join invoice as i 
	on c.customer_id = i.customer_id 
	group by c.customer_id
	order by total_invoice desc
	limit 1


Question Set 2 – Moderate
1. Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A 
	select * from genre
	select concat(c.first_name,' ',c.last_name) as name, c.email
	from customer as c 
	join invoice as i on c.customer_id = i.customer_id
	join invoice_line as il on i.invoice_id = il.invoice_id
	where track_id in (
		select track_id from track as t
		join genre as g on t.genre_id = g.genre_id
		where g.name like 'Rock'
	)
	order by email
	
2. Let's' invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands 
	select * from artist
	select * from album
	select art.artist_id,art.name, count(t.track_id) total_track
	from artist as art
	join album as al on art.artist_id = al.artist_id
	join track as t on al.album_id = t.album_id
	where genre_id = (
		select genre_id 
		from genre
		where name like 'Rock'
	)
	group by art.artist_id
	order by total_track desc
	limit 10
3. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first
	 select * from track

	 select name, milliseconds
	 from track
	 where milliseconds > (select avg(milliseconds) from track)
	 order by milliseconds desc

Question Set 3 – Advance 
1. Find how much amount spent by each customer on artists? Write a query to return 
customer name, artist name and total spent 
	with best_selling_artist as (
		select art.artist_id, art.name,
		sum(ivl.unit_price * ivl.quantity) as total_spent
		from artist as art
		join album as alb on art.artist_id = alb.artist_id
		join track as trc on alb.album_id = trc.album_id
		join invoice_line as ivl on trc.track_id = ivl.track_id
		group by art.artist_id
		order by total_spent desc
		limit 2
	)
	select cmr.customer_id, concat(cmr.first_name,' ',cmr.last_name) as customer_name,
	bsa.name, sum(ivl.unit_price*ivl.quantity) total_spent
	from customer cmr
	join invoice iv on cmr.customer_id = iv.customer_id
	join invoice_line ivl on iv.invoice_id = ivl.invoice_id
	join track trc on trc.track_id = ivl.track_id
	join album alb on alb.album_id = trc.album_id
	join best_selling_artist bsa on bsa.artist_id = alb.artist_id
	group by 1,2,3 
	order by total_spent desc
2. We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres 
	with populer_genre as (
		select gr.genre_id, gr.name,cmr.country, count(ivl.quantity) as purchases,
		row_number() over(partition by cmr.country order by count(ivl.quantity) desc) as row_no
		from genre gr
		join track trc on gr.genre_id = trc.genre_id
		join invoice_line ivl on trc.track_id = ivl.track_id
		join invoice iv on iv.invoice_id = ivl.invoice_id
		join customer cmr on cmr.customer_id = iv.customer_id
		group by 1,3
		order by 3 asc, 4 desc
	)
	select country, name, purchases 
	from populer_genre 
	where row_no = 1
3. Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how 
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount
	with recursive 
	customer_with_country as (
		select cmr.customer_id, concat(cmr.first_name,' ',cmr.last_name) as customer_name,
		iv.billing_country, sum(iv.total) as total_spend
		from customer cmr
		join invoice iv on cmr.customer_id = iv.customer_id
		group by 1,3
		ORDER by 1,4 desc
	),
	country_max_spending as (
		select billing_country,max(total_spend) as max_spending
		from customer_with_country
		group by billing_country
	)

	select cwc.customer_id,cwc.customer_name,cwc.billing_country,cms.max_spending
	from customer_with_country cwc
	join country_max_spending cms on cwc.billing_country = cms.billing_country
	where cwc.total_spend = cms.max_spending
	order by 3


**
	select billing_country,count(*) from invoice group by billing_country order by 2 DESC