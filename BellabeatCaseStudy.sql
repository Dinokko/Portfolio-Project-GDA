-- USED 3 TABLES: DailyActivity, WeightLogInfo & SleepLog

-- Checked for distinct values in DailyActivity:

SELECT DISTINCT Id FROM DailyActivity;
# Pulled 33 results

-- Checked for distinct values in WeightLogInfo:

SELECT DISTINCT Id FROM WeightLogInfo;
# Pulled 8 results

-- Checked for distinct values in SleepLog:

SELECT DISTINCT Id FROM SleepLog;
# Pulled 24 results

-- Checked for duplicate values in DailyActivity:

SELECT Id, COUNT(*) AS numRow
FROM DailyActivity
GROUP BY Id, ActivityDate
HAVING COUNT(Id) > 1;
# Returned none

-- Checked for duplicate values in WeightLogInfo:

SELECT Id, COUNT(*) AS numRow
FROM WeightLogInfo
GROUP BY Id, Date, WeightKg, WeightPounds, Fat, BMI, IsManualReport, LogId
HAVING COUNT(*) > 1;
# Returned none

-- Checked for duplicate values in SleepLog:

SELECT Id, COUNT(*) AS numRow
FROM SleepLog
GROUP BY Id, SleepDay, TotalSleepRecords, TotalTimeInBed, TotalMinutesAsleep
HAVING COUNT(*) > 1;
# Returned 3 values

-- Create new table with distinct values from SleepLog:

SELECT DISTINCT Id, SleepDay, TotalSleepRecords, TotalTimeInBed, TotalMinutesAsleep
INTO SleepLog2
FROM SleepLog;
# Created SleepLog2 table

-- Rename SleepLog table and then give SleepLog2 table SleepLog name:

EXEC SP_RENAME 'SleepLog', 'DeletedTable'
EXEC SP_RENAME 'SleepLog2', 'SleepLog';
# Renames SleepLog to DeletedTable and SleepLog2 to SleepLog

-- Delete DeletedTable:

DROP TABLE IF EXISTS SleepLog2;
# Deletes table;

-- Checking DailyActivity for zero step days:

SELECT SUM(ZeroDays) AS numZeroDays
FROM (
	SELECT COUNT(*) AS ZeroDays
	FROM DailyActivity
	WHERE TotalSteps = 0
) AS t;
# Returned 77 entries

-- Checking other categories of days which had zero steps counted:

SELECT *, ROUND((SedentaryMinutes / 60), 2) AS SedentaryHours
FROM DailyActivity
WHERE TotalSteps = 0;
# Returned many entries with 24 hours of no activity. Most likely due to the FitBit not being worn.

-- Removing 0 step day rows from the table:

DELETE 
FROM DailyActivity
WHERE TotalSteps = 0;
# Removed 77 rows

-- Updating Boolean values in WeightLogInfo to True/False:

ALTER TABLE WeightLogInfo
ALTER COLUMN IsManualReport varchar(255);
# Changed datatype from boolean to string

UPDATE WeightLogInfo
SET IsManualReport = 'True'
WHERE IsManualReport = '1';
# Changes 1 to True

UPDATE WeightLogInfo
SET IsManualReport = 'False'
WHERE IsManualReport = '0';
# Changes 0 to False

-- Checking length of Id column in DailyActivity to ensure no Id's are longer or less than 10 characters:

SELECT Id
FROM DailyActivity
WHERE LEN(Id) < 10
OR LEN(Id) > 10;
# Returned none

-- Checking length of Id column in WeightLogInfo to ensure no Id's are longer or less than 10 characters:

SELECT Id
FROM WeightLogInfo
WHERE LEN(Id) < 10
OR LEN(Id) > 10;
# Returned none

-- Checking length of Id column in SleepLog to ensure no Id's are longer or less than 10 characters:

SELECT Id
FROM SleepLog
WHERE LEN(Id) < 10
OR LEN(Id) > 10;
# Returned none

-- Left join the 3 tables:

SELECT *
FROM DailyActivity AS d 
LEFT JOIN SleepLog AS s
ON d.ActivityDate = s.SleepDay AND d.Id = s.Id
LEFT JOIN WeightLogInfo AS w
ON s.SleepDay = w.Date AND s.Id = w.Id
ORDER BY d.Id, Date;

-- Comparing time asleep to total steps:

SELECT d.Id, ActivityDate, TotalSteps, TotalMinutesAsleep
FROM DailyActivity AS d
JOIN SleepLog AS s
ON d.Id = s.Id AND ActivityDate = SleepDay

-- Comparing amount of sleep to distance travelled:

SELECT d.Id, ActivityDate, TotalMinutesAsleep, TotalDistance
FROM DailyActivity AS d
JOIN SleepLog AS s
ON d.Id = s.Id AND ActivityDate = SleepDay

-- Convert date format to day of week:

SELECT ActivityDate, DATENAME(weekday, ActivityDate) AS DayOfWeek
FROM DailyActivity;

-- Splitting days into weekdays and weekend days:

SELECT ActivityDate, 
	CASE 
		WHEN DayOfWeek = 'Monday' THEN 'Weekday'
		WHEN DayOfWeek = 'Tuesday' THEN 'Weekday'
		WHEN DayOfWeek = 'Wednesday' THEN 'Weekday'
		WHEN DayOfWeek = 'Thursday' THEN 'Weekday'
		WHEN DayOfWeek = 'Friday' THEN 'Weekday'
		ELSE 'Weekend' 
	END AS WeekType
FROM
	(SELECT *, DATENAME(weekday, ActivityDate) AS DayOfWeek
	FROM DailyActivity) as t;

-- Looking at average time to fall asleep during the week:

SELECT DATENAME(weekday, SleepDay) AS DayOfWeek, AVG(TotalMinutesAsleep) AS AvgMinutesAsleep, AVG(TotalMinutesAsleep / 60) AS AvgHoursAsleep, AVG(TotalTimeInBed - TotalMinutesAsleep) AS AvgTimeToFallAsleep
FROM SleepLog
GROUP BY DATENAME(weekday, SleepDay)
ORDER BY AvgHoursAsleep;

-- Comparing time asleep to sedentary minutes:

SELECT d.Id, TotalMinutesAsleep, SedentaryMinutes
FROM DailyActivity AS d
JOIN SleepLog AS s
ON d.Id = s.Id AND ActivityDate = SleepDay;

-- Calculating average steps, and calories:

SELECT DATENAME(weekday, ActivityDate) AS DayOfWeek, AVG(CAST(TotalSteps as numeric)) AS AvgSteps, AVG(CAST(Calories as numeric)) AS AvgCalories
FROM DailyActivity
GROUP BY DATENAME(weekday, ActivityDate);

-- Looking at total time asleep vs. steps:

SELECT d.Id, TotalMinutesAsleep, TotalSteps
FROM DailyActivity AS d
JOIN SleepLog AS s
ON d.Id = s.Id AND ActivityDate = SleepDay;

-- Looking at day of week vs. average minutes asleep, average hours asleep and average time to fall asleep:

SELECT DATENAME(weekday, ActivityDate) AS DayOfWeek, AVG(CAST(TotalMinutesAsleep / 60 as numeric)) AS AvgHoursAsleep, AVG(CAST(TotalTimeInBed as numeric)) - AVG(CAST(TotalMinutesAsleep as numeric)) AS AvgTimeToFallAsleep
FROM DailyActivity AS d
JOIN SleepLog AS s
ON d.Id = s.Id AND ActivityDate = SleepDay
GROUP BY DATENAME(weekday, ActivityDate);

-- Looking at total minutes asleep vs. sedentary minutes:

SELECT d.Id, TotalMinutesAsleep, SedentaryMinutes
FROM DailyActivity AS d
JOIN SleepLog AS s
ON d.Id = s.Id AND ActivityDate = SleepDay;

-- Looking at day of week vs. average distance and average calories burned:

SELECT DATENAME(weekday, ActivityDate) AS DayOfWeek, AVG(CAST(TotalDistance as numeric)) As AvgDistance, AVG(CAST(Calories as numeric)) AS AvgCaloriesBurned
FROM DailyActivity AS d
JOIN SleepLog AS s
ON d.Id = s.Id AND ActivityDate = SleepDay
GROUP BY DATENAME(weekday, ActivityDate);

-- Looking at distance vs. calories burned:

SELECT TotalDistance, Calories
FROM DailyActivity



