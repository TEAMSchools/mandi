USE KIPP_NJ
GO

ALTER VIEW ROSTERS$PS_staff AS

WITH managers AS (
  SELECT DISTINCT reports_to_position_id
  FROM KIPP_NJ..PEOPLE$ADP_detail WITH(NOLOCK)
  WHERE rn_curr = 1
    AND location NOT IN ('KIPP NJ', 'Room 9', 'TEAM Schools')    
    AND job_title NOT IN ('Custodian', 'Food Service Worker', 'Security', 'Intern')
    AND reports_to_position_id IS NOT NULL
 )

,current_teachers AS (
  SELECT CONVERT(VARCHAR,TEACHERNUMBER) AS TEACHERNUMBER
        ,SCHOOLID
        ,CASE WHEN homeschoolid = 999999 THEN 0 ELSE HOMESCHOOLID END AS homeschoolid
  FROM KIPP_NJ..PS$TEACHERS#static WITH(NOLOCK)  
 )

SELECT sub.teachernumber
      ,sub.first_name
      ,sub.last_name
      ,CASE WHEN sub.status = 1 THEN sub.loginid ELSE '' END AS loginid
      ,CASE WHEN sub.status = 1 THEN sub.teacherloginid ELSE '' END AS teacherloginid
      ,sub.email_addr      
      ,CONVERT(INT,COALESCE(t.schoolid,sub.homeschoolid,0)) AS schoolid -- temp fix until we clean up ADP
      ,CONVERT(INT,COALESCE(t.homeschoolid,sub.homeschoolid,0)) AS homeschoolid -- temp fix until we clean up ADP
      ,sub.status      
      ,CASE WHEN sub.status = 1 THEN 1 ELSE 0 END AS teacherldapenabled
      ,CASE WHEN sub.status = 1 THEN 1 ELSE 0 END AS adminldapenabled      
      ,CASE WHEN sub.status = 1 THEN 1 ELSE 0 END AS ptaccess      
      /* OFF UNTIL WE CLEAN UP ADP
      ,staffstatus      
      ,[group]      
      ,psaccess
      ,CASE WHEN ptaccess = 1 THEN 1 ELSE 0 END AS teacherldapenabled
      ,CASE WHEN psaccess = 1 THEN 1 ELSE 0 END AS adminldapenabled      
      ,CASE WHEN [group] = 8 THEN (SELECT KIPP_NJ.dbo.GROUP_CONCAT_D(DISTINCT schoolid, '; ') FROM KIPP_NJ..STUDENTS WITH(NOLOCK)) ELSE NULL END AS canchangeschool
      --*/
FROM
    (
     SELECT COALESCE(LTRIM(RTRIM(STR(link.TEACHERNUMBER))), adp.[associate_id]) AS teachernumber           
           ,adp.preferred_first AS first_name
           ,adp.preferred_last AS last_name
           ,ISNULL(LOWER(dir.sAMAccountName),'') AS loginid
           ,ISNULL(LOWER(dir.sAMAccountName),'') AS teacherloginid
           ,ISNULL(LOWER(dir.mail),'') AS email_addr      
           ,CASE
             WHEN adp.location_code IS NULL THEN 0
             WHEN adp.location_code = 1 THEN 133570965
             WHEN adp.location_code = 2 THEN 0
             WHEN adp.location_code = 4 THEN 73254
             WHEN adp.location_code = 5 THEN 73252
             WHEN adp.location_code = 7 THEN 73253
             WHEN adp.location_code = 8 THEN 73255
             WHEN adp.location_code = 9 THEN 73256
             WHEN adp.location_code = 10 THEN 73257
             WHEN adp.location_code = 11 THEN 73257
             WHEN adp.location_code = 12 THEN 179901
             WHEN adp.location_code = 13 THEN 0
             WHEN adp.location_code = 14 THEN 0
             WHEN adp.location_code = 15 THEN 73258
             WHEN adp.location_code = 16 THEN 179902
             WHEN adp.location_code = 17 THEN 179903
             WHEN adp.location_code = 18 THEN 179901
            END AS homeschoolid      
           ,CASE
             WHEN adp.position_status = 'Terminated' THEN 1
             WHEN link.is_master = 0 THEN 1
             --WHEN adp.employee_type = 'Intern' OR adp.job_title = 'Intern' THEN 12
             WHEN adp.department_code IN ('DATAAN') THEN 8 -- data team
             WHEN adp.department = 'R9 IT' THEN 8 -- tech team
             WHEN adp.job_title IN ('Registrar') THEN 4  
             WHEN adp.job_title IN ('Case Manager Assistant',	'Social Worker') THEN 11
             WHEN adp.job_title LIKE '%Nurse%' THEN 14
             -- ops roles
             WHEN adp.job_title IN ('Aide - Non-Instructional','Assistant School Leader','Dean of Instruction','Dean of Students','Director of School Operations','Office Manager'
                                   ,'Regional Literacy Coach','School Leader')              
                  OR adp.department IN ('R9 School Ops','College Placement','Enrollment')
                  OR adp.department LIKE '%Alumni Support%'
                  OR adp.position_id IN (SELECT reports_to_position_id FROM managers) THEN 9
             /* instructional staff */
             WHEN adp.job_title IN ('Paraprofessional',	'Aide - Instructional',	'Fellow',	'Learning Specialist',	'Teacher') OR adp.benefits_elig_class NOT LIKE '%Non-Instructional%' THEN 5
             ELSE 1
            END AS [group]
           ,CASE
             WHEN adp.termination_date < CONVERT(DATE,GETDATE()) THEN 2
             ----WHEN adp.position_status = 'Terminated' THEN 2
             WHEN link.is_master = 0 THEN 2
             WHEN adp.job_title = 'Intern' THEN 2 --OR adp.employee_type = 'Intern'
             WHEN adp.position_status IN ('Active','Leave') OR adp.termination_date >= CONVERT(DATE,GETDATE()) THEN 1
             /* OFF UNTIL ADP GETS CLEANED UP             
             WHEN adp.job_title IN ('Registrar','Case Manager Assistant','Social Worker','Aide - Non-Instructional','Assistant School Leader','Dean of Instruction','Dean of Students'
                                   ,'Director of School Operations','Office Manager','Regional Literacy Coach','School Leader','Paraprofessional','Aide - Instructional'
                                   ,'Fellow','Learning Specialist','Teacher')
                  OR adp.job_title LIKE '%Nurse%'
                  OR adp.department LIKE '%Alumni Support%'                   
                  OR adp.department_code IN ('DATAAN') 
                  OR adp.department IN ('R9 School Ops','College Placement','Enrollment','R9 IT')
                  OR adp.benefits_elig_class NOT LIKE '%Non-Instructional%' 
                  OR adp.position_id IN (SELECT reports_to_position_id FROM managers)
                  THEN 1        
             */
             ELSE 2
            END AS [status]
           ,CASE
             WHEN adp.position_status = 'Terminated' THEN 0
             WHEN link.is_master = 0 THEN 0
             WHEN adp.job_title IN ('Registrar','Case Manager Assistant','Social Worker','Aide - Non-Instructional','Assistant School Leader','Dean of Instruction','Dean of Students'
                                   ,'Director of School Operations','Office Manager','Regional Literacy Coach','School Leader','Intern','Paraprofessional','Aide - Instructional')
                  OR adp.job_title LIKE '%Nurse%'
                  OR adp.department LIKE '%Alumni Support%' 
                  --OR adp.employee_type = 'Intern'
                  OR adp.department_code IN ('DATAAN') 
                  OR adp.department IN ('R9 School Ops','College Placement','Enrollment','R9 IT')                  
                  OR adp.position_id IN (SELECT reports_to_position_id FROM managers)
                  THEN 2             
             WHEN adp.job_title IN ('Fellow',	'Learning Specialist',	'Teacher') OR adp.benefits_elig_class NOT LIKE '%Non-Instructional%' THEN 1
             ELSE 0
            END AS staffstatus
           ,CASE
             WHEN adp.position_status = 'Terminated' THEN 0
             WHEN link.is_master = 0 THEN 0
             WHEN adp.job_title = 'Intern' --OR adp.employee_type = 'Intern'
                    THEN 0
             WHEN adp.department_code IN ('DATAAN') THEN 1 -- data team
             WHEN adp.department = 'R9 IT' THEN 1 -- tech team
             WHEN adp.job_title IN ('Registrar') THEN 0
             WHEN adp.job_title IN ('Case Manager Assistant',	'Social Worker') THEN 1
             WHEN adp.job_title LIKE '%Nurse%' THEN 0
             /* ops roles */
             WHEN adp.department IN ('R9 School Ops','College Placement','Enrollment') THEN 1
             WHEN adp.job_title IN ('Aide - Non-Instructional','Assistant School Leader','Dean of Instruction','Dean of Students','Director of School Operations','Office Manager'
                                   ,'Regional Literacy Coach','School Leader')              
                  OR adp.department LIKE '%Alumni Support%'
                  OR adp.position_id IN (SELECT reports_to_position_id FROM managers) THEN 0
             /* instructional staff */
             WHEN adp.job_title IN ('Paraprofessional',	'Aide - Instructional',	'Fellow',	'Learning Specialist',	'Teacher') OR adp.benefits_elig_class NOT LIKE '%Non-Instructional%' THEN 1
             ELSE 0
            END AS ptaccess
           ,CASE
             /* allow */
             WHEN adp.department_code IN ('DATAAN','002004','COLPLC','ENROLL','002003','ALUSPT','002008') THEN 1 /* data, tech, R9 ops, enrollment, KTC */
             WHEN adp.position_id IN (SELECT reports_to_position_id FROM managers) THEN 1 /* managers */
             WHEN adp.job_title IN ('Registrar' /* specific positions */
                                   ,'Case Manager Assistant'
                                   ,'Social Worker'
                                   ,'Aide - Non-Instructional'
                                   ,'Assistant School Leader'
                                   ,'Dean of Instruction'
                                   ,'Dean of Students'
                                   ,'Director of School Operations'
                                   ,'Office Manager'
                                   ,'Regional Literacy Coach'
                                   ,'School Leader'
                                   ,'Nurse'
                                   ,'School Nurse Coordinator')
                                   THEN 1
             /* deny */
             WHEN adp.position_status = 'Terminated' /* terminated */
                  OR link.is_master = 0 /* dupes */
                  OR adp.job_title = 'Intern' --OR adp.employee_type = 'Intern' /* interns */
                  OR adp.job_title IN ('Paraprofessional',	'Aide - Instructional',	'Fellow',	'Learning Specialist',	'Teacher') /* instructional staff */ 
                  THEN 0
             ELSE 0
            END AS psaccess
           /* -- auditing 
           ,link.is_master
           ,adp.position_status
           ,adp.[department]      
           ,adp.[job_title]            
           --,adp.[employee_type]
           ,adp.[benefits_elig_class]                  
           -- */           
     FROM [KIPP_NJ].[dbo].[PEOPLE$ADP_detail] adp WITH(NOLOCK)
     JOIN [KIPP_NJ].[dbo].[PEOPLE$AD_users#static] dir WITH(NOLOCK)
       ON adp.position_id = dir.employeenumber
      AND dir.is_active = 1
     LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_PEOPLE_teachernumber_associateid_link link WITH(NOLOCK)
       ON adp.associate_id = link.associate_id
     WHERE adp.rn_curr = 1     
       AND adp.associate_id NOT IN ('OJOCGAWIL','B8IZPXIOF','CLB53DM3M') /* data team */       
    ) sub
LEFT OUTER JOIN current_teachers t WITH(NOLOCK)
  ON sub.teachernumber = t.TEACHERNUMBER