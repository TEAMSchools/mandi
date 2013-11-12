      --notable dates
      ,key_dates.this_report_short
      ,key_dates.this_report_long
      ,key_dates.this_report_distributed
      ,key_dates.next_report
      ,key_dates.next_report_distributed
      ,key_dates.top_quote
      
/*      
      ,ks_nca_pr_grades.y11_q1 as performance_review_q1
      ,ks_nca_pr_grades.y11_q3 as performance_review_q3
*/

left outer join nca_pr_key_dates key_dates on trunc(sysdate) <= key_dates.this_report_distributed 
            and trunc(sysdate) >= key_dates.this_report_begins

/*
left outer join ks_nca_pr_grades on to_char(s.student_number) = ks_nca_pr_grades.stu_num
*/