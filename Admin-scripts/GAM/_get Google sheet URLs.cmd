@(REM coding:CP866
FOR /F "usebackq delims=" %%A IN ("%~dpn0.txt") DO SET "docIDURL=https://docs.google.com/spreadsheets/d/%%~A/"
)
(
SET "csvURL=%docIDURL%pub?gid=351940138&single=true&output=csv"
SET "editURL=%docIDURL%edit#gid=2099719599"
)
