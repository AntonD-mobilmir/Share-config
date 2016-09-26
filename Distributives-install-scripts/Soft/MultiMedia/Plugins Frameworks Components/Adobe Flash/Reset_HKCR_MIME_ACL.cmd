@REM coding:OEM

SetACL -silent -ignoreerr -ot reg -on HKCR\MIME -actn setowner -ownr "n:S-1-5-32-544;s:y" 
SetACL -silent -ignoreerr -ot reg -on HKCR\MIME -actn setprot -op "dacl:np" -actn clear -clr dacl -actn rstchldrn -rst dacl -rec yes
rem SetACL -ot reg -on HKCR\MIME -actn list -lst "f:tab;w:o,g,d;i:n;s:y"

