SELECT
	DATENAME(MONTH, ps.AdmittedDate) AS AdmittedMonth
	, COUNT(*) AS [Number Of Patients]
FROM
	dbo.PatientStay ps
GROUP BY
	DATENAME(MONTH, ps.AdmittedDate);


    SELECT
	ps.PatientId
	, ps.Hospital
	, ps.Ward
	, ps.AdmittedDate
	, ps.Tariff
	, COUNT(*) OVER () AS TotalCount
   ,sum(tariff) over () as TotalTariff
	-- create a window over the whole table
FROM
	PatientStay ps
ORDER BY
	ps.PatientId;


 SELECT
    ps.PatientId
    , ps.Hospital
    , ps.Ward
    , ps.AdmittedDate
    , ps.Tariff
    , COUNT(*) OVER () AS TotalCount
  , COUNT(*) OVER (PARTITION BY ps.Hospital) AS HospitalCount -- create a window over those rows with the same hospital as the current row
  , COUNT(*) OVER (PARTITION BY ps.Ward) AS WardCount
  , COUNT(*) OVER (PARTITION BY ps.Hospital , ps.Ward) AS HospitalWardCount
FROM
    PatientStay ps
ORDER BY
    ps.PatientId;
    
    /*
Use case: percentage of all rows in result set and percentage of a group 
*/
 
SELECT

	ps.PatientId
	, ps.Tariff
	, ps.Ward
	, SUM(ps.Tariff) OVER () AS TotalTariff
	, SUM(ps.Tariff) OVER (PARTITION BY ps.Ward) AS WardTariff
	, 100.0 * ps.Tariff / SUM(ps.Tariff) OVER () AS PctOfAllTariff
, 100.0 * ps.Tariff / SUM(ps.Tariff) OVER (PARTITION BY ps.Ward) AS PctOfWardTariff

FROM
	PatientStay ps

ORDER BY
	ps.Ward
	, ps.PatientId;

 

 /*
ROW_NUMBER() is a special function used with Window functions to index rows in a window
It must have a ORDER BY since SQL must know  how to sort rows in each window
*/
SELECT
    ps.PatientId
    , ps.Hospital
    , ps.Ward
    , ps.AdmittedDate
    , ps.Tariff
    , ROW_NUMBER() OVER (ORDER BY ps.PatientId ) AS PatientIndex
  , ROW_NUMBER() OVER (PARTITION BY ps.Hospital ORDER BY ps.PatientId) AS PatientByHospitalIndex
 ,COUNT(*) OVER (PARTITION BY ps.Hospital order by ps.PatientId)  as PatientByHospitalIndexAlt -- An alternative way of indexing
FROM
    PatientStay ps
ORDER BY
    ps.Hospital
    , ps.PatientId;
 
/*
Compare ROW_NUMBER(), RANK() and DENSE_RANK() where there are ties
ROW_NUMBER() will always create a monotonically  increasing sequence 1,2,3,... and arbitrarily choose one tie row over another
RANK() will give all tie rows the same value and the rank of the next row will n higher if there are n tie rows e.g. 1,1,3,...
DENSE_RANK() will give all tie rows the same value and the rank of the next row will one higher e.g. 1,1,2,...
NTILE(10) splits into deciles
*/
 
SELECT
    ps.PatientId
    , ps.Tariff
    ,AdmittedDate
 --   , ROW_NUMBER() OVER (ORDER BY ps.Tariff DESC) AS PatientRowIndex
 -- , RANK() OVER ( ORDER BY ps.Tariff DESC) AS PatientRank
 , DENSE_RANK() OVER (ORDER BY ps.Tariff DESC, AdmittedDate desc) AS PatientDenseRank
-- , NTILE(4) OVER (ORDER BY ps.Tariff DESC) AS PatientIdDecile
FROM
    PatientStay ps
ORDER BY
    ps.Tariff DESC;
 
-- Use Window functions to calculate a cumulative value , or running total
SELECT
    ps.AdmittedDate
    , ps.Tariff
     , ROW_NUMBER() OVER (ORDER BY ps.AdmittedDate) AS RowIndex
     , SUM(ps.Tariff) OVER (ORDER BY ps.AdmittedDate) AS RunningTariff
    , ROW_NUMBER() OVER (PARTITION BY DATENAME(MONTH, ps.AdmittedDate) ORDER BY ps.AdmittedDate) AS MonthIndex
     , SUM(ps.Tariff) OVER (PARTITION BY DATENAME(MONTH, ps.AdmittedDate) ORDER BY ps.AdmittedDate) AS MonthToDateTariff
FROM
    PatientStay ps
WHERE
    ps.Hospital = 'Oxleas'
    AND ps.Ward = 'Dermatology'
ORDER BY
    ps.AdmittedDate;