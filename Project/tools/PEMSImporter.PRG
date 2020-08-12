Clear All
Release All
Close Databases All

Open Database i:\ursver6\data\urs

Select * ;
From pems2urs ;
Into Cursor pems2urs_cur ReadWrite ;
Where .f.

cFileName=GetFile()

If Empty(cFileName)
   Return
Endif

oXMLDoc=CreateObject('Microsoft.XMLDOM')
oXMLDoc.load(cFileName)

topElement = oXMLDoc.documentElement
aP2UNodes = topElement.selectNodes("PEMS2URS")

For Each xmlNode IN aP2UNodes
   INSERT INTO pems2urs_cur ( ;
      pems2urs_id, ;
      agency_id, ;
      contract_id, ;
      prog_id, ;
      model_id, ;
      intervention_id, ;
      dbdc, ;
      serv_cat, ;
      enc_id, ;
      service_id) ;
   VALUEs (;
       xmlNode.selectSingleNode("ID").text, ;
       xmlNode.selectSingleNode("Agency_ID").text, ;
       VAL(xmlNode.selectSingleNode("Contract_id").text), ;
       xmlNode.selectSingleNode("Prog_ID").text, ;
       VAL(xmlNode.selectSingleNode("Model_ID").text), ;
       VAL(xmlNode.selectSingleNode("Intervention_ID").text), ;
       LOWER(xmlNode.selectSingleNode("DBDC").text) == 'true', ;
       xmlNode.selectSingleNode("Serv_Cat").text, ;
       VAL(xmlNode.selectSingleNode("Enc_id").text), ;
       VAL(xmlNode.selectSingleNode("Service_id").text))
EndFor 