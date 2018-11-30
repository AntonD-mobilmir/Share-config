@(REM coding:CP866

    FOR %%A IN ("%~dp0..\..\Programs\collectProductKeys.exe" "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\Programs\collectProductKeys.exe") DO IF EXIST "%%~A" (
        "%%~A"
        EXIT /B
    )
)
