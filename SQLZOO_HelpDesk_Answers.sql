/*
SQLZOO Helpdesk Answers
Questions available at http://sqlzoo.net/wiki/Help_Desk
*/


-- #1
/*
There are three issues that include the words "index" and "Oracle". Find the call_date for each of them
*/
SELECT
  call_date,
  call_ref
FROM
  Issue
WHERE
  detail LIKE '%index%'
  AND detail LIKE '%Oracle%';

-- #2
/*
Samantha Hall made three calls on 2017-08-14. Show the date and time for each
*/
SELECT
	Issue.call_date,
	Caller.first_name,
	Caller.last_name
FROM
	Issue
	JOIN
		Caller
		ON (Caller.caller_id = Issue.caller_id)
WHERE
	Caller.first_name = 'Samantha'
	AND Caller.last_name = 'Hall'
	AND Issue.call_date LIKE '%2017-08-14%';

-- #3
/*
There are 500 calls in the system (roughly). Write a query that shows the number that have each status.
*/
SELECT
	status,
	Count(*) AS Volume
FROM
	Issue
GROUP BY
	status;

-- #4
/*
Calls are not normally assigned to a manager but it does happen. How many calls have been assigned to staff who are at Manager Level?
*/
SELECT
	COUNT(*) AS mlcc
FROM
	Issue
	JOIN
		Staff
		ON (Issue.Assigned_to = Staff.Staff_code)
	JOIN
		Level
		ON (Staff.Level_code = Level.Level_code)
WHERE
	Level.Manager = 'Y';

-- #5
/*
Show the manager for each shift. Your output should include the shift date and type; also the first and last name of the manager.
*/
SELECT
	Shift.Shift_date,
	Shift.Shift_type,
	Staff.first_name,
	Staff.last_name
FROM
	Shift
	JOIN
		Staff
		ON (Shift.Manager = Staff.Staff_Code)
ORDER BY
	Shift.Shift_date;

-- #6
/*
List the Company name and the number of calls for those companies with more than 18 calls.
*/
SELECT
	Customer.Company_name,
	COUNT(*)
FROM
	Customer
	JOIN
		Caller
		ON (Customer.Company_ref = Caller.Company_ref)
	JOIN
		Issue
		ON (Caller.Caller_id = Issue.Caller_id)
GROUP BY
	Customer.Company_name
HAVING
	COUNT(*) > 18;

-- #7
/*
Find the callers who have never made a call. Show first name and last name
*/
SELECT
	Caller.first_name,
	Caller.last_name
FROM
	Caller
	LEFT JOIN
		Issue
		ON (Caller.Caller_id = Issue.Caller_id)
WHERE
	Issue.Caller_id IS NULL;

-- #8
/*
For each customer show: Company name, contact name, number of calls where the number of calls is fewer than 5
*/
SELECT
	a.Company_name,
	b.first_name,
	b.last_name,
	a.nc
FROM
	(
		SELECT
			Customer.Company_name,
			Customer.Contact_id,
			COUNT(*) AS nc
		FROM
			Customer
			JOIN
				Caller
				ON (Customer.Company_ref = Caller.Company_ref)
			JOIN
				Issue
				ON (Caller.Caller_id = Issue.Caller_id)
		GROUP BY
			Customer.Company_name,
			Customer.Contact_id
		HAVING
			COUNT(*) < 5
	)
	AS a
	JOIN
		(
			SELECT
				*
			FROM
				Caller
		)
		AS b
		ON (a.Contact_id = b.Caller_id);

-- #9
/*
For each shift show the number of staff assigned. Beware that some roles may be NULL and that the same person might have been assigned to multiple roles (The roles are 'Manager', 'Operator', 'Engineer1', 'Engineer2').
*/
SELECT
	a.Shift_date,
	a.Shift_type,
	COUNT(DISTINCT role) AS cw
FROM
	(
		SELECT
			shift_date,
			shift_type,
			Manager AS role
		FROM
			Shift
		UNION ALL
		SELECT
			shift_date,
			shift_type,
			Operator AS role
		FROM
			Shift
		UNION ALL
		SELECT
			shift_date,
			shift_type,
			Engineer1 AS role
		FROM
			Shift
		UNION ALL
		SELECT
			shift_date,
			shift_type,
			Engineer2 AS role
		FROM
			Shift
	)
	AS a
GROUP BY
	a.Shift_date,
	a.Shift_type;

-- #10
/*
Caller 'Harry' claims that the operator who took his most recent call was abusive and insulting. Find out who took the call (full name) and when.
*/
SELECT
	Staff.first_name,
	Staff.last_name,
	Issue_Max.call_date
FROM
	(
		SELECT
			b.call_date,
			b.Taken_by,
			b.Caller_id
		FROM
			(
				SELECT
					Issue.Caller_id,
					MAX(Issue.call_date) AS call_date
				FROM
					Issue
				GROUP BY
					Issue.Caller_id
			)
			AS a
			JOIN
				Issue AS b
				ON a.Caller_id = b.Caller_id
				AND a.call_date = b.call_date
	)
	AS Issue_Max
	JOIN
		Staff
		ON (Staff.Staff_code = Issue_Max.Taken_By)
	JOIN
		Caller
		ON (Issue_Max.Caller_id = Caller.Caller_id)
WHERE
	Caller.first_name = 'Harry';

-- #11
/*
Show the manager and number of calls received for each hour of the day on 2017-08-12
*/
SELECT
	Shift.Manager,
	i.date_hour as Hr,
	COUNT(*) as CC
FROM
	(
		SELECT
			DATE_FORMAT(call_date, '%Y-%m-%d %H') date_hour,
			DATE_FORMAT(call_date, '%Y-%m-%d') date,
			DATE_FORMAT(call_date, '%H') hour,
			Taken_by
		FROM
			Issue
		WHERE
			YEAR(call_date) = '2017'
			AND MONTH(call_date) = '08'
			AND DAY(call_date) = '12'
	)
	AS i
	JOIN
		Shift
		ON (i.date = Shift.Shift_date)
WHERE
	Shift.Shift_type = 'early'
	AND i.hour <= 13
	OR Shift.Shift_type = 'late'
	AND i.hour > 13
GROUP BY
	Shift.Manager,
	i.date_hour
ORDER BY
	i.date_hour
;

-- #12
/*
80/20 rule. It is said that 80% of the calls are generated by 20% of the callers. Is this true? What percentage of calls are generated by the most active 20% of callers.
*/
SELECT
	ROUND(SUM(p2.cc / (SELECT COUNT(*) FROM Issue)) * 100, 4)
	FROM
		(
			SELECT
				p1.*,
				@counter := @counter + 1 AS counter
			FROM
				(
					SELECT
						@counter := 0
				)
				AS initvar,
				(
					SELECT
						Caller_id,
						COUNT(*) AS cc
					FROM
						Issue
					GROUP BY
						Caller_id
					ORDER BY
						COUNT(*) DESC
				)
				AS p1
		)
		AS p2
	WHERE
		counter <= (20 / 100 * @counter);

-- #13
/*
Annoying customers. Customers who call in the last five minutes of a shift are annoying. Find the most active customer who has never been annoying.
*/
SELECT
	Customer.Company_name,
	COUNT(*)
FROM
	Customer
	JOIN
		Caller
		ON (Customer.Company_ref = Caller.Company_ref)
	JOIN
		Issue
		ON (Caller.Caller_id = Issue.Caller_id)
WHERE
	Customer.Company_name NOT IN
	(
		SELECT
			Customer.Company_name
		FROM
			Customer
			JOIN
				Caller
				ON (Customer.Company_ref = Caller.Company_ref)
			JOIN
				Issue
				ON (Caller.Caller_id = Issue.Caller_id)
		WHERE
			(
				DATE_FORMAT(call_date, '%H') = 13
				OR DATE_FORMAT(call_date, '%H') = 19
			)
			AND DATE_FORMAT(call_date, '%i') >= 55
	)
GROUP BY
	Customer.Company_name
ORDER BY
	COUNT(*) DESC LIMIT 1;

-- #14
/*
Maximal usage. If every caller registered with a customer makes a call in one day then that customer has "maximal usage" of the service. List the maximal customers for 2017-08-13.
*/
SELECT
	a.Company_name,
	a.caller_count,
	b.issue_count
FROM
	(
		SELECT
			Customer.Company_name,
			COUNT(Caller.Company_ref) AS caller_count
		FROM
			Customer
			JOIN
				Caller
				ON (Customer.Company_ref = Caller.Company_ref)
		GROUP BY
			Customer.Company_name
	)
	AS a
	JOIN
		(
			SELECT
				Customer.Company_name,
				COUNT(DISTINCT Issue.Caller_id) AS issue_count
			FROM
				Customer
				JOIN
					Caller
					ON (Customer.Company_ref = Caller.Company_ref)
				JOIN
					Issue
					ON (Caller.Caller_id = Issue.Caller_id)
			WHERE
				YEAR(Issue.call_date) = '2017'
				AND MONTH(Issue.call_date) = '08'
				AND DAY(Issue.call_date) = '13'
			GROUP BY
				Customer.Company_name
		)
		AS b
		ON a.Company_name = b.Company_name
WHERE
	a.caller_count = b.issue_count;

-- #15
/*
Consecutive calls occur when an operator deals with two callers within 10 minutes. Find the longest sequence of consecutive calls – give the name of the operator and the first and last call date in the sequence.Is
*/
SELECT
	a.taken_by,
	a.first_call,
	a.last_call,
	a.call_count AS calls
FROM
	(
		SELECT
			taken_by,
			call_date AS last_call,
			@row_number1:= CASE
				WHEN
					TIMESTAMPDIFF(MINUTE, @call_date, call_date) <= 10
				THEN
					@row_number1 + 1
				ELSE
					1
			END AS call_count,
      @first_call_date:= CASE
				WHEN
					@row_number1 = 1
				THEN
					call_date
				ELSE
					@first_call_date
			END AS first_call,
      @call_date:= Issue.call_date AS call_date
		FROM
			Issue,
			(
				SELECT
					@row_number1 := 0,
					@call_date := 0,
					@first_call_date := 0
			)
			AS row_number_init
		ORDER BY
			taken_by,
			call_date
	)
	AS a
ORDER BY
	a.call_count DESC LIMIT 1;
