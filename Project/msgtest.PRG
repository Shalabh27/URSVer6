Parameters cMessage2Show
Set Procedure To \ursver6\project\progs\servlib
Set Classlib To \ursver6\libs\urs
Set Memowidth to 1000

*!*   cParmList=''
*!*   cParmList=cParmList+' - MEDICAID Claims are on file.'+Chr(13)
*!*   cParmList=cParmList+' - Encounter(s) are on file.'+Chr(13)
*!*   cParmList=cParmList+' - Needle Exchange on file.'+Chr(13)
*!*   cMsg1="An HIV+ Status record has been written to the client's HIV Status History."+Chr(13)+;
*!*         "Please review and update if necessary."

*!*   cMsg2='Part D (HIV Test Survey) must be completed for a Conventional Positive Result.'

oApp=CreateObject('app')

* oApp.msg2user('NEWTEST')

* xy=oApp.msg2user('INTAKEDEL',cParmList)
* ? xy

* =oApp.msg2user('INFORM','IMPORTANT:'+Chr(13)+' Missing encounter start and end time(s) were entered.')

* =oApp.msg2user('DOYOUWANT','For this (deleted) group activity...','remove all of the associated client encounters and services?'+Chr(13)+;
'(The encounters and services can then be accessed individually)')

* =oApp.msg2user('YES_NO','This user must be logged-out of the system.','Are you sure you want to proceed?')
* oApp.Msg2user('INFORM','PROBLEM:'+Chr(13)+;
                       'The "Agency ID" was not created during this session.')
                       
*!*   cMessage='IMPORTANT'+Chr(13)+Chr(13)+Iif(!Empty(cMsg1),cMsg1+Chr(13)+Chr(13),'')+cMsg2
*!*   oApp.msg2user('INFORM',cMessage)

*!* oApp.msg2user('TA_21')
*!* oApp.msg2user('INFORM','Please select a Program first!')
*!* oApp.msg2user('FIXPROBLEM')
*!* oApp.msg2user('MSG_YESNO','This operation requires exclusive use of the system.'+Chr(13)+;
*!*                           'Please inform all users to exit the system.'+Chr(13)+;
*!*                           'Would you like view the connection log?')
*!* oApp.msg2user('MESSAGE','Data Extract processing canceled.')
*!* oApp.msg2user('COLLATERAL')
* oApp.Msg2user('YES_NO','Important: All encounters and services associated with'+Chr(13)+'this group activity will be deleted.','Are you sure you want to proceed?')
* oApp.Msg2user('YES_NO','ALL encounters and services associated with this group activity will be deleted.','Are you sure you want to proceed?','',.f.)
* oApp.Msg2user('INFORM','The program you have selected was originally assigned a PEMS contract, but there are no longer any active contracts for the date entered.  Please contact your PEMS provider for updated contract information.'+Chr(13)+Chr(13))
* oApp.Msg2user('PEMSPROB','"Model"','"Models"')
* oApp.Msg2user('RSRCFAILED')
* oApp.Msg2user('INFORM','RSR Extract was successfully created, archived (zipped) and saved.'+Chr(13)+;
*!*                            "Use the 'Copy to Disk' button to put the zip file to disk for forwarding to your funder.")
* oApp.Msg2user('NOCLRHOST','','Please contact support to assist you in solving this problem.')
* oApp.Msg2user('NOCLRHOST','','As a result the extract process will not continue.'+Chr(13)+'Please contact support to assist you in solving this problem.')
*!*   oApp.Msg2user('MSG_YESNO', ;
                     'The eUCI number is a required element in the RSR extract.  '+Chr(13)+;
                     'The data will not be accepted if any client is missing a eUCI number.'+Chr(13)+;  
                     'However, you can choose to proceed with the extract for testing purposes.'+Chr(13)+Chr(13),;
                     'Do you want to create the extract anyway?')
*!*   oApp.msg2user('INFORM','IMPORTANT:'+Chr(13)+'You will be adding a new Posttest Survey to the Pretest conducted on '+Dtoc(Date())+'.')
*!*   oApp.msg2user("MESSAGE", "The assessments for this client appear to be suspect."+Chr(13)+"  Please contact support.")
*!*   oApp.msg2user('CANTDEL2','This Pretest assessment is liked to a posttest assessment still on file.','Delete the posttest assessment first.')
*!*   oApp.msg2user('RSR_MSG1')
*!*   oApp.Msg2user('INFORM','Please Wait: Loading XML Document...')
*!*   oApp.Msg2user('WAITRUN','Please Wait...','Loading XML Document')
*!*   oApp.Msg2user('MSG_YESNO', ;
                    'You have selected the file...'+Chr(13)+;
                    'SOME FILE NAME','Begin Processing?')
*!*   oApp.msg2user('INFORM','XML Import Failure:'+Chr(13)+'An error was encountered during the import process.'+Chr(13)+;
                             'The details are available in the logd.')
*!*   oApp.msg2user('MESSAGE','XML Import Failure...'+Chr(13)+;
                              'An error was encountered during the import process.'+Chr(13)+;
                              'The details are available in the history log.')
*!*   oApp.Msg2user('MSG_YESNO', ;
                'SOME FILE NAME','Begin Processing?')
*!*   oApp.Msg2user('MSG_YESNO', ;
                'You have selected the file...'+Chr(13)+;
                'SOME FILE NAME asdf asdf asdf asdf asdf asd fwtuywty wty wrty wty ty ','Begin Processing?')
*!*   oApp.Msg2user('INFORM', ;
              'Risk for this date was entered through the "HIV/AIDS Risk History"'+Chr(13)+;
              'form.  Only certain Risk information can be updated on this form.'+Chr(13)+;
              'RW & CDC Risk categories will NOT be updated from data entered here.')
*!*   oApp.Msg2user('MESSAGE', ;
              'HIV/AIDS Risk History'+Chr(13)+;
              'Risk for this date was entered through the "HIV/AIDS Risk History" form'+Chr(13)+;
              'or was created from another Part A. Therefore, only certain fields can be'+Chr(13)+;
              'updated.  Use the "HIV/AIDS Risk History" form to update information that'+Chr(13)+;
              'is not available on this form. RW & CDC Risk categories will NOT be updated from data entered in the "Risk Factors" section on this form.')
*!*   oApp.Msg2user('MESSAGE','Test #2 [Standard of Confirmatory] can only be'+Chr(13)+'added if Test #1 [Rapid Testing] is positive.')
*!*   oApp.msg2user('MESSAGE','Please Save or Cancel the changes made in this session before moving to a different test.')
*!*   oApp.msg2user('GENERROR','An Encounter is required for this test.'+Chr(13)+'You cannot save this record until an encounter is entered.')
*!*   cMsg1="An HIV+ Status record has been written to the client's HIV Status History."+Chr(13)+;
*!*         "Please review and update if necessary."
*!*   cMsg2='The Post-Test [Part D-HIV Test Survey] must be completed for a Conventional, Positive test where the test result was provided.'
*!*   cMessage='** IMPORTANT **'+Chr(13)+Iif(!Empty(cMsg1),cMsg1+Chr(13)+Chr(13),'')+cMsg2
*!*   oApp.msg2user('MESSAGE',cMessage)
*!*   oApp.Msg2user('MESSAGE','Cannot enter a Test #1 [Rapid].'+Chr(13)+'A Test #2 [Standard or Confirmatory] was already entered.')
*!*   oApp.Msg2user('GENERROR','CTR PartD must be completed before you can exit.')
*!*   oApp.Msg2User("AREUSURE", "Extract for the period of " + Dtoc(Date()) + ;
*!*                            " - " + DTOC(Date()) + Chr(13)+;
*!*                            " has already been created.", "recreate it")
*!*   oApp.Msg2user('MESSAGE', ;
*!*     'HIV/AIDS Risk History'+Chr(13)+;
*!*     'Risk for this date was entered through the "HIV/AIDS Risk History" form.'+Chr(13)+;
*!*     'There can be a difference between information entered using the CTR Part A form"'+;
*!*     'and the "HIV/AIDS Risk History" form.  RW & CDC Risk categories will updated by either form.')
*!*   oApp.msg2user('HIVHIST')
*!*   oApp.Msg2user('INFORM', 'Planning/Target file Import Cancelled!')
*!*   oApp.Msg2user('INFORM', "This encounter information was used for Billing and can't be edited.")
*!*   oApp.Msg2user('INFORM', "One or more of the 'Services Provided' are not valid for the 'Actual Date' of the encounter.  "+;
*!*                           "This condition could happen because..."+Chr(13)+Chr(13)+;
*!*                           "* The list of available services has changed *"+Chr(13)+;
*!*                           "* Your access to services has changed *")
*!*   oApp.msg2user('INSCHANGE2')
*!*   oApp.msg2user('INSCHANGE1')
*!*   oApp.msg2user('INSCHANGE2')
*!*   oApp.Msg2user('GENERROR','You must first enter or select a Client.')
*!*   oApp.Msg2user('SYRNGXMSG1')
*!*   oApp.Msg2user('GENERROR','The Client ID you entered is not in the system.'+Chr(13)+'You can search by DblClicking or pressing Enter in the field.')
*!*   oApp.Msg2user('EXCHANGE2')
*!*   oApp.Msg2user('AREUSURE','This action will delete all of the Syringe Exchanges listed.','proceed with deleting these records')
*!*   oApp.Msg2user('SYRNGXMSG3')
*!*   oApp.Msg2user('SYRNGXMSG4')
*!*   cEncDesc='Row1: asdfasdfasdfasdfasdfasdfasdfasdfasdf werqwer'
*!*   cServDesc='Row2: asdfasdfasdfasdfasdfasdfasdfasdfasdfwqwqer'
*!*   oApp.Msg2user('LIMPORTANT','This test was created the Encounter & Service...'+Chr(13)+cEncDesc+Chr(13)+cServDesc+Chr(13)+Chr(13))
*!*   oApp.Msg2user('CO_0001')
*!*   oApp.Msg2user('CO_0003a')
*!*   oApp.Msg2user('CO_0003b')
*!*   oApp.Msg2user('INFORM','The program selected was originally assigned a Planning File contract, '+;
*!*                          'but there are no longer any active contracts for the date entered.  '+;
*!*                          'Please contact your Planning File provider for updated contract information.'+Chr(13)+Chr(13))
*!*   oApp.Msg2user('MEDINDIC')
*!*   oApp.Msg2user('IMPORTANT','Important: This test was automatically generated by a service.'+Chr(13)+;
*!*                             'The service entry that created this test was deleted.'+Chr(13)+;
*!*                             'Please review the need for keeping this test.')
*!*   oApp.Msg2user('IMPORTANT','Important: This test was automatically generated by a service. The service entry that created this test was deleted.'+Chr(13)+;
*!*                             'Please review the need for keeping this test.')
*!*   oApp.Msg2user('MESSAGE','"Test #2 [Standard or Confirmatory]" '+Chr(13)+;
*!*                     'Can only be added when "Test #1 [Rapid Testing]"...'+Chr(13)+Chr(13)+;
*!*                     '* Has a Positive Result *'+Chr(13)+'Or'+Chr(13)+;
*!*                     '* Is Negative AND "Suspected Acute Infection" is indicated AND a "Confirmatory Sample" was provided *')
*!*   oApp.Msg2user('MSG_YESNO', ;
*!*                 'Both "Count" and "Unknown/Not Applicable" are unanswered or a count'+Chr(13)+;
*!*                 ' of "0" was entered. If "0" is a valid, known entry please respond "Yes".','Respond "No" if the "0" count is "Unknown/Not Applicable"')
*!*   oApp.Msg2user('UNKNOWN1')
*!*   oApp.msg2user('IMPORTANT','The folder that is used to create AIDS Institutes Extracts was not found.'+Chr(13)+'Please have an administrator define this System Preference.')
*!*   oApp.Msg2user('CO_0002')
*!*   oApp.Msg2user('UNKNOWN1')
*!*   oApp.Msg2user('AREUSURE','This action will remove all of the Exchanges listed below plus'+Chr(13)+'their referrals, if any.','proceed with deleting these records')
*!*   oApp.Msg2user("INFORM","The Syringe Exchange information that you've marked for deletion/removal, which includes Referrals, will not be saved")
*!*   oApp.Msg2user("NOTSAVED")
*!*   oApp.Msg2user("NOTSAVEDNX")
*!*   oApp.Msg2user("INFORM","* Important *"+Chr(13)+"The referral associated with this exchange will also be deleted.")
*!*   oApp.msg2user("IMPORTANT","** IMPORTANT **"+Chr(13)+'Selecting this item will automatically select the "with Male" option.')
*!*   oApp.msg2user("IMPORTANT","** IMPORTANT **"+Chr(13)+'Deselecting this item will automatically un-select the '+Chr(13)+'"with person who is MSM (female Only)" option.')
*!*   oApp.msg2user("INFORM","You must first enter the 'Gender' of the client.")
*!*   oApp.msg2user("IMPORTANT",'* Required Information Missing *'+Chr(13)+"The client's 'Gender' must be entered before Risk History.")
*!*   oApp.msg2user("INFORM","An 'HIV-Positive, CDC-Defined AIDS Status' was automatically added to this client's"+Chr(13)+ "'HIV Status Information.'")
*!*   oApp.msg2user("INFORM","The 'HIV-Positive, CDC-Defined AIDS Status' that was automatically added"+Chr(13)+ "to this client's 'HIV Status Information' was removed")
*!*   oApp.msg2user('MSG_YESNO',;
*!*              'You have checked the "Test Indicator" flag.'+Chr(13)+'Files created while this flag is checked are for testing purposes ONLY and will NOT be adjudicated.',;
*!*              'Are you sure this is correct?')
*!*   oApp.msg2user('MSG_YESNO',"You've selected the '5010' Claim Output Format.","Is this the file you are looking to generate?")
*!*   oApp.msg2user("SETUP5010")
*!*   oApp.msg2user("INFORM","There is an RSR Assessment already on file for the current period."+Chr(13)+ "Use 'Locate...' to select existing Assessments.")
*!*   oApp.msg2user("MESSAGE","There is an RSR Assessment already on file for the current period."+Chr(13)+ "Use 'Locate...' to select existing Assessments.")
*!*   oApp.msg2user('MESSAGE', 'This Client has a Status of "CDC Defined AIDS".'+Chr(13)+'Additional statuses can not be added.')
*!*   oApp.msg2user('VERWARN1')
*!*   oApp.msg2user('VERWARN2','Edit')
*!*   oApp.msg2user('VERWARN2','Remove')
*!*   oApp.msg2user('CANTDEL2','Housing Information that was entered at intake is required.','Please edit the information.')
*!*   oApp.Msg2user('INFORM','You must use the "Open Encounter Form" to add additional Services/Activites Provided')
*!*   oApp.Msg2user('MESSAGE','To Add or Remove "Services/Activites Provided" you must use'+Chr(13)+'the "Open Encounter Form" link.')
*!*   oApp.Msg2user('MESSAGE','"Healh Homes": Only clients that do NOT have a "Health Homes"'+Chr(13)+'encounter and "Enrollment" service on '+Dtoc(Date())+' will be selected.')
*!*   oApp.msg2user('UNKNOWN1')
*!*   oApp.Msg2user('CTRREF1')
*!*   oApp.Msg2user('CTRREF2')
*!*   oApp.Msg2user('HHREJECTS')
*!*   oApp.msg2user('IMPORTANT','There is no data that matches the EPI Extract requirements.')
*!*   oApp.msg2user('INFORM','There is no data that matches the EPI Extract requirements.')
*!*   oApp.msg2user('HHSELECT')
*!*   oApp.msg2user('MESSAGE',"The file: "+'extracts\Billx'+Dtos(Date())+'.zip'+Chr(13)+" is in the destination folder. It will be overwritten.")
*!*   oApp.msg2user("VER_MSG41",Dtoc(Date()),Dtoc(Date()))
*!*   oApp.msg2user('IMPORTANT','There are no new or changed records'+Chr(13)+'that match the EPI Extract requirements.')
*!*   oApp.Msg2user('INFORM','EPI Extract was successfully created, archived (zipped), encrypted and saved.'+Chr(13)+;
*!*                          "Use the 'Save to Disk' button to copy the zip file to disk for forwarding.")
*!*   oApp.msg2user('IMPORTANT','There are no new or changed records that match the EPI Extract requirements.'+Chr(13))
*!*   oApp.Msg2user('INFORM','EPI Extract was successfully created, archived (zipped), encrypted and saved.'+Chr(13)+;
*!*                          "Use the 'Save to Disk' button to copy the zip file to disk for forwarding.")
*!*   oApp.msg2user('IMPORTANT','The folder that is used to store Extracts was not found.'+Chr(13)+;
*!*                            'Please have an administrator define this System Preference.')
*!*   oApp.msg2user('IMPORTANT','The folder that is used to store Extracts was not found.'+Chr(13)+;
*!*                             'Please have an administrator define this System Preference.')
*!*   oApp.msg2user('RSR_MSG3',Date(),Date())
*!*   oApp.msg2user('GENERROR','At least one selection is required to perform a search.')
*!*   cMessage="NOTE: Any Verified Dates that are after the 'End Date' will be deleted.  "+Chr(13)+"Before 'Saving', please check the End Date entered."
*!*   oApp.msg2user('IMPORTANT',cMessage)
*!*   cMessage1="The 'End Date' will be saved but the 'Verified Dates' after"+Chr(13)+"the 'End Date' have been deleted."
*!*   cMessage1="The 'End Date' will be saved but the 'Last Date Verified' was"+Chr(13)+"updated to reflect the new information."+Chr(13)
*!*   cMessage2="Since this has ended, it is expected that a new history record be"+Chr(13)+"added to keep the information current."+Chr(13)
*!*   oApp.msg2user('IMPORTANT',cMessage1+cMessage2)
*!*   oApp.msg2user('IMPORTANT',"NOTE: Any Verified Dates that are after the 'Treatment End Date'"+Chr(13)+;
*!*                             "will be deleted.  Before 'Saving', please check the"+Chr(13)+" 'Treatment End Date' entered."+Chr(13))
*!*   oApp.msg2user('MESSAGE','There were no clients found with missing data.')
*!*   oApp.msg2user('SYRNGXMSG2')
*!*   oApp.msg2user('IMPORTANT','Based on this diagnosis and "HIV Status" of CDC Defined AIDS (10)'+Chr(13)+' was entered.')
*!*   oApp.msg2user('MESSAGE','All the fields must be completed or use "Search Mode".')
*!*   oApp.msg2user('HCV1')
*!*   oApp.msg2user("IMPORTANT","There is no information that can be used for this report"+Chr(13)+ "that match the time frame and/or options entered.")

*!*  oApp.msg2user("MSG_YESNO",'Both Funding and Program were entered, only one can be used.'+Chr(13)+;
*!*                         'You can select Funding or Program, but not both.',;
*!*                         'The report will use Funding, do you want to proceed?')

*!*  oApp.msg2user("MSG_YESNO",'Both Funding and Program were entered, only one can be used by this report.  You can select Funding or Program, but not both.',;
                               'The report will use Funding, do you want to proceed?')

*!* oApp.msg2user('INFORM','The HIV Status of CDC defined AIDS that was created by this diagnosis will be removed.')

*!* oApp.msg2user('INFORM','There is an HIV status of "CDC Defined AIDS" for this'+Chr(13)+'client that cannot be removed automatically.'+Chr(13)+'Please review the information for this client and determine if the "CDC Defined AIDS" should also be removed. If so, you must remove it from the HIV status form.')

*!* oApp.msg2user('FINANCE111')
*!* oApp.msg2user('INFORM','This client is defined as being "Not Pregnant"; nothing is editable.')

*!* oApp.msg2user('RSR_MSG3',Date(),Date())

*!* oApp.msg2user('IMPORTANT','This Risk information is linked to an HCV Rapid Test,'+Chr(13)+'the "Effective Date" is not editable.')
*!* oApp.msg2user('MESSAGE','The Visits will be deleted when this information is saved.')

*!* ? oApp.msg2user('MSG_YESNO','Would you like to add another Anonymous Referral','for the same Site, Program, Staff and Date?')

*!* oApp.msg2user('INFORM','Important'+Chr(13)+;
                       'Site, Program, Staff & Date are not editable, all other fields can be changed.'+Chr(13)+;
                       'To change these fields you will need to first delete then reenter the referral.')
*!* oApp.Msg2user('AREUSURE','Remove','remove this anonymous refefferal')
*!* oApp.Msg2user('MSG_YESNO','Please respond...','Are you sure that you want to remove this anonymous refefferal?')
*!* oApp.msg2user('IMPORTANT', 'Processing was not completed...'+Chr(13)+' The archive (zipped) file could not be created.')
*!* oApp.Msg2user('IMPORTANT','** IMPORTANT **'+Chr(13)+;
                             'EPI Extract was created, archived (zipped), encrypted and saved.'+Chr(13)+;
                             'However, The extract that was prepared containes only one record'+Chr(13)+;
                             'indicating that there was no new or updated information since the last run.'+Chr(13)+;
                             "Use the 'Save to Disk' button to copy the zip file to disk for forwarding.")

*!* oApp.Msg2user('GRPENCSVCS')

*!* oApp.Msg2user('IMPORTANT','** IMPORTANT **'+Chr(13)+;
                             'EPI Extract was created, archived (zipped), encrypted and saved.'+Chr(13)+;
                             'However, The extract that was prepared contains only one record'+Chr(13)+;
                             'indicating that there are no new records or updated information to'+Chr(13)+;
                             'report since last reported.  Click "Save to Disk" to save the zip file.'+Chr(13)+;
                             'Once saved forward to the AIDS Institute via the NYSDOH Secure HDN')

*!* oApp.Msg2user('INFORM','EPI Extract was successfully created, archived (zipped), encrypted and saved.'+Chr(13)+;
                       'Click "Save to Disk" to save the zip file. Once saved forward to the'+Chr(13)+;
                       'AIDS Institute via the NYSDOH Secure HDN')
                       

*!* oApp.Msg2user('GRPNOCHANG')

*!* oApp.Msg2user('EPINOCHANG')

*!* oApp.Msg2user('INFORM','EPI Extract was successfully created, archived (zipped), encrypted and saved.'+Chr(13)+;
                             'Click "Save to Disk" to save the zip file. Once saved forward to the'+Chr(13)+;
                             'AIDS Institute via the NYSDOH Health Commerce System (HCS)')
*!* oApp.Msg2user('EPICHANGED')

*!* oApp.msg2user('INFORM','Important: When Editing...'+Chr(13)+;
                     'Site, Program, Staff, and Date fields are not editable.  All other fields can be changed.  Once back on the screen, click [Edit] to proceed.'+Chr(13)+Chr(13)+;
                     'If the Site, Program, Staff, and/or Date fields must be changed, you will need to delete the record and reenter the referral.'+Chr(13))

*!* oApp.Msg2user('GRPENCSVCS')

*!* oApp.Msg2user('INFORM','EPI Extract was successfully created, archived (zipped), encrypted and saved.'+Chr(13)+;
                       'Click "Save to Disk" to save the zip file. Once saved forward to the'+Chr(13)+;
                       'AIDS Institute via the NYSDOH Health Commerce System (HCS)')



*!* oApp.Msg2user('IMPORTANT','The Provider Report must be printed prior to completing the RSR Extract.'+Chr(13)+'Output will be sent to the default printer or select an alternate device.')
*!* oApp.Msg2user('INFORM','Printing Cancelled - You will be returned to the menu.')
*!* oApp.Msg2user('IMPORTANT','HCV Treatment Types were not updated.'+Chr(13)+'Please contact support with information about this entry.')
*!* oApp.msg2user("INFORM",'This "Insurance Provider" is not part of a "Plan".'+Chr(13)+'The "Plan" information will be removed.')
*!* oApp.msg2user("HEPNOSAVE",'Infected (acute)')
*!* oApp.msg2user("IMPORTANT",+'Planning File import cannot proceed until the following is resolved...'+Chr(13)+'Exclusive use of the PEMS tables could not be secured.'+Chr(13)+'Please contact support with the following message "control.urs" is missing.' )
*!* oApp.msg2user("IMPORTANT",'This "Insurance Provider" is not part of a selected "Plan"...'+Chr(13)+;
                             'The "Plan" information will be removed.')
*!* oApp.msg2user("IMPORTANT",'This "Insurance Provider" is not part of a "Plan"...'+Chr(13)+;
                                       'The "Plan" information will be removed.')
*!* oApp.msg2user("IMPORTANT",'This version of the report is not historical.'+Chr(13)+;
                          "The 'As Of Date' has been changed to today's date.")

*!* oApp.msg2user("IMPORTANT",'Problem...'+Chr(13)+'"Date Asked" must be completed before you can proceed.')
*!* oApp.msg2user("MSG_YESNO",'** IMPORTANT **'+Chr(13)+"An Adult HIV Status 'HIV-Positive, CDC-Defined AIDS (10)' must be added for this formerly pediatric client."+Chr(13)+"Would you like to proceed?")
*!* oApp.msg2user("IMPORTANT","The client Pediatric HIV Status should be updated to the adult status"+Chr(13)+"'HIV-Positive, CDC-Defined AIDS' (10)."+Chr(13)+"Press the 'Add' button to insert a new status.")
*!* oApp.Msg2user('AREUSURE','Remove','remove this anonymous refefferal')
*!* oApp.msg2user("OSWARNING")
*!* oApp.Msg2User("INFORM", "An (ARV) Drug Therapy History record indicating that the client is"+Chr(13)+"On ARV therapy was created.")
*!* oApp.Msg2User("INFORM", "An (ARV) Drug Therapy History record indicating that the client is"+Chr(13)+"Not on ARV therapy was created.")

*!* oApp.Msg2User("INFORM", "An (ARV) Drug Therapy History record indicating that the client is"+Chr(13)+;
*!*                         "ON ARV Therapy was created.")

*!* oApp.Msg2User("INFORM", "An (ARV) Drug Therapy History record was Not Created for this client"+Chr(13)+;
                        "because ARV Drug Therapy record(s) already exist."+Chr(13)+;
                        "Please review the Drug Therapy History for this client.")
                        
*!* oApp.Msg2User("ONLYSOME",'HIV Status of "CDC Defined AIDS"....')
*!* oApp.Msg2user('NOCLRHOST','','Please contact support to assist you in solving this problem [2].  '+;
                                 'Extract processing will contiue.')

*!* oApp.msg2user("IMPORTANT","The AIDS Institute Extract was successfully created.  Use the"+Chr(13)+;
                          "'Save To Disk' option to copy the file to the 'Extracts' folder."+Chr(13))


*!* oApp.msg2user("MESSAGE","The AIDS Institute Extract was successfully processed. But, a problem"+Chr(13)+;
                            "was encountered while trying to archive (ZIP) the file."+Chr(13))

*!* oApp.msg2user('AIEXTRACT1')


*!* oApp.msg2user("INFORM",'The AIDS Institute Data Extract was completed.'+Chr(13)+;
                        'However, one or more data errors were found. The extract can be sent'+Chr(13)+;
                        'as you normally would do.  Use the "Save To Disk" option to copy the'+Chr(13)+;
                        'file to the "Extracts" folder. Please log a support request with the'+Chr(13)+;
                        'subject "Data Problem In AI Extract" to resolve the problem.')
                          
*!* oApp.msg2user('AIEXTRACT1')
*!* oApp.msg2user('GENERROR','XML Import Canceled...'+Chr(13)+;
                         'The file you have selected is not an XML file.'+Chr(13)+;
                         'Please select the PEMS XML file for your agency.')

* oApp.Msg2User("INFORM", 'The file "ClientVerificationStatus.csv" was copied to the extracts folder.')

*!* oApp.Msg2User("DRUGREG1")
*!* oApp.Msg2User("DRUGREG2")
*!* oApp.Msg2User("DRUGREG3")

* oApp.msg2user("MSG_YESNO",'You have entered a partial "eUCI" (less than 41 characters).'+Chr(13)+;
                          'The search may return more than 1 row.'+Chr(13)+;
                          'Do you want to proceeed anyway?')
                          
* oApp.msg2user("GENERROR",'You must enter a Client, TC ID or eUCI to search.')

*!*   oApp.msg2user('NOTFOUNDG')
*!*   oApp.msg2user('NOTFOUNDC','The eUCI that was provided',"eUCI's from the last RSR submission. Check the number and try again")
*!*   oApp.msg2user('MEDINDIC')
*!*   oApp.Msg2user('UNKNOWN2')
*!*   oApp.msg2user("LABTESTPRV")
*!*   oApp.msg2user("MSG_YESNO", "Only eUCI numbers from the last RSR submission are searched."+Chr(13)+;
                           'Do you want to proceeed?')
                          
*!*   oApp.msg2user("MESSAGE",'There already is a record for the current reporting year.'+Chr(13)+'Use Edit to modify the selected information.')
*!*   oApp.msg2user('UNKNOWN2')

*!*   oApp.msg2user("IMPORTANT",'RSR-Funded Service Categories for the current year will be created.'+Chr(13)+;
                                'Service lines that are funded by Part B are preselected and cannot be changed.  Carefully review the list and make the necessary additions.'+Chr(13)+' ')
*!*   oApp.msg2user('RSR_SC2','2015')

*!*   oApp.msg2user("RSR_CL2")
*!*   oApp.msg2user("RSR_MSG1",{01/01/2015},{12/31/2015})
*!*   oApp.msg2user("RSR_SC3")
*!*   oApp.msg2user("RSR_SC")
*!*   oApp.msg2user("RSR_MSG1",{01/01/2015},{12/31/2015})
*!*   oApp.msg2user("RSR_SC2",Year({01/01/2015}))
*!*   oApp.msg2user("RSR_SC3")
*!*   oApp.msg2user("VL_CONFIRM")

*!*   oApp.msg2user("MESSAGE",'DOB must be entered before you can enter HIV status.')

*!*   oApp.msg2user('MSG_YESNO',;
                 'You have checked the "ICD10 - Implemented" flag.'+Chr(13)+;
                 'All files for this "Claim Output Format" will use the ICD10 Diagnosis Code.'+Chr(13)+;
                 '(Note: Uncheck this flag to revet back to the ICD9 diagnosis code)',;
                 'Are you sure this is correct?')
*!*   oApp.msg2user("COMPLETED")
*!*   oApp.msg2user("MESSAGE",'AIRS Data Process was Cancelled!' )
*!*   oApp.msg2user("IMPORTANT",'The RSR Client Detail CSV export was copied to...'+Chr(13)+;
                          'rsr_extracts\rsr_client_detaisl.csv'+Chr(13)+' ')
*!*   oApp.msg2user("HA_ADD1")
*!*   oApp.msg2user("MSG_YESNO",'Seleting a "Test" requires reentering the "Test Result".'+Chr(13)+'01 Negative (-)','Do you want to proceeed anyway?')
*!*   oApp.msg2user("IMPORTANT",'Clients who received reportable Services but are not reportable'+Chr(13)+;
                          'was copied to C:\4peter\asdfasdfasdfas.csv')
*!*   oApp.msg2user('HA_REMOVE1')
*!*   oApp.msg2user('HA_REMOVE2')                          
*!*   oApp.msg2user('HA_REMOVE3')
*!*   oApp.msg2user("HA_SUBSTAD")
*!*   oApp.msg2user("IMPORTANT",'A default location for the extracted files could not be accessed.'+Chr(13)+'Please check the system options to set a location that you can access.')
*!*   oApp.msg2user("IMPORTANT",'* There are files in the destination folder *'+Chr(13)+;
*!*                             'All files in the destination folder will be deleted and replaced'+Chr(13)+;
*!*                             'with the ones selected.')
*!*   oApp.msg2user("WAITRUN ",'Data Extract Processing was completed'+Chr(13)+;
*!*                            'Preparing Report...')

*!*   oApp.msg2user("CANTDEL2","This 'Primary Insurance' record when other insurances are in place.","Remove the other insurance records first.")
*!*   oApp.msg2user("GENERROR","Primary Insurance can't be changed from 'Primary' to 'Secondary', 'Tircheary' or 'Other'.")

*!*   oApp.msg2user("MESSAGE",'The new AIRS Data Extract(s) module has been enabled.'+Chr(13)+'You can use this same option to revert to the original module.  Other logged-in users may need to restart AIRS to gain access to this module.')
*!*   oApp.msg2user("MESSAGE",'The new AIRS Data Extract(s) module has been Disabled.'+Chr(13)+'The new module can be re-enabled at any time. Other logged-in users may need to restart AIRS to gain access to this module.')


*!*   oApp.msg2user("MESSAGE",'The new AIRS Data Extract(s) module has been enabled. '+Chr(13)+;
                             'Use this option to re-enable to the original "Data Extract" module.'+Chr(13)+;
                             'NOTE:  Currently logged-in users may need to restart AIRS to gain access to this new process.')
                             
*!*   oApp.msg2user("GENERROR","Cleanup failed.  Please contact your system administrator to check the security permissions or in-use status for the files in the destination folder.")

*!*   oApp.msg2user("GENERROR","'Start Date' can't be empty and must be less than the 'End Date'.")

*!*   oApp.msg2user("MESSAGE",'There are no open enrollments for the selected program.')
*!*   oApp.msg2user("MESSAGE",'An "HCV Rapid Test Lab Test" record was created from this Rapid Test.')
*!*   oApp.msg2user("MESSAGE",'"HCV Rapid Test Lab Test" record was updated information from this rapid test.')
*!*   oApp.msg2user("MSG_YESNO",'The Lab Test that was created from this rapid test will also be deleted.','Do you want to proceeed?')

*!*   oApp.msg2user("IMPORTANT",'A default location for the extracted files could not be accessed.'+Chr(13)+;
                          'Please check the system options to set a location that you can access.'+Chr(13))

*!*   oApp.msg2user("MESSAGE",'The new AIRS Data Extract(s) module has been enabled. '+Chr(13)+;
                        'Use this option to re-enable to the original "Data Extract" module.'+Chr(13)+;
                        'NOTE:  Currently logged-in users may need to restart AIRS to gain access to this new process.')

*!*   oApp.msg2user("HCVRAPID1",'09/22/2016','Negative')
*!*   oApp.msg2user("HCVRAPID2",'09/22/2016','Negative')
*!*   oApp.msg2user("HCVRAPID3",'09/22/2016','Negative')
*!*   oApp.msg2user("HCVRAPID4",'09/22/2016')
*!*   oApp.msg2user('HCVRAPID1D',' - Referrals made with this Rapid Test')
*!*   oApp.msg2user('HCVRAPID1D',' ')
*!*   oApp.msg2user('HCVRAPID3D',' - Referrals made with this Rapid Test')
*!*   oApp.msg2user('HCVRAPID3D',' ')
*!*   oApp.msg2user('HCVRAPID4D',' - Referrals made with this Rapid Test')
*!*   oApp.msg2user('HCVRAPID4D',' ')
*!*   oApp.msg2user('HCVRAPID5D',' ')
*!*   oApp.msg2user('EPIEXTRACT','C:\AIRS\EXTRACTS\asdfasdf.zip')
*!*   oApp.msg2user("MESSAGE","A new Primary Insurance / Payment type can't be added until the current one is ended or expired."+Chr(13)+'   ')
*!*   oApp.msg2user('HCVRAPID1','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID2','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID3','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID4','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID5','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID6','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID7','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID8','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID1D',' - Referral(s)'+Chr(13)+;
                                 ' - HCV Risk Information')
*!*   oApp.msg2user("MESSAGE","Insurance/Coverage information has been Verified. To add a ‘new’ record, a valid ‘Expiration Date’ must be added to the current record."+Chr(13)+'  ')
*!*   oApp.Msg2user('PEMSPROB','Service Categories',Dtoc(Date()))
*!*    oApp.msg2user("MESSAGE",'The V8.9 "AIRS Data Extracts" module been Enabled.'+Chr(13)+;
*!*                            'You can use this option to the re-enable the original module.'+Chr(13)+;
*!*                            'NOTE: Logged-in users may need to restart AIRS to regain access.')
*!*  oApp.msg2user("MESSAGE","The V8.9 'AIRS Data Extracts' module has been Disabled."+Chr(13)+;
              "At any time, you may use this option to re-enable the"+Chr(13)+;
              "V8.9 'AIRS Data Extracts'."+Chr(13)+;
              "NOTE: Logged-in users may need to restart AIRS to regain access.")
*!*  oApp.msg2user("MESSAGE","You must enter an expiration date for the current record before a new 'Primary' insurance/coverage record can be entered."+Chr(13)+'  ')
*!*  oApp.msg2user("NOERAFOLDR")
*!*  oApp.msg2user("MESSAGE","Changes were made to 'HCV Risk' to accurately reflect the 'HIV Status'."+Chr(13)+;
                        "Please review the 'HCV Risk' information for this client.")
*!*  oApp.msg2user("HCV1")
*!*  =oApp.Msg2user('INFORM','A response to the HCV Treatment "Experience" is required.')
*!*  =oApp.Msg2user('MESSAGE','A response to the HCV Treatment "Experience" is required.')
*!*  =oApp.Msg2user('GENERROR','A response to the HCV Treatment "Experience" is required.')
*!*  =oApp.Msg2user('MESSAGE',"You've indicated that the client is 'HCV Treatment Experienced'."+Chr(13)+"All HCV Treatment records were updated to reflect this information.")
*!*  =oApp.Msg2user('LIMPORTANT','A one-time setting that will identity the client as Treatment "Naïve" or "Experienced"'+Chr(13)+'prior to "HCV Treatment" information collected at this agency.'+Chr(13)+'If "Experienced" is selected, all treatment history records will be flagged "Experienced".')
*!*  =oApp.Msg2user('MESSAGE',"This program has already been selected."+Chr(13)+"Please select a different program")
*!*  =oApp.Msg2user('LIMPORTANT',"This program has already been selected."+Chr(13)+"Please select a different program")
*!*  =oApp.Msg2user('INFORM',"This program has already been selected."+Chr(13)+"Please select a different program")
*!*  =oApp.Msg2user('GENERROR',"This program has already been selected."+Chr(13)+"Please select a different program>")
*!*  =oApp.Msg2user('WARNING',"If you 'Close' now your last pending-entry won't be added to the list of program enrollments.")
*!*  =oApp.Msg2user('YES_NO',"If you 'Close' now your last pending-entry won't be added to the list of program enrollments.")
*!*  =oApp.Msg2user('DOYOUWANT',"If you 'Close' now your last pending-entry won't be added to the list of program enrollments.",'continue anyway?')
*!*  =oApp.Msg2user('MSG_YESNO',"If you 'Close' now the pending entry will not be added to the list of program enrollments.",'Do you want Close anyway?'+Chr(13)+'  ')
*!*  =oApp.Msg2user('MSG_YESNO',"Your last entry was not added to the list of program enrollments."+Chr(13)+;
                                "Press 'Add to Program Enrollments' if you want to add this row."+Chr(13)+'  ',"Do you want 'Close' anyway?")
*!*  mAdditionalMsg= '"HCV Treatment Experience" for this client has not been set.'
*!*  mAdditionalMsg= 'HCV Treatment - set to Experienced on 05/08/2017.'
*!*  =oApp.Msg2user('HCVTREATEX',mAdditionalMsg)
*!*  =oApp.Msg2user('PWMUSTCHNG')
*!*  =oApp.Msg2user('NOAIRS4YOU')
*!*  =oApp.Msg2user('GENERROR',"Required Information Missing"+Chr(13)+"The 'Login Name' must be entered first.")
*!*  =oApp.Msg2user('PW_RESET')
*!*  =oApp.Msg2user('GENERROR','This account has been Locked.'+Chr(13)+'Access to AIRS will not be granted until your account is unlocked.')
*!*  =oApp.Msg2user('GENERROR','This account has been disabled.'+Chr(13)+'Please contact the system adminstrator for assistance.')
*!*  =oApp.Msg2user('GENERROR','Incorrect Password: '+Transform(4,'@rb 9')+' attempt(s) remain.')
*!*   =oApp.Msg2user('GENERROR','* ACCOUNT LOCKED *'+Chr(13)+;
*!*                  'Access to AIRS will not be granted until your account is unlocked.'+Chr(13)+;
*!*                  'Please contact the AIRS system administrator for assistance.')
*!*   =oApp.Msg2user('GENERROR','* ACCOUNT LOCK NOTICE* '+Chr(13)+;
*!*                  'You have exceeded the maximum number of failed login attempts.'+Chr(13)+;
*!*                  'As a result your account has been locked.  Please contact the AIRS '+Chr(13)+;
*!*                  'system administrator for assistance.')
*!*   =oApp.Msg2user('GENERROR','* ACCOUNT DISABLED  * '+Chr(13)+;
                          'This account has been disabled.'+Chr(13)+'Please contact the system adminstrator for assistance.')
*!*   =oApp.msg2user('GENERROR','Login Name and Password are both required.'+Chr(13)+'Try Again.')
*!*   nLockOutDuration=15
*!*   =oApp.Msg2user('PW_LOCKED1',Alltrim(Transform(nLockOutDuration,'999')))
*!*   =oApp.Msg2user('PW_LOCKED2')
*!*   =oApp.Msg2user('PW_LOCKED3','15')
*!*   =oApp.Msg2user('PW_LOCKED4')
*!*   =oApp.Msg2user('PW_WARNING')
*!*   =oApp.Msg2user('INFORM',"Access cannot be granted until the last name and first name are entered.")
*!*   =oApp.Msg2user('GENERROR','** ACCESS DENIED **'+Chr(13)+;
                                'There is a problem with the password for your account.'+Chr(13)+;
                                'The AIRS System Administrator must review your account and'+Chr(13)+;
                                'enter a new password from the Staff Information Form.'+Chr(13))
*!*   nAccounts=2
*!*   =oApp.Msg2user('GENERROR','** ACCESS DENIED **'+Chr(13)+;
*!*                             'There is a problem with the Login Name for your account.'+Chr(13)+;
*!*                             'There are '+Alltrim(Transform(nAccounts,'999'))+' staff associates with the same "Login Name".'+Chr(13)+;
*!*                             'The AIRS System Administrator must review these accounts from'+Chr(13)+;  
*!*                             'from the Staff Information Form.'+Chr(13))
*!*    =oApp.Msg2user('GENERROR','** ACCESS DENIED **'+Chr(13)+;
                 'There is a problem with the ID associated with this account.  The'+Chr(13)+;
                 'AIRS System Administrator must retire this account and enter a new'+Chr(13)+;
                 '"Staff" account for you.'+Chr(13)+'- Or -'+Chr(13)+;
                 'The AIRS System Administrator should also create a Support'+Chr(13)+;
                 'request with "Failed staff_id during Login" in the subject line.')
*!*   oApp.msg2user('HCVRAPID1A','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID2A','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID3A','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID4A','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID5A','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID6A','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID7A','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID8A','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID1','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID2','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID3','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID4','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID5','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID6','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID7','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('HCVRAPID8','01/01/2015','Non-reactive (Negative)')
*!*   oApp.msg2user('RSR_MSG1','01/01/2017','12/31/2017')

*!*   oApp.Msg2user('CSEARCH3','CTR Form ID')
*!*    cPartoPass="'24' clients have been identified who are NOT included in the RSR."+Chr(13)+;
*!*               "They received at least 1 reportable Service but do not currently meet"+Chr(13)+;
*!*               "the Ryan White Eligibility criteria based on data entry in AIRS."+Chr(13)+"These clients need to be reviewed."+Chr(13)+'*'

*!*    oApp.msg2user('RSR_INFO1',cPartoPass)

*!*    cPartoPass="999 clients received at least 1 reportable service but DO NOT currently"+Chr(13)+;
*!*    "meet RW Eligibility Criteria. These clients are currently not in the RSR and"+Chr(13)+;
*!*    "MUST be reviewed! Please run the RSR CLIENT LIST for details."+Chr(13)+;
*!*    "(REPORTS -> RSR Completeness Reports)"
*!*    oApp.msg2user('RSR_INFO1',cPartoPass)

*!*    cFailedTable='AI_ENC'
*!*    oApp.msg2user('GENERROR','*** LOGIN PROCESS HALTED ***'+Chr(13)+;
*!*                             'There is a problem accessing the table "'+cFailedTable+'".'+Chr(13)+;
*!*                             'Notify your AIRS Administrator about this serious problem.'+Chr(13)+;
*!*                             'Press Ok to Exit')

*!*    oApp.msg2user("HA_SUBSTAN","'Housing Retention Risk Assessment'","Housing Retention Risk Assessment")
*!*    oApp.msg2user("HA_SUBSTAN","'HUB Assessment'","HUB Substance Use Assessment")

*!*   =oApp.msg2user("MESSAGE",'* View Only *'+Chr(13)+'This information was converted from and older version of AIRS.'+Chr(13)+'Some of the substances displayed are no longer being tracked.'+Chr(13))
*!*   =oApp.msg2user("OSWARNING")
*!*   =oApp.Msg2user('GENERROR','* SECURITY MEASURE *'+Chr(13)+;
*!*                             'As of Spring 2018, the "ADMIN" Login Name that was originally'+Chr(13)+;
*!*                             'provided to all URS/AIRS agencies has been retired.'+Chr(13)+Chr(13)+;
*!*                             'Please have an AIRS administrator create a new staff account for you.'+Chr(13))
*!*   =oApp.Msg2user('GENERROR','Problem'+Chr(13)+;
*!*                  'The screening date entered is out of range for the contract period. '+Chr(13)+;
*!*                  "This screening information can't be saved")

*!*   =oApp.msg2user("REMOVE1",'Substance Screening','of 06/11/2018')
*!*   =oApp.msg2user("GENERROR",'"Service Date" within the contracted period could not be located.')
*!*   =oApp.msg2user("IMPORTANT",'* Important *'+Chr(13)+'An Intake/Assessment/Evaluation service is required'+Chr(13)+'and must be selected before you can save this information.'+Chr(13)+Chr(13))

*!*   =oApp.msg2user("CANTDELINT")

*!*   =oApp.msg2user("HUBSAVE1",'The Encounter "Harm Reduction/Medical Care" with the selected'+Chr(13)+;
                                'service(s) has been saved. You can only edit this encounter through'+Chr(13)+;
                                'this module.'+Chr(13)+Chr(13))

*!*   =oApp.msg2user("HUBSAVE1",'An encounter has been added for this service. To update referral (linkage)'+Chr(13)+;
                                'information please use this module or Referral Tracking. '+Chr(13)+Chr(13))

*!*   =oApp.msg2user("GENERROR2",'"Service Date" within the contracted period could not be located.'+Chr(13)+'Another Line for messages')

*!*   =oApp.Msg2user('GENERROR','* Problem *'+Chr(13)+Chr(13)+;
*!*                            'This client was not enrolled in a CJI program on the "Date Asked".'+Chr(13)+;
*!*                            'Enter corrected "Date Asked" or Cancel this transaction.')

*!*   =oApp.Msg2user('GENERROR','** Problem **'+Chr(13)+;
*!*                             "- This Initiative can't be selected -"+Chr(13)+Chr(13)+;
*!*                             'The "Date Asked" is out of range for the program contract period.'+Chr(13)+;
*!*                             'Please check the planning file for valid dates for this program.')

*!*    =oApp.msg2user("HUBSAVE1",'The following activtity was also completed...'+Chr(13)+;
                                   '- An Encounter for "Linkage/Navigation" was created on 04/02/2018.'+Chr(13)+;
                                   '   - Service "Linkage to HCV Provider Post-Release" was created.'+Chr(13)+; 
                                   '- Referral:"Care Cordination"; 04/04/2018.'+Chr(13)+;
                                   '- Referral:"HCV Medical Evaluation and Treatment"; 04/04/2018.')

*!*   cEncMessage='Encounter Message'
*!*   cRefCBOMessage='CBO Message'
*!*   cRefHCVMessage='HIV Message'
*!*   cEncMessage=''
*!*   cNewMessage='The following activtity was also completed...'+Chr(13)+;
*!*                     cEncMessage+;
*!*                     Iif(!Empty(cEncMessage),Chr(13),'')+cRefCBOMessage+;
*!*                     Iif(!Empty(cRefCBOMessage),Chr(13),'')+cRefHCVMessage
*!*   =oApp.msg2user("IMPORTANT",cNewMessage)

*!*   Dimension _aGenCount(1)
*!*   _aGenCount[1]=5000

*!*   cMessageProgram=''
*!*   cMessageProgram=cMessageProgram+'- Active program Enrollments:'+Alltrim(Transform(_aGenCount[1],'@r 999,999'))+Chr(13)
*!*   cMessageProgram=cMessageProgram+'- Groups still active:'+Alltrim(Transform(_aGenCount[1],'@r 999,999'))+Chr(13)
*!*   cMessageProgram=cMessageProgram+'- Groups enrollments still active:'+Alltrim(Transform(_aGenCount[1],'@r 999,999'))+Chr(13)
*!*   =oApp.Msg2user('PROGSTATUS',cMessageProgram)

*!*   =oApp.msg2user("CANTDELINT")

*!*   =oApp.msg2user("HUBSAVE1", "The Encounter 'Harm Reduction/Medical Care' was created with"+Chr(13)+;
                                 "the selected service(s)."+Chr(13)+Chr(13)+;
                                 "PLEASE NOTE... "+Chr(13)+;
                                 "This encounter and service(s) can only be editied or deleted through"+Chr(13)+;
                                 "this 'Health Hub Drug Treatment' module."+Chr(13)+" ")

 *!*  =oApp.msg2user("HUBSAVE1", "The Encounter 'Harm Reduction/Medical Care' and Service"+Chr(13)+;
                             "'Linkage to OASAS Treatment' have been created for this linkage."+Chr(13)+Chr(13)+;
                             "To update the Referral (Linkage) information, use this screen or the"+Chr(13)+;
                             "'Referral Tracking' screen."+Chr(13)+' ')
                             
=oApp.Msg2user('IMPORTANT',"Good News!"+Chr(13)+"No data quality issues were found."+Chr(13)+"Press 'Done' to continue/exit"+Chr(13)+'   ')