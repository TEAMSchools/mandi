      ,key_dates.this_report_short
      ,key_dates.this_report_long
      ,key_dates.this_report_distributed
      ,key_dates.next_report
      ,key_dates.next_report_distributed
      ,key_dates.top_quote
      ,key_dates.parent_question

left outer join rise_pr_key_dates key_dates on sysdate <= key_dates.this_report_distributed 
            and sysdate >= key_dates.this_report_begins