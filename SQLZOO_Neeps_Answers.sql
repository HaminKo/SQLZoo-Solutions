/*
SQLZOO Guest House Answers
Questions available at http://sqlzoo.net/wiki/Neeps
*/


-- #1
/*
Give the room id in which the event co42010.L01 takes place.
*/
SELECT
  event.room
FROM
  event
WHERE
  event.id = 'co42010.L01';

-- #2
/*
For each event in module co72010 show the day, the time and the place.
*/
SELECT
  event.dow,
  event.tod,
  event.room
FROM
  event
WHERE
  event.modle = 'co72010';

-- #3
/*
List the names of the staff who teach on module co72010.
*/
SELECT DISTINCT
  staff.name
FROM
  staff
  JOIN
    teaches
    ON staff.id = teaches.staff
  JOIN
    event
    ON teaches.event = event.id
WHERE
  event.modle = 'co72010';

-- #4
/*
Give a list of the staff and module number associated with events using room cr.132 on Wednesday, include the time each event starts.
*/
SELECT
  staff.name,
  event.modle,
  event.tod
FROM
  staff
  JOIN
    teaches
    ON staff.id = teaches.staff
  JOIN
    event
    ON teaches.event = event.id
WHERE
  event.room = 'cr.132'
  AND event.dow = 'Wednesday';

-- #5
/*
Give a list of the student groups which take modules with the word 'Database' in the name.
*/
SELECT
  student.name
FROM
  student
  JOIN
    attends
    ON student.id = attends.student
  JOIN
    event
    ON attends.event = event.id
  JOIN
    modle
    ON event.modle = modle.id
WHERE
  LOWER(modle.name) LIKE LOWER('%database%');

-- #6
/*
Show the 'size' of each of the co72010 events. Size is the total number of students attending each event.
*/
SELECT
  event.id,
  SUM(student.sze)
FROM
  student
  JOIN
    attends
    ON student.id = attends.student
  JOIN
    event
    ON attends.event = event.id
WHERE
  event.modle = 'co72010'
GROUP BY
  event.id;

-- #7
/*
For each post-graduate module, show the size of the teaching team. (post graduate modules start with the code co7).
*/
SELECT
  COUNT(DISTINCT staff.id),
  event.modle
FROM
  staff
  JOIN
    teaches
    ON staff.id = teaches.staff
  JOIN
    event
    ON teaches.event = event.id
WHERE
  event.modle LIKE 'co7%'
GROUP BY
  event.modle;

-- #8
/*
Give the full name of those modules which include events taught for fewer than 10 weeks.
*/
SELECT DISTINCT
  modle.name
FROM
  modle
  JOIN
    event
    ON event.modle = modle.id
  JOIN
    occurs
    ON event.id = occurs.event
GROUP BY
  event.id, modle.name
HAVING
  COUNT(occurs.week) < 10;

-- #9
/*
Identify those events which start at the same time as one of the co72010 lectures.
*/
SELECT
  event.id
FROM
  event
WHERE
  CONCAT(event.dow, event.tod) IN
    (
      SELECT
        CONCAT(event.dow, event.tod)
      FROM
        event
      WHERE
        event.modle = 'co72010'
    );

-- #10
/*
How many members of staff have contact time which is greater than the average?
*/
SELECT
  COUNT(*) AS 'Number of staff with greater than average contact time'
FROM
  (
    SELECT
      staff.id,
      SUM(event.duration)
    FROM
      staff
      JOIN
        teaches
        ON staff.id = teaches.staff
      JOIN
        event
        ON teaches.event = event.id
    GROUP BY
      staff.id
    HAVING
      SUM(event.duration) > (
        SELECT
          SUM(t.hours)/COUNT(t.hours)
        FROM
          (
            SELECT
              SUM(event.duration) AS hours
            FROM
              staff
              JOIN
                teaches
                ON staff.id = teaches.staff
              JOIN
                event
                ON teaches.event = event.id
            GROUP BY
              staff.id
          ) AS t
        )
  ) AS a

-- #11
/*
co.CHt is to be given all the teaching that co.ACg currently does. Identify those events which will clash.
*/
SELECT DISTINCT
  a.id, b.id
FROM
  (
    SELECT
      event.id,
      event.tod AS time_begin,
      event.tod + event.duration AS time_end,
      event.dow,
      occurs.week
    FROM
      event
      JOIN
        teaches
        ON event.id = teaches.event
      JOIN
        staff
        ON teaches.staff = staff.id
      JOIN occurs
        ON event.id = occurs.event
    WHERE
      staff.id = 'co.CHt'
  ) AS a
  CROSS JOIN
  (
    SELECT
      event.id,
      event.tod AS time_begin,
      event.tod + event.duration AS time_end,
      event.dow,
      occurs.week
    FROM
      event
      JOIN
        teaches
        ON event.id = teaches.event
      JOIN
        staff
        ON teaches.staff = staff.id
      JOIN occurs
        ON event.id = occurs.event
    WHERE
      staff.id = 'co.ACg'
  ) AS b
WHERE
  a.dow = b.dow
  AND (a.time_begin >= b.time_begin AND a.time_begin < b.time_end)
  OR (b.time_begin >= a.time_begin AND b.time_begin < a.time_end)
  AND a.week = b.week
  AND a.id > b.id;

-- #12
/*
Produce a table showing the utilisation rate and the occupancy level for all rooms with a capacity more than 60

NOTE: Cannot answer this one as room table seems to be prioritized by another room table in a different database.
*/
