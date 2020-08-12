Local nArea1
nArea1=Select()

=OpenFile('xml_imports')
Set Order To started Desc
Go Top

loImport_main=NewObject("import_main","imports")
loImport_main.Show()

=base_close()
If Empty(Alias(nArea1))
   Select ai_clien
Else
   Select(nArea1)
EndIf 
