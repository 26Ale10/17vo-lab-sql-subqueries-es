USE SAKILA;

-- 1.¿Cuántas copias de la película El Jorobado Imposible existen en el sistema de inventario?

SELECT 
    T1.film_id, T1.title, quantity
FROM
    film AS T1
        LEFT JOIN
    (SELECT 
        film_id, COUNT(inventory_id) AS quantity
    FROM
        inventory
    WHERE
        film_id = 439) AS T2 ON T1.film_id = T2.film_id
WHERE
    quantity IS NOT NULL
ORDER BY T2.quantity DESC;

-- 2.Lista todas las películas cuya duración sea mayor que el promedio de todas las películas

SELECT 
    title, length
FROM
    film
WHERE
    length > (SELECT 
            AVG(length)
        FROM
            film)
ORDER BY length DESC;

-- 3. Usa subconsultas para mostrar todos los actores que aparecen en la película Viaje Solo.
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    actor_id IN (SELECT 
            actor_id
        FROM
            film_actor
        WHERE
            film_id = 17);

-- 4. Las ventas han estado disminuyendo entre las familias jóvenes, y deseas dirigir todas las películas familiares a una promoción. 
-- Identifica todas las películas categorizadas como películas familiares.
SELECT 
    film_id, title
FROM
    film
WHERE
    film_id IN (SELECT 
            film_id
        FROM
            film_category
        WHERE
            category_id IN (SELECT 
                    category_id
                FROM
                    category
                WHERE
                    LOWER(name) LIKE 'family'));

-- 5. Obtén el nombre y correo electrónico de los clientes de Canadá usando subconsultas. Haz lo mismo con uniones.
-- Ten en cuenta que para crear una unión, tendrás que identificar las tablas correctas con sus claves primarias y claves foráneas, que te ayudarán a obtener la información relevante.

SELECT 
    first_name, email
FROM
    customer AS T1
        INNER JOIN
    (SELECT 
        address_id
    FROM
        address
    WHERE
        city_id IN (SELECT 
                city_id
            FROM
                city
            WHERE
                country_id IN (SELECT 
                        country_id
                    FROM
                        country
                    WHERE
                        LOWER(country) LIKE 'canada'))) AS T2 ON T2.address_id = T1.address_id
;

-- 6. ¿Cuáles son las películas protagonizadas por el actor más prolífico? El actor más prolífico se define como el actor que ha actuado en el mayor número de películas. 
-- Primero tendrás que encontrar al actor más prolífico y luego usar ese actor_id para encontrar las diferentes películas en las que ha protagonizado.

SELECT title
FROM film
WHERE film_id IN 
(SELECT film_id
FROM film_actor AS T1
INNER JOIN 
(SELECT actor_id,COUNT(DISTINCT film_id) AS total_pro, RANK() OVER(ORDER BY COUNT(DISTINCT film_id) DESC) AS ranking FROM film_actor
GROUP BY actor_id
ORDER BY ranking
LIMIT 1) T2 ON T2.actor_id = T1.actor_id);

-- 7. Películas alquiladas por el cliente más rentable. 
-- Puedes usar la tabla de clientes y la tabla de pagos para encontrar al cliente más rentable, es decir, el cliente que ha realizado la mayor suma de pagos.

SELECT title
FROM film
WHERE film_id IN
(SELECT film_id 
FROM inventory
WHERE inventory_id IN
(SELECT inventory_id FROM rental AS t3 
INNER JOIN 
(SELECT T2.customer_id, T2.rental_id AS rental_id ,T2.payment_id as payment_id
FROM payment AS T2
INNER JOIN (SELECT customer_id ,SUM(amount) AS total_amount, RANK() OVER(ORDER BY sum(amount) DESC) AS ranking FROM payment
GROUP BY customer_id
ORDER BY ranking
LIMIT 1) AS T1 ON T1.customer_id = T2.customer_id) as t4 on T4.rental_id = T3.rental_id))
;

-- 8. Obtén el client_id y el total_amount_spent de esos clientes que gastaron más que el promedio del total_amount gastado por cada cliente.





