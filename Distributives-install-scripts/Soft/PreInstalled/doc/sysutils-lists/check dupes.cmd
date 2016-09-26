@ECHO OFF

TYPE *.list | SORT | uniq -di
