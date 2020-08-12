 Local nReturnCode, noldarea, nCount, lCloseJT, lCloseSH, lCloseSB, lCloseSC

 noldarea=Select()
 nCount=0
   
 lCloseJT=.f.   
 lCloseSH=.f.
 lCloseSB=.f.
 lCloseSC=.f.

 If !Used('jobtype')
    Use jobtype In 0
    lCloseJT=.t.
 EndIf
   
 If !Used('schemes')
    Use schemes In 0
    lCloseSH=.t.
 EndIf
   
 If !Used('skipbar')
    Use skipbar In 0
    lCloseSB=.t.
 EndIf
   
 If !Used('screens')
    Use screens In 0
    lCloseSC=.t.
 EndIf
   
 Select skipbar 
 Replace All screen_id With Upper(Alltrim(screen_id))
 Delete From skipbar Where screen_id Not In (Select id From screens)
 Delete From skipbar Where scheme_id Not In (Select scheme_id From schemes)

 Select schemes
 Go Top

 m.scheme_id=scheme_id

 Scan
    m.can_supervise=.f.
    If Seek(m.scheme_id,'jobtype','scheme_id')
       m.can_supervise=jobtype.can_superv
    EndIf
    m.scheme_id=scheme_id

    Insert Into skipbar (scheme_id, screen_id, has_access, addenable, editenable, delenable);
     Select m.scheme_id, ;
         id,;
         Iif(screens.available=(.t.) And m.can_supervise=(.t.),.t.,.f.),;
         Iif(screens.available=(.t.) And screens.has_add=(.t.) And m.can_supervise=(.t.),.t.,.f.),;
         Iif(screens.available=(.t.) And screens.has_edit=(.t.) And m.can_supervise=(.t.),.t.,.f.),;
         Iif(screens.available=(.t.) And screens.has_delete=(.t.) And m.can_supervise=(.t.),.t.,.f.);
     From screens ;
     Where id Not In ;
         (Select screen_id ;
         From skipbar ;
         Where scheme_id=m.scheme_id);
     Order by id
     nCount = nCount+_Tally   
   
     Select schemes
 EndScan

 If lCloseJT=(.t.)
    Use In jobtype 
 EndIf
   
 If lCloseSH=(.t.)
    Use In schemes
 EndIf
   
 If lCloseSB=(.t.)
    Use In skipbar
 EndIf
   
 If lCloseSC=(.t.)
    Use In screens
 EndIf
   
 Select(noldarea)
   
 Return 0