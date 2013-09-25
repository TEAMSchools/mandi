USE KIPP_NJ
GO

ALTER VIEW PS$CUSTOM_STUDENTS AS
SELECT DISTINCT *
FROM OPENQUERY(PS_TEAM,'
       SELECT s.id AS studentid
             ,DBMS_LOB.SUBSTR(s.guardianemail,2000,1) AS guardianemail
             ,pvcs_SID.string_value   AS SID
             ,pvcs_adv.string_value   AS advisor
             ,pvcs_adv_e.string_value AS advisor_email
             ,pvcs_adv_c.string_value AS advisor_cell
             ,pvcs_sped.string_value  AS SPEDLEP
             ,pvcs_mom_c.string_value AS mother_cell
             ,pvcs_mom_d.string_value AS mother_day
             ,pvcs_mom_h.string_value AS mother_home
             ,pvcs_dad_c.string_value AS father_cell
             ,pvcs_dad_d.string_value AS father_day
             ,pvcs_dad_h.string_value AS father_home      
             ,pvcs_LS.string_value    AS lunch_status_1112
             ,pvcs_LB.string_value    AS lunch_balance
       FROM STUDENTS s
       LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_adv   ON s.id = pvcs_adv.studentid   AND pvcs_adv.field_name   = ''Advisor''
       LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_adv_e ON s.id = pvcs_adv_e.studentid AND pvcs_adv_e.field_name = ''Advisor_Email''
       LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_adv_c ON s.id = pvcs_adv_c.studentid AND pvcs_adv_c.field_name = ''Advisor_Cell''
       LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_sped  ON s.id = pvcs_sped.studentid  AND pvcs_sped.field_name  = ''SPEDLEP''
       LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_mom_c ON s.id = pvcs_mom_c.studentid AND pvcs_mom_c.field_name = ''Mother_Cell''
       LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_mom_d ON s.id = pvcs_mom_d.studentid AND pvcs_mom_d.field_name = ''motherdayphone''
       LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_mom_h ON s.id = pvcs_mom_h.studentid AND pvcs_mom_h.field_name = ''Mother_home_phone''
       LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_dad_c ON s.id = pvcs_dad_c.studentid AND pvcs_dad_c.field_name = ''Father_Cell''
       LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_dad_d ON s.id = pvcs_dad_d.studentid AND pvcs_dad_d.field_name = ''fatherdayphone''
       LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_dad_h ON s.id = pvcs_dad_h.studentid AND pvcs_dad_h.field_name = ''Father_home_phone''
       LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_SID   ON s.id = pvcs_SID.studentid   AND pvcs_SID.field_name   = ''SID''
       LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_LS    ON s.id = pvcs_LS.studentid    AND pvcs_LS.field_name    = ''Lunch_Status_1112''
       LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_LB    ON s.id = pvcs_LB.studentid    AND pvcs_LB.field_name    = ''Lunch_Balance''
       WHERE s.enroll_status = 0
       ')