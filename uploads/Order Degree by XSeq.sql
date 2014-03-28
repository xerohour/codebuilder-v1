/* Temporarily orders the degrees so that they can be selected by max values. 
*/
,
TA_degrees AS ( 
SELECT d1.id_number, d1.degree_year, d1.xsequence, count(*) over (partition by d1.id_number order by d1.degree_year,rownum) r1
FROM advance.degrees d1 
WHERE d1.local_ind = 'Y' 
AND d1.id_number IN (SELECT DISTINCT id_number FROM target_group) 
AND (d1.major_code1 in ('TAS','TA', 'HUM') or
     d1.major_code2 in ('TAS','TA', 'HUM') or
      d1.major_code3 in ('TAS','TA', 'HUM'))
ORDER BY d1.id_number, d1.degree_year 

/* Use in conjunction with this in the where clause.
*/
and d.degree_year = (select max(ta.degree_year) from TA_degrees ta where tg.id_number = ta.id_number)
