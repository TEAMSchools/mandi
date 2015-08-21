USE KIPP_NJ
GO

ALTER VIEW GRADES$HW_90_90#Rise#pivot AS

SELECT term
      ,org_unit
      ,[Above]
      ,[Middle]
      ,[Below]      
FROM
    (
     SELECT n.cur_ninety_ninety_status
           ,'Cur term' AS term
           ,CAST(n.grade_level AS VARCHAR) AS org_unit
           ,dbo.GROUP_CONCAT_D(SUBSTRING(s.first_name, 1, 1) + '. ' + s.LAST_NAME, ', ') AS elements
     FROM KIPP_NJ..GRADES$HW_90_90#Rise n WITH(NOLOCK)
     JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
       ON n.studentid = s.id
     GROUP BY n.cur_ninety_ninety_status
             ,n.grade_level
       
     UNION ALL

     SELECT n.cur_ninety_ninety_status
           ,'Cur term' AS term
           ,t.first_name + ' ' + t.last_name AS advisor
           ,dbo.GROUP_CONCAT_D(SUBSTRING(s.first_name, 1, 1) + '. ' + s.LAST_NAME, ', ') AS elements
     FROM KIPP_NJ..GRADES$HW_90_90#Rise n WITH(NOLOCK)
     JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
       ON n.studentid = s.id
     JOIN KIPP_NJ..PS$CC#static cc WITH(NOLOCK)
       ON s.id = cc.STUDENTID
      AND cc.course_number = 'HR'
      AND cc.termid >= KIPP_NJ.dbo.fn_Global_Term_Id()
      AND cc.dateenrolled <= CAST(GETDATE() AS date)
      AND cc.dateleft >= CAST(GETDATE() AS date)
     JOIN KIPP_NJ..PS$SECTIONS#static sect WITH(NOLOCK)
       ON cc.sectionid = sect.id
     JOIN KIPP_NJ..PS$TEACHERS#static t WITH(NOLOCK)
       ON sect.teacher = t.id
     GROUP BY n.cur_ninety_ninety_status
             ,t.first_name + ' ' + t.last_name  
      
     UNION ALL
       
     SELECT n.yr_ninety_ninety_status
           ,'Year' AS term
           ,CAST(n.grade_level AS VARCHAR) AS grade_level
           ,dbo.GROUP_CONCAT_D(SUBSTRING(s.first_name, 1, 1) + '. ' + s.LAST_NAME, ', ') AS elements
     FROM KIPP_NJ..GRADES$HW_90_90#Rise n WITH(NOLOCK)
     JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
       ON n.studentid = s.id
     GROUP BY n.yr_ninety_ninety_status
             ,n.grade_level
       
     UNION ALL

     SELECT n.yr_ninety_ninety_status
           ,'Year' AS term
           ,t.first_name + ' ' + t.last_name AS advisor
           ,dbo.GROUP_CONCAT_D(SUBSTRING(s.first_name, 1, 1) + '. ' + s.LAST_NAME, ', ') AS elements
     FROM KIPP_NJ..GRADES$HW_90_90#Rise n WITH(NOLOCK)
     JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
       ON n.studentid = s.id
     JOIN KIPP_NJ..PS$CC#static cc WITH(NOLOCK)
       ON s.id = cc.STUDENTID
      AND cc.course_number = 'HR'
      AND cc.termid >= dbo.fn_Global_Term_Id()
      AND cc.dateenrolled <= CAST(GETDATE() AS date)
      AND cc.dateleft >= CAST(GETDATE() AS date)
     JOIN KIPP_NJ..PS$SECTIONS#static sect WITH(NOLOCK)
       ON cc.sectionid = sect.id
     JOIN KIPP_NJ..PS$TEACHERS#static t WITH(NOLOCK)
       ON sect.teacher = t.id
     GROUP BY n.yr_ninety_ninety_status
             ,t.first_name + ' ' + t.last_name 
    ) sub
PIVOT(
  MAX(elements)
  FOR cur_ninety_ninety_status IN ([Above]
                                  ,[Middle]
                                  ,[Below])
) AS wat