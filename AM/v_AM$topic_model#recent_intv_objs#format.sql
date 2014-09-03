USE RutgersReady
GO

ALTER VIEW AM$topic_model#recent_intv_objs#format AS
SELECT studentid
      ,stu_name
      ,lastfirst
      ,year
      ,grade
      ,school
      ,dgradelevel
      ,lda_k
      ,topic_bin
      ,bin_label
      ,COUNT(*) AS N
      ,KIPP_NJ.dbo.GROUP_CONCAT_D('(' + CAST(DATEPART(MM, intv_flagged) AS NVARCHAR) + '/' 
         + CAST(DATEPART(DD, intv_flagged) AS NVARCHAR) +') ' + vchdescription, ' | ') AS elements
FROM
      (SELECT intv.studentid
             ,intv.stu_name
             ,intv.lastfirst
             ,intv.year
             ,intv.grade
             ,intv.school
             ,intv.dgradelevel
             ,intv.lda_k
             ,intv.topic_bin
             ,intv.intv_flagged
             ,intv.vchdescription
             ,KIPP_NJ.dbo.GROUP_CONCAT_D(labs.key_word, ' ') AS bin_label    
       FROM RutgersReady..[AM$topic_model#classified_intv_objs] intv
       JOIN RutgersReady..AM$topic_model#topic_labels labs
         ON intv.lda_k = labs.lda_k
        AND labs.word_rank <= 5
        AND intv.topic_bin = labs.topic_num
       WHERE intv.lda_k = 15
          AND (intv.rn = 1 OR intv.intv_flag_days <= 7)
       GROUP BY intv.studentid
               ,intv.stu_name
               ,intv.lastfirst
               ,intv.year
               ,intv.grade
               ,intv.school
               ,intv.dgradelevel
               ,intv.lda_k
               ,intv.topic_bin
               ,intv.intv_flagged
               ,intv.vchdescription
       ) sub
GROUP BY studentid
        ,stu_name 
        ,lastfirst
        ,year
        ,grade
        ,school
        ,dgradelevel
        ,lda_k
        ,topic_bin
        ,bin_label    