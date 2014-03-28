/* Author: Ryan Ludwigsen (RALUDW02)
   Date: 10/2/2013
   Needs: ID# (donor/sps/ent), Name (pref), Address, [Usuals], Phone,
   Pref School, DNM/DNS, Date of giving, Value, Type, Allocation 
   Notes: Returns all information of people who have bequeathed money
   to a specified school (fund -- &i_school).
      ***Only living people though. Not entirely sure how to get the
      dead ones yet. Check ulp_pg_gifts_by_unit or ulp_load_conn_society 
*/

WITH target_group AS (
    SELECT DISTINCT e.id_number
    FROM advance.entity e, advance.address a
    WHERE NOT EXISTS (SELECT DISTINCT 1
                     FROM advance.mailing_list ml
                     WHERE ml.id_number = e.id_number AND
                     ml.mail_list_type_code IN ('DNM','N') AND
                     ml.mail_list_status_code = 'A')
    AND a.id_number = e.id_number
    AND a.addr_pref_ind = 'Y'
    AND a.addr_status_code = 'A'

 ), join_ids AS(
SELECT tg.id_number ,e.record_type_code,e.gender_code,e.spouse_id_number,tgs.id_number sp_id,sps.record_type_code sp_code,sps.gender_code sp_gender
,CASE
  WHEN sps.id_number IS NULL THEN  tg.id_number
  WHEN e.record_type_code     IN ('AL','AD','AS') AND sps.record_type_code NOT IN ('AL','AD','AS')THEN tg.id_number||sps.id_number
  WHEN e.record_type_code NOT IN ('AL','AD','AS') AND sps.record_type_code IN ('AL','AD','AS') THEN sps.id_number || tg.id_number
  WHEN e.gender_code = 'F' AND sps.gender_code = 'M' THEN tg.id_number || sps.id_number
  WHEN e.gender_code = 'M' AND sps.gender_code = 'F' THEN sps.id_number || tg.id_number
  WHEN e.gender_code = sps.gender_code OR e.gender_code NOT IN ('M ','F') OR sps.gender_code NOT IN ('M ','F')THEN
             (SELECT distinct
               CASE
                 WHEN e1.last_name < spe.last_name THEN e1.id_number ||spe.id_number
                 WHEN e1.last_name = spe.last_name AND e1.first_name < spe.first_name THEN e1.id_number ||spe.id_number
                 WHEN e1.last_name = spe.last_name AND e1.first_name = spe.first_name AND e1.id_number < spe.id_number THEN e1.id_number || spe.id_number
                 ELSE spe.id_number ||e1.id_number
                END joinid
                FROM advance.entity e1, target_group tg1, advance.entity spe
                WHERE e1.id_number =tg1.id_number
                AND e1.spouse_id_number =spe.id_number
                AND (e1.gender_code = spe.gender_code
                      OR e1.gender_code NOT IN ('M ','F')
                      OR spe.gender_code NOT IN('M ','F'))
                AND tg1.id_number = tg.id_number )
   END  joint_id
FROM target_group tg, advance.entity e,target_group tgs, advance.entity sps
WHERE tg.id_number = e.id_number
AND e.spouse_id_number = tgs.id_number(+)
AND tgs.id_number = sps.id_number(+)

), base_pg as (
select g.gift_donor_id donor_id
, g.gift_receipt_number receipt
, g.gift_transaction_type transx 
, pg.prim_gift_amount amount
, 'Paid' status
, pg.prim_gift_date_of_record dor
, g.gift_associated_allocation allocation
, g.gift_associated_purpose purpose
, pg.proposal_id proposal_id
from advance.gift g, advance.ultemp_sch2fund f, advance.primary_gift pg
where g.gift_transaction_type ='OB' --Bequeathed gift
and g.gift_associated_code = 'P'
and g.gift_receipt_number = pg.prim_gift_receipt_number
and g.gift_associated_fund_name = f.fund_code
and f.college_code = &i_school
union
select p.pledge_donor_id donor_id
, p.pledge_pledge_number receipt
, p.pledge_pledge_type tranx
, decode(pp.prim_pledge_status, 'W', pp.prim_pledge_amount_paid,
          decode(pp.discounted_amt, 0, pp.prim_pledge_amount, pp.discounted_amt)) amount
,(select tps.short_desc
         from advance.tms_pledge_status tps
         where tps.pledge_status_code = pp.prim_pledge_status) status
, pp.prim_pledge_date_of_record dor
, p.pledge_allocation_name allocation
, p.pledge_purpose purpose
, pp.proposal_id proposal_id
from advance.pledge p, advance.ultemp_sch2fund f, advance.primary_pledge pp
where p.pledge_pledge_type = 'B' --Bequeathed pledge
and p.pledge_associated_code = 'P'
and pp.prim_pledge_number = p.pledge_pledge_number
and p.pledge_fund_name = f.fund_code
and f.college_code = &i_school 
)
SELECT b.donor_id
, e.id_number
, tg.joint_id
, decode(e.record_status_code,
         'D',e.pref_mail_name || ' (decd)',e.pref_mail_name) donor_name
, b.dor xdate
, b.amount xvalue
, decode(b.transx,
         'OB','Bequest (outright)',
         'B','Bequest (pledge)') xtype
, (select aloc.short_name
          from advance.allocation aloc
          where aloc.allocation_code = b.allocation) xfor
, e.record_status_code
, e.record_type_code
, e.prefix
, e.first_name
, e.middle_name
, e.last_name
, e.pers_suffix
, e.prof_suffix
, e.pref_mail_name
, a.addr_pref_ind
, a.addr_status_code
, a.addr_type_code
, a.street1
, a.street2
, a.city
, a.state_code
, a.zipcode
, substr(tg.joint_id,11,10) spouse_id_number
, (SELECT ent.record_status_code
   FROM advance.entity ent
   WHERE ent.id_number = substr(tg.joint_id,11,10)) spouse_record_status_code
, (SELECT ent.record_type_code
   FROM advance.entity ent
   WHERE ent.id_number = substr(tg.joint_id,11,10)) spouse_record_type_code
, (SELECT ent.prefix
   FROM advance.entity ent
   WHERE ent.id_number = substr(tg.joint_id,11,10)) spouse_prefix
, (SELECT ent.first_name
   FROM advance.entity ent
   WHERE ent.id_number = substr(tg.joint_id,11,10)) spouse_first_name
, (SELECT ent.middle_name
   FROM advance.entity ent
   WHERE ent.id_number = substr(tg.joint_id,11,10)) spouse_middle_name
, (SELECT ent.last_name
   FROM advance.entity ent
   WHERE ent.id_number = substr(tg.joint_id,11,10)) spouse_last_name
, (SELECT ent.pers_suffix
   FROM advance.entity ent
   WHERE ent.id_number = substr(tg.joint_id,11,10)) spouse_pers_suffix
, (SELECT ent.prof_suffix
   FROM advance.entity ent
   WHERE ent.id_number = substr(tg.joint_id,11,10)) spouse_prof_suffix
, (SELECT ent.pref_mail_name
   FROM advance.entity ent
   WHERE ent.id_number = substr(tg.joint_id,11,10)) spouse_pref_mail_name
, (SELECT ent.pref_school_code
   FROM advance.entity ent
   WHERE ent.id_number = substr(tg.joint_id,11,10)) spouse_pref_school_code
, (SELECT ent.pref_class_year
   FROM advance.entity ent
   WHERE ent.id_number = substr(tg.joint_id,11,10)) spouse_pref_class_year
, advance.ulf_format_phone_full(t.area_code,t.telephone_number,t.extension) phone
, advance.ulf_dnm(tg.joint_id) do_not_mail
, advance.ulf_get_all_dns(tg.joint_id) solitication_codes
, e.pref_class_year
, e.pref_school_code
FROM advance.entity e, advance.address a, join_ids tg, advance.telephone t, base_pg b             
WHERE substr(tg.joint_id,1,10) = tg.id_number
AND tg.id_number = e.id_number
AND a.id_number = e.id_number
and e.id_number = b.donor_id
AND a.addr_pref_ind = 'Y'
AND a.addr_status_code = 'A'
AND e.id_number = t.id_number(+)
AND t.telephone_status_code(+) = 'A'
AND t.preferred_ind(+) = 'Y'
AND e.record_type_code NOT LIKE 'E%'
AND a.state_code IN (SELECT ts.state_code FROM advance.tms_states ts WHERE ts.national_region <> ' ')
order by e.last_name, e.first_name
        
