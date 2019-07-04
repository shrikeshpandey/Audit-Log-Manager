CREATE OR REPLACE VIEW ALMGR_ALL_COL_LOGS_VW AS
SELECT "ROW_LOG_ID","COL_LOG_ID","EVENT_TIME","EVENT_TYPE_CODE","EVENT_NAME","SCHEMA_NAME","TABLE_NAME","PRIMARY_KEY","COLUMN_NAME","VALUE_TYPE","OLD_VALUE","NEW_VALUE","ORACLE_USER","OS_USER","APPL_USER","TERMINAL","PROGRAM","TRAN_NAME" FROM ALMGR_COL_LOGS_VW
  UNION ALL
  SELECT "ROW_LOG_ID","COL_LOG_ID","EVENT_TIME","EVENT_TYPE_CODE","EVENT_NAME","SCHEMA_NAME","TABLE_NAME","PRIMARY_KEY","COLUMN_NAME","VALUE_TYPE","OLD_VALUE","NEW_VALUE","ORACLE_USER","OS_USER","APPL_USER","TERMINAL","PROGRAM","TRAN_NAME" FROM ALMGR_COL_LOGS_ARCHIVED_VW;