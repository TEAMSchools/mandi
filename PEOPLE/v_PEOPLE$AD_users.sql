USE KIPP_NJ
GO

ALTER VIEW PEOPLE$AD_users AS

SELECT employeenumber
      ,employeeID      
      ,idautostatus
      ,displayName      
      ,sAMAccountName      
      ,givenName
      ,middleName
      ,sn                  
      ,company           
      ,department
      ,title
      ,mail
      ,l
      ,physicalDeliveryOfficeName                        
      ,createTimeStamp
      ,modifyTimeStamp        
      ,useraccountcontrol
      ,distinguishedname
      /* might be useful in the future */
      ,telephoneNumber
      ,homePhone      
      ,mobile             
      ,homePostalAddress
      ,manager                 
      ,name
      ,userPrincipalName
      ,cn
      ,textEncodedORAddress            
      ,objectCategory      
      ,CASE WHEN useraccountcontrol & 2 = 0 THEN 1 ELSE 0 END AS is_active
      ,CASE WHEN distinguishedname LIKE '%OU=Student%' THEN 1 ELSE 0 END AS is_student
FROM OPENQUERY(ADSI,'
  SELECT useraccountcontrol
        ,distinguishedname
        ,cn
        ,company        
        ,createTimeStamp                
        ,department                
        ,displayName        
        ,employeeID        
        ,employeenumber
        ,givenName        
        ,homePhone
        ,homePostalAddress 
        ,idautostatus       
        ,l        
        ,logonCount
        ,mail        
        ,manager        
        ,middleName
        ,mobile
        ,modifyTimeStamp        
        ,name
        ,objectCategory                
        ,physicalDeliveryOfficeName        
        ,sAMAccountName        
        ,sn        
        ,telephoneNumber
        ,textEncodedORAddress        
        ,title        
        ,userPrincipalName
  FROM ''LDAP://RM9DC-TS-1.teamschools.kipp.org/OU=Users,OU=TEAM,DC=teamschools,DC=kipp,DC=org''    
')