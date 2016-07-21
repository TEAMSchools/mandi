USE KIPP_NJ
GO

ALTER VIEW LIT$readingscores AS

SELECT CONCAT('PS', unique_id) AS unique_id
      ,studentid
      ,schoolid
      ,CONVERT(DATE,test_date) AS test_date      
      /*
       prior to SY14, academic_year and test_round were derived
       from the test_date, which caused a lot of problems
       so now they're entered directly with the test 
      */
      ,CASE        
        WHEN academic_year IS NULL THEN KIPP_NJ.dbo.fn_DateToSY(test_date)
        ELSE CONVERT(INT,LEFT(LTRIM(RTRIM(academic_year)),4))
       END AS academic_year              
      ,CASE        
        WHEN LTRIM(RTRIM(test_round)) = 'Diagnostic' THEN 'DR'        
        ELSE CONVERT(VARCHAR(8),LTRIM(RTRIM(test_round)))
       END AS test_round
      ,CONVERT(INT,testid) AS testid
      ,CONVERT(VARCHAR(8),LTRIM(RTRIM(READ_LVL))) AS read_lvl
      ,CONVERT(VARCHAR(32),LTRIM(RTRIM(status))) AS status
      ,CONVERT(VARCHAR(16),LTRIM(RTRIM(color))) AS color
      ,CONVERT(VARCHAR(8),UPPER(LTRIM(RTRIM(instruct_lvl)))) AS instruct_lvl
      ,CONVERT(VARCHAR(8),UPPER(LTRIM(RTRIM(indep_lvl)))) AS indep_lvl
      ,CONVERT(VARCHAR(16),LTRIM(RTRIM(genre))) AS genre
      ,CONVERT(FLOAT,name_ass) AS name_ass
      ,CONVERT(FLOAT,ltr_nameid) AS ltr_nameid
      ,CONVERT(FLOAT,ltr_soundid) AS ltr_soundid
      ,CONVERT(FLOAT,pa_rhymingwds) AS pa_rhymingwds
      ,CONVERT(FLOAT,pa_mfs) AS pa_mfs
      ,CONVERT(FLOAT,pa_segmentation) AS pa_segmentation
      ,CONVERT(FLOAT,cp_orient) AS cp_orient
      ,CONVERT(FLOAT,cp_121match) AS cp_121match
      ,CONVERT(FLOAT,cp_slw) AS cp_slw
      ,CONVERT(FLOAT,devsp_first) AS devsp_first
      ,CONVERT(FLOAT,devsp_svs) AS devsp_svs
      ,CONVERT(FLOAT,devsp_final) AS devsp_final
      ,CONVERT(FLOAT,devsp_ifbd) AS devsp_ifbd
      ,CONVERT(FLOAT,devsp_longvowel) AS devsp_longvowel
      ,CONVERT(FLOAT,devsp_rcontrol) AS devsp_rcontrol      
      ,CONVERT(FLOAT,devsp_vowldig) AS devsp_vowldig
      ,CONVERT(FLOAT,devsp_cmplxb) AS devsp_cmplxb
      ,CONVERT(FLOAT,devsp_eding) AS devsp_eding
      ,CONVERT(FLOAT,devsp_doubsylj) AS devsp_doubsylj      
      ,CONVERT(FLOAT,rr_121match) AS rr_121match
      ,CONVERT(FLOAT,rr_holdspattern) AS rr_holdspattern
      ,CONVERT(FLOAT,rr_understanding) AS rr_understanding      
      ,CONVERT(FLOAT,accuracy_1a) AS accuracy_1a
      ,CONVERT(FLOAT,accuracy_2b) AS accuracy_2b
      ,CONVERT(FLOAT,ra_errors) AS ra_errors
      ,CONVERT(FLOAT,cc_factual) AS cc_factual
      ,CONVERT(FLOAT,cc_infer) AS cc_infer
      ,CONVERT(FLOAT,cc_other) AS cc_other
      ,CONVERT(FLOAT,cc_ct) AS cc_ct
      ,CONVERT(FLOAT,ocomp_factual) AS ocomp_factual
      ,CONVERT(FLOAT,ocomp_ct) AS ocomp_ct
      ,CONVERT(FLOAT,ocomp_infer) AS ocomp_infer
      ,CONVERT(FLOAT,scomp_factual) AS scomp_factual
      ,CONVERT(FLOAT,scomp_infer) AS scomp_infer
      ,CONVERT(FLOAT,scomp_ct) AS scomp_ct
      ,CONVERT(FLOAT,wcomp_fact) AS wcomp_fact
      ,CONVERT(FLOAT,wcomp_infer) AS wcomp_infer
      ,CONVERT(FLOAT,wcomp_ct) AS wcomp_ct
      ,CONVERT(FLOAT,retelling) AS retelling      
      ,CONVERT(VARCHAR(32),LTRIM(RTRIM(reading_rate))) AS reading_rate
      ,CONVERT(FLOAT,fluency) AS fluency
      ,CONVERT(FLOAT,fp_wpmrate) AS fp_wpmrate
      ,CONVERT(FLOAT,fp_fluency) AS fp_fluency
      ,CONVERT(FLOAT,fp_accuracy) AS fp_accuracy
      ,CONVERT(FLOAT,fp_comp_within) AS fp_comp_within
      ,CONVERT(FLOAT,fp_comp_beyond) AS fp_comp_beyond
      ,CONVERT(FLOAT,fp_comp_about) AS fp_comp_about
      ,CONVERT(VARCHAR(32),LTRIM(RTRIM(fp_keylever))) AS fp_keylever
      ,CONVERT(VARCHAR(8),LTRIM(RTRIM(coaching_code))) AS coaching_code

      --aggregate fields
      ,CASE WHEN testid != 3273 THEN
        CONVERT(FLOAT,ISNULL(cc_factual,0)) 
         + CONVERT(FLOAT,ISNULL(cc_other,0)) 
         + CONVERT(FLOAT,ISNULL(cc_infer,0)) 
         + CONVERT(FLOAT,ISNULL(cc_ct,0)) 
        ELSE NULL
       END AS cc_prof      
      ,CASE WHEN testid != 3273 THEN
        CONVERT(FLOAT,ISNULL(ocomp_factual,0)) 
         + CONVERT(FLOAT,ISNULL(ocomp_infer,0)) 
         + CONVERT(FLOAT,ISNULL(ocomp_ct,0)) 
        ELSE NULL
       END AS ocomp_prof
      ,CASE WHEN testid != 3273 THEN
        CONVERT(FLOAT,ISNULL(scomp_factual,0)) 
         + CONVERT(FLOAT,ISNULL(scomp_infer,0)) 
         + CONVERT(FLOAT,ISNULL(scomp_ct,0)) 
        ELSE NULL
       END AS scomp_prof
      ,CASE WHEN testid != 3273 THEN
        CONVERT(FLOAT,ISNULL(wcomp_fact,0)) 
         + CONVERT(FLOAT,ISNULL(wcomp_infer,0)) 
         + CONVERT(FLOAT,ISNULL(wcomp_ct,0)) 
        ELSE NULL
       END AS wcomp_prof
      ,CASE WHEN testid = 3273 THEN
        CONVERT(FLOAT,ISNULL(fp_comp_within,0)) 
         + CONVERT(FLOAT,ISNULL(fp_comp_beyond,0)) 
         + CONVERT(FLOAT,ISNULL(fp_comp_about,0)) 
        ELSE NULL
       END AS fp_comp_prof      
      ,CASE WHEN testid != 3273 THEN
        CONVERT(FLOAT,ISNULL(cp_orient,0)) 
         + CONVERT(FLOAT,ISNULL(cp_121match,0)) 
         + CONVERT(FLOAT,ISNULL(cp_slw,0)) 
        ELSE NULL
       END AS cp_prof
      ,CASE WHEN testid != 3273 THEN
        CONVERT(FLOAT,ISNULL(rr_121match,0)) 
         + CONVERT(FLOAT,ISNULL(rr_holdspattern,0)) 
         + CONVERT(FLOAT,ISNULL(rr_understanding,0)) 
        ELSE NULL
       END AS rr_prof
      ,CASE WHEN testid != 3273 THEN
        CONVERT(FLOAT,ISNULL(devsp_first,0)) 
         + CONVERT(FLOAT,ISNULL(devsp_svs,0)) 
         + CONVERT(FLOAT,ISNULL(devsp_final,0))
         + CONVERT(FLOAT,ISNULL(devsp_ifbd,0))
        ELSE NULL
       END AS devsp_prof      
FROM LIT$READINGSCORES#STAGING WITH(NOLOCK)