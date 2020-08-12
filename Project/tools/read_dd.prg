CLOSE ALL
OPEN DATABASE urs
USE datadict ALIAS dd EXCLUSIVE
ZAP

=ADBOBJECTS(aTables, "TABLE")
FOR i = 1 TO ALEN(aTables, 0)
	SELECT 0
	USE (aTables[i]) AGAIN
	COPY STRUCTURE TO temp extended
	USE 
	
	USE temp EXCLUSIVE
	ALTER table temp ADD COLUMN fieldorder I
	REPLACE ;
		fieldorder WITH RECNO(), ;
		table_name WITH UPPER((aTables[i])) all
	USE
	
	SELECT dd
	APPEND from temp
ENDFOR



