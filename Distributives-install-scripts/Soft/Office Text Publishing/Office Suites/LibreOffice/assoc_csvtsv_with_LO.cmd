@REM coding:OEM
ASSOC .tsv=LibreOffice.PlainTextSpreadsheet
ASSOC .csv=LibreOffice.PlainTextSpreadsheet

FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype LibreOffice.CalcDocument.1`) DO FTYPE LibreOffice.PlainTextSpreadsheet=%%I
