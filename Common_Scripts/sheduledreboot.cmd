@REM coding:OEM
@Echo Off
If %2. == . GoTo today
At %1 /interactive /next:%2 psshutdown -cfrt 300
GoTo end

:today
At %1 /interactive psshutdown -cfrt 300

:end
