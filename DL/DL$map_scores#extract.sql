SELECT map.student_number
      ,map.test_year
      ,map.term AS map_term
      ,map.MeasurementScale AS map_subject
      ,map.percentile_2011_norms AS map_percentile
      ,map.testritscore AS map_ritscore
FROM KIPP_NJ..MAP$CDF#identifiers#static map WITH(NOLOCK)
JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  ON map.student_number = s.student_number
 AND s.ENROLL_STATUS = 0