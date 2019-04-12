;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

WinAuditCSVToSheetRow_GetColNamesLine(ByRef s := ",", ByRef q := """") {
    return q "ram" q s q "dimmSize" q s q "dimmType" q s q "cpuType" q s q "coreCount" q s q "hdd1size" q s q "hdd1name" q s q "hdd1sn" q s q "hdd1pn" q s q "hdd*size" q s q "hdd*name" q s q "hdd*sn" q s q "hdd*pn" q
}

WinAuditCSVToSheetRow(ByRef winauditcsv, ByRef sep := ",", ByRef q := """") {
    multivalCellSep := q ? "`n" : " | " ; newline if values are quoted
    rptdata := FilterCSVByFirstCol(winauditcsv, { 3600: {3: 1}
                                                , 3700: {4: 1, 7: 2, 8: 3, 9: 4}
                                                , 6400: {9: 1, 19: 2}
                                                , 7100: {7: 1, 12: 2} })
    If (rptdata) {
        dataMap := {}
        For i, objRptLine in rptdata {
            If (objRptLine[1]!="0MB") {
                key := objRptLine[""]
                If (dataMap.HasKey(key))
                    dataMap[key].Push(objRptLine)
                Else
                    dataMap[key] := [objRptLine]
            }
        }
        diskFields := CollapseSheetToLine(dataMap[3700], 2, multivalCellSep)
        cpuFields := CollapseSheetToLine(dataMap[6400], 1, multivalCellSep)
        dimmFields := CollapseSheetToLine(dataMap[7100], 1, "+")
        ;MsgBox % "dataMap: " ObjectToText(dataMap)
        ;     . "`ndiskFields" ObjectToText(diskFields)
        ;     . "`ndimmFields" ObjectToText(dimmFields)
        ;      ram – 1 val
        return dataMap[3600][1][1]
        ;	         dimm*size	        dimm*type
                 . sep . ArrayJoin(dimmFields, sep)
                 . sep . ArrayJoin(cpuFields, sep)
        ;                hdd1size	        hdd1name	       hdd1sn	              hdd1pn
        ;	         hdd*size	        hdd*name	       hdd*sn	              hdd*pn	       
                 . sep . ArrayJoin(dataMap[3700][1], sep)
                 . sep . ArrayJoin(diskFields, sep)
    }
}

#include %A_LineFile%\..\ArrayJoin.ahk
#include %A_LineFile%\..\CollapseSheetToLine.ahk
#include %A_LineFile%\..\FilterCSVByFirstCol.ahk

;Full WinAudit %hostname% *.csv

;"3600","Память","4096MB","1232MB","5916MB","2617MB"
;"3700","Жесткие диски","1","953867MB","Fixed hard disk media","","TOSHIBA DT01ACA100","X5GKA9PFS","MS2OA750","Primary","Master","121601","255","63","47304KB","Да","Да","OK"

;"3600","Память","8192MB","4467MB","10002MB","6422MB"
;"3700","Жесткие диски","1","122103MB","Fixed hard disk media","","ADATA SU800","2I3920037656","R0427ANR","Primary","Master","15566","255","63","","Да","Да","OK"
;"3700","Жесткие диски","2","476937MB","Fixed hard disk media","","TOSHIBA DT01ACA050","Y7E3KTRAS","MS1OA750","Primary","Master","60801","255","63","47304KB","Да","Да","OK"
;"3800","Логические диски","C","Fixed Drive","31%","19.1GB","44.3GB","63.4GB","System","NTFS","9A77-AFDB","8","512","11609649","16619775"
;"3800","Логические диски","D","Fixed Drive","17%","38.0GB","193.1GB","231.0GB","Data","NTFS","E81F-E332","8","512","50619520","60568319"
;"3800","Логические диски","R","Fixed Drive","5%","11.3GB","221.3GB","232.7GB","Backup","NTFS","962A-F6C7","8","512","58025461","60999679"

;"7000","Memory Array","1","System board or motherboard","System memory","None","","65534","2",""
;"7100","Memory Device","1","0xFFFE","64bit","64bit","4096MB","DIMM","Unknown","ChannelA-DIMM0","BANK 0","DDR3","Synchronous","1333MHz","1319","00000000","9876543210","CL9-9-9 D3-1333","1","","1333","","",""
;"7100","Memory Device","2","0xFFFE","0bit","0bit","0MB","DIMM","Unknown","ChannelA-DIMM1","BANK 1","Unknown","","0MHz","[Empty]","[Empty]","9876543210","[Empty]","","","","","",""
;"7100","Memory Device","3","0xFFFE","0bit","0bit","0MB","DIMM","Unknown","ChannelB-DIMM0","BANK 2","Unknown","","0MHz","[Empty]","[Empty]","9876543210","[Empty]","","","","","",""
;"7100","Memory Device","4","0xFFFE","0bit","0bit","0MB","DIMM","Unknown","ChannelB-DIMM1","BANK 3","Unknown","","0MHz","[Empty]","[Empty]","9876543210","[Empty]","","","","","",""

;"6400","Processor","1","SOCKET 0","Central Processor","Intel(R) Celeron(R) processor","Intel","0xBFEBFBFF-0x000306C3","Intel(R) Celeron(R) CPU G1820 @ 2.70GHz","1.200000V","100MHz","3800MHz","2700MHz","CPU Socket Populated, CPU Enabled","Socket LGA1155","","Fill By OEM","Fill By OEM","2","2","","64-bit Capable",""

;1   , 2	 ,3,4	      ,5	  	  ,6				  ,7	  ,8			  ,9					    ,10		,11	 ,12	   	 ,13	         ,14		                     ,15	      ,16,17	       ,18	     ,19	   ,20	          ,21	         ,22
;6400,"Processor",1,"SOCKET 0","Central Processor","Intel(R) Celeron(R) processor","Intel","0xBFEBFBFF-0x000306C3","Intel(R) Celeron(R) CPU G1820 @ 2.70GHz","1.200000V","100MHz","3800MHz"	 ,"2700MHz"      ,"CPU Socket Populated, CPU Enabled","Socket LGA1155",  ,"Fill By OEM","Fill By OEM",2	           ,2	          ,              ,"64-bit Capable"
;    ,	   	 , ,          ,			  ,				  ,	  ,			  ,					    ,		,	 ,"Maximum Speed","Current Speed",		       		     ,		      ,	 ,	       ,	     ,"Core Count" ,"Core Enabled","Thread Count",
