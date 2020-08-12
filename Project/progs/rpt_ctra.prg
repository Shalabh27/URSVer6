cEthnic=''
cgender=''
cRace=''

Select cli_cur
Locate For tc_id = cTC_ID

cidno=cli_cur.id_no

***Gender
Select gender
Locate For gender.code = cli_cur.gender 
If Found()
   cgender = Left(gender.descript, 45)
Else
   cgender = Space(45)
Endif

***Ethnicity
If (cli_cur.white + cli_cur.blafrican + cli_cur.asian + cli_cur.hawaisland + cli_cur.indialaska +cli_cur.someother) > 1
               cEthnic = "More than One Race    "
Else
   Do Case
      Case cli_cur.white = 1
         cEthnic = "White, Not Hispanic   "
      Case cli_cur.blafrican = 1
         cEthnic = "Black, Not Hispanic   "
      Case cli_cur.asian = 1
         cEthnic = "Asian                 "
      Case cli_cur.hawaisland = 1
         cEthnic = "Hawaiian/Pacific Isl. "   
      Case cli_cur.indialaska = 1
         cEthnic = "Native American/Alaska"      
      Case cli_cur.someother = 1
         cEthnic = "Some Other Race       "      
      Otherwise
         cEthnic = "Unknown Race          "
   EndCase
Endif 

cRace=''
Do Case
   Case cli_cur.hispanic = 2 
        cRace = "Hispanic"
        
   Case cli_cur.hispanic = 1
        cRace = "Non-Hispanic"
        
   Otherwise
        cRace = "Unknown Ethnicity"
Endcase

cZip=cli_cur.zip
cDob=Dtoc(cli_cur.dob)