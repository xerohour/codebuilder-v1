WITH target_group AS (

SELECT DISTINCT e.id_number
FROM advance.entity e, advance.address a
WHERE NOT EXISTS (SELECT DISTINCT 1
                  FROM advance.mailing_list ml
                  WHERE ml.id_number = e.id_number AND
                  ml.mail_list_type_code IN ('DNM') AND
                  ml.mail_list_status_code = 'A')
AND e.record_status_code = 'A'
AND e.id_number = a.id_number
AND a.addr_status_code = 'A'
AND a.addr_pref_ind = 'Y'
AND a.state_code IN (SELECT DISTINCT s.state_code FROM advance.tms_states s WHERE s.state_code = 'KY')
and a.city = 'Frankfort'

)