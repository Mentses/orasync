CREATE OR REPLACE FUNCTION F_CBIND(P_1 varchar2, P_2 varchar2, P_SYMBOL varchar2)
  RETURN VARCHAR2 AS
  v_output varchar2(100);
BEGIN
  select nvl2(P_1, P_1 || nvl2(P_2, P_SYMBOL || P_2, ''), nvl2(P_2, P_2, ''))
    into v_output
    from dual;
  return v_output;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END F_CBIND;
/
