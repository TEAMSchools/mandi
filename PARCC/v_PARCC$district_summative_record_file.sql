USE KIPP_NJ
GO

ALTER VIEW PARCC$district_summative_record_file AS

SELECT BINI_ID
      ,CONVERT(VARCHAR,[administrationdirectionsclarifiedinstudentsnativelanguage]) AS [administrationdirectionsclarifiedinstudentsnativelanguage]
      ,CONVERT(VARCHAR,[administrationdirectionsreadaloudinstudentsnativelanguage]) AS [administrationdirectionsreadaloudinstudentsnativelanguage]
      ,CONVERT(VARCHAR,[alternaterepresentationpapertest]) AS [alternaterepresentationpapertest]
      ,CONVERT(VARCHAR,[americanindianoralaskanative]) AS [americanindianoralaskanative]
      ,CONVERT(VARCHAR,[answermasking]) AS [answermasking]
      ,CONVERT(VARCHAR,[answersrecordedintestbook]) AS [answersrecordedintestbook]
      ,CONVERT(VARCHAR,[asian]) AS [asian]
      ,CONVERT(VARCHAR,[aslvideo]) AS [aslvideo]
      ,CONVERT(VARCHAR,[assessmentgrade]) AS [assessmentgrade]
      ,CONVERT(VARCHAR,[assessmentyear]) AS [assessmentyear]
      ,CONVERT(VARCHAR,[screenreaderorotherassistivetechnologyapplication]) AS [screenreaderorotherassistivetechnologyapplication]
      ,CONVERT(VARCHAR,[birthdate]) AS [birthdate]
      ,CONVERT(VARCHAR,[blackorafricanamerican]) AS [blackorafricanamerican]
      ,CONVERT(VARCHAR,[brailleresponse]) AS [brailleresponse]
      ,CONVERT(VARCHAR,[braillewithtactilegraphics]) AS [braillewithtactilegraphics]
      ,CONVERT(VARCHAR,[calculationdeviceandmathematicstools]) AS [calculationdeviceandmathematicstools]
      ,CONVERT(VARCHAR,[closedcaptioningforelal]) AS [closedcaptioningforelal]
      ,CONVERT(VARCHAR,[colorcontrast]) AS [colorcontrast]
      ,CONVERT(VARCHAR,[economicdisadvantagestatus]) AS [economicdisadvantagestatus]
      ,CONVERT(VARCHAR,[elalconstructedresponse]) AS [elalconstructedresponse]
      ,CONVERT(VARCHAR,[elalselectedresponseortechnologyenhanceditems]) AS [elalselectedresponseortechnologyenhanceditems]
      ,CONVERT(VARCHAR,[englishlearner]) AS [englishlearner]
      ,CONVERT(VARCHAR,[extendedtime]) AS [extendedtime]
      ,CONVERT(VARCHAR,[federalraceethnicity]) AS [federalraceethnicity]
      ,CONVERT(VARCHAR,[filler]) AS [filler]
      ,CONVERT(VARCHAR,[filler1]) AS [filler1]
      ,CONVERT(VARCHAR,[filler2]) AS [filler2]
      ,CONVERT(VARCHAR,[filler3]) AS [filler3]
      ,CONVERT(VARCHAR,[filler4]) AS [filler4]
      ,CONVERT(VARCHAR,[filler5]) AS [filler5]
      ,CONVERT(VARCHAR,[firstname]) AS [firstname]
      ,CONVERT(VARCHAR,[frequentbreaks]) AS [frequentbreaks]
      ,CONVERT(VARCHAR,[giftedandtalented]) AS [giftedandtalented]
      ,CONVERT(VARCHAR,[gradelevelwhenassessed]) AS [gradelevelwhenassessed]
      ,CONVERT(VARCHAR,[hispanicorlatinoethnicity]) AS [hispanicorlatinoethnicity]
      ,CONVERT(VARCHAR,[humanreaderorhumansigner]) AS [humanreaderorhumansigner]
      ,CONVERT(VARCHAR,[humanreaderorhumansignerforelal]) AS [humanreaderorhumansignerforelal]
      ,CONVERT(VARCHAR,[humanreaderorhumansignerformathematics]) AS [humanreaderorhumansignerformathematics]
      ,CONVERT(VARCHAR,[largeprint]) AS [largeprint]
      ,CONVERT(VARCHAR,[lastname]) AS [lastname]
      ,CONVERT(VARCHAR,[localstudentidentifier]) AS [localstudentidentifier]
      ,CONVERT(VARCHAR,[mathematicsresponse]) AS [mathematicsresponse]
      ,CONVERT(VARCHAR,[mathematicsresponseel]) AS [mathematicsresponseel]
      ,CONVERT(VARCHAR,[middlename]) AS [middlename]
      ,CONVERT(VARCHAR,[migrantstatus]) AS [migrantstatus]
      ,CONVERT(VARCHAR,[monitortestresponse]) AS [monitortestresponse]
      ,CONVERT(VARCHAR,[multiplerecordflag]) AS [multiplerecordflag]
      ,CONVERT(VARCHAR,[nativehawaiianorotherpacificislander]) AS [nativehawaiianorotherpacificislander]
      ,CONVERT(VARCHAR,[eoynottestedreason]) AS [eoynottestedreason]
      ,CONVERT(VARCHAR,[eoyformid]) AS [eoyformid]
      ,CONVERT(VARCHAR,[pbaformid]) AS [pbaformid]
      ,CONVERT(VARCHAR,[pbaunit1numberofattempteditems]) AS [pbaunit1numberofattempteditems]
      ,CONVERT(VARCHAR,[pbaunit2numberofattempteditems]) AS [pbaunit2numberofattempteditems]
      ,CONVERT(VARCHAR,[pbaunit2totalnumberofitems]) AS [pbaunit2totalnumberofitems]
      ,CONVERT(VARCHAR,[pbaunit3numberofattempteditems]) AS [pbaunit3numberofattempteditems]
      ,CONVERT(VARCHAR,[pbaunit3totalnumberofitems]) AS [pbaunit3totalnumberofitems]
      ,CONVERT(VARCHAR,[pbaunit4numberofattempteditems]) AS [pbaunit4numberofattempteditems]
      ,CONVERT(VARCHAR,[pbaunit4totalnumberofitems]) AS [pbaunit4totalnumberofitems]
      ,CONVERT(VARCHAR,[pbaunit1totalnumberofitems]) AS [pbaunit1totalnumberofitems]
      ,CONVERT(VARCHAR,[parccstudentidentifier]) AS [parccstudentidentifier]
      ,CONVERT(VARCHAR,[primarydisabilitytype]) AS [primarydisabilitytype]
      ,CONVERT(VARCHAR,[refreshablebrailledisplayforelal]) AS [refreshablebrailledisplayforelal]
      ,CONVERT(VARCHAR,[reportsuppressionaction]) AS [reportsuppressionaction]
      ,CONVERT(VARCHAR,[reportsuppressioncode]) AS [reportsuppressioncode]
      ,CONVERT(VARCHAR,[responsibledistrictidentifier]) AS [responsibledistrictidentifier]
      ,CONVERT(VARCHAR,[responsibledistrictname]) AS [responsibledistrictname]
      ,CONVERT(VARCHAR,[responsibleschoolinstitutionidentifier]) AS [responsibleschoolinstitutionidentifier]
      ,CONVERT(VARCHAR,[responsibleschoolinstitutionname]) AS [responsibleschoolinstitutionname]
      ,CONVERT(VARCHAR,[reportedrosterflag]) AS [reportedrosterflag]
      ,CONVERT(VARCHAR,[separatealternatelocation]) AS [separatealternatelocation]
      ,CONVERT(VARCHAR,[sex]) AS [sex]
      ,CONVERT(VARCHAR,[smalltestinggroup]) AS [smalltestinggroup]
      ,CONVERT(VARCHAR,[specializedequipmentorfurniture]) AS [specializedequipmentorfurniture]
      ,CONVERT(VARCHAR,[specifiedareaorsetting]) AS [specifiedareaorsetting]
      ,CONVERT(VARCHAR,[staffmemberidentifier]) AS [staffmemberidentifier]
      ,CONVERT(VARCHAR,[stateabbreviation]) AS [stateabbreviation]
      ,CONVERT(VARCHAR,[optionalstatedata1]) AS [optionalstatedata1]
      ,CONVERT(VARCHAR,[optionalstatedata2]) AS [optionalstatedata2]
      ,CONVERT(VARCHAR,[optionalstatedata3]) AS [optionalstatedata3]
      ,CONVERT(VARCHAR,[optionalstatedata4]) AS [optionalstatedata4]
      ,CONVERT(VARCHAR,[optionalstatedata5]) AS [optionalstatedata5]
      ,CONVERT(VARCHAR,[optionalstatedata6]) AS [optionalstatedata6]
      ,CONVERT(VARCHAR,[optionalstatedata7]) AS [optionalstatedata7]
      ,CONVERT(VARCHAR,[optionalstatedata8]) AS [optionalstatedata8]
      ,CONVERT(VARCHAR,[statestudentidentifier]) AS [statestudentidentifier]
      ,CONVERT(VARCHAR,[eoystudenttestuuid]) AS [eoystudenttestuuid]
      ,CONVERT(VARCHAR,[studentwithdisabilities]) AS [studentwithdisabilities]
      ,CONVERT(VARCHAR,[subclaim1category]) AS [subclaim1category]
      ,CONVERT(VARCHAR,[subclaim2category]) AS [subclaim2category]
      ,CONVERT(VARCHAR,[subclaim3category]) AS [subclaim3category]
      ,CONVERT(VARCHAR,[subclaim4category]) AS [subclaim4category]
      ,CONVERT(VARCHAR,[subclaim5category]) AS [subclaim5category]
      ,CONVERT(VARCHAR,[subclaim6category]) AS [subclaim6category]
      ,CONVERT(VARCHAR,[subject]) AS [subject]
      ,CONVERT(VARCHAR,[reportedsummativescoreflag]) AS [reportedsummativescoreflag]
      ,CONVERT(VARCHAR,[eoytestattemptednessflag]) AS [eoytestattemptednessflag]
      ,CONVERT(VARCHAR,[testcode]) AS [testcode]
      ,CONVERT(VARCHAR,[summativecsem]) AS [summativecsem]
      ,CONVERT(VARCHAR,[eoytestingdistrictidentifier]) AS [eoytestingdistrictidentifier]
      ,CONVERT(VARCHAR,[eoytestingdistrictname]) AS [eoytestingdistrictname]
      ,CONVERT(VARCHAR,[eoytestingschoolinstitutionidentifier]) AS [eoytestingschoolinstitutionidentifier]
      ,CONVERT(VARCHAR,[summativeperformancelevel]) AS [summativeperformancelevel]
      ,CONVERT(VARCHAR,[summativereadingcsem]) AS [summativereadingcsem]
      ,CONVERT(VARCHAR,[summativereadingscalescore]) AS [summativereadingscalescore]
      ,CONVERT(VARCHAR,[summativescalescore]) AS [summativescalescore]
      ,CONVERT(VARCHAR,[summativewritingcsem]) AS [summativewritingcsem]
      ,CONVERT(VARCHAR,[summativewritingscalescore]) AS [summativewritingscalescore]
      ,CONVERT(VARCHAR,[texttospeechforelal]) AS [texttospeechforelal]
      ,CONVERT(VARCHAR,[texttospeechformathematics]) AS [texttospeechformathematics]
      ,CONVERT(VARCHAR,[timeofday]) AS [timeofday]
      ,CONVERT(VARCHAR,[titleiiilimitedenglishproficientparticipationstatus]) AS [titleiiilimitedenglishproficientparticipationstatus]
      ,CONVERT(VARCHAR,[eoytotaltestitems]) AS [eoytotaltestitems]
      ,CONVERT(VARCHAR,[eoytotaltestitemsattempted]) AS [eoytotaltestitemsattempted]
      ,CONVERT(VARCHAR,[translationofthemathematicsassessmentinpaper]) AS [translationofthemathematicsassessmentinpaper]
      ,CONVERT(VARCHAR,[translationofthemathematicsassessmentintexttospeech]) AS [translationofthemathematicsassessmentintexttospeech]
      ,CONVERT(VARCHAR,[translationofthemathematicsassessmentonline]) AS [translationofthemathematicsassessmentonline]
      ,CONVERT(VARCHAR,[twoormoreraces]) AS [twoormoreraces]
      ,CONVERT(VARCHAR,[eoyunit1numberofattempteditems]) AS [eoyunit1numberofattempteditems]
      ,CONVERT(VARCHAR,[eoyunit1totalnumberofitems]) AS [eoyunit1totalnumberofitems]
      ,CONVERT(VARCHAR,[eoyunit2numberofattempteditems]) AS [eoyunit2numberofattempteditems]
      ,CONVERT(VARCHAR,[eoyunit2totalnumberofitems]) AS [eoyunit2totalnumberofitems]
      ,CONVERT(VARCHAR,[eoyunit3numberofattempteditems]) AS [eoyunit3numberofattempteditems]
      ,CONVERT(VARCHAR,[eoyunit3totalnumberofitems]) AS [eoyunit3totalnumberofitems]
      ,CONVERT(VARCHAR,[eoyunit4numberofattempteditems]) AS [eoyunit4numberofattempteditems]
      ,CONVERT(VARCHAR,[eoyunit4totalnumberofitems]) AS [eoyunit4totalnumberofitems]
      ,CONVERT(VARCHAR,[eoyvoidpbaeoyscorereason]) AS [eoyvoidpbaeoyscorereason]
      ,CONVERT(VARCHAR,[white]) AS [white]
      ,CONVERT(VARCHAR,[wordprediction]) AS [wordprediction]
      ,CONVERT(VARCHAR,[wordtoworddictionary]) AS [wordtoworddictionary]
      ,NULL AS [assistivetechnologynonscreenreader]
      ,NULL AS [attemptcreatedate]
      ,NULL AS [classname]
      ,NULL AS [elaccommodation]
      ,NULL AS [emergencyaccommodation]
      ,NULL AS [filler10]
      ,NULL AS [filler11]
      ,NULL AS [filler6]
      ,NULL AS [filler7]
      ,NULL AS [filler8]
      ,NULL AS [filler9]
      ,NULL AS [fillerfield]
      ,NULL AS [fillerfield1]
      ,NULL AS [nottestedcode]
      ,NULL AS [period]
      ,NULL AS [responsibleorganizationcodetype]
      ,NULL AS [retest]
      ,NULL AS [shipreportdistrictcode]
      ,NULL AS [shipreportschoolcode]
      ,NULL AS [statefield10]
      ,NULL AS [statefield11]
      ,NULL AS [statefield12]
      ,NULL AS [statefield9]
      ,NULL AS [studentreadsassessmentaloudtothemselves]
      ,NULL AS [studentunit1testuuid]
      ,NULL AS [studentunit2testuuid]
      ,NULL AS [studentunit3testuuid]
      ,NULL AS [studentunit4testuuid]
      ,NULL AS [testadministrator]
      ,NULL AS [testingorganizationaltype]
      ,NULL AS [testscorecomplete]
      ,NULL AS [teststatus]
      ,NULL AS [uniqueaccommodation]
      ,NULL AS [unit1formid]
      ,NULL AS [unit1onlinetestenddatetime]
      ,NULL AS [unit1onlineteststartdatetime]
      ,NULL AS [unit2formid]
      ,NULL AS [unit2onlinetestenddatetime]
      ,NULL AS [unit2onlineteststartdatetime]
      ,NULL AS [unit3formid]
      ,NULL AS [unit3onlinetestenddatetime]
      ,NULL AS [unit3onlineteststartdatetime]
      ,NULL AS [unit4formid]
      ,NULL AS [unit4onlinetestenddatetime]
      ,NULL AS [unit4onlineteststartdatetime]
      ,CONVERT(VARCHAR,[assessmentaccommodation504]) AS [assessmentaccommodation504]
      ,CONVERT(VARCHAR,[assessmentaccommodationenglishlearner]) AS [assessmentaccommodationenglishlearner]
      ,CONVERT(VARCHAR,[assessmentaccommodationindividualizededucationalplan]) AS [assessmentaccommodationindividualizededucationalplan]
      ,CONVERT(VARCHAR,[eoy03category]) AS [eoy03category]
      ,CONVERT(VARCHAR,[eoytestingschoolinstitutionname]) AS [eoytestingschoolinstitutionname]
      ,CONVERT(VARCHAR,[eoyunit5numberofattempteditems]) AS [eoyunit5numberofattempteditems]
      ,CONVERT(VARCHAR,[eoyunit5totalnumberofitems]) AS [eoyunit5totalnumberofitems]
      ,CONVERT(VARCHAR,[fillerracefield]) AS [fillerracefield]
      ,CONVERT(VARCHAR,[pba03category]) AS [pba03category]
      ,CONVERT(VARCHAR,[pbanottestedreason]) AS [pbanottestedreason]
      ,CONVERT(VARCHAR,[pbastudenttestuuid]) AS [pbastudenttestuuid]
      ,CONVERT(VARCHAR,[pbatestattemptednessflag]) AS [pbatestattemptednessflag]
      ,CONVERT(VARCHAR,[pbatestingdistrictidentifier]) AS [pbatestingdistrictidentifier]
      ,CONVERT(VARCHAR,[pbatestingdistrictname]) AS [pbatestingdistrictname]
      ,CONVERT(VARCHAR,[pbatestingschoolinstitutionidentifier]) AS [pbatestingschoolinstitutionidentifier]
      ,CONVERT(VARCHAR,[pbatestingschoolinstitutionname]) AS [pbatestingschoolinstitutionname]
      ,CONVERT(VARCHAR,[pbatotaltestitems]) AS [pbatotaltestitems]
      ,CONVERT(VARCHAR,[pbatotaltestitemsattempted]) AS [pbatotaltestitemsattempted]
      ,CONVERT(VARCHAR,[pbaunit5numberofattempteditems]) AS [pbaunit5numberofattempteditems]
      ,CONVERT(VARCHAR,[pbaunit5totalnumberofitems]) AS [pbaunit5totalnumberofitems]
      ,CONVERT(VARCHAR,[pbavoidpbaeoyscorereason]) AS [pbavoidpbaeoyscorereason]
      ,CONVERT(VARCHAR,[recordtype]) AS [recordtype]
      ,CONVERT(VARCHAR,[summativescorerecorduuid]) AS [summativescorerecorduuid]
      ,CONVERT(VARCHAR,[tactilegraphics]) AS [tactilegraphics]
FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PARCC_district_summative_record_file_2014] WITH(NOLOCK)
WHERE recordtype = 1 
  AND reportedsummativescoreflag = 'Y'  
  AND reportsuppressioncode IS NULL

UNION ALL

SELECT BINI_ID
      ,CONVERT(VARCHAR,[administrationdirectionsclarifiedinstudentsnativelanguage]) AS [administrationdirectionsclarifiedinstudentsnativelanguage]
      ,CONVERT(VARCHAR,[administrationdirectionsreadaloudinstudentsnativelanguage]) AS [administrationdirectionsreadaloudinstudentsnativelanguage]
      ,CONVERT(VARCHAR,[alternaterepresentationpapertest]) AS [alternaterepresentationpapertest]
      ,CONVERT(VARCHAR,[americanindianoralaskanative]) AS [americanindianoralaskanative]
      ,CONVERT(VARCHAR,[answermasking]) AS [answermasking]
      ,CONVERT(VARCHAR,[answersrecordedintestbook]) AS [answersrecordedintestbook]
      ,CONVERT(VARCHAR,[asian]) AS [asian]
      ,CONVERT(VARCHAR,[aslvideo]) AS [aslvideo]
      ,CONVERT(VARCHAR,[assessmentgrade]) AS [assessmentgrade]
      ,CONVERT(VARCHAR,[assessmentyear]) AS [assessmentyear]
      ,CONVERT(VARCHAR,[assistivetechnologyscreenreader]) AS [assistivetechnologyscreenreader]
      ,CONVERT(VARCHAR,[birthdate]) AS [birthdate]
      ,CONVERT(VARCHAR,[blackorafricanamerican]) AS [blackorafricanamerican]
      ,CONVERT(VARCHAR,[brailleresponse]) AS [brailleresponse]
      ,CONVERT(VARCHAR,[braillewithtactilegraphics]) AS [braillewithtactilegraphics]
      ,CONVERT(VARCHAR,[calculationdeviceandmathematicstools]) AS [calculationdeviceandmathematicstools]
      ,CONVERT(VARCHAR,[closedcaptioningforelal]) AS [closedcaptioningforelal]
      ,CONVERT(VARCHAR,[colorcontrast]) AS [colorcontrast]
      ,CONVERT(VARCHAR,[economicdisadvantagestatus]) AS [economicdisadvantagestatus]
      ,CONVERT(VARCHAR,[elalconstructedresponse]) AS [elalconstructedresponse]
      ,CONVERT(VARCHAR,[elalselectedresponseortechnologyenhanceditems]) AS [elalselectedresponseortechnologyenhanceditems]
      ,CONVERT(VARCHAR,[englishlearnerel]) AS [englishlearnerel]
      ,CONVERT(VARCHAR,[extendedtime]) AS [extendedtime]
      ,CONVERT(VARCHAR,[federalraceethnicity]) AS [federalraceethnicity]
      ,CONVERT(VARCHAR,[filler]) AS [filler]
      ,CONVERT(VARCHAR,[filler1]) AS [filler1]
      ,CONVERT(VARCHAR,[filler2]) AS [filler2]
      ,CONVERT(VARCHAR,[filler3]) AS [filler3]
      ,CONVERT(VARCHAR,[filler4]) AS [filler4]
      ,CONVERT(VARCHAR,[filler5]) AS [filler5]
      ,CONVERT(VARCHAR,[firstname]) AS [firstname]
      ,CONVERT(VARCHAR,[frequentbreaks]) AS [frequentbreaks]
      ,CONVERT(VARCHAR,[giftedandtalented]) AS [giftedandtalented]
      ,CONVERT(VARCHAR,[gradelevelwhenassessed]) AS [gradelevelwhenassessed]
      ,CONVERT(VARCHAR,[hispanicorlatinoethnicity]) AS [hispanicorlatinoethnicity]
      ,CONVERT(VARCHAR,[humanreaderorhumansigner]) AS [humanreaderorhumansigner]
      ,CONVERT(VARCHAR,[humansignerfortestdirections]) AS [humansignerfortestdirections]
      ,CONVERT(VARCHAR,[humansignerfortestdirections]) AS [humansignerfortestdirections]
      ,CONVERT(VARCHAR,[largeprint]) AS [largeprint]
      ,CONVERT(VARCHAR,[lastorsurname]) AS [lastorsurname]
      ,CONVERT(VARCHAR,[localstudentidentifier]) AS [localstudentidentifier]
      ,CONVERT(VARCHAR,[mathematicsresponse]) AS [mathematicsresponse]
      ,CONVERT(VARCHAR,[mathematicsresponseel]) AS [mathematicsresponseel]
      ,CONVERT(VARCHAR,[middlename]) AS [middlename]
      ,CONVERT(VARCHAR,[migrantstatus]) AS [migrantstatus]
      ,CONVERT(VARCHAR,[monitortestresponse]) AS [monitortestresponse]
      ,CONVERT(VARCHAR,[multipletestregistration]) AS [multipletestregistration]
      ,CONVERT(VARCHAR,[nativehawaiianorotherpacificislander]) AS [nativehawaiianorotherpacificislander]
      ,CONVERT(VARCHAR,[nottestedreason]) AS [nottestedreason]
      ,CONVERT(VARCHAR,[onlineformid]) AS [onlineformid]
      ,CONVERT(VARCHAR,[paperformid]) AS [paperformid]
      ,CONVERT(VARCHAR,[papersection1numberofattempteditems]) AS [papersection1numberofattempteditems]
      ,CONVERT(VARCHAR,[papersection2numberofattempteditems]) AS [papersection2numberofattempteditems]
      ,CONVERT(VARCHAR,[papersection2totaltestitems]) AS [papersection2totaltestitems]
      ,CONVERT(VARCHAR,[papersection3numberofattempteditems]) AS [papersection3numberofattempteditems]
      ,CONVERT(VARCHAR,[papersection3totaltestitems]) AS [papersection3totaltestitems]
      ,CONVERT(VARCHAR,[papersection4numberofattempteditems]) AS [papersection4numberofattempteditems]
      ,CONVERT(VARCHAR,[papersection4totaltestitems]) AS [papersection4totaltestitems]
      ,CONVERT(VARCHAR,[paperunit1totaltestitems]) AS [paperunit1totaltestitems]
      ,CONVERT(VARCHAR,[parccstudentidentifier]) AS [parccstudentidentifier]
      ,CONVERT(VARCHAR,[primarydisabilitytype]) AS [primarydisabilitytype]
      ,CONVERT(VARCHAR,[refreshablebrailledisplayforelal]) AS [refreshablebrailledisplayforelal]
      ,CONVERT(VARCHAR,[reportsuppressionaction]) AS [reportsuppressionaction]
      ,CONVERT(VARCHAR,[reportsuppressioncode]) AS [reportsuppressioncode]
      ,CONVERT(VARCHAR,[responsibledistrictcode]) AS [responsibledistrictcode]
      ,CONVERT(VARCHAR,[responsibledistrictname]) AS [responsibledistrictname]
      ,CONVERT(VARCHAR,[responsibleschoolcode]) AS [responsibleschoolcode]
      ,CONVERT(VARCHAR,[responsibleschoolname]) AS [responsibleschoolname]
      ,CONVERT(VARCHAR,[rosterflag]) AS [rosterflag]
      ,CONVERT(VARCHAR,[separatealternatelocation]) AS [separatealternatelocation]
      ,CONVERT(VARCHAR,[sex]) AS [sex]
      ,CONVERT(VARCHAR,[smalltestinggroup]) AS [smalltestinggroup]
      ,CONVERT(VARCHAR,[specializedequipmentorfurniture]) AS [specializedequipmentorfurniture]
      ,CONVERT(VARCHAR,[specifiedareaorsetting]) AS [specifiedareaorsetting]
      ,CONVERT(VARCHAR,[staffmemberidentifier]) AS [staffmemberidentifier]
      ,CONVERT(VARCHAR,[stateabbreviation]) AS [stateabbreviation]
      ,CONVERT(VARCHAR,[statefield1]) AS [statefield1]
      ,CONVERT(VARCHAR,[statefield2]) AS [statefield2]
      ,CONVERT(VARCHAR,[statefield3]) AS [statefield3]
      ,CONVERT(VARCHAR,[statefield4]) AS [statefield4]
      ,CONVERT(VARCHAR,[statefield5]) AS [statefield5]
      ,CONVERT(VARCHAR,[statefield6]) AS [statefield6]
      ,CONVERT(VARCHAR,[statefield7]) AS [statefield7]
      ,CONVERT(VARCHAR,[statefield8]) AS [statefield8]
      ,CONVERT(VARCHAR,[statestudentidentifier]) AS [statestudentidentifier]
      ,CONVERT(VARCHAR,[studenttestuuid]) AS [studenttestuuid]
      ,CONVERT(VARCHAR,[studentwithdisabilities]) AS [studentwithdisabilities]
      ,CONVERT(VARCHAR,[subclaim1category]) AS [subclaim1category]
      ,CONVERT(VARCHAR,[subclaim2category]) AS [subclaim2category]
      ,CONVERT(VARCHAR,[subclaim3category]) AS [subclaim3category]
      ,CONVERT(VARCHAR,[subclaim4category]) AS [subclaim4category]
      ,CONVERT(VARCHAR,[subclaim5category]) AS [subclaim5category]
      ,CONVERT(VARCHAR,[subclaim6category]) AS [subclaim6category]
      ,CONVERT(VARCHAR,[subject]) AS [subject]
      ,CONVERT(VARCHAR,[summative_flag]) AS [summative_flag]
      ,CONVERT(VARCHAR,[testattemptednessflag]) AS [testattemptednessflag]
      ,CONVERT(VARCHAR,[testcode]) AS [testcode]
      ,CONVERT(VARCHAR,[testcsemprobablerange]) AS [testcsemprobablerange]
      ,CONVERT(VARCHAR,[testingdistrictcode]) AS [testingdistrictcode]
      ,CONVERT(VARCHAR,[testingdistrictname]) AS [testingdistrictname]
      ,CONVERT(VARCHAR,[testingschoolcode]) AS [testingschoolcode]
      ,CONVERT(VARCHAR,[testperformancelevel]) AS [testperformancelevel]
      ,CONVERT(VARCHAR,[testreadingcsem]) AS [testreadingcsem]
      ,CONVERT(VARCHAR,[testreadingscalescore]) AS [testreadingscalescore]
      ,CONVERT(VARCHAR,[testscalescore]) AS [testscalescore]
      ,CONVERT(VARCHAR,[testwritingcsem]) AS [testwritingcsem]
      ,CONVERT(VARCHAR,[testwritingscalescore]) AS [testwritingscalescore]
      ,CONVERT(VARCHAR,[texttospeech]) AS [texttospeech]
      ,CONVERT(VARCHAR,[texttospeech]) AS [texttospeech]
      ,CONVERT(VARCHAR,[timeofday]) AS [timeofday]
      ,CONVERT(VARCHAR,[titleiiilimitedenglishproficientparticipationstatus]) AS [titleiiilimitedenglishproficientparticipationstatus]
      ,CONVERT(VARCHAR,[totaltestitems]) AS [totaltestitems]
      ,CONVERT(VARCHAR,[totaltestitemsattempted]) AS [totaltestitemsattempted]
      ,CONVERT(VARCHAR,[translationofthemathematicsassessment]) AS [translationofthemathematicsassessment]
      ,CONVERT(VARCHAR,[translationofthemathematicsassessment]) AS [translationofthemathematicsassessment]
      ,CONVERT(VARCHAR,[translationofthemathematicsassessment]) AS [translationofthemathematicsassessment]
      ,CONVERT(VARCHAR,[twoormoreraces]) AS [twoormoreraces]
      ,CONVERT(VARCHAR,[unit1numberofattempteditems]) AS [unit1numberofattempteditems]
      ,CONVERT(VARCHAR,[unit1totaltestitems]) AS [unit1totaltestitems]
      ,CONVERT(VARCHAR,[unit2numberofattempteditems]) AS [unit2numberofattempteditems]
      ,CONVERT(VARCHAR,[unit2totaltestitems]) AS [unit2totaltestitems]
      ,CONVERT(VARCHAR,[unit3numberofattempteditems]) AS [unit3numberofattempteditems]
      ,CONVERT(VARCHAR,[unit3totaltestitems]) AS [unit3totaltestitems]
      ,CONVERT(VARCHAR,[unit4numberofattempteditems]) AS [unit4numberofattempteditems]
      ,CONVERT(VARCHAR,[unit4totaltestitems]) AS [unit4totaltestitems]
      ,CONVERT(VARCHAR,[voidscorereason]) AS [voidscorereason]
      ,CONVERT(VARCHAR,[white]) AS [white]
      ,CONVERT(VARCHAR,[wordprediction]) AS [wordprediction]
      ,CONVERT(VARCHAR,[wordtoworddictionaryenglishnativelanguage]) AS [wordtoworddictionaryenglishnativelanguage]
      ,CONVERT(VARCHAR,[assistivetechnologynonscreenreader]) AS [assistivetechnologynonscreenreader]
      ,CONVERT(VARCHAR,[attemptcreatedate]) AS [attemptcreatedate]
      ,CONVERT(VARCHAR,[classname]) AS [classname]
      ,CONVERT(VARCHAR,[elaccommodation]) AS [elaccommodation]
      ,CONVERT(VARCHAR,[emergencyaccommodation]) AS [emergencyaccommodation]
      ,CONVERT(VARCHAR,[filler10]) AS [filler10]
      ,CONVERT(VARCHAR,[filler11]) AS [filler11]
      ,CONVERT(VARCHAR,[filler6]) AS [filler6]
      ,CONVERT(VARCHAR,[filler7]) AS [filler7]
      ,CONVERT(VARCHAR,[filler8]) AS [filler8]
      ,CONVERT(VARCHAR,[filler9]) AS [filler9]
      ,CONVERT(VARCHAR,[fillerfield]) AS [fillerfield]
      ,CONVERT(VARCHAR,[fillerfield1]) AS [fillerfield1]
      ,CONVERT(VARCHAR,[nottestedcode]) AS [nottestedcode]
      ,CONVERT(VARCHAR,[period]) AS [period]
      ,CONVERT(VARCHAR,[responsibleorganizationcodetype]) AS [responsibleorganizationcodetype]
      ,CONVERT(VARCHAR,[retest]) AS [retest]
      ,CONVERT(VARCHAR,[shipreportdistrictcode]) AS [shipreportdistrictcode]
      ,CONVERT(VARCHAR,[shipreportschoolcode]) AS [shipreportschoolcode]
      ,CONVERT(VARCHAR,[statefield10]) AS [statefield10]
      ,CONVERT(VARCHAR,[statefield11]) AS [statefield11]
      ,CONVERT(VARCHAR,[statefield12]) AS [statefield12]
      ,CONVERT(VARCHAR,[statefield9]) AS [statefield9]
      ,CONVERT(VARCHAR,[studentreadsassessmentaloudtothemselves]) AS [studentreadsassessmentaloudtothemselves]
      ,CONVERT(VARCHAR,[studentunit1testuuid]) AS [studentunit1testuuid]
      ,CONVERT(VARCHAR,[studentunit2testuuid]) AS [studentunit2testuuid]
      ,CONVERT(VARCHAR,[studentunit3testuuid]) AS [studentunit3testuuid]
      ,CONVERT(VARCHAR,[studentunit4testuuid]) AS [studentunit4testuuid]
      ,CONVERT(VARCHAR,[testadministrator]) AS [testadministrator]
      ,CONVERT(VARCHAR,[testingorganizationaltype]) AS [testingorganizationaltype]
      ,CONVERT(VARCHAR,[testscorecomplete]) AS [testscorecomplete]
      ,CONVERT(VARCHAR,[teststatus]) AS [teststatus]
      ,CONVERT(VARCHAR,[uniqueaccommodation]) AS [uniqueaccommodation]
      ,CONVERT(VARCHAR,[unit1formid]) AS [unit1formid]
      ,CONVERT(VARCHAR,[unit1onlinetestenddatetime]) AS [unit1onlinetestenddatetime]
      ,CONVERT(VARCHAR,[unit1onlineteststartdatetime]) AS [unit1onlineteststartdatetime]
      ,CONVERT(VARCHAR,[unit2formid]) AS [unit2formid]
      ,CONVERT(VARCHAR,[unit2onlinetestenddatetime]) AS [unit2onlinetestenddatetime]
      ,CONVERT(VARCHAR,[unit2onlineteststartdatetime]) AS [unit2onlineteststartdatetime]
      ,CONVERT(VARCHAR,[unit3formid]) AS [unit3formid]
      ,CONVERT(VARCHAR,[unit3onlinetestenddatetime]) AS [unit3onlinetestenddatetime]
      ,CONVERT(VARCHAR,[unit3onlineteststartdatetime]) AS [unit3onlineteststartdatetime]
      ,CONVERT(VARCHAR,[unit4formid]) AS [unit4formid]
      ,CONVERT(VARCHAR,[unit4onlinetestenddatetime]) AS [unit4onlinetestenddatetime]
      ,CONVERT(VARCHAR,[unit4onlineteststartdatetime]) AS [unit4onlineteststartdatetime]
      ,NULL AS [assessmentaccommodation504]
      ,NULL AS [assessmentaccommodationenglishlearner]
      ,NULL AS [assessmentaccommodationindividualizededucationalplan]
      ,NULL AS [eoy03category]
      ,NULL AS [eoytestingschoolinstitutionname]
      ,NULL AS [eoyunit5numberofattempteditems]
      ,NULL AS [eoyunit5totalnumberofitems]
      ,NULL AS [fillerracefield]
      ,NULL AS [pba03category]
      ,NULL AS [pbanottestedreason]
      ,NULL AS [pbastudenttestuuid]
      ,NULL AS [pbatestattemptednessflag]
      ,NULL AS [pbatestingdistrictidentifier]
      ,NULL AS [pbatestingdistrictname]
      ,NULL AS [pbatestingschoolinstitutionidentifier]
      ,NULL AS [pbatestingschoolinstitutionname]
      ,NULL AS [pbatotaltestitems]
      ,NULL AS [pbatotaltestitemsattempted]
      ,NULL AS [pbaunit5numberofattempteditems]
      ,NULL AS [pbaunit5totalnumberofitems]
      ,NULL AS [pbavoidpbaeoyscorereason]
      ,NULL AS [recordtype]
      ,NULL AS [summativescorerecorduuid]
      ,NULL AS [tactilegraphics]
FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PARCC_district_summative_record_file_2015] WITH(NOLOCK)
WHERE teststatus = 'Attempt'
  AND summative_flag = 'Y'
  AND reportsuppressioncode IS NULL