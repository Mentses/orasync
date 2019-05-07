@echo off
::加载数据库配置
for /f "delims=;" %%a in (conf\db.ini) do (
set %%a
)

for /f "delims=;" %%a in (conf\list.ini) do (
::建表
sqlplus %ora_uid%/%ora_pwd%@%ora_ip%:%ora_port%/%ora_sid% @ctab\%%a.sql
::入库
sqlldr %ora_uid%/%ora_pwd%@%ora_ip%:%ora_port%/%ora_sid% control=ctl\%%a.ctl log=log\%%a.log bad=log\%%a.bad skip=0 direct=true rows=2000
)
exit
