/* Author: Ryan Ludwigsen (RALUDW02)
   Date: 8/5/2013
   Needs: ID Num. 
   Notes: This query returns values for Theatre Arts majors (HUM, TA, TAS) within a specified
   range of miles from a city. The values include: ID, Person/Org, Status, Full Name and Pref. Name, 
   Record Type, Degree Year, XSeq, Degree Type, Majors, Address index/status, and Address Type.
   
*/  
WITH target_group AS (

select distinct e.id_number
from advance.entity e, advance.address a, advance.zip_city zc, advance.degrees d
where e.id_number = a.id_number
and e.id_number = d.id_number
and e.person_or_org = 'P'
and e.record_status_code = 'A'
AND e.record_type_code in ('AL', 'AD')
and a.addr_status_code = 'A'
and a.addr_pref_ind = 'Y'
AND a.state_code IN (SELECT DISTINCT s.state_code 
                     FROM advance.tms_states s 
                     WHERE s.national_region <> ' '
                     )
and not exists (select distinct 1 from advance.mailing_list ml
                where ml.id_number = e.id_number
                and ml.mail_list_type_code = 'DNE'
                and ml.mail_list_status_code = 'A')
and d.local_ind = 'Y'                
AND (d.major_code1 in ('TAS','TA', 'HUM')
OR (d.major_code2 in ('TAS','TA', 'HUM'))
OR (d.major_code3 in ('TAS','TA', 'HUM')))
AND zc.start_zip = substr(a.zipcode,1,5)
     AND trim(zc.latitude) is not null
     AND trim(zc.longitude) is not null
            /*
            add 5 miles (for padding) to the radius entered and calculate the square miles around center point
            then, calculate radius inside the square (an inscribed circle); reducing the number of zips for radius calculation.
            
            The number 69 was chosen this is the estimated number of miles per degree
            
            SOURCE:  http://www.nationalatlas.gov/articles/mapping/a_latlong.html
            How precise can we be with latitude and longitude?
            Degrees of latitude and longitude can be further subdivided into minutes and seconds: there are 60 minutes (') per degree, 
            and 60 seconds (") per minute. For example, a coordinate might be written 65° 32' 15". Degrees can also be expressed as decimals: 65.5375, 
            degrees and decimal minutes: 65° 32.25', or even degrees, minutes, and decimal seconds: 65° 32' 15.275". All these notations allow us to locate 
            places on the Earth quite precisely – to within inches.
            
            A degree of latitude is approximately 69 miles, and a minute of latitude is approximately 1.15 miles. A second of latitude is approximately 0.02 miles, 
            or just over 100 feezc.
            
            A degree of longitude varies in size. At the equator, it is approximately 69 miles, the same size as a degree of latitude. The size gradually decreases 
            to zero as the meridians converge at the poles. At a latitude of 45 degrees, a degree of longitude is approximately 49 miles. Because a degree of longitude 
            varies in size, minutes and seconds of longitude also vary, decreasing in size towards the poles.
            */
            --minLong , maxLong
            AND zc.longitude BETWEEN (SELECT y.lon - round(((&i_radius + 25)/69),4)
                                     FROM (SELECT ((abs(min(zc.longitude)) - abs(max(zc.longitude)))/2) + min(zc.longitude) lon
                                           FROM advance.zip_city zc
                                           WHERE upper(trim(zc.city)) = upper(trim(&i_city))
                                           AND zc.state = upper(&i_state)) y) 
                            AND (SELECT y.lon + round(((&i_radius + 25)/69),4)
                                     FROM (SELECT ((abs(min(zc.longitude)) - abs(max(zc.longitude)))/2) + min(zc.longitude) lon
                                           FROM advance.zip_city zc
                                           WHERE upper(trim(zc.city)) = upper(trim(&i_city))
                                           AND zc.state = upper(&i_state)) y)
            --minLat , maxLat
            AND zc.latitude BETWEEN (SELECT x1.lat - round(((&i_radius + 25)/69),4)
                                    FROM (SELECT ((max(zc.latitude) - min(zc.latitude))/2) + min(zc.latitude) lat
                                          FROM advance.zip_city zc
                                          WHERE upper(trim(zc.city)) = upper(trim(&i_city))
                                          AND zc.state = upper(&i_state)) x1)
                           AND (SELECT x2.lat + round(((&i_radius + 25)/69),4)
                                    FROM (SELECT ((max(zc.latitude) - min(zc.latitude))/2) + min(zc.latitude) lat
                                          FROM advance.zip_city zc
                                          WHERE upper(trim(zc.city)) = upper(trim(&i_city))
                                          AND zc.state = upper(&i_state)) x2)
            AND round(advance.zz_distance((SELECT x.lat
                                              FROM (SELECT ((max(zc.latitude) - min(zc.latitude))/2) + min(zc.latitude) lat
                                                    FROM advance.zip_city zc
                                                    WHERE upper(trim(zc.city)) = upper(trim(&i_city))
                                                    AND zc.state = upper(&i_state)) x),
                                             (SELECT y.lon
                                              FROM (SELECT ((abs(min(zc.longitude)) - abs(max(zc.longitude)))/2) + min(zc.longitude) lon
                                                    FROM advance.zip_city zc
                                                    WHERE upper(trim(zc.city)) = upper(trim(&i_city))
                                                    AND zc.state = upper(&i_state)) y),
                                             zc.latitude,zc.longitude),0) <= &i_radius
),
TA_degrees AS ( 
SELECT d1.id_number, d1.degree_year, d1.xsequence, count(*) over (partition by d1.id_number order by d1.degree_year,rownum) r1
FROM advance.degrees d1 
WHERE d1.local_ind = 'Y' 
AND d1.id_number IN (SELECT DISTINCT id_number FROM target_group) 
AND (d1.major_code1 in ('TAS','TA', 'HUM') or
     d1.major_code2 in ('TAS','TA', 'HUM') or
      d1.major_code3 in ('TAS','TA', 'HUM'))
ORDER BY d1.id_number, d1.degree_year 
)
select distinct e.id_number
, e.person_or_org
, e.record_status_code
, e.prefix
, e.first_name
, e.middle_name
, e.last_name
, e.pers_suffix
, e.prof_suffix
, e.pref_mail_name
, e.record_type_code
, (select max(d2.degree_year)
   from advance.degrees d2
   where d2.local_ind = 'Y'
   and d2.id_number = e.id_number
   and d2.degree_level_code not in ('Y', 'N')
   AND (d2.major_code1 in ('TAS','TA', 'HUM')
   OR (d2.major_code2 in ('TAS','TA', 'HUM'))
   OR (d2.major_code3 in ('TAS','TA', 'HUM')))) degree_year
, (select max(d3.xsequence)
   from advance.degrees d3
   where d3.local_ind = 'Y'
   and d3.id_number = e.id_number
   and d3.degree_level_code not in ('Y', 'N')
   AND (d3.major_code1 in ('TAS','TA', 'HUM')
   OR (d3.major_code2 in ('TAS','TA', 'HUM'))
   OR (d3.major_code3 in ('TAS','TA', 'HUM')))) x_seq
, (select max(d3.major_code1)
   from advance.degrees d3
   where d3.local_ind = 'Y'
   and d3.id_number = e.id_number
   and d3.degree_level_code not in ('Y', 'N')
   AND (d3.major_code1 in ('TAS','TA', 'HUM')
   OR (d3.major_code2 in ('TAS','TA', 'HUM'))
   OR (d3.major_code3 in ('TAS','TA', 'HUM')))) Major  
, d.major_code1
, d.major_code2
, d.major_code3                
, d.degree_type                                                                                                
, a.addr_pref_ind
, a.addr_status_code
, a.addr_type_code

from advance.entity e, advance.address a, target_group tg, advance.degrees d
where tg.id_number = e.id_number 
and e.id_number = a.id_number 
and e.id_number = d.id_number  
and e.person_or_org = 'P'
and e.record_status_code = 'A'
AND e.record_type_code IN ('AL', 'AD')
and a.addr_status_code = 'A'
and a.addr_pref_ind = 'Y'
AND a.state_code IN (SELECT DISTINCT s.state_code 
                     FROM advance.tms_states s 
                     WHERE s.national_region <> ' '
                     )
and not exists (select distinct 1 from advance.mailing_list ml
                where ml.id_number = e.id_number
                and ml.mail_list_type_code = 'DNE'
                and ml.mail_list_status_code = 'A')
and d.local_ind = 'Y'
and d.degree_year = (select max(ta.degree_year) from TA_degrees ta where tg.id_number = ta.id_number)                
AND (d.major_code1 in ('TAS','TA', 'HUM')
OR (d.major_code2 in ('TAS','TA', 'HUM'))
OR (d.major_code3 in ('TAS','TA', 'HUM')))
order by e.last_name, e.first_name


     

 
