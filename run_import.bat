@echo off
::�������ݿ�����
for /f "delims=;" %%a in (conf\db.ini) do (
set %%a
)

for /f "delims=;" %%a in (conf\list.ini) do (
::����
sqlplus %ora_uid%/%ora_pwd%@%ora_ip%:%ora_port%/%ora_sid% @ctab\%%a.sql
::���
sqlldr %ora_uid%/%ora_pwd%@%ora_ip%:%ora_port%/%ora_sid% control=ctl\%%a.ctl log=log\%%a.log bad=log\%%a.bad skip=0 direct=true rows=2000
)
exit
