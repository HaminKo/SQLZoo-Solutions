/*
SQLZOO Guest House Answers
Questions available at http://sqlzoo.net/wiki/Guest_House
*/


-- #1
/*
Guest 1183. Give the booking_date and the number of nights for guest 1183.
*/
SELECT
	booking_date,
	nights
FROM
	booking
WHERE
	guest_id = 1183;

-- #2
/*
When do they get here? List the arrival time and the first and last names for all guests due to arrive on 2016-11-05, order the output by time of arrival.
*/
SELECT
	booking.arrival_time,
	guest.first_name,
	guest.last_name
FROM
	booking
	JOIN
		guest
		ON (booking.guest_id = guest.id)
WHERE
	YEAR(booking.booking_date) = '2016'
	AND MONTH(booking.booking_date) = '11'
	AND DAY(booking.booking_date) = '05'
ORDER BY
	booking.arrival_time;

-- #3
/*
Look up daily rates. Give the daily rate that should be paid for bookings with ids 5152, 5165, 5154 and 5295. Include booking id, room type, number of occupants and the amount.
*/
SELECT
	booking.booking_id,
	booking.room_type_requested,
	booking.occupants,
	rate.amount
FROM
	booking
	JOIN
		rate
		ON (booking.occupants = rate.occupancy
		AND booking.room_type_requested = rate.room_type)
WHERE
	booking.booking_id = 5152
	OR booking.booking_id = 5154
	OR booking.booking_id = 5295;

-- #4
/*
Who’s in 101? Find who is staying in room 101 on 2016-12-03, include first name, last name and address.
*/
SELECT
	guest.first_name,
	guest.last_name,
	guest.address
FROM
	guest
	JOIN
		booking
		ON (booking.guest_id = guest.id)
WHERE
	booking.room_no = 101
	AND booking.booking_date = '2016-12-03';

-- #5
/*
How many bookings, how many nights? For guests 1185 and 1270 show the number of bookings made and the total number nights. Your output should include the guest id and the total number of bookings and the total number of nights.
*/
SELECT
	guest_id,
	COUNT(nights),
	sum(nights)
FROM
	booking
WHERE
	guest_id = 1185
	OR guest_id = 1270
GROUP BY
	guest_id;

-- #6
/*
Ruth Cadbury. Show the total amount payable by guest Ruth Cadbury for her room bookings. You should JOIN to the rate table using room_type_requested and occupants.
*/
SELECT
	SUM(booking.nights * rate.amount)
FROM
	booking
	JOIN
		rate
		ON (booking.occupants = rate.occupancy
		AND booking.room_type_requested = rate.room_type)
	JOIN
		guest
		ON (guest.id = booking.guest_id)
WHERE
	guest.first_name = 'Ruth'
	AND guest.last_name = 'Cadbury';

-- #7
/*
Including Extras. Calculate the total bill for booking 5128 including extras.
*/
SELECT
	SUM(booking.nights * rate.amount) + SUM(e.amount) AS Total
FROM
	booking
	JOIN
		rate
		ON (booking.occupants = rate.occupancy
		AND booking.room_type_requested = rate.room_type)
	JOIN
		(
			SELECT
				booking_id,
				SUM(amount) as amount
			FROM
				extra
			group by
				booking_id
		)
		AS e
		ON (e.booking_id = booking.booking_id)
WHERE
	booking.booking_id = 5128;

-- #8
/*
Edinburgh Residents. For every guest who has the word “Edinburgh” in their address show the total number of nights booked. Be sure to include 0 for those guests who have never had a booking. Show last name, first name, address and number of nights. Order by last name then first name.
*/
SELECT
	guest.last_name,
	guest.first_name,
	guest.address,
	CASE
		WHEN
			SUM(booking.nights) IS NULL
		THEN
			0
		ELSE
			SUM(booking.nights)
	END
	AS nights
FROM
	booking
	RIGHT JOIN
		guest
		ON (guest.id = booking.guest_id)
WHERE
	guest.address LIKE '%Edinburgh%'
GROUP BY
	guest.last_name, guest.first_name, guest.address
ORDER BY
	guest.last_name, guest.first_name;

-- #9
/*
Show the number of people arriving. For each day of the week beginning 2016-11-25 show the number of people who are arriving that day.
*/
SELECT
	booking_date AS i,
	COUNT(booking_id) AS arrivals
FROM
	booking
WHERE
	booking_date BETWEEN '2016-11-25' AND '2016-12-01'
GROUP BY
	booking_date;

-- #10
/*
How many guests? Show the number of guests in the hotel on the night of 2016-11-21. Include all those who checked in that day or before but not those who have check out on that day or before.
*/
SELECT
	SUM(occupants)
FROM
	booking
WHERE
	booking_date <= '2016-11-21'
	AND DATE_ADD(booking_date, INTERVAL nights DAY) > '2016-11-21';

-- #11
/*
Coincidence. Have two guests with the same surname ever stayed in the hotel on the evening? Show the last name and both first names. Do not include duplicates.
*/
SELECT DISTINCT
	a.last_name,
	a.first_name,
	b.first_name
FROM
	(
		SELECT
			*
		FROM
			booking
			JOIN
				guest
				ON (booking.guest_id = guest.id)
	)
	AS a
	JOIN
		(
			SELECT
				*
			FROM
				booking
				JOIN
					guest
					ON (booking.guest_id = guest.id)
		)
		AS b
		ON (a.last_name = b.last_name)
		AND a.booking_date <= b.booking_date
		AND DATE_ADD(a.booking_date, INTERVAL (a.nights - 1) DAY) >= b.booking_date
		AND a.first_name > b.first_name
ORDER BY
	a.last_name;

-- #12
/*
Check out per floor. The first digit of the room number indicates the floor – e.g. room 201 is on the 2nd floor. For each day of the week beginning 2016-11-14 show how many guests are checking out that day by floor number. Columns should be day (Monday, Tuesday ...), floor 1, floor 2, floor 3.
*/
SELECT
  DATE_ADD(booking_date, INTERVAL nights DAY) AS i,
  SUM(CASE WHEN room_no LIKE '1%' THEN 1 ELSE 0 END) AS 1st,
  SUM(CASE WHEN room_no LIKE '2%' THEN 1 ELSE 0 END) AS 2nd,
  SUM(CASE WHEN room_no LIKE '3%' THEN 1 ELSE 0 END) AS 3rd
FROM
	booking
WHERE
	DATE_ADD(booking_date, INTERVAL nights DAY) BETWEEN '2016-11-14' AND '2016-11-20'
GROUP BY
	i;

-- #13
/*
Who is in 207? Who is in room 207 during the week beginning 21st Nov. Be sure to list those days when the room is empty. Show the date and the last name. You may find the table calendar useful for this query.
*/
SELECT
	a.i,
	b.last_name
FROM
	(
		SELECT
			*
		FROM
			calendar
			JOIN
				(
					SELECT DISTINCT
						room_no
					FROM
						booking
				)
				AS c
	)
	AS a
	LEFT JOIN
		(
			SELECT
				booking_date,
				DATE_ADD(booking_date, INTERVAL nights DAY) AS checkout_date,
				room_no,
				last_name
			FROM
				booking
				JOIN
					guest
					ON booking.guest_id = guest.id
		)
		AS b
		ON a.i >= b.booking_date
		AND a.i < b.checkout_date
		AND a.room_no = b.room_no
WHERE
	a.i BETWEEN '2016-11-21' AND '2016-11-27'
	AND a.room_no = 207;

-- #14
/*
Double room for seven nights required. A customer wants a double room for 7 consecutive nights as some time between 2016-11-03 and 2016-12-19. Show the date and room number for the first such availabilities.
*/
SELECT
	room.id,
	DATE_ADD(rc.i, INTERVAL - rc.room_availability_streak + 1 DAY) AS i
FROM
	(
		SELECT
			a.i,
			a.room_no,
			@row_number1 :=
			CASE
				WHEN
					b.room_no IS NULL
				THEN
					@row_number1 + 1
				ELSE
					0
			END
			AS room_availability_streak
		FROM
			(
				SELECT
					*
				FROM
					calendar
					JOIN
						(
							SELECT DISTINCT
								room_no
							FROM
								booking
						)
						AS c
			)
			AS a
			LEFT JOIN
				(
					SELECT
						booking_date,
						DATE_ADD(booking_date, INTERVAL nights DAY) AS checkout_date,
						room_no
					FROM
						booking
				)
				AS b
				ON a.i >= b.booking_date
				AND a.i < b.checkout_date
				AND a.room_no = b.room_no,
				(
					SELECT
						@row_number1 := 0
				)
				AS counter_int
		WHERE
			a.i BETWEEN '2016-11-03' AND '2016-12-19'
		ORDER BY
			a.room_no,
			a.i
	)
	AS rc
	JOIN
		room
		ON (rc.room_no = room.id)
WHERE
	rc.room_availability_streak = 7
	AND room.room_type = 'double'
ORDER BY
	i LIMIT 2;
-- For this problem consider utilizing window functions. However, MYSQL does not support window functoins. Thus I just used LIMIT.

-- #15
/*
Gross income by week. Money is collected from guests when they leave. For each Thursday in November show the total amount of money collected from the previous Friday to that day, inclusive.
*/
SELECT
	DATE_ADD(MAKEDATE(2016, 7), INTERVAL WEEK(DATE_ADD(booking.booking_date, INTERVAL booking.nights - 5 DAY), 0) WEEK) AS i,
	SUM(booking.nights * rate.amount) + SUM(e.amount) AS Total
FROM
	booking
	JOIN
		rate
		ON (booking.occupants = rate.occupancy
		AND booking.room_type_requested = rate.room_type)
	LEFT JOIN
		(
			SELECT
				booking_id,
				SUM(amount) as amount
			FROM
				extra
			group by
				booking_id
		)
		AS e
		ON (e.booking_id = booking.booking_id)
GROUP BY
	i;
