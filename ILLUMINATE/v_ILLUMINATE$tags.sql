USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$tags AS

SELECT *
FROM OPENQUERY(ILLUMINATE,'
  SELECT tagid.assessment_id
        ,t.tag
  FROM dna_assessments.tags t
  LEFT OUTER JOIN dna_assessments.assessments_tags tagid
    ON t.tag_id = tagid.tag_id
')