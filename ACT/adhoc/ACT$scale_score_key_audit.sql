SELECT *
FROM
    (
     SELECT academic_year
           ,grade_level
           ,administration_round
           ,subject
           ,MAX(raw_score) + 1 AS max_score_adjusted
           ,COUNT(subject) AS N_records
     FROM KIPP_NJ..AUTOLOAD$GDOCS_ACT_scale_score_key
     GROUP BY academic_year
             ,grade_level
             ,administration_round
             ,subject
    ) sub
WHERE (max_score_adjusted != N_records) OR (RIGHT(max_score_adjusted,1) NOT IN (1,6))