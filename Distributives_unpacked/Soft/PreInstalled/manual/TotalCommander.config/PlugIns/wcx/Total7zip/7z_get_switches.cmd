@REM coding:OEM
REM file to set compression methods' parameters and usage range
REM 
REM Theese scripts
REM run 7z with different arguments to gain maximum compression,
REM then compare results'size, deleting all but one smallest,
REM and test the last one at end
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru
REM This script is licensed under LGPL

REM :d26 is default for ultra (mx=9)

CALL :setEnvVarsValue PPMd 0 "-mx=9 -m0=PPMd:mem=29:o=16 -mqs"
CALL :setEnvVarsValue LZMA 0 "-mx=9 -m0=LZMA:a=2:fb=273:lc=4 -mqs"
CALL :setEnvVarsValue LZMABCJ2 0 "-mx=9 -m0=BCJ2 -m1=LZMA:a=2:fb=273:lc=4 -m2=LZMA:d22 -m3=LZMA:d22 -mb0:1 -mb0s1:2 -mb0s2:3 -mqs"
CALL :setEnvVarsValue LZMA2 1 "-mx=9 -m0=LZMA2:a=2:fb=273 -mqs"
CALL :setEnvVarsValue LZMA2BCJ2 1 "-mx=9 -m0=BCJ2 -m1=LZMA2:a=2:fb=273 -m2=LZMA2:d22 -m3=LZMA2:d22 -mb0:1 -mb0s1:2 -mb0s2:3 -mqs"

EXIT /b
:setEnvVarsValue
REM %1 - method (var suffix)
REM %2 - use default (0 or 1)
REM %3 - switches
IF NOT DEFINED z7zswitches%1 SET z7zswitches%1=%~3
IF NOT DEFINED z7zusedeflt%1 SET z7zusedeflt%1=%2
EXIT /b
