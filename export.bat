@echo off
::获取入参
set tablename=%1
if "%tablename%"=="" (
    goto end
)
::读取数据库配置
for /f "delims=;" %%a in (conf\db.ini) do (
set %%a
)
::生成文件
echo set trimspool on>sql\%tablename%_sql.sql
echo set linesize 4000>>sql\%tablename%_sql.sql
echo set pagesize 0 >>sql\%tablename%_sql.sql
echo set newpage 1 >>sql\%tablename%_sql.sql
echo set heading off>>sql\%tablename%_sql.sql
echo set term off>>sql\%tablename%_sql.sql
echo set feedback off>>sql\%tablename%_sql.sql
echo alter session set nls_date_format='yyyymmddhh24miss';>>sql\%tablename%_sql.sql
::生成导出数据的sql文件
echo spool sql\%tablename%_data.sql>>sql\%tablename%_sql.sql
echo select 'select '^|^|listagg('''"''||'||column_name||'||''"''','^|^|'',''^|^|')within group(order by column_id) ^|^|' from %tablename%;' from user_tab_cols where table_name = '%tablename%';>>sql\%tablename%_sql.sql
echo spool off>>sql\%tablename%_sql.sql

::导出数据功能模块
echo spool data\%tablename%.csv>>sql\%tablename%_sql.sql
echo @@sql\%tablename%_data.sql;>>sql\%tablename%_sql.sql
echo spool off>>sql\%tablename%_sql.sql

::生成建表脚本
echo spool ctab\%tablename%.sql>>sql\%tablename%_sql.sql
echo SELECT 'CREATE TABLE ' ^|^| '%tablename%' ^|^| CHR(10) ^|^| '(' ^|^| CHR(10) ^|^|>>sql\%tablename%_sql.sql
echo LISTAGG(' ' ^|^| T1.COLUMN_NAME ^|^| ' ' ^|^| CASE>>sql\%tablename%_sql.sql
echo WHEN DATA_TYPE = 'NUMBER' THEN 'NUMBER'>>sql\%tablename%_sql.sql
echo WHEN DATA_TYPE = 'VARCHAR2' THEN>>sql\%tablename%_sql.sql
echo DATA_TYPE ^|^| '(' ^|^| DATA_LENGTH ^|^| ')'>>sql\%tablename%_sql.sql
echo WHEN DATA_TYPE = 'DATE' THEN>>sql\%tablename%_sql.sql
echo 'DATE'>>sql\%tablename%_sql.sql
echo ELSE>>sql\%tablename%_sql.sql
echo DATA_TYPE>>sql\%tablename%_sql.sql
echo END,>>sql\%tablename%_sql.sql
echo ',' ^|^| CHR(10)) WITHIN GROUP(ORDER BY COLUMN_ID) ^|^| CHR(10) ^|^| ');'^|^|chr(10)^|^|'exit;'>>sql\%tablename%_sql.sql
echo FROM USER_TAB_COLUMNS T1>>sql\%tablename%_sql.sql
echo WHERE T1.TABLE_NAME = '%tablename%';>>sql\%tablename%_sql.sql
echo spool off>>sql\%tablename%_sql.sql

::生成sqlldr控制文件
echo spool ctl\%tablename%.ctl>>sql\%tablename%_sql.sql
echo select 'LOAD DATA'^|^|chr(10)^|^| >>sql\%tablename%_sql.sql
echo 'INFILE ''data\%tablename%.csv'''^|^|chr(10)^|^| >>sql\%tablename%_sql.sql
echo 'APPEND INTO TABLE %tablename%'^|^|chr(10)^|^| >>sql\%tablename%_sql.sql
echo 'FIELDS TERMINATED BY '',''' ^|^|chr(10)^|^| >>sql\%tablename%_sql.sql
echo 'OPTIONALLY ENCLOSED BY ''^"'''^|^|chr(10)^|^| >>sql\%tablename%_sql.sql
echo 'TRAILING NULLCOLS'^|^|chr(10)^|^|'('^|^|listagg(f_cbind(column_name, >>sql\%tablename%_sql.sql
echo case when data_type = 'DATE' then 'date "yyyymmddhh24miss"' >>sql\%tablename%_sql.sql
echo when data_length ^> 255 then 'char(4000)' else null end, ' '), >>sql\%tablename%_sql.sql
echo ',' ^|^| chr(10)) within group(order by column_id)^|^|')' >>sql\%tablename%_sql.sql
echo from user_tab_cols t >>sql\%tablename%_sql.sql
echo where table_name = '%tablename%';>>sql\%tablename%_sql.sql
echo spool off>>sql\%tablename%_sql.sql

echo exit;>>sql\%tablename%_sql.sql

sqlplus -s %ora_uid%/%ora_pwd%@%ora_ip%:%ora_port%/%ora_sid% @sql\%tablename%_sql.sql


