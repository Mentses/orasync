@echo off
::����Oracle����
for /f "delims=;" %%a in (conf\db.ini) do (
set %%a
)
sqlplus -s %ora_uid%/%ora_pwd%@%ora_ip%:%ora_port%/%ora_sid% @conf\f_cbind.fnc
::��ʼ����
for /f "delims=;" %%a in (conf\list.ini) do (
call export.bat %%a
echo %%a �������.
)
exit
