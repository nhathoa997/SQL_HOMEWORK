Use sakila;

#1a. Display the first and last names of all actors from 
#the table actor.
Select first_name, last_name from actor; 
#1b. Display the first and last name of each actor in a single
#column in upper case letters. Name the column Actor Name.

SELECT CONCAT(first_name, last_name) 
AS 'Actor Name' from actor;

#2a. You need to find the ID number, first name, and last name 
#of an actor, of whom you know only the first name, "Joe."
# What is one query would you use to obtain this information?
SELECT * FROM actor WHERE actor.first_name LIKE 'Joe';

#2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor WHERE actor.last_name LIKE '%GEN%';

#2c. Find all actors whose last names contain the letters LI. 
#This time, order the rows by last name and first name, in 
#that order:

SELECT last_name, first_name FROM actor  
WHERE actor.last_name LIKE '%LI%';

#2d. Using IN, display the country_id and country columns
#of the following countries: Afghanistan, Bangladesh, and 
#China:

Select country_id, country from country where 
country in ('Afghanistan', 'Bangladesh', 'China');

#3a. You want to keep a description of each actor. 
#You don't think you will be performing queries on a description,
#so create a column in the table actor named description and 
#use the data type BLOB (Make sure to research the type BLOB, 
#as the difference between it and VARCHAR are significant).

ALTER TABLE actor
ADD COLUMN description BLOB;

#3b. Very quickly you realize that entering descriptions 
#for each actor is too much effort. Delete the description 
#column.
ALTER TABLE actor DROP description;

#4a. List the last names of actors, as well as how many 
#actors have that last name.
SELECT last_name, COUNT(*)
FROM actor
GROUP BY last_name;

#4b. List last names of actors and the number of actors who 
#have that last name, but only for names that are shared by at 
#least two actors.
SELECT last_name, COUNT(*) as cnt
FROM actor
GROUP BY last_name
Having cnt >=2;

#4.c The actor HARPO WILLIAMS was accidentally entered in the 
#actor table as GROUCHO WILLIAMS. Write a query to fix the 
#record.

UPDATE actor SET  
first_name = 'HARPO', last_name = 'WILLIAMS'
where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
#It turns out that GROUCHO was the correct name after all! 
#In a single query, if the first name of the actor is currently 
#HARPO, change it to GROUCHO.

UPDATE actor SET 
first_name = REPLACE(first_name, 'HARPO', 'GROUCHO')
WHERE last_name = 'WILLIAMS';

#5a. You cannot locate the schema of the address table. 
#Which query would you use to re-create it?
CREATE SCHEMA address;

#6a. Use JOIN to display the first and last names, as well as 
#the address, of each staff member. Use the tables staff and 
#address:

SELECT first_name, last_name
FROM staff
INNER JOIN address ON staff.address_id = address.address_id;

#6b. Use JOIN to display the total amount rung up by each 
#staff member in August of 2005. Use tables staff and payment.

SELECT staff.first_name, staff.last_name, sum(payment.amount)
from staff INNER JOIN payment ON staff.staff_id = payment.staff_id
group by staff.first_name, staff.last_name;

#6c. List each film and the number of actors who are listed 
#for that film. Use tables film_actor and film. Use inner join.

Select film.title, count(actor_id) as 'Actor Count' 
from film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
group by film.title;

#6d How many copies of the film Hunchback Impossible exist 
#in the inventory system?

Select count(*) as 'count', film.title from film 
INNER JOIN inventory ON film.film_id = inventory.film_id
where film.title Like "Hunchback Impossible";

#6e. Using the tables payment and customer and the JOIN 
#command, list the total paid by each customer. List the 
#customers alphabetically by last name:

Select customer.first_name, customer.last_name, sum(payment.amount)
from  customer INNER JOIN payment on customer.customer_id = payment.customer_id
group by customer.customer_id order by customer.last_name;

#7a. The music of Queen and Kris Kristofferson have seen an 
#unlikely resurgence. As an unintended consequence, films 
#starting with the letters K and Q have also soared in 
#popularity. Use subqueries to display the titles of movies 
#starting with the letters K and Q whose language is English.

Select * from film Where language_id LIKE 1 and title 
LIKE "Q%" or title LIKE "K%"; 

#7b. Use subqueries to display all actors who appear in 
#the film Alone Trip.

#Select first_name, last_name from actor where actor_id 
#in (select actor_id from film_actor where film_id in 
		#(select film_id from film 
	#		where title = 'Alone Trip')
	#);
select first_name, last_name from actor 
where actor_id in 
	(
		Select actor_id from film_actor
        where film_id in 
			(
				select film_id from film
                where title like 'Alone Trip'
			)
	);
#7c. You want to run an email marketing campaign in Canada, 
#for which you will need the names and email addresses of all 
#Canadian customers. Use joins to retrieve this information.
Select c.first_name, c.last_name, c.email from customer c
INNER JOIN address ON c.address_id = address.address_id
INNER JOIN city ON address.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id
WHERE country = 'CANADA';

#7d. Sales have been lagging among young families, and you 
#wish to target all family movies for a promotion. Identify 
#all movies categorized as family films.

Select title from film 
INNER JOIN film_category ON film.film_id = film_category.film_id
INNER JOIN category ON film_category.category_id = category.category_id
Where name = 'Family';

#7e. Display the most frequently rented movies in descending order.
Select film.title, count(*) as rental from film 
INNER JOIN inventory ON film.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id 
group by film.title
order by rental desc;

#7f. Write a query to display how much business, in dollars, each store brought in.
Select store.store_id, sum(payment.amount) as payment from store 
INNER JOIN inventory ON store.store_id = inventory.store_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
INNER JOIN payment ON payment.rental_id = rental.rental_id
group by store.store_id
order by payment desc;

#7g. Write a query to display for each store its store ID, city, and country.
Select store.store_id, city.city, country.country from store
INNER JOIN address USING (address_id)
INNER JOIN city USING (city_id)
INNER JOIN country USING (country_id);

#7h. List the top five genres in gross revenue in descending order. 
#(Hint: you may need to use the following tables: category, film_category, inventory, 
#payment, and rental.)
Select category.name ,sum(payment.amount) as revenue from payment 
INNER JOIN rental USING (rental_id)
INNER JOIN inventory USING (inventory_id)
INNER JOIN film_category USING (film_id)
INNER JOIN category USING (category_id)
group by category.name 
order by revenue desc
limit 5;

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top 
#five genres by gross revenue. Use the solution from the problem above to create a view. 
#If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW Top_5_genres AS
Select category.name ,sum(payment.amount) as revenue from payment 
INNER JOIN rental USING (rental_id)
INNER JOIN inventory USING (inventory_id)
INNER JOIN film_category USING (film_id)
INNER JOIN category USING (category_id)
group by category.name 
order by revenue desc
limit 5;

#8b. How would you display the view that you created in 8a?
select * from top_5_genres;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_5_genres;