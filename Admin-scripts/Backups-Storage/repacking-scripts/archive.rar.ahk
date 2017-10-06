#NoEnv
storeext = *.?bz2;7z;aac;ac3;ace;ape;apl;arc;arj;asf;avi;bz2;cab;cpio;deb;fla;flac;gif;ha;jif;jpeg;jpg;lha;lzh;m1v;m2v;m4a;mka;mkv;mod;mov;mp+;mp2;mp3;mp4;mpc;mpe;mpeg;mpg;mpp;mpv;off;ofr;ofs;ogg;ogm;pac;png;psf;psf2;qt;rar;rle;rm;rpm;rv;shn;sid;spx;svx;swm;tbz;tbz2;tfm;tif;tta;umx;vob;wim;wm;wma;wmf;wmv;wv;xz;z;zoo

Loop %0%
{
    arg := %A_Index%
    SplitPath arg, ArchName
    ;-ibck	background
    ;-se	solid groups by extension
    ;-ep1	exclude base path
    
    RunWait "%A_ProgramFiles%\WinRAR\WinRAR.exe" m -t -r -cfg- -ed -ilog"%A_ScriptDir%\rar.log" -k -ma5 -m5 -md128 -ms%storeext% -oh -oi -qo -ri4 -rr1 -w"%A_ScriptDir%" -x*.bak -- "..\%ArchName%.rar", %arg%
}
