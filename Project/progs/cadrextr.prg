PARAMETER dStartDate, dEndDate, oExtrForm1

PRIVATE cRepPeriod

* define period for report
cRepPeriod = DTOC(dStartDate)+'-'+DTOC(dEndDate)

* Get the log_id for a new entry
cLog_ID = GetNextId("EXTRALOGID")
IF TYPE("cLog_ID")<>"C"
	oApp.Msg2User("NONEXTID")
	RETURN
ENDIF

* jss, 4/15/05, define variables here to be used when comparing numbers from Section2 with those in Section6.1 and Section6.2
m.sect2posin=0
m.sect61posi=0
m.sect2all=0
m.sect62all=0

SET CENTURY OFF
* SET UDFPARMS TO VALUE

If Empty(Nvl(oApp.gcrdr_folder,''))
   If Directory(Addbs(Sys(05)+Sys(2003))+'EXTRACTS')
      oApp.gcrdr_folder=Addbs(Sys(05)+Sys(2003))+'EXTRACTS'
   Else
      oApp.gcrdr_folder=Addbs(Sys(05)+Sys(2003))
   EndIf
EndIf
      
cFileZip=gcSys_Prefix + 'CA' + PADL(Month(dEndDate),2,"0") + RIGHT(Str(Year(dEndDate)), 2) + ".ZIP"

cTempDir=Addbs(Sys(2023))

cFileName1 = cTempDir + "SECTION1.DBF"
cFileName2 = cTempDir + "SECTION2.DBF"
cFileName3 = cTempDir + "SECTION3.DBF"
cFileName4 = cTempDir + "SECTION4.DBF"
cFileName5 = cTempDir + "SECTION5.DBF"
cFileNam61  = cTempDir + "SECTIO61.DBF"
cFileNam61b = cTempDir + "SECTIO61a.DBF"
cFileNam62  = cTempDir + "SECTIO62.DBF"
cFileName7  = cTempDir + "SECTIO61e.DBF"   && New table for 2008 RDR 
cFileName8  = cTempDir + "C_AND_T.DBF"   && New table for 2008 RDR 

oThermo=NewObject('thermobox','standard','',"Creating RDR Extract")
oThermo.show


* create section 1
oThermo.refresh("Building Section 1...", 20)
=Section1()

* prep for sections 2 & 3
oThermo.refresh("Preparing Data for Sections 2 & 3...", 30)

DO sect23prep IN rpt_cadr

* create section 2 
oThermo.refresh("Building Section 2...", 50)
=Section2()

* create section 3 
oThermo.refresh("Building Section 3...", 60) 
=Section3()

* create section 4 
oThermo.refresh("Building Section 4...", 70) 
=Section4()

* create section 5 
oThermo.refresh("Building Section 5...", 80) 
=Section5()

* create section 6 
oThermo.refresh("Building Section 6...", 90)
=Section6()

**********************************************
oThermo.refresh("Completed creating extract.", 100)
* zip the extract files, log the zipped extract files, and put the zipped extract files into the memo field
oThermo.Release

cFileList=cFileName1+' '+cFileName2+' '+cFileName3+' '+cFileName4+' '+cFileName5+' '+cFileNam61+' '+cFileNam62+' '+cFileName7+' '+cFileName8

oExtrForm1.height=163
oExtrForm1.oZipMonitor.citems2zip=cFileList
oExtrForm1.oZipMonitor.cstoragelocation = cFileZip
oExtrForm1.oZipMonitor.zip_files()

SET CENTURY ON
lSuccess=Iif(oExtrForm1.oZipMonitor.dzocx11.errorcode=0,.t.,.f.)   && gET THE RESULT OF THE ZIP

IF lSuccess
	select EXTRALOG
	APPEND BLANK
	REPLACE ;
		Extralogid WITH cLog_Id ,;
		Userprompt WITH cRepPeriod, ;
		Createdate WITH DATE(), ;
		Createtime WITH TIME(), ;
		Userdef1   WITH DTOC(dStartDate),;
		Userdef2   WITH DTOC(dEndDate),;
		Userdef3   WITH Str(nScope, 1, 0) ,;
		Exfilename WITH cFileZip,;
		Extra_id   WITH '700', ;
		user_id    WITH gcWorker ,;
		dt         WITH DATE()  ,;
		tm         WITH TIME()

	APPEND MEMO backupfile FROM (cFileZip) OVERWRITE

	ERASE (cFileZip)
	ERASE (cFileName1)
	ERASE (cFileName2)
	ERASE (cFileName3)
	ERASE (cFileName4)
	ERASE (cFileName5)
	ERASE (cFileNam61)
	ERASE (cFileNam62)
   Erase (cFileName7)
   Erase (cFileName8)
      
   MESSAGEBOX(cFileZip + ' extract file was successfully created ...', 64, 'Extract Finished')
   oExtrForm1.height=103
   REQUERY('lv_extralog_filtered')
ELSE
   MESSAGEBOX("Problems with compressing the file...", 16, 'Problem')
ENDIF

SET UDFPARMS TO REFERENCE
Return

******************
PROCEDURE SECTION1
******************
* define sect1 cursor
If Used('sect1a')
   Use In sect1a
Endif
   
CREATE CURSOR ;
	sect1a (recid		C(10),;
			prvid 		C(4),;
			regcode		C(5),;
			prvname1	C(61),;
			fromdate	C(8),;
			thrudate	C(8),;
			prvaddr1	C(61),;
			prvcity		C(15),;
			state		C(2),;
			zip			C(5),;
			zip4		C(4),;
			contname	C(30),;
			conttitle	C(30),;
			phone		C(10),;
			fax			C(10),;
			email		C(30),;
			compname	C(35),;
			compphone   C(10),;
			compemail	C(35),;
			prystart	C(8),;
			pryend		C(8),;
			scope		C(1),;
			agtype		C(2),;
			taxid		C(9),;
			zipmain		C(5),;
			numbsite	C(3),;
			prvtype		C(2),;
			owner		C(2),;
			paidstaf	C(5),;
			volstaf		C(5),;
			c12			C(1),;
			c13			C(1),;
			c14			C(1),;
			section_33	C(17),;
			faithbased  C(3), ;
			maifunding	C(17),;
			title1_fun	C(1),;
			titl1code1  C(2), ;
			titl1name1	C(50),;
			titl1code2  C(2), ;
			titl1name2	C(50),;
			titl1name3	C(50),;
			title2_fun	C(1),;
			titl2code1  C(2), ;
			titl2name1	C(50),;
			titl2name2	C(50),;
			titl2name3	C(50),;
			title3_fun	C(1),;
			titl3name1	C(50),;
			titl3name2	C(50),;
			titl3name3	C(50),;
			title4_fun	C(1),;
			titl4name1	C(50),;
			titl4name2	C(50),;
			titl4name3	C(50))
         
* jss, 11/19/07, remove next 4 fields (Title 4 Adolescent checkbox and grantee names) for 2007 PDR         
*!*   			title4_ado	C(1),;
*!*   			titadname1	C(50),;
*!*   			titadname2	C(50),;
*!*   			titadname3	C(50))

If Used('sect1b')
   Use In sect1b
Endif
   
CREATE CURSOR ;
	sect1b	(plan_eval	C(1),;
			administra	C(1),;
			fiscal		C(1),;
			technical	C(1),;
			capacity	C(1),;
			quality		C(1),;
			onlyserv	C(1),;
			title1recd  C(9),;
			title2recd  C(9),;
			title3recd  C(9),;
			title4recd  C(9),;
			mai1recd	C(9),;
			mai2recd	C(9),;
			mai3recd	C(9),;
			mai4recd	C(9),;
			oralrecd    C(9),;
			migrant		C(1),;
			rural		C(1),;
			women		C(1),;
			children	C(1),;
			minorities  C(1),;
			homeless	C(1),;
			gay_youth	C(1),;
			gay_adults	C(1),;
			incarcerat	C(1),;
			adolescent	C(1),;
			runaway		C(1),;
			injection	C(1),;
			non_inject	C(1),;
			parolees	C(1),;
			other		C(1),;
			otherspeci	C(50),;
			am_board	C(1),;
			am_staff	C(1),;
			am_clinic	C(1),;
			am_served	C(1),;
			am_other	C(1),;
			title3prov  C(1),;
			title4prov  C(1),;
			apa_prov	C(1),;
			hip_prov    C(1),;
			version		C(25))

If Used('sect1')
   Use In sect1
Endif
   
SELECT ;
	sect1a.*, ;
	sect1b.* ;
FROM ;
	sect1a, ;
	sect1b ;
INTO CURSOR ;
	sect1

* reopen, make it writable
oApp.REOPENCUR('sect1','sect1tmp')
SCATTER memvar 

DO sect1 IN rpt_cadr

m.version=gcCadrVers

SELECT sect1tmp
APPEND BLANK
GATHER memvar

* now, create the dbf file
* jss, 7/25/07, add "fox2x" to copy in order to create FOXPRO 2.6 type tables
COPY TO &cFileName1 FOX2X

* close some tables/cursors
USE IN sect1a
USE IN sect1b
USE IN sect1tmp

RETURN
******************
PROCEDURE SECTION2
******************
* define sect2 cursor
If Used('sect2a')
   Use In sect2a
Endif
   
CREATE CURSOR ;
	sect2a (recid		C(10),;
			prvid 		C(4),;
			regcode		C(5),;
			prvname1	C(61),;
			tothivpos	C(6),;
			tothivind	C(6),;
			tothivneg	C(6),;
			tothivunk	C(6),;
			tothivtot	C(6),;
			newhivpos	C(6),;
			newhivind	C(6),;
			newhivneg	C(6),;
			newhivunk	C(6),;
			newhivtot	C(6),;
			malepos		C(6),;
			maleaff  	C(6),;
			femalepos	C(6),;
			femaleaff	C(6),;
			transpos	C(6),;
			transaff	C(6),;
			genunkpos	C(6),;
			genunkaff	C(6),;
			gentotpos	C(6),;
			gentotaff	C(6),;
			aless2pos	C(6),;
			aless2aff	C(6),;
			a212pos		C(6),;
			a212aff		C(6),;
			a1324pos	C(6),;
			a1324aff	C(6),;
			a2544pos	C(6),;
			a2544aff	C(6),;
			a4564pos	C(6),;
			a4564aff	C(6),;
			a65pluspos	C(6),;
			a65plusaff	C(6),;
			aunkpos		C(6),;
			aunkaff		C(6),;
			atotpos		C(6),;
			atotaff		C(6))

If Used('sect2b')
   Use In sect2b
Endif

CREATE CURSOR ;
	sect2b (whitepos	C(6),;
			whiteaff	C(6),;
			blackpos	C(6),;
			blackaff	C(6),;
			hisppos		C(6),;
			hispaff		C(6),;
			asianpos	C(6),;
			asianaff	C(6),;
			nativepos	C(6),;
			nativeaff  	C(6),;
			indianpos	C(6),;
			indianaff	C(6),;
			multipos	C(6),;
			multiaff	C(6),;
			unkracpos	C(6),;
			unkracaff	C(6),;
			racetotpos	C(6),;
			racetotaff	C(6),;
			inceqpos	C(6),;
			inceqaff	C(6),;
			inc101pos	C(6),;
			inc101aff	C(6),;
			inc201pos	C(6),;
			inc201aff	C(6),;
			inc301pos	C(6),;
			inc301aff	C(6),;
			incunkpos	C(6),;
			incunkaff	C(6),;
			inctotpos	C(6),;
			inctotaff	C(6),;
			permpos		C(6),;
			permaff		C(6),;
			nonpermpos	C(6),;
			nonpermaff	C(6),;
			instpos		C(6),;
			instaff		C(6),;
			housothpos	C(6),;
			housothaff	C(6),;
			housunkpos	C(6),;
			housunkaff	C(6))

If Used('sect2c')
   Use In sect2c
Endif

CREATE CURSOR ;
	sect2c (houstotpos	C(6),;
			houstotaff	C(6),;
			privpos		C(6),;
			privaff		C(6),;
			mcarepos	C(6),;
			mcareaff	C(6),;
			mcaidpos	C(6),;
			mcaidaff	C(6),;
			pubpos		C(6),;
			pubaff  	C(6),;
			nonepos		C(6),;
			noneaff		C(6),;
			insothpos	C(6),;
			insothaff	C(6),;
			insunkpos	C(6),;
			insunkaff	C(6),;
			instotpos	C(6),;
			instotaff	C(6),;
			hposnotaid	C(6),;
			hposunk		C(6),;
			aids		C(6),;
			hivindet	C(6),;
			hnegaff		C(6),;
			statunk		C(6),;
			stattotpos	C(6),;
			stattotaff	C(6),;
			actnewpos	C(6),;
			actnewaff	C(6),;
			actconpos	C(6),;
			actconaff	C(6),;
			actdecpos	C(6),;
			actdecaff	C(6),;
			inactpos	C(6),;
			inactaff	C(6),;
			enrunkpos	C(6),;
			enrunkaff	C(6),;
			enrtotpos	C(6),;
			enrtotaff	C(6),;
			totexpadh	C(1),;
			version		C(25),;
         HWHITEPS   C(06),;
         HWHITEAF   C(06),;
         HBLACKPS   C(06),;
         HBLACKAF   C(06),;
         HASIANPS   C(06),;
         HASIANAF   C(06),;
         HNATIVEPS  C(06),;
         HNATIVEAF  C(06),;
         HINDIANPS  C(06),;
         HINDIANAF  C(06),;
         HMULTIPS   C(06),;
         HMULTIAF   C(06),;
         HUNKRACPS  C(06),;
         HUNKRACAF  C(06),;
         HRACETOTPS C(06),;
         HRACETOTAF C(06)) 

* combine into one cursor
If Used('sect2')
   Use In sect2
Endif

SELECT ;
	sect2a.*, ; 
	sect2b.*, ;
	sect2c.*  ;
FROM ;
	sect2a, ;
	sect2b, ;
	sect2c  ;
INTO CURSOR ;
	sect2

* reopen, make it writable
oApp.ReopenCur('sect2','sect2tmp')
SCATTER memvar 

DO sect2 IN rpt_cadr

m.version=gcCadrVers

SELECT sect2tmp
APPEND BLANK
GATHER memvar

* now, create the dbf file
* jss, 7/25/07, add "fox2x" to copy in order to create FOXPRO 2.6 type tables
COPY TO &cFileName2 FOX2X

* close some tables/cursors
USE IN sect2a
USE IN sect2b
USE IN sect2c
USE IN sect2tmp

RETURN
******************
PROCEDURE SECTION3
******************
* define sect3 cursor
*!*   If Used('sect3a')
*!*      Use In sect3a
*!*   Endif
*!*      
*!*   CREATE CURSOR ;
*!*   	sect3a (recid		C(10),;
*!*   			prvid 		C(4),;
*!*   			regcode		C(5),;
*!*   			prvname1	C(61),;
*!*   			ambulat_3	C(1),;
*!*   			ambulat_4	C(6),;
*!*   			ambulat_5	C(6),;
*!*   			ambulat_6	C(1),;
*!*   			ambulat_7	C(6),;
*!*   			ambulat_8	C(6),;
*!*   			ambulat_9	C(1),;
*!*   			mental_3	C(1),;
*!*   			mental_4	C(6),;
*!*   			mental_5	C(6),;
*!*   			mental_6	C(1),;
*!*   			mental_7	C(6),;
*!*   			mental_8	C(6),;
*!*   			mental_9 	C(1),;
*!*   			oral_3		C(1),;
*!*   			oral_4		C(6),;
*!*   			oral_5		C(6),;
*!*   			oral_6		C(1),;
*!*   			oral_7		C(6),;
*!*   			oral_8		C(6),;
*!*   			oral_9		C(1),;
*!*   			sub_out_3	C(1),;
*!*   			sub_out_4	C(6),;
*!*   			sub_out_5	C(6),;
*!*   			sub_out_6	C(1),;
*!*   			sub_out_7	C(6),;
*!*   			sub_out_8	C(6),;
*!*   			sub_out_9	C(1),;
*!*   			sub_res_3	C(1),;
*!*   			sub_res_4	C(6),;
*!*   			sub_res_5	C(6),;
*!*   			sub_res_6	C(1),;
*!*   			sub_res_7	C(6),;
*!*   			sub_res_8	C(6),;
*!*   			sub_res_9	C(1),;
*!*   			rehabil_3	C(1),;
*!*   			rehabil_4	C(6),;
*!*   			rehabil_5	C(6),;
*!*   			rehabil_6	C(1),;
*!*   			rehabil_7	C(6),;
*!*   			rehabil_8	C(6),;
*!*   			rehabil_9	C(1),;
*!*   			paracare_3	C(1),;
*!*   			paracare_4	C(6),;
*!*   			paracare_5	C(6),;
*!*   			paracare_6	C(1),;
*!*   			paracare_7	C(6),;
*!*   			paracare_8	C(6),;
*!*   			paracare_9	C(1),;
*!*   			profcare_3	C(1),;
*!*   			profcare_4	C(6),;
*!*   			profcare_5	C(6),;
*!*   			profcare_6	C(1),;
*!*   			profcare_7	C(6),;
*!*   			profcare_8	C(6),;
*!*   			profcare_9	C(1),;
*!*   			speccare_3	C(1),;
*!*   			speccare_4	C(6),;
*!*   			speccare_5	C(6),;
*!*   			speccare_6	C(1),;
*!*   			speccare_7	C(6),;
*!*   			speccare_8	C(6),;
*!*   			speccare_9	C(1))

*!*   If Used('sect3b')
*!*      Use In sect3b
*!*   Endif
*!*   			
*!*   CREATE CURSOR ;
*!*   	sect3b (case_man_3	C(1),;
*!*   			case_man_4	C(6),;
*!*   			case_man_5	C(6),;
*!*   			case_man_6	C(1),;
*!*   			case_man_7	C(6),;
*!*   			case_man_8	C(6),;
*!*   			case_man_9	C(1),;
*!*   			buddy_3 	C(1),;
*!*   			buddy_4 	C(6),;
*!*   			buddy_5 	C(6),;
*!*   			buddy_6 	C(1),;
*!*   			childser_3 	C(1),;
*!*   			childser_4 	C(6),;
*!*   			childser_5 	C(6),;
*!*   			childser_6 	C(1),;
*!*   			childwel_3 	C(1),;
*!*   			childwel_4 	C(6),;
*!*   			childwel_5 	C(6),;
*!*   			childwel_6 	C(1),;
*!*   			clientad_3 	C(1),;
*!*   			clientad_4 	C(6),;
*!*   			clientad_5 	C(6),;
*!*   			clientad_6 	C(1),;
*!*   			day_care_3 	C(1),;
*!*   			day_care_4 	C(6),;
*!*   			day_care_5 	C(6),;
*!*   			day_care_6 	C(1),;
*!*   			develser_3 	C(1),;
*!*   			develser_4 	C(6),;
*!*   			develser_5 	C(6),;
*!*   			develser_6 	C(1),;
*!*   			earlyser_3 	C(1),;
*!*   			earlyser_4 	C(6),;
*!*   			earlyser_5 	C(6),;
*!*   			earlyser_6 	C(1),;
*!*   			emergen_3 	C(1),;
*!*   			emergen_4 	C(6),;
*!*   			emergen_5 	C(6),;
*!*   			emergen_6 	C(1),;
*!*   			foodbank_3 	C(1),;
*!*   			foodbank_4 	C(6),;
*!*   			foodbank_5 	C(6),;
*!*   			foodbank_6 	C(1),;
*!*   			healthed_3 	C(1),;
*!*   			healthed_4 	C(6),;
*!*   			healthed_5 	C(6),;
*!*   			healthed_6 	C(1))

*!*   If Used('sect3c')
*!*      Use In sect3c
*!*   Endif

*!*   CREATE CURSOR ;
*!*   	sect3c (housser_3	C(1),;
*!*   			housser_4 	C(6),;
*!*   			housser_5 	C(6),;
*!*   			housser_6 	C(1),;
*!*   			legalser_3 	C(1),;
*!*   			legalser_4 	C(6),;
*!*   			legalser_5 	C(6),;
*!*   			legalser_6 	C(1),;
*!*   			nutrit_3 	C(1),;
*!*   			nutrit_4 	C(6),;
*!*   			nutrit_5 	C(6),;
*!*   			nutrit_6 	C(1),;
*!*   			outreach_3 	C(1),;
*!*   			outreach_4 	C(6),;
*!*   			outreach_5 	C(6),;
*!*   			outreach_6 	C(1),;
*!*   			perplan_3 	C(1),;
*!*   			perplan_4 	C(6),;
*!*   			perplan_5 	C(6),;
*!*   			perplan_6 	C(1),;
*!*   			psychser_3 	C(1),;
*!*   			psychser_4 	C(6),;
*!*   			psychser_5 	C(6),;
*!*   			psychser_6 	C(1),;
*!*   			ref_care_3 	C(1),;
*!*   			ref_care_4 	C(6),;
*!*   			ref_care_5 	C(6),;
*!*   			ref_care_6 	C(1),;
*!*   			ref_res_3 	C(1),;
*!*   			ref_res_4 	C(6),;
*!*   			ref_res_5 	C(6),;
*!*   			ref_res_6 	C(1),;
*!*   			res_care_3 	C(1),;
*!*   			res_care_4 	C(6),;
*!*   			res_care_5 	C(6),;
*!*   			res_care_6 	C(1),;
*!*   			transer_3 	C(1),;
*!*   			transer_4 	C(6),;
*!*   			transer_5 	C(6),;
*!*   			transer_6 	C(1),;
*!*   			treatmen_3 	C(1),;
*!*   			treatmen_4 	C(6),;
*!*   			treatmen_5 	C(6),;
*!*   			treatmen_6 	C(1),;
*!*   			otherser_3 	C(1),;
*!*   			otherser_4 	C(6),;
*!*   			otherser_5 	C(6),;
*!*   			otherser_6 	C(1),;
*!*   			version		C(25))

* define sect3 cursor
If Used('sect3a')
   Use In sect3a
Endif
* jss, 11/21/07, reorganize following cursor to match 2007 report order changes.
CREATE CURSOR ;
   sect3a (recid     C(10),;
         prvid       C(4),;
         regcode     C(5),;
         prvname1    C(61),;
         ambulat_3   C(1),;
         ambulat_4   C(6),;
         ambulat_5   C(6),;
         ambulat_6   C(1),;
         ambulat_7   C(6),;
         ambulat_8   C(6),;
         ambulat_9   C(1),;
         pharmass_3  C(1),;
         pharmass_4  C(6),;
         pharmass_5  C(6),;
         pharmass_6  C(1),;
         oral_3      C(1),;
         oral_4      C(6),;
         oral_5      C(6),;
         oral_6      C(1),;
         oral_7      C(6),;
         oral_8      C(6),;
         oral_9      C(1),;
         earlyser_3  C(1),;
         earlyser_4  C(6),;
         earlyser_5  C(6),;
         earlyser_6  C(1),;
         earlyser_7  C(6),;
         earlyser_8  C(6),;
         earlyser_9  C(1),;
         insprem_3   C(1),;
         homecar_3   C(1),;
         homecar_4   C(6),;
         homecar_5   C(6),;
         homecar_6   C(1),;
         homecar_7   C(6),;
         homecar_8   C(6),;
         homecar_9   C(1),;
         commcar_3   C(1),;
         commcar_4   C(6),;
         commcar_5   C(6),;
         commcar_6   C(1),;
         commcar_7   C(6),;
         commcar_8   C(6),;
         commcar_9   C(1),;
         res_care_3  C(1),;
         res_care_4  C(6),;
         res_care_5  C(6),;
         res_care_6  C(1),;
         res_care_7  C(6),;
         res_care_8  C(6),;
         res_care_9  C(1),;
         mental_3    C(1),;
         mental_4    C(6),;
         mental_5    C(6),;
         mental_6    C(1),;
         mental_7    C(6),;
         mental_8    C(6),;
         mental_9    C(1))
                  
If Used('sect3b')
   Use In sect3b
Endif

CREATE CURSOR ;
   sect3b (nutrit_3  C(1),;
         nutrit_4    C(6),;
         nutrit_5    C(6),;
         nutrit_6    C(1),;
         nutrit_7    C(6),;
         nutrit_8    C(6),;
         nutrit_9    C(1),;
         med_case_3  C(1),;
         med_case_4  C(6),;
         med_case_5  C(6),;
         med_case_6  C(1),;
         med_case_7  C(6),;
         med_case_8  C(6),;
         med_case_9  C(1),;
         sub_out_3   C(1),;
         sub_out_4   C(6),;
         sub_out_5   C(6),;
         sub_out_6   C(1),;
         sub_out_7   C(6),;
         sub_out_8   C(6),;
         sub_out_9   C(1),;
         case_man_3  C(1),;
         case_man_4  C(6),;
         case_man_5  C(6),;
         case_man_6  C(1),;
         childser_3  C(1),;
         childser_4  C(6),;
         childser_5  C(6),;
         childser_6  C(1),;
         develser_3  C(1),;
         develser_4  C(6),;
         develser_5  C(6),;
         develser_6  C(1),;
         emergen_3   C(1),;
         emergen_4   C(6),;
         emergen_5   C(6),;
         emergen_6   C(1),;
         foodbank_3  C(1),;
         foodbank_4  C(6),;
         foodbank_5  C(6),;
         foodbank_6  C(1),;
         healthed_3  C(1),;
         healthed_4  C(6),;
         healthed_5  C(6),;
         healthed_6  C(1))

If Used('sect3c')
   Use In sect3c
Endif

CREATE CURSOR ;
   sect3c (housser_3 C(1),;
         housser_4   C(6),;
         housser_5   C(6),;
         housser_6   C(1),;
         legalser_3  C(1),;
         legalser_4  C(6),;
         legalser_5  C(6),;
         legalser_6  C(1),;
         lingser_3   C(1),;
         lingser_4   C(6),;
         lingser_5   C(6),;
         lingser_6   C(1),;
         transer_3   C(1),;
         transer_4   C(6),;
         transer_5   C(6),;
         transer_6   C(1),;
         outreach_3  C(1),;
         outreach_4  C(6),;
         outreach_5  C(6),;
         outreach_6  C(1),;
         perplan_3   C(1),;
         perplan_4   C(6),;
         perplan_5   C(6),;
         perplan_6   C(1),;
         psychser_3  C(1),;
         psychser_4  C(6),;
         psychser_5  C(6),;
         psychser_6  C(1),;
         ref_care_3  C(1),;
         ref_care_4  C(6),;
         ref_care_5  C(6),;
         ref_care_6  C(1),;
         rehabil_3   C(1),;
         rehabil_4   C(6),;
         rehabil_5   C(6),;
         rehabil_6   C(1),;
         day_care_3  C(1),;
         day_care_4  C(6),;
         day_care_5  C(6),;
         day_care_6  C(1),;
         sub_res_3   C(1),;
         sub_res_4   C(6),;
         sub_res_5   C(6),;
         sub_res_6   C(1),;
         treatmen_3  C(1),;
         treatmen_4  C(6),;
         treatmen_5  C(6),;
         treatmen_6  C(1),;
         version     C(25))

* combine into one cursor
If Used('sect3')
   Use In sect3
Endif

SELECT ;
	sect3a.*, ; 
	sect3b.*, ;
	sect3c.* ;
FROM ;
	sect3a, ;
	sect3b, ;
	sect3c  ;
INTO CURSOR ;
	sect3

* reopen, make it writable
oApp.ReopenCur('sect3','sect3tmp')
SCATTER memvar 

DO sect3 IN rpt_cadr

m.version=gcCadrVers

SELECT sect3tmp
APPEND BLANK
GATHER memvar

* now, create the dbf file
* jss, 7/25/07, add "fox2x" to copy in order to create FOXPRO 2.6 type tables
COPY TO &cFileName3 FOX2X

* close some tables/cursors
USE IN sect3a
USE IN sect3b
USE IN sect3c
USE IN sect3tmp

RETURN
******************
PROCEDURE SECTION4
******************
* define sect4 cursor
If Used('sect4')
   Use In sect4
Endif
   
CREATE CURSOR ;
	sect4  (recid		C(10),;
			prvid 		C(4),;
			regcode		C(5),;
			prvname1	C(61),;
			ctprov		C(3),;
			ctnoinfant	C(6),;
			rwfundused	C(3),;
			preconf		C(6),;
			preanon		C(6),;
			hivtstconf	C(6),;
			hivtstanon	C(6),;
			hiv_pos		C(6),;
			postconf	C(6),;
			postanon 	C(6),;
			postnoretu	C(6),;
			pnotifserv	C(3),;
			partsnotif	C(6),;
			version		C(25))
			
* reopen, make it writable
oApp.ReopenCur('sect4','sect4tmp')
SCATTER memvar 

DO sect4 IN rpt_cadr

m.version=gcCadrVers

SELECT sect4tmp
APPEND BLANK
GATHER memvar

* now, create the dbf file
* jss, 7/25/07, add "fox2x" to copy in order to create FOXPRO 2.6 type tables
COPY TO &cFileName4 FOX2X

USE IN sect4tmp

RETURN

******************
PROCEDURE SECTION5
******************
* define sect5 cursor
If Used('sect5')
   Use In sect5
Endif
   
CREATE CURSOR ;
	sect5  (recid		C(10),;
			prvid 		C(4),;
			regcode		C(5),;
			prvname1	C(61),;
			n_male		C(6),;
			n_female	C(6),;
			n_trans		C(6),;
			n_unknown	C(6),;
			n_total		C(6),;
			visit1		C(6),;
			visit2		C(6),;
			visit34		C(6),;
			visit5plus	C(6),;
			visitunk	C(6),;
			visittot	C(6),;
			r_msm		C(6),;
			r_idu		C(6),;
			r_msmidu	C(6),;
			r_hemophil	C(6),;
			r_hetero	C(6),;
			r_transfus	C(6),;
			r_perinata	C(6),;
			r_other		C(6),;
			r_undeterm	C(6),;
			r_total		C(6),;
			newhivcli	C(6),;
			cd4cnt		C(6),;
			viralcnt	C(6),;
			ppdind		C(6),;
			ppd			C(6),;
			ppdneg		C(6),;
			ppdpos		C(6),;
			ppdunk		C(6),;
			prophtreat	C(6),;
			activtreat	C(6),;
			unktreat	C(6),;
			prophcomp	C(6),;
			activcomp	C(6),;
			currtreat	C(6),;
			unkcomp		C(6),;
			syphtest	C(6),;
			syphtreat	C(6),;
			othstitest	C(6),;
			othstitrea	C(6),;
			hepctest	C(6),;
			hepctreat	C(6),;
			newaids		C(6),;
			hivdied  	C(6),;			
			art_none	C(6),;
			art_haart	C(6),;
			art_other	C(6),;
			art_unkn	C(6),;
			art_total	C(6),;
			pap			C(6),;
			hivpospreg	C(6),;
			stage_1st	C(6),;
			stage_2nd	C(6),;
			stage_3rd	C(6),;
			stage_del	C(6),;
			stage_tot	C(6),;
			pregonart	C(6),;
			childdeliv	C(6),;
			childpos	C(6),;
			childind	C(6),;
			childneg	C(6),;
			mgmtqual	C(1),;
			version	C(25),;
         PPDIndrmt C(6))
			
* reopen, make it writable
oapp.ReopenCur('sect5','sect5tmp')
SCATTER memvar

DO sect5 IN rpt_cadr

m.version=gcCadrVers

SELECT sect5tmp
APPEND BLANK
GATHER memvar

* now, create the dbf file
* jss, 7/25/07, add "fox2x" to copy in order to create FOXPRO 2.6 type tables
COPY TO &cFileName5 FOX2X

USE IN sect5tmp

RETURN
******************
PROCEDURE SECTION6
******************
If Used('sect61a')
   Use In sect61a
Endif
   
If Used('sect61a')
   Use In sect61a
Endif
   
CREATE CURSOR ;
   sect61a ;
      (recid     C(10),;
      prvid      C(4),;
      regcode    C(5),;
      prvname1   C(61),;
      skip_55_58 C(1),;
      t3_pos     C(6),;
      t3_ind     C(6),;
      t3_posind  C(6),;
      t3_male    C(6),;
      t3_female  C(6),;
      t3_trans   C(6),;
      t3_unkgen  C(6),;
      t3_totgen  C(6),;
      t3_0_1     C(6),;
      t3_2_12    C(6),;
      t3_13_24   C(6),;
      t3_25_44   C(6),;
      t3_45_64   C(6),;
      t3_65plus  C(6),;
      t3_unkage  C(6),;
      t3_totage  C(6),;
      t3_white   C(6),;
      t3_black   C(6),;
      t3_hisp    C(6),;
      t3_asian   C(6),;
      t3_hawaii  C(6),;
      t3_native  C(6),;
      t3_moreth1 C(6),;
      t3_unkrace C(6),;
      t3_totrace C(6),;
      rwhmale    C(80),;
      rwhfemale  C(80),;
      rwhtrans   C(80),;
      rwhunk     C(80),;
      rblmale    C(80),;
      rblfemale  C(80),;
      rbltrans   C(80),;
      rblunk     C(80),;
      rhmale     C(80),;
      rhfemale   C(80),;
      rhtrans    C(80),;
      rhunk      C(80),;
      rasmale    C(80),;
      rasfemale  C(80),;
      rastrans   C(80),;
      rasunk     C(80),;
      rnamale    C(80),;
      rnafemale  C(80),;
      rnatrans   C(80),;
      rnaunk     C(80),;
      rinmale    C(80),;
      rinfemale  C(80),;
      rintrans   C(80),;
      rinunk     C(80),;
      rmomale    C(80),;
      rmofemale  C(80),;
      rmotrans   C(80),;
      rmounk     C(80),;
      runmale    C(80),;
      runfemale  C(80),;
      runtrans   C(80),;
      rununk     C(80),;
      rtmale     C(80),;
      rtfemale   C(80),;
      rttrans    C(80),;
      rtunk      C(80),;
      T3_HWHITE  C(6),;
      T3_HBLACK  C(6),;
      T3_HASIAN  C(6),;
      T3_HHAWAII C(6),;
      T3_HNATIVE C(6),;
      T3_HMORTH1 C(6),;
      T3_HUNKRAC C(6),;
      T3_HTOTRAC C(6))
 

If Used('sect61b')
   Use In sect61b
Endif
         
CREATE CURSOR ;
   sect61b ;
      (emsmmale  C(80),;
      emsmfemale C(80),;
      emsmtrans  C(80),;
      emsmunk    C(80),;
      eidumale   C(80),;
      eidufemale C(80),;
      eidutrans  C(80),;
      eiduunk    C(80),;
      emidmale   C(80),;
      emidfemale C(80),;
      emidtrans  C(80),;
      emidunk    C(80),;
      ehemmale   C(80),;
      ehemfemale C(80),;
      ehemtrans  C(80),;
      ehemunk    C(80),;
      ehetmale   C(80),;
      ehetfemale C(80),;
      ehettrans  C(80),;
      ehetunk    C(80),;
      etrnmale   C(80),;
      etrnfemale C(80),;
      etrntrans  C(80),;
      etrnunk    C(80),;
      epermale   C(80),;
      eperfemale C(80),;
      epertrans  C(80),;
      eperunk    C(80),;
      eothmale   C(80),;
      eothfemale C(80),;
      eothtrans  C(80),;
      eothunk    C(80),;
      eunkmale   C(80),;
      eunkfemale C(80),;
      eunktrans  C(80),;
      eunkunk    C(80),;
      etmale     C(80),;
      etfemale   C(80),;
      ettrans    C(80),;
      etunk      C(80))
        
         
If Used('sect61c')
   Use In sect61c
Endif

CREATE CURSOR ;
   sect61c ;
      (amsmmale  C(80),;
      amsmfemale C(80),;
      amsmtrans  C(80),;
      amsmunk    C(80),;
      aidumale   C(80),;
      aidufemale C(80),;
      aidutrans  C(80),;
      aiduunk    C(80),;
      amidmale   C(80),;
      amidfemale C(80),;
      amidtrans  C(80),;
      amidunk    C(80),;
      ahemmale   C(80),;
      ahemfemale C(80),;
      ahemtrans  C(80),;
      ahemunk    C(80),;
      ahetmale   C(80),;
      ahetfemale C(80),;
      ahettrans  C(80),;
      ahetunk    C(80),;
      atrnmale   C(80),;
      atrnfemale C(80),;
      atrntrans  C(80),;
      atrnunk    C(80),;
      apermale   C(80),;
      aperfemale C(80),;
      apertrans  C(80),;
      aperunk    C(80),;
      aothmale   C(80),;
      aothfemale C(80),;
      aothtrans  C(80),;
      aothunk    C(80),;
      aunkmale   C(80),;
      aunkfemale C(80),;
      aunktrans  C(80),;
      aunkunk    C(80),;
      atmale     C(80),;
      atfemale   C(80),;
      attrans    C(80),;
      atunk      C(80))

If Used('sect61d')
   Use In sect61d
Endif
         
CREATE CURSOR ;
   sect61d;
      (t_prim    C(9),;
      t_oth      C(9),;
      t3_prim    C(9),;
      t3_oth     C(9),;
      t3_pharm   C(9),;
      pt_prim    C(9),;
      pt_oth     C(9),;
      th_prim    C(9),;
      th_oth     C(9),;
      oth_prim   C(9),;
      oth_oth    C(9),;
      eis        C(3),;
      eis_sites  C(6),;
      eis_client C(6),;
      ambul      C(1),;
      dermat1    C(1),;
      dermat2    C(1),;
      dermat3    C(1),;
      pharm1     C(1),;
      pharm2     C(1),;
      pharm3     C(1),;
      gas1       C(1),;
      gas2       C(1),;
      gas3       C(1),;
      medcasmgt1 C(1),;
      medcasmgt2 C(1),;
      medcasmgt3 C(1),;
      nutrit1    C(1),;
      nutrit2    C(1),;
      nutrit3    C(1),;
      mental1    C(1),;
      mental2    C(1),;
      mental3    C(1),;
      neuro1     C(1),;
      neuro2     C(1),;
      neuro3     C(1),;
      obstet1    C(1),;
      obstet2    C(1),;
      obstet3    C(1),;
      optom1     C(1),;
      optom2     C(1),;
      optom3     C(1),;
      oral1      C(1),;
      oral2      C(1),;
      oral3      C(1),;
      subst1     C(1),;
      subst2     C(1),;
      subst3     C(1),;
      othserv1   C(1),;
      othserv2   C(1),;
      othserv3   C(1),;
      version    C(25))

      
If Used('sect62a')
   Use In sect62a
Endif

* PB 12/2008 Added last 16 columns for 2008 RDR
CREATE CURSOR ;
   sect62a ;
      (recid      C(10),;
      prvid       C(4),;
      regcode     C(5),;
      prvname1    C(61),;
      skip_66_70  C(1), ;
      t4_pos      C(6),;
      t4_ind      C(6),;
      t4_negunk   C(6),;
      t4_newpos   C(6),;
      t4_newind   C(6),;
      t4_newnegu  C(6),;
      t4p_male    C(6),;
      t4a_male    C(6),;
      t4p_female  C(6),;
      t4a_female  C(6),;
      t4p_trans   C(6),;
      t4a_trans   C(6),;
      t4p_unkgen  C(6),;
      t4a_unkgen  C(6),;
      t4p_totgen  C(6),;
      t4a_totgen  C(6),;
      t4p_0_1     C(6),;
      t4a_0_1     C(6),;
      t4p_2_12    C(6),;
      t4a_2_12    C(6),;
      t4p_13_24   C(6),;
      t4a_13_24   C(6),;
      t4p_25_44   C(6),;
      t4a_25_44   C(6),;
      t4p_45_64   C(6),;
      t4a_45_64   C(6),;
      t4p_65plus  C(6),;
      t4a_65plus  C(6),;
      t4p_unkage  C(6),;
      t4a_unkage  C(6),;
      t4p_totage  C(6),;
      t4a_totage  C(6),;
      t4pwhite    C(6),;
      t4awhite    C(6),;
      t4pblack    C(6),;
      t4ablack    C(6),;
      t4phisp     C(6),;
      t4ahisp     C(6),;
      t4pasian    C(6),;
      t4aasian    C(6),;
      t4phawaii   C(6),;
      t4ahawaii   C(6),;
      t4pnative   C(6),;
      t4anative   C(6),;
      t4pmoreth1  C(6),;
      t4amoreth1  C(6),;
      t4punkrace  C(6),;
      t4aunkrace  C(6),;
      t4ptotrace  C(6),;
      t4atotrace  C(6),;
      T4PHWHITE   C(6),;
      T4AHWHITE   C(6),;
      T4PHBLACK   C(6),;
      T4AHBLACK   C(6),;
      T4PHASIAN   C(6),;
      T4AHASIAN   C(6),;
      T4PHHAWAII  C(6),;
      T4AHHAWAII  C(6),;
      T4PHNATIVE  C(6),;
      T4AHNATIVE  C(6),;
      T4PHMORTH1  C(6),;
      T4AHMORTH1  C(6),;
      T4PHUNKRAC  C(6),;
      T4AHUNKRAC  C(6),;
      T4PHTOTRAC  C(6),;
      T4AHTOTRAC  C(6))

If Used('sect62b')
   Use In sect62b
Endif

* PB 12/2008 Added last 16 columns for 2008 RDR
Create Cursor ;
  sect62b (;
      gmalepos C(80),;
      gmaleneg C(80),;
      gfempos  C(80),;
      gfemneg  C(80),;
      gtrnpos  C(80),;
      gtrnneg  C(80),;
      gunkpos  C(80),;
      gunkneg  C(80),;
      gtpos    C(80),;
      gtneg    C(80),;
      whpos    C(80),;
      whneg    C(80),;
      blpos    C(80),;
      blneg    C(80),;
      hisppos  C(80),;
      hispneg  C(80),;
      aspos    C(80),;
      asneg    C(80),;
      napos    C(80),;
      naneg    C(80),;
      inpos    C(80),;
      inneg    C(80),;
      morepos  C(80),;
      moreneg  C(80),;
      unkpos   C(80),;
      unkneg   C(80),;
      totpos   C(80),;
      totneg   C(80),;
      eamsm    C(80),;
      eaidu    C(80),;
      eamid    C(80),;
      eahem    C(80),;
      eahet    C(80),;
      eatrn    C(80),;
      eaper    C(80),;
      eaoth    C(80),;
      eaunk    C(80),;
      eatot    C(80),;
      version  C(25),;
      HWHPOS   C(80),;
      HWHNEG   C(80),;
      HBLPOS   C(80),;
      HBLNEG   C(80),;
      HASPOS   C(80),;
      HASNEG   C(80),;
      HNAPOS   C(80),;
      HNANEG   C(80),;
      HINPOS   C(80),;
      HINNEG   C(80),;
      HMOREPOS C(80),;
      HMORENEG C(80),;
      HUNKPOS  C(80),;
      HUNKNEG  C(80),;
      HTOTPOS  C(80),;
      HTOTNEG  C(80))

If Used('sect61e')
   Use In sect61e
EndIf

*!* PB 12/2008 New Table required foir 2008 RDR
Create Cursor ;
   sect61e;
      (recid     C(10),;
      prvid      C(4),;
      regcode    C(5),;
      prvname1   C(61),;
      RHWHMALE   C(80),;
      RHWHFEMALE C(80),;
      RHWHTRANS  C(80),;
      RHWHUNK    C(80),;
      RHBLMALE   C(80),;
      RHBLFEMALE C(80),;
      RHBLTRANS  C(80),;
      RHBLUNK    C(80),;
      RHASMALE   C(80),;
      RHASFEMALE C(80),;
      RHASTRANS  C(80),;
      RHASUNK    C(80),;
      RHNAMALE   C(80),;
      RHNAFEMALE C(80),;
      RHNATRANS  C(80),;
      RHNAUNK    C(80),;
      RHINMALE   C(80),;
      RHINFEMALE C(80),;
      RHINTRANS  C(80),;
      RHINUNK    C(80),;
      RHMOMALE   C(80),;
      RHMOFEMALE C(80),;
      RHMOTRANS  C(80),;
      RHMOUNK    C(80),;
      RHUNMALE   C(80),;
      RHUNFEMALE C(80),;
      RHUNTRANS  C(80),;
      RHUNUNK    C(80),;
      RHTMALE    C(80),;
      RHTFEMALE  C(80),;
      RHTTRANS   C(80),;
      RHTUNK     C(80),;
      EHMSMMALE  C(80),;
      EHMSMFEMLE C(80),;
      EHMSMTRANS C(80),;
      EHMSMUNK   C(80),;
      EHIDUMALE  C(80),;
      EHIDUFEMLE C(80),;
      EHIDUTRANS C(80),;
      EHIDUUNK   C(80),;
      EHMIDMALE  C(80),;
      EHMIDFEMLE C(80),;
      EHMIDTRANS C(80),;
      EHMIDUNK   C(80),;
      EHHEMMALE  C(80),;
      EHHEMFEMLE C(80),;
      EHHEMTRANS C(80),;
      EHHEMUNK   C(80),;
      EHHETMALE  C(80),;
      EHHETFEMLE C(80),;
      EHHETTRANS C(80),;
      EHHETUNK   C(80),;
      EHTRNMALE  C(80),;
      EHTRNFEMLE C(80),;
      EHTRNTRANS C(80),;
      EHTRNUNK   C(80),;
      EHPERMALE  C(80),;
      EHPERFEMLE C(80),;
      EHPERTRANS C(80),;
      EHPERUNK   C(80),;
      EHOTHMALE  C(80),;
      EHOTHFEMLE C(80),;
      EHOTHTRANS C(80),;
      EHOTHUNK   C(80),;
      EHUNKMALE  C(80),;
      EHUNKFEMLE C(80),;
      EHUNKTRANS C(80),;
      EHUNKUNK   C(80),;
      EHTMALE    C(80),;
      EHTFEMLE   C(80),;
      EHTTRANS   C(80),;
      EHTUNK     C(80))

Select sect61e
Scatter Memvar Blank

* now, create cursors for sect61 and sect62 from those defined above
* sect61

If Used('sect61')
   Use In sect61
Endif

SELECT ;
   sect61a.*, ; 
   sect61b.*, ;
   sect61c.*, ;
   sect61d.*  ;
FROM ;
   sect61a, ;
   sect61b, ;
   sect61c, ;
   sect61d  ;
INTO CURSOR ;
   sect61

* reopen, make it writable
oApp.REOPENCUR('sect61','sect61tmp')
SCATTER memvar 

If Used('sect62')
   Use In sect62
Endif

* sect62
SELECT ;
	sect62a.*, ; 
	sect62b.* ;
FROM ;
	sect62a, ;
	sect62b ;
INTO CURSOR ;
	sect62

* reopen, make it writable
oApp.REOPENCUR('sect62','sect62tmp')
SCATTER memvar 

DO sect6 IN rpt_cadr

m.version=gcCadrVers

SELECT sect61tmp
APPEND BLANK
GATHER memvar

* now, create the dbf file
* jss, 7/25/07, add "fox2x" to copy in order to create FOXPRO 2.6 type tables
COPY TO &cFileNam61 FOX2X

SELECT sect62tmp
APPEND BLANK
GATHER memvar

* now, create the dbf file
* jss, 7/25/07, add "fox2x" to copy in order to create FOXPRO 2.6 type tables
COPY TO &cFileNam62 FOX2X

*!* PB 12/2008 New Table required foir 2008 RDR
Select sect61e
Append Blank
Gather Memvar
COPY TO &cFileName7 FOX2X

oRDR=NewObject('rdr_ctr_data','rsr')
oRDR.create_file(dStartDate, dEndDate,cFileName8)

* close some tables/cursors
USE IN sect61a
USE IN sect61b
USE IN sect61c
USE IN sect61d
USE IN sect61tmp
USE IN sect62a
USE IN sect62b
USE IN sect62tmp
Use In sect61e

RETURN