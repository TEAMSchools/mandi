--OPENQUERY of materialized view on Oracle
--source code commented out at bottom

USE KIPP_NJ
GO

ALTER VIEW PS$CUSTOM_STUDENTS AS
SELECT *
FROM
    (SELECT openq.*
          ,ROW_NUMBER() OVER
                 (PARTITION BY studentid
                  ORDER BY studentid) AS rn
    FROM OPENQUERY(KIPP_NWK,'
         SELECT *           
         FROM CUSTOM_STUDENTS
         ')openq
    )sub
WHERE rn = 1

/*
CREATE MATERIALIZED VIEW CUSTOM_STUDENTS
NOCACHE 
NOPARALLEL 
BUILD IMMEDIATE 
USING INDEX 
REFRESH NEXT SYSDATE + (30/(24*60)) COMPLETE 
DISABLE QUERY REWRITE AS
select s.id as studentid
      ,pvcs_SID.string_value   as SID
      ,pvcs_adv.string_value   as advisor
      ,pvcs_adv_e.string_value as advisor_email
      ,pvcs_adv_c.string_value as advisor_cell
      ,pvcs_sped.string_value  as SPEDLEP
      ,pvcs_mom_c.string_value as mother_cell
      ,pvcs_mom_d.string_value as mother_day
      ,pvcs_mom_h.string_value as mother_home
      ,pvcs_dad_c.string_value as father_cell
      ,pvcs_dad_d.string_value as father_day
      ,pvcs_dad_h.string_value as father_home
<<<<<<< HEAD
      ,pvcs_LS.string_value as lunch_status_1112
=======
      ,pvcs_LS.string_value    AS lunch_status_1112
      ,pvcs_LB.string_value    AS lunch_balance

>>>>>>> 11d7c29d1f6ef047cead01b113ed0a57f8616977
from students@PS_TEAM s
left outer join PVSIS_CUSTOM_STUDENTS@PS_TEAM pvcs_adv   on s.id = pvcs_adv.studentid   and pvcs_adv.field_name   = 'Advisor'
left outer join PVSIS_CUSTOM_STUDENTS@PS_TEAM pvcs_adv_e on s.id = pvcs_adv_e.studentid and pvcs_adv_e.field_name = 'Advisor_Email'
left outer join PVSIS_CUSTOM_STUDENTS@PS_TEAM pvcs_adv_c on s.id = pvcs_adv_c.studentid and pvcs_adv_c.field_name = 'Advisor_Cell'
left outer join PVSIS_CUSTOM_STUDENTS@PS_TEAM pvcs_sped  on s.id = pvcs_sped.studentid  and pvcs_sped.field_name  = 'SPEDLEP'
left outer join PVSIS_CUSTOM_STUDENTS@PS_TEAM pvcs_LS    on s.id = pvcs_LS.studentid    and pvcs_LS.field_name    = 'Lunch_Status_1112'
left outer join PVSIS_CUSTOM_STUDENTS@PS_TEAM pvcs_mom_c on s.id = pvcs_mom_c.studentid and pvcs_mom_c.field_name = 'Mother_Cell'
left outer join PVSIS_CUSTOM_STUDENTS@PS_TEAM pvcs_mom_d on s.id = pvcs_mom_d.studentid and pvcs_mom_d.field_name = 'motherdayphone'
left outer join PVSIS_CUSTOM_STUDENTS@PS_TEAM pvcs_mom_h on s.id = pvcs_mom_h.studentid and pvcs_mom_h.field_name = 'Mother_home_phone'
left outer join PVSIS_CUSTOM_STUDENTS@PS_TEAM pvcs_dad_c on s.id = pvcs_dad_c.studentid and pvcs_dad_c.field_name = 'Father_Cell'
left outer join PVSIS_CUSTOM_STUDENTS@PS_TEAM pvcs_dad_d on s.id = pvcs_dad_d.studentid and pvcs_dad_d.field_name = 'fatherdayphone'
left outer join PVSIS_CUSTOM_STUDENTS@PS_TEAM pvcs_dad_h on s.id = pvcs_dad_h.studentid and pvcs_dad_h.field_name = 'Father_home_phone'
left outer join PVSIS_CUSTOM_STUDENTS@PS_TEAM pvcs_SID on s.id = pvcs_SID.studentid and pvcs_SID.field_name = 'SID'
LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS@PS_TEAM pvcs_LS  ON s.id = pvcs_LS.studentid AND pvcs_LS.field_name = 'Lunch_Status_1112'
LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS@PS_TEAM pvcs_LB  ON s.id = pvcs_LB.studentid AND pvcs_LB.field_name = 'Lunch_Balance'
*/