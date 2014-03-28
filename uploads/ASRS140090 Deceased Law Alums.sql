/* Author: Ryan Ludwigsen (RALUDW02)
   Date: 7/30/2013
   Needs: Name, LAW school, and Grad Year
   Notes: See if we have a consistant death report out there, otherwise,
   continue using the record status code. All ids are unique.
*/
WITH target_group AS (
    SELECT DISTINCT e.id_number
    from advance.entity e, advance.degrees d
    WHERE e.record_status_code in ('D', 'A')
    and e.id_number = d.id_number
    and e.record_type_code = 'AL'
    and d.local_ind = 'Y'
    and d.school_code = 'LA'
)                   
SELECT distinct e.id_number
, e.record_status_code
, e.record_type_code
, e.prefix
, e.first_name
, e.middle_name
, e.last_name
, e.pers_suffix
, e.prof_suffix
, e.pref_mail_name
, d.school_code
, d.degree_type
, e.pref_class_year
, e.death_confirmed_date
, d.degree_year
FROM advance.entity e, advance.address a, target_group tg, advance.degrees d
WHERE e.id_number = tg.id_number
and a.id_number = e.id_number
and e.id_number = d.id_number
and a.addr_pref_ind = 'Y'
and d.school_code = 'LA'
and d.degree_type in ('G', 'P')
AND e.record_type_code NOT LIKE 'E%'
and e.death_confirmed_date between to_date('2012/06/30', 'yyyy/mm/dd') 
                           and to_date('2013/07/01', 'yyyy/mm/dd')
group by e.id_number
, e.record_status_code
, e.record_type_code
, e.prefix
, e.first_name
, e.middle_name
, e.last_name
, e.pers_suffix
, e.prof_suffix
, e.pref_mail_name
, d.school_code
, d.degree_type
, e.pref_class_year
, e.death_confirmed_date
, d.degree_year
order by e.last_name, e.first_name

