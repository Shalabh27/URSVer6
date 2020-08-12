*!* Update the enc_ser table for HH rates

lCloseTable1=.f.
=dbcOpenTable('enc_serv','',@lCloseTable1)
=dbcOpenTable('rate_hd','',@lCloseTable1)
=dbcOpenTable('med_prov','',@lCloseTable1)
=dbcOpenTable('med_pro2','',@lCloseTable1)
=dbcOpenTable('med_pro3','',@lCloseTable1)
=dbcOpenTable('site','',@lCloseTable1)
=dbcOpenTable('rate_history','',@lCloseTable1)

Select enc_serv
Delete For enc_id=298

Select site
m.site=''
Locate for hh_default_site=(1)
If Found()
   m.site=site.site_id
EndIf

Select ;
   med_pro3.prog,;
   med_pro3.rate_grp,;
   rate_hd.rate_code;
From med_pro2 ;
  Join med_pro3 On med_pro3.prov2_id=med_pro2.prov2_id;
  Join rate_history On rate_history.rate_grp=med_pro3.rate_grp;
  Join rate_hd On rate_hd.rate_hd_id=rate_history.rate_hd_id;
Where med_pro2.hh_provider=(.t.);
Order By 3;
Into cursor _curenc_serv

Select _curenc_serv 
Go Top
Scan
   m.prog = _curenc_serv.prog
   m.rate_grp = _curenc_serv.rate_grp
   m.rate_code = _curenc_serv.rate_code
   dDate=Date()
   cTime=Time()

   Insert Into enc_serv (;
         serv_cat, ;
         prog, ;
         site, ;
         rate_grp, ;
         enc_id, ;
         enc, ;
         service_id, ;
         proc_code, ;
         rate_code, ;
         rate_cdef, ;
         can_bill, ;
         copay,;
         user_id, dt, tm);
     Values(;
        '00001', ;
        m.prog, ;
        m.site, ;
        m.rate_grp, ;
        298,;
        'Health Homes',;
        0,;
        '99.99',;
        m.rate_code,;
        m.rate_code,;
        .t.,;
        00.00,;
        '_dsi',dDate, cTime)

     Insert Into enc_serv (;
         serv_cat, ;
         prog, ;
         site, ;
         rate_grp, ;
         enc_id, ;
         enc, ;
         service_id, ;
         proc_code, ;
         rate_code, ;
         rate_cdef, ;
         can_bill, ;
         copay,;
         user_id, dt, tm);
     Values(;
        '00001', ;
        m.prog, ;
        m.site, ;
        m.rate_grp, ;
        298,;
        'Enrollment',;
        1206,;
        '',;
        m.rate_code,;
        '',;
        .t.,;
        00.00,;
        '_dsi',dDate, cTime)

EndScan

Use In _curenc_serv 
Use In enc_serv
Use In rate_hd
Use In med_prov
Use In med_pro2
Use In med_pro3
Use In site
Use In rate_history
 
=dbcOpenTable('billtype','',@lCloseTable1)
Locate For code='00013'
If Found()
   Replace template With 'MONBILL'
   
Else
   Insert Into billtype (Code,descript,template) Values ('00013','Health Homes','MONBILL')
   
EndIf
Use In billtype