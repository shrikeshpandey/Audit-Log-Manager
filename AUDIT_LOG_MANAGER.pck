CREATE OR REPLACE PACKAGE AUDIT_LOG_MANAGER IS
  /*============================================================================================*/

  ------------------------------------------------------------------------------------
  FUNCTION IS_TABLE_ALMGR(i_table_name IN VARCHAR) RETURN BOOLEAN;
  FUNCTION IS_TABLE_ALMGR(i_schema_name IN VARCHAR,
                          i_table_name  IN VARCHAR) RETURN BOOLEAN;

  PROCEDURE ADD_TABLE(i_table_name        IN VARCHAR,
                      i_keep_data_online  IN NUMBER DEFAULT NULL,
                      i_keep_data_archive IN NUMBER DEFAULT NULL);
  PROCEDURE ADD_TABLE(i_schema_name       IN VARCHAR,
                      i_table_name        IN VARCHAR,
                      i_keep_data_online  IN NUMBER DEFAULT NULL,
                      i_keep_data_archive IN NUMBER DEFAULT NULL);

  PROCEDURE MODIFY_TABLE(i_table_name        IN VARCHAR,
                         i_keep_data_online  IN NUMBER DEFAULT NULL,
                         i_keep_data_archive IN NUMBER DEFAULT NULL);
  PROCEDURE MODIFY_TABLE(i_schema_name       IN VARCHAR,
                         i_table_name        IN VARCHAR,
                         i_keep_data_online  IN NUMBER DEFAULT NULL,
                         i_keep_data_archive IN NUMBER DEFAULT NULL);

  PROCEDURE REMOVE_TABLE(i_table_name IN VARCHAR);
  PROCEDURE REMOVE_TABLE(i_schema_name IN VARCHAR, i_table_name IN VARCHAR);
  ------------------------------------------------------------------------------------
  PROCEDURE ADD_COLUMN(i_table_name IN VARCHAR, i_column_name IN VARCHAR);
  PROCEDURE ADD_COLUMN(i_schema_name IN VARCHAR,
                       i_table_name  IN VARCHAR,
                       i_column_name IN VARCHAR);

  PROCEDURE REMOVE_COLUMN(i_table_name  IN VARCHAR,
                          i_column_name IN VARCHAR);
  PROCEDURE REMOVE_COLUMN(i_schema_name IN VARCHAR,
                          i_table_name  IN VARCHAR,
                          i_column_name IN VARCHAR);

  PROCEDURE ADD_ALL_COLUMNS(i_table_name IN VARCHAR);
  PROCEDURE ADD_ALL_COLUMNS(i_schema_name IN VARCHAR,
                            i_table_name  IN VARCHAR);

  PROCEDURE REMOVE_ALL_COLUMNS(i_table_name IN VARCHAR);
  PROCEDURE REMOVE_ALL_COLUMNS(i_schema_name IN VARCHAR,
                               i_table_name  IN VARCHAR);
  ------------------------------------------------------------------------------------
  PROCEDURE RECREATE_OBJECTS(i_table_name IN VARCHAR);
  PROCEDURE RECREATE_OBJECTS(i_schema_name IN VARCHAR,
                             i_table_name  IN VARCHAR);
  ------------------------------------------------------------------------------------
  PROCEDURE SET_PARAMETER(i_code IN VARCHAR, i_value IN VARCHAR);

  FUNCTION GET_PARAMETER(i_code IN VARCHAR) RETURN VARCHAR;
  ------------------------------------------------------------------------------------
  PROCEDURE SET_APPL_USER(i_appl_user IN VARCHAR);

  FUNCTION GET_APPL_USER RETURN VARCHAR;
  ------------------------------------------------------------------------------------
  PROCEDURE SET_TRAN_NAME(i_tran_name IN VARCHAR);

  FUNCTION GET_TRAN_NAME RETURN VARCHAR;
  ------------------------------------------------------------------------------------
  FUNCTION IS_ALMGR_ACTIVE RETURN BOOLEAN;

  PROCEDURE START_ALMGR;

  PROCEDURE STOP_ALMGR;
  ------------------------------------------------------------------------------------
  PROCEDURE SET_EVENT_NAME(i_code IN VARCHAR, i_name IN VARCHAR);

  FUNCTION GET_EVENT_NAME(i_code IN VARCHAR) RETURN VARCHAR;
  ------------------------------------------------------------------------------------
  FUNCTION FUNCTION_NAME(i_table_name IN VARCHAR) RETURN VARCHAR;
  FUNCTION FUNCTION_NAME(i_schema_name IN VARCHAR, i_table_name IN VARCHAR)
    RETURN VARCHAR;
  ------------------------------------------------------------------------------------
  PROCEDURE MODIFY_JOB(i_interval IN VARCHAR, i_next_date IN DATE);
  ------------------------------------------------------------------------------------
  FUNCTION INTERNAL_NAME(i_table_name IN VARCHAR) RETURN VARCHAR;
  FUNCTION INTERNAL_NAME(i_schema_name IN VARCHAR, i_table_name IN VARCHAR)
    RETURN VARCHAR;
  ------------------------------------------------------------------------------------
  PROCEDURE INSERT_ROW_LOG(i_event_type  IN VARCHAR,
                           i_schema_name IN VARCHAR,
                           i_table_name  IN VARCHAR,
                           i_pk          IN VARCHAR);
  ------------------------------------------------------------------------------------
  PROCEDURE INSERT_COL_LOG(i_etc       IN CHAR,
                           i_col_name  IN VARCHAR,
                           i_old_value IN NVARCHAR2,
                           i_new_value IN NVARCHAR2);
  PROCEDURE INSERT_COL_LOG(i_etc       IN CHAR,
                           i_col_name  IN VARCHAR,
                           i_old_value IN NUMBER,
                           i_new_value IN NUMBER);
  PROCEDURE INSERT_COL_LOG(i_etc       IN CHAR,
                           i_col_name  IN VARCHAR,
                           i_old_value IN DATE,
                           i_new_value IN DATE);
  PROCEDURE INSERT_COL_LOG(i_etc       IN CHAR,
                           i_col_name  IN VARCHAR,
                           i_old_value IN TIMESTAMP,
                           i_new_value IN TIMESTAMP);
  PROCEDURE INSERT_COL_LOG(i_etc       IN CHAR,
                           i_col_name  IN VARCHAR,
                           i_old_value IN TIMESTAMP WITH TIME ZONE,
                           i_new_value IN TIMESTAMP WITH TIME ZONE);
  ------------------------------------------------------------------------------------
  FUNCTION GET_PK(i_schema_name IN VARCHAR,
                  i_table_name  IN VARCHAR,
                  i_prefix      IN VARCHAR) RETURN VARCHAR;
  ------------------------------------------------------------------------------------
  FUNCTION DMLS_BACKWARDS(i_table_name IN VARCHAR,
                          i_pk         IN VARCHAR DEFAULT NULL,
                          i_to_date    IN DATE DEFAULT NULL)
    RETURN t_dmls_list;
  FUNCTION DMLS_BACKWARDS(i_schema_name IN VARCHAR,
                          i_table_name  IN VARCHAR,
                          i_pk          IN VARCHAR DEFAULT NULL,
                          i_to_date     IN DATE DEFAULT NULL)
    RETURN t_dmls_list;
  ------------------------------------------------------------------------------------
  PROCEDURE CREATE_TRIGGERS(i_schema_name IN VARCHAR,
                            i_table_name  IN VARCHAR);

  PROCEDURE DROP_TRIGGERS(i_schema_name IN VARCHAR,
                          i_table_name  IN VARCHAR);
  ------------------------------------------------------------------------------------
  PROCEDURE CREATE_TYPES(i_schema_name IN VARCHAR, i_table_name IN VARCHAR);

  PROCEDURE DROP_TYPES(i_schema_name IN VARCHAR, i_table_name IN VARCHAR);
  ------------------------------------------------------------------------------------
  PROCEDURE CREATE_FUNCTION(i_schema_name IN VARCHAR,
                            i_table_name  IN VARCHAR);

  PROCEDURE DROP_FUNCTION(i_schema_name IN VARCHAR,
                          i_table_name  IN VARCHAR);
  ------------------------------------------------------------------------------------
  PROCEDURE CREATE_OBJECTS(i_table_name IN VARCHAR);
  PROCEDURE CREATE_OBJECTS(i_schema_name IN VARCHAR,
                           i_table_name  IN VARCHAR);

  PROCEDURE DROP_OBJECTS(i_table_name IN VARCHAR);
  PROCEDURE DROP_OBJECTS(i_schema_name IN VARCHAR, i_table_name IN VARCHAR);
  ------------------------------------------------------------------------------------

  FUNCTION GET_JOB_ID RETURN NUMBER;

  PROCEDURE MOVE_TO_ARCHIVE;

  PROCEDURE PURGE_ARCHIVE;

  PROCEDURE JOB_PROC;
  ------------------------------------------------------------------------------------
END AUDIT_LOG_MANAGER;
/
CREATE OR REPLACE PACKAGE BODY AUDIT_LOG_MANAGER IS
  /*============================================================================================*/

  G_APPL_USER varchar(40) := null;
  G_TRAN_NAME varchar(400) := null;

  ------------------------------------------------------------------------------------
  -- set/get parameteres
  ------------------------------------------------------------------------------------

  PROCEDURE SET_PARAMETER(i_code IN VARCHAR, i_value IN VARCHAR) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_value ALMGR_PARAMETERS.value%TYPE;
    l_code  ALMGR_PARAMETERS.code%TYPE;
  BEGIN
    l_code  := UPPER(i_code);
    l_value := UPPER(SUBSTR(i_value, 1, 100));
    UPDATE ALMGR_PARAMETERS SET value = l_value WHERE UPPER(code) = l_code;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20000, sqlerrm);
  END;

  ------------------------------------------------------------------------------------
  FUNCTION GET_PARAMETER(i_code IN VARCHAR) RETURN VARCHAR IS
    l_value ALMGR_PARAMETERS.value%TYPE;
    l_code  ALMGR_PARAMETERS.code%TYPE;
  BEGIN
    l_code := UPPER(i_code);
    SELECT value
      INTO l_value
      FROM ALMGR_PARAMETERS
     WHERE UPPER(code) = l_code;
    RETURN l_value;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  ------------------------------------------------------------------------------------
  -- set/get application user name
  ------------------------------------------------------------------------------------
  PROCEDURE SET_APPL_USER(i_appl_user IN VARCHAR) IS
  BEGIN
    G_APPL_USER := substr(i_appl_user, 1, 40);
  END;

  ------------------------------------------------------------------------------------
  FUNCTION GET_APPL_USER RETURN VARCHAR IS
  BEGIN
    RETURN G_APPL_USER;
  END;

  ------------------------------------------------------------------------------------
  -- set/get transaction name
  ------------------------------------------------------------------------------------
  PROCEDURE SET_TRAN_NAME(i_tran_name IN VARCHAR) IS
  BEGIN
    G_TRAN_NAME := substr(i_tran_name, 1, 400);
  END;

  ------------------------------------------------------------------------------------
  FUNCTION GET_TRAN_NAME RETURN VARCHAR IS
  BEGIN
    RETURN G_TRAN_NAME;
  END;

  ------------------------------------------------------------------------------------
  -- Intelligence
  ------------------------------------------------------------------------------------
  FUNCTION GET_SCHEMA_FOR_TABLE(i_table_name IN VARCHAR) RETURN VARCHAR IS
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
    l_table_name  ALMGR_TABLES.table_name%TYPE;
    l_cn          number;
  BEGIN
    l_schema_name := UPPER(USER);
    l_table_name  := UPPER(SUBSTR(i_table_name, 1, 40));
    SELECT COUNT(*)
      INTO l_cn
      FROM ALL_TABLES
     WHERE OWNER = l_schema_name
       AND TABLE_NAME = l_table_name;
    IF l_cn = 0 THEN
      SELECT COUNT(*)
        INTO l_cn
        FROM ALL_TABLES
       WHERE TABLE_NAME = l_table_name;
      IF l_cn = 1 THEN
        SELECT OWNER
          INTO l_schema_name
          FROM ALL_TABLES
         WHERE TABLE_NAME = l_table_name;
      ELSE
        l_schema_name := NULL;
      END IF;
    END IF;
    RETURN l_schema_name;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  ------------------------------------------------------------------------------------
  -- Switch on/off the ALMGR service using ONOFF parameter
  ------------------------------------------------------------------------------------
  FUNCTION IS_ALMGR_ACTIVE RETURN BOOLEAN IS
  BEGIN
    IF GET_PARAMETER('ONOFF') = 'ON' THEN
      RETURN TRUE;
    END IF;
    RETURN FALSE;
  END;

  FUNCTION IS_ALMGR_RUNNING RETURN BOOLEAN IS
  BEGIN
    RETURN IS_ALMGR_ACTIVE;
  END;

  ------------------------------------------------------------------------------------
  PROCEDURE START_ALMGR IS
  BEGIN
    IF NOT IS_ALMGR_ACTIVE THEN
      SET_PARAMETER('ONOFF', 'ON');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001, sqlerrm);
  END;

  ------------------------------------------------------------------------------------
  PROCEDURE STOP_ALMGR IS
  BEGIN
    IF IS_ALMGR_ACTIVE THEN
      SET_PARAMETER('ONOFF', 'OFF');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20002, sqlerrm);
  END;

  ------------------------------------------------------------------------------------
  -- set/get Event names
  ------------------------------------------------------------------------------------

  PROCEDURE SET_EVENT_NAME(i_code IN VARCHAR, i_name IN VARCHAR) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_name ALMGR_EVENT_TYPES.name%TYPE;
    l_code ALMGR_EVENT_TYPES.code%TYPE;
  BEGIN
    l_code := UPPER(i_code);
    l_name := SUBSTR(i_name, 1, 64);
    UPDATE ALMGR_EVENT_TYPES SET name = l_name WHERE UPPER(code) = l_code;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20003, sqlerrm);
  END;

  ------------------------------------------------------------------------------------
  FUNCTION GET_EVENT_NAME(i_code IN VARCHAR) RETURN VARCHAR IS
    l_name ALMGR_EVENT_TYPES.name%TYPE;
    l_code ALMGR_EVENT_TYPES.code%TYPE;
  BEGIN
    l_code := UPPER(i_code);
    SELECT name
      INTO l_name
      FROM ALMGR_EVENT_TYPES
     WHERE UPPER(code) = l_code;
    RETURN l_name;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  ------------------------------------------------------------------------------------
  -- Logging
  ------------------------------------------------------------------------------------
  PROCEDURE INSERT_ROW_LOG(i_event_type  IN VARCHAR,
                           i_schema_name IN VARCHAR,
                           i_table_name  IN VARCHAR,
                           i_pk          IN VARCHAR) IS
  BEGIN
    IF GET_PARAMETER('ONOFF') = 'ON' THEN
      G_APPL_USER := substr(NVL(V('APP_USER'), USER), 1, 40);
      INSERT INTO ALMGR_ROW_LOGS
        (event_type_code, schema_name, table_name, pk)
      VALUES
        (i_event_type, i_schema_name, i_table_name, i_pk);
    END IF;
  END;

  ------------------------------------------------------------------------------------
  FUNCTION IS_DIFFER(i_old_value IN NVARCHAR2, i_new_value IN NVARCHAR2)
    RETURN BOOLEAN IS
  BEGIN
    IF (i_old_value IS NOT NULL AND i_new_value IS NULL) OR
       (i_old_value IS NULL AND i_new_value IS NOT NULL) OR
       (i_old_value IS NOT NULL AND i_new_value IS NOT NULL AND
       i_old_value <> i_new_value) THEN
      RETURN TRUE;
    END IF;
    RETURN FALSE;
  END;

  FUNCTION IS_DIFFER(i_old_value IN NUMBER, i_new_value IN NUMBER)
    RETURN BOOLEAN IS
  BEGIN
    IF (i_old_value IS NOT NULL AND i_new_value IS NULL) OR
       (i_old_value IS NULL AND i_new_value IS NOT NULL) OR
       (i_old_value IS NOT NULL AND i_new_value IS NOT NULL AND
       i_old_value <> i_new_value) THEN
      RETURN TRUE;
    END IF;
    RETURN FALSE;
  END;

  FUNCTION IS_DIFFER(i_old_value IN DATE, i_new_value IN DATE) RETURN BOOLEAN IS
  BEGIN
    IF (i_old_value IS NOT NULL AND i_new_value IS NULL) OR
       (i_old_value IS NULL AND i_new_value IS NOT NULL) OR
       (i_old_value IS NOT NULL AND i_new_value IS NOT NULL AND
       i_old_value <> i_new_value) THEN
      RETURN TRUE;
    END IF;
    RETURN FALSE;
  END;

  FUNCTION IS_DIFFER(i_old_value IN TIMESTAMP, i_new_value IN TIMESTAMP)
    RETURN BOOLEAN IS
  BEGIN
    IF (i_old_value IS NOT NULL AND i_new_value IS NULL) OR
       (i_old_value IS NULL AND i_new_value IS NOT NULL) OR
       (i_old_value IS NOT NULL AND i_new_value IS NOT NULL AND
       i_old_value <> i_new_value) THEN
      RETURN TRUE;
    END IF;
    RETURN FALSE;
  END;

  FUNCTION IS_DIFFER(i_old_value IN TIMESTAMP WITH TIME ZONE,
                     i_new_value IN TIMESTAMP WITH TIME ZONE) RETURN BOOLEAN IS
  BEGIN
    IF (i_old_value IS NOT NULL AND i_new_value IS NULL) OR
       (i_old_value IS NULL AND i_new_value IS NOT NULL) OR
       (i_old_value IS NOT NULL AND i_new_value IS NOT NULL AND
       i_old_value <> i_new_value) THEN
      RETURN TRUE;
    END IF;
    RETURN FALSE;
  END;

  ------------------------------------------------------------------------------------
  PROCEDURE INSERT_COL_LOG(i_etc       IN CHAR,
                           i_col_name  IN VARCHAR,
                           i_old_value IN NVARCHAR2,
                           i_new_value IN NVARCHAR2) IS
  BEGIN
    IF GET_PARAMETER('ONOFF') = 'ON' THEN
      IF (i_etc = 'U') AND NOT IS_DIFFER(i_old_value, i_new_value) THEN
        RETURN;
      END IF;
      INSERT INTO ALMGR_COL_LOGS
        (column_name, value_type, old_value, new_value)
      VALUES
        (i_col_name,
         'S',
         SUBSTR(i_old_value, 1, 2000),
         SUBSTR(i_new_value, 1, 2000));
    END IF;
  END;

  PROCEDURE INSERT_COL_LOG(i_etc       IN CHAR,
                           i_col_name  IN VARCHAR,
                           i_old_value IN NUMBER,
                           i_new_value IN NUMBER) IS
  BEGIN
    IF GET_PARAMETER('ONOFF') = 'ON' THEN
      IF (i_etc = 'U') AND NOT IS_DIFFER(i_old_value, i_new_value) THEN
        RETURN;
      END IF;
      INSERT INTO ALMGR_COL_LOGS
        (column_name, value_type, old_value, new_value)
      VALUES
        (i_col_name, 'N', TO_CHAR(i_old_value), TO_CHAR(i_new_value));
    END IF;
  END;

  PROCEDURE INSERT_COL_LOG(i_etc       IN CHAR,
                           i_col_name  IN VARCHAR,
                           i_old_value IN DATE,
                           i_new_value IN DATE) IS
  BEGIN
    IF GET_PARAMETER('ONOFF') = 'ON' THEN
      IF (i_etc = 'U') AND NOT IS_DIFFER(i_old_value, i_new_value) THEN
        RETURN;
      END IF;
      INSERT INTO ALMGR_COL_LOGS
        (column_name, value_type, old_value, new_value)
      VALUES
        (i_col_name,
         'D',
         TO_CHAR(i_old_value,
                 NVL(GET_PARAMETER('DATEFORMAT'), 'YYYY.MM.DD HH24:MI:SS')),
         TO_CHAR(i_new_value,
                 NVL(GET_PARAMETER('DATEFORMAT'), 'YYYY.MM.DD HH24:MI:SS')));
    END IF;
  END;

  PROCEDURE INSERT_COL_LOG(i_etc       IN CHAR,
                           i_col_name  IN VARCHAR,
                           i_old_value IN TIMESTAMP,
                           i_new_value IN TIMESTAMP) IS
  BEGIN
    IF GET_PARAMETER('ONOFF') = 'ON' THEN
      IF (i_etc = 'U') AND NOT IS_DIFFER(i_old_value, i_new_value) THEN
        RETURN;
      END IF;
      INSERT INTO ALMGR_COL_LOGS
        (column_name, value_type, old_value, new_value)
      VALUES
        (i_col_name,
         'T',
         TO_CHAR(i_old_value,
                 NVL(GET_PARAMETER('TSFORMAT'), 'YYYY.MM.DD HH24:MI:SS.FF')),
         TO_CHAR(i_new_value,
                 NVL(GET_PARAMETER('TSFORMAT'), 'YYYY.MM.DD HH24:MI:SS.FF')));
    END IF;
  END;

  PROCEDURE INSERT_COL_LOG(i_etc       IN CHAR,
                           i_col_name  IN VARCHAR,
                           i_old_value IN TIMESTAMP WITH TIME ZONE,
                           i_new_value IN TIMESTAMP WITH TIME ZONE) IS
  BEGIN
    IF GET_PARAMETER('ONOFF') = 'ON' THEN
      IF (i_etc = 'U') AND NOT IS_DIFFER(i_old_value, i_new_value) THEN
        RETURN;
      END IF;
      INSERT INTO ALMGR_COL_LOGS
        (column_name, value_type, old_value, new_value)
      VALUES
        (i_col_name,
         'Z',
         TO_CHAR(i_old_value,
                 NVL(GET_PARAMETER('TSWZFORMAT'),
                     'YYYY.MM.DD HH24:MI:SS.FF TZH:TZM')),
         TO_CHAR(i_new_value,
                 NVL(GET_PARAMETER('TSWZFORMAT'),
                     'YYYY.MM.DD HH24:MI:SS.FF TZH:TZM')));
    END IF;
  END;

  ------------------------------------------------------------------------------------
  -- add/modify/remove audit logged table data
  ------------------------------------------------------------------------------------
  PROCEDURE DROP_TRIGGERS(i_schema_name IN VARCHAR,
                          i_table_name  IN VARCHAR) IS
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
    l_table_name  ALMGR_TABLES.table_name%TYPE;
    l_int_name    VARCHAR(40);
    l_sql         VARCHAR(2000);
    l_trg_number  NUMBER(10);
  BEGIN
    l_schema_name := UPPER(SUBSTR(i_schema_name, 1, 40));
    l_table_name  := UPPER(SUBSTR(i_table_name, 1, 40));
    l_int_name    := INTERNAL_NAME(l_schema_name, l_table_name);
    SELECT trg_number
      INTO l_trg_number
      FROM ALMGR_TABLES lt
     WHERE lt.schema_name = l_schema_name
       AND lt.table_name = l_table_name;
    l_sql := 'DROP TRIGGER trg__' || l_int_name || '_I';
    BEGIN
      EXECUTE IMMEDIATE l_sql;
    EXCEPTION
      WHEN OTHERS THEN
        NULL; -- Hide the error if raised
    END;
    l_sql := 'DROP TRIGGER  trg__' || l_int_name || '_U';
    BEGIN
      EXECUTE IMMEDIATE l_sql;
    EXCEPTION
      WHEN OTHERS THEN
        NULL; -- Hide the error if raised
    END;
    l_sql := 'DROP TRIGGER  trg__' || l_int_name || '_D';
    BEGIN
      EXECUTE IMMEDIATE l_sql;
    EXCEPTION
      WHEN OTHERS THEN
        NULL; -- Hide the error if raised
    END;
  END;

  ------------------------------------------------------------------------------------
  -- return with the list of primary keys column names separated by ||'separator'||
  -- Prefix is ':new' or ':old' for example
  ------------------------------------------------------------------------------------
  -- for non work space managed tables
  FUNCTION GET_PK_NWS(i_schema_name IN VARCHAR,
                      i_table_name  IN VARCHAR,
                      i_prefix      IN VARCHAR) RETURN VARCHAR IS
    l_pk  VARCHAR(4000);
    l_sep VARCHAR(40);
  BEGIN
    l_pk  := '';
    l_sep := NVL(GET_PARAMETER('SEPARATOR'), '|');
    FOR l_a_pk IN (SELECT column_name
                     FROM all_constraints uc, all_cons_columns dbc
                    WHERE uc.constraint_type = 'P'
                      AND dbc.constraint_name = uc.constraint_name
                      AND dbc.owner = i_schema_name
                      AND uc.owner = i_schema_name
                      AND dbc.table_name = i_table_name
                    ORDER BY POSITION) LOOP
      IF NVL(LENGTH(l_pk), 0) + LENGTH(l_a_pk.column_name) < 4000 THEN
        l_pk := l_pk || i_prefix || l_a_pk.column_name || '||''' || l_sep ||
                '''||';
      END IF;
    END LOOP;
    l_pk := SUBSTR(l_pk, 1, LENGTH(l_pk) - (6 + LENGTH(l_sep)));
    RETURN l_pk;
  END;

  ------------------------------------------------------------------------------------
  -- for general usage
  FUNCTION GET_PK(i_schema_name IN VARCHAR,
                  i_table_name  IN VARCHAR,
                  i_prefix      IN VARCHAR) RETURN VARCHAR IS
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
    l_table_name  ALMGR_TABLES.table_name%TYPE;
  BEGIN
    l_schema_name := UPPER(SUBSTR(i_schema_name, 1, 40));
    l_table_name  := UPPER(SUBSTR(i_table_name, 1, 40));
    RETURN GET_PK_NWS(l_schema_name, l_table_name, i_prefix);
  END;

  ------------------------------------------------------------------------------------
  -- Trigger creations
  ------------------------------------------------------------------------------------

  ------------------------------------------------------------------------------------
  -- for non work space managed tables
  PROCEDURE CREATE_TRIGGERS_NWS(i_schema_name IN VARCHAR,
                                i_table_name  IN VARCHAR) IS
  
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
    l_table_name  ALMGR_TABLES.table_name%TYPE;
  
    CURSOR l_c IS
      SELECT tc.column_name cn
        FROM all_tab_columns tc, ALMGR_COLUMNS lc
       WHERE tc.owner = l_schema_name
         AND tc.table_name = l_table_name
         AND tc.owner = lc.schema_name
         AND tc.table_name = lc.table_name
         AND tc.column_name = lc.column_name
         AND (tc.data_type IN ('CHAR',
                               'DATE',
                               'FLOAT',
                               'NCHAR',
                               'NUMBER',
                               'NVARCHAR',
                               'VARCHAR',
                               'VARCHAR2',
                               'NVARCHAR2') OR
             tc.data_type LIKE 'TIMESTAMP%')
       ORDER BY tc.column_id;
    l_cr       l_c%ROWTYPE;
    l_crlf     VARCHAR(2) := CHR(13) || CHR(10); -- $0D0A  CrLf
    l_pk_n     VARCHAR(4000);
    l_pk_o     VARCHAR(4000);
    l_sql      VARCHAR(20000); -- Full trg string
    l_int_name VARCHAR(40);
  
  BEGIN
    l_schema_name := UPPER(SUBSTR(i_schema_name, 1, 40));
    l_table_name  := UPPER(SUBSTR(i_table_name, 1, 40));
    l_int_name    := INTERNAL_NAME(l_schema_name, l_table_name);
    l_pk_n        := NVL(GET_PK(l_schema_name, l_table_name, ':NEW.'),
                         'NULL');
    l_pk_o        := NVL(GET_PK(l_schema_name, l_table_name, ':OLD.'),
                         'NULL');
  
    -- INSERT
    l_sql := 'CREATE OR REPLACE TRIGGER trg__' || l_int_name || '_I';
    l_sql := l_sql || '  AFTER INSERT ON ' || l_schema_name || '.' ||
             l_table_name || ' FOR EACH ROW' || l_crlf;
    l_sql := l_sql || 'BEGIN' || l_crlf;
    l_sql := l_sql || '  AUDIT_LOG_MANAGER.INSERT_ROW_LOG(''I'',''' ||
             l_schema_name || ''',''' || l_table_name || ''',' || l_pk_n || ');' ||
             l_crlf;
    l_sql := l_sql || 'END;';
    EXECUTE IMMEDIATE l_sql;
  
    -- UPDATE
    l_sql := 'CREATE OR REPLACE TRIGGER trg__' || l_int_name || '_U';
    l_sql := l_sql || '  AFTER UPDATE ON ' || l_schema_name || '.' ||
             l_table_name || ' FOR EACH ROW' || l_crlf;
    l_sql := l_sql || 'BEGIN' || l_crlf;
    l_sql := l_sql || '  AUDIT_LOG_MANAGER.INSERT_ROW_LOG(''U'',''' ||
             l_schema_name || ''',''' || l_table_name || ''',' || l_pk_n || ');' ||
             l_crlf;
    OPEN l_c;
    LOOP
      FETCH l_c
        INTO l_cr;
      EXIT WHEN l_c%NOTFOUND;
      l_sql := l_sql || '  AUDIT_LOG_MANAGER.INSERT_COL_LOG(''U'',''' ||
               l_cr.cn || ''',:OLD.' || l_cr.cn || ',:NEW.' || l_cr.cn || ');' ||
               l_crlf;
    END LOOP;
    CLOSE l_c;
    l_sql := l_sql || 'END;';
    EXECUTE IMMEDIATE l_sql;
  
    -- DELETE
    l_sql := 'CREATE OR REPLACE TRIGGER trg__' || l_int_name || '_D';
    l_sql := l_sql || '  AFTER DELETE ON ' || l_schema_name || '.' ||
             l_table_name || ' FOR EACH ROW' || l_crlf;
    l_sql := l_sql || 'BEGIN' || l_crlf;
    l_sql := l_sql || '  AUDIT_LOG_MANAGER.INSERT_ROW_LOG(''D'',''' ||
             l_schema_name || ''',''' || l_table_name || ''',' || l_pk_o || ');' ||
             l_crlf;
    OPEN l_c;
    LOOP
      FETCH l_c
        INTO l_cr;
      EXIT WHEN l_c%NOTFOUND;
      l_sql := l_sql || '  AUDIT_LOG_MANAGER.INSERT_COL_LOG(''D'',''' ||
               l_cr.cn || ''',:OLD.' || l_cr.cn || ',NULL);' || l_crlf;
    END LOOP;
    CLOSE l_c;
    l_sql := l_sql || 'END;';
    EXECUTE IMMEDIATE l_sql;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20006, sqlerrm);
  END;

  ------------------------------------------------------------------------------------

  PROCEDURE CREATE_TRIGGERS(i_schema_name IN VARCHAR,
                            i_table_name  IN VARCHAR) IS
  BEGIN
    CREATE_TRIGGERS_NWS(i_schema_name, i_table_name);
  END;

  ------------------------------------------------------------------------------------
  -- Historical view
  ------------------------------------------------------------------------------------
  FUNCTION IS_TABLE_ALMGR(i_table_name IN VARCHAR) RETURN BOOLEAN IS
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
  BEGIN
    l_schema_name := GET_SCHEMA_FOR_TABLE(i_table_name);
    IF l_schema_name IS NOT NULL THEN
      RETURN IS_TABLE_ALMGR(l_schema_name, i_table_name);
    ELSE
      RAISE_APPLICATION_ERROR(-20008, sqlerrm);
    END IF;
  END;

  FUNCTION IS_TABLE_ALMGR(i_schema_name IN VARCHAR,
                          i_table_name  IN VARCHAR) RETURN BOOLEAN IS
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
    l_table_name  ALMGR_TABLES.table_name%TYPE;
    l_cnt         NUMBER(10);
  BEGIN
    l_schema_name := UPPER(SUBSTR(i_schema_name, 1, 40));
    l_table_name  := UPPER(SUBSTR(i_table_name, 1, 40));
    -- exists?
    SELECT COUNT(*)
      INTO l_cnt
      FROM ALMGR_TABLES lt
     WHERE UPPER(lt.schema_name) = l_schema_name
       AND UPPER(lt.table_name) = l_table_name;
    IF l_cnt = 1 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;

  -- return with the internal name of trg ID
  FUNCTION INTERNAL_NAME(i_table_name IN VARCHAR) RETURN VARCHAR IS
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
  BEGIN
    l_schema_name := GET_SCHEMA_FOR_TABLE(i_table_name);
    IF l_schema_name IS NOT NULL THEN
      RETURN INTERNAL_NAME(l_schema_name, i_table_name);
    ELSE
      RAISE_APPLICATION_ERROR(-20009, sqlerrm);
    END IF;
  END;

  FUNCTION INTERNAL_NAME(i_schema_name IN VARCHAR, i_table_name IN VARCHAR)
    RETURN VARCHAR IS
    l_trg_number  ALMGR_TABLES.trg_number%TYPE;
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
    l_table_name  ALMGR_TABLES.table_name%TYPE;
  BEGIN
    l_schema_name := UPPER(SUBSTR(i_schema_name, 1, 40));
    l_table_name  := UPPER(SUBSTR(i_table_name, 1, 40));
    IF IS_TABLE_ALMGR(l_schema_name, l_table_name) THEN
      SELECT trg_number
        INTO l_trg_number
        FROM ALMGR_TABLES
       WHERE UPPER(schema_name) = l_schema_name
         AND UPPER(table_name) = l_table_name;
      RETURN LPAD(LTRIM(TO_CHAR(l_trg_number)), 10, '0');
    ELSE
      RETURN '';
    END IF;
  END;

  ------------------------------------------------------------------------------------
  -- return with the function name
  FUNCTION FUNCTION_NAME(i_table_name IN VARCHAR) RETURN VARCHAR IS
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
  BEGIN
    l_schema_name := GET_SCHEMA_FOR_TABLE(i_table_name);
    IF l_schema_name IS NOT NULL THEN
      RETURN FUNCTION_NAME(l_schema_name, i_table_name);
    ELSE
      RAISE_APPLICATION_ERROR(-20010,
                              'Schema is ambiguous. Call FUNCTION_NAME(schema, table) function!');
    END IF;
  END;

  FUNCTION FUNCTION_NAME(i_schema_name IN VARCHAR, i_table_name IN VARCHAR)
    RETURN VARCHAR IS
  BEGIN
    RETURN 'ALMGR_' || INTERNAL_NAME(i_schema_name, i_table_name) || '_H';
  END;

  ------------------------------------------------------------------------------------

  PROCEDURE DROP_TYPES(i_schema_name IN VARCHAR, i_table_name IN VARCHAR) IS
    l_int_name    VARCHAR(40);
    l_sql         VARCHAR(4000);
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
    l_table_name  ALMGR_TABLES.table_name%TYPE;
  BEGIN
    l_schema_name := UPPER(SUBSTR(i_schema_name, 1, 40));
    l_table_name  := UPPER(SUBSTR(i_table_name, 1, 40));
    l_int_name    := INTERNAL_NAME(l_schema_name, l_table_name);
    l_sql         := 'DROP TYPE T_' || l_int_name || '_T';
    BEGIN
      EXECUTE IMMEDIATE l_sql;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    l_sql := 'DROP TYPE T_' || l_int_name || '_R';
    BEGIN
      EXECUTE IMMEDIATE l_sql;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END;

  ------------------------------------------------------------------------------------
  PROCEDURE CREATE_TYPES(i_schema_name IN VARCHAR, i_table_name IN VARCHAR) IS
    l_crlf        VARCHAR(2) := CHR(13) || CHR(10); -- $0D0A  CrLf
    l_int_name    VARCHAR(40);
    l_sql         CLOB; --VARCHAR(4000);
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
    l_table_name  ALMGR_TABLES.table_name%TYPE;
    l_length      NUMBER := 0;
  BEGIN
    l_schema_name := UPPER(SUBSTR(i_schema_name, 1, 40));
    l_table_name  := UPPER(SUBSTR(i_table_name, 1, 40));
    l_int_name    := INTERNAL_NAME(l_schema_name, l_table_name);
    l_sql         := 'CREATE OR REPLACE TYPE T_' || l_int_name ||
                     '_R  AS OBJECT ( ' || l_crlf;
    l_sql         := l_sql || ' ROW_LOG_ID NUMBER(10),' || l_crlf;
  
    FOR l_cr IN (SELECT tc.column_name,
                        tc.data_type,
                        tc.data_length,
                        tc.data_precision,
                        tc.data_scale
                   FROM all_tab_columns tc
                  WHERE tc.owner = l_schema_name
                    AND tc.table_name = l_table_name
                    AND (tc.data_type IN ('CHAR',
                                          'DATE',
                                          'FLOAT',
                                          'NCHAR',
                                          'NUMBER',
                                          'NVARCHAR',
                                          'VARCHAR',
                                          'VARCHAR2',
                                          'NVARCHAR2') OR
                        tc.data_type LIKE 'TIMESTAMP%')
                  ORDER BY tc.column_id) LOOP
      l_length := length(l_sql);
      l_sql    := l_sql || ' ' || l_cr.column_name || '  ' ||
                  l_cr.data_type;
      IF l_cr.data_type IN
         ('CHAR', 'NCHAR', 'NVARCHAR', 'VARCHAR', 'VARCHAR2', 'NVARCHAR2') AND
         NVL(l_cr.data_length, 0) > 0 THEN
        l_sql := l_sql || '(' || l_cr.data_length || ')';
      ELSIF l_cr.data_type IN ('FLOAT', 'NUMBER') THEN
        l_sql := l_sql || '(' || NVL(l_cr.data_precision, 20);
        IF NVL(l_cr.data_scale, 0) > 0 THEN
          l_sql := l_sql || ',' || l_cr.data_scale || ')';
        ELSE
          l_sql := l_sql || ')';
        END IF;
      END IF;
    
      l_sql := l_sql || ',' || l_crlf;
    
    END LOOP;
    l_sql := SUBSTR(l_sql, 1, LENGTH(l_sql) - 3);
    l_sql := l_sql || ')' || l_crlf;
    EXECUTE IMMEDIATE l_sql;
    l_sql := 'CREATE OR REPLACE TYPE T_' || l_int_name ||
             '_T AS TABLE OF T_' || l_int_name || '_R';
    EXECUTE IMMEDIATE l_sql;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line(l_sql);
      RAISE_APPLICATION_ERROR(-20011, sqlerrm);
  END;

  ------------------------------------------------------------------------------------
  PROCEDURE DROP_FUNCTION(i_schema_name IN VARCHAR,
                          i_table_name  IN VARCHAR) IS
    l_fnc_name VARCHAR(40);
    l_sql      VARCHAR(4000);
  BEGIN
    l_fnc_name := FUNCTION_NAME(i_schema_name, i_table_name);
    l_sql      := 'DROP FUNCTION ' || l_fnc_name;
    EXECUTE IMMEDIATE l_sql;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  ------------------------------------------------------------------------------------
  PROCEDURE GET_COL_LISTS(i_schema_name IN VARCHAR,
                          i_table_name  IN VARCHAR,
                          o_col_list    OUT VARCHAR,
                          o_null_list   OUT VARCHAR,
                          o_num_of_cols OUT NUMBER) IS
  BEGIN
    o_col_list    := '';
    o_null_list   := '';
    o_num_of_cols := 0;
    FOR l_cr IN (SELECT column_name
                   FROM all_tab_columns tc
                  WHERE owner = i_schema_name
                    AND table_name = i_table_name
                    AND (data_type IN ('CHAR',
                                       'DATE',
                                       'FLOAT',
                                       'NCHAR',
                                       'NUMBER',
                                       'NVARCHAR',
                                       'VARCHAR',
                                       'VARCHAR2',
                                       'NVARCHAR2') OR
                        data_type LIKE 'TIMESTAMP%')
                  ORDER BY column_id) LOOP
      o_col_list    := o_col_list || ',' || l_cr.column_name;
      o_null_list   := o_null_list || ',NULL';
      o_num_of_cols := o_num_of_cols + 1;
    END LOOP;
    o_col_list  := SUBSTR(o_col_list, 2, 4000);
    o_null_list := SUBSTR(o_null_list, 2, 4000);
  END;

  ------------------------------------------------------------------------------------
  FUNCTION DMLS_BACKWARDS(i_schema_name IN VARCHAR,
                          i_table_name  IN VARCHAR,
                          i_pk          IN VARCHAR DEFAULT NULL,
                          i_to_date     IN DATE DEFAULT NULL)
    RETURN t_dmls_list IS
    l_sql         VARCHAR(20000) := '';
    l_col_list    VARCHAR(10000) := '';
    l_val_list    VARCHAR(10000) := '';
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
    l_table_name  ALMGR_TABLES.table_name%TYPE;
    l_table       t_dmls_list := t_dmls_list();
    l_rec         t_dmls_rec := t_dmls_rec(null, null);
    l_pk          VARCHAR(400);
    l_del_flag    BOOLEAN := FALSE;
    l_upd_flag    BOOLEAN := FALSE;
    l_prev_rlID   NUMBER(10) := 0;
    l_prev_pk_val VARCHAR(400);
  BEGIN
    l_schema_name := UPPER(SUBSTR(i_schema_name, 1, 40));
    l_table_name  := UPPER(SUBSTR(i_table_name, 1, 40));
    l_pk          := GET_PK(l_schema_name, l_table_name, null);
    FOR l_cr IN (SELECT *
                   FROM ALMGR_ALL_COL_LOGS_VW
                  WHERE schema_name = l_schema_name
                    AND table_name = l_table_name
                    AND event_time >= NVL(i_to_date, event_time)
                    AND primary_key = NVL(i_pk, primary_key)
                  ORDER BY row_log_id DESC) LOOP
    
      IF (l_cr.event_type_code <> 'D') AND l_del_flag THEN
        l_col_list := SUBSTR(l_col_list, 1, LENGTH(l_col_list) - 1);
        l_val_list := SUBSTR(l_val_list, 1, LENGTH(l_val_list) - 1);
        l_sql      := l_sql || ' (' || l_col_list || ') values (' ||
                      l_val_list || ');';
        l_col_list := '';
        l_val_list := '';
        l_table.EXTEND;
        l_rec.row_log_id := l_cr.row_log_id;
        l_rec.dml_command := l_sql;
        l_table(l_table.COUNT) := l_rec;
        l_del_flag := FALSE;
      END IF;
    
      IF (l_cr.row_log_id <> l_prev_rlID) AND l_upd_flag THEN
        l_col_list := SUBSTR(l_col_list, 1, LENGTH(l_col_list) - 1);
        l_sql      := l_sql || l_col_list || ' WHERE ' || l_pk || ' = ''' ||
                      l_prev_pk_val || ''';';
        l_col_list := '';
        l_table.EXTEND;
        l_rec.row_log_id := l_cr.row_log_id;
        l_rec.dml_command := l_sql;
        l_table(l_table.COUNT) := l_rec;
        l_upd_flag := FALSE;
      END IF;
    
      --- INSERT -> DELETE
      IF l_cr.event_type_code = 'I' THEN
        l_sql := 'DELETE ' || l_schema_name || '.' || l_table_name ||
                 ' WHERE ' || l_pk || ' = ''' || l_cr.primary_key || ''';';
        l_table.EXTEND;
        l_rec.row_log_id := l_cr.row_log_id;
        l_rec.dml_command := l_sql;
        l_table(l_table.COUNT) := l_rec;
      
        --- DELETE -> INSERT
      ELSIF l_cr.event_type_code = 'D' THEN
        IF NOT l_del_flag THEN
          l_del_flag := TRUE;
          l_sql      := 'INSERT INTO ' || l_schema_name || '.' ||
                        l_table_name;
        END IF;
        IF l_del_flag THEN
          l_col_list := l_col_list || l_cr.column_name || ',';
          IF l_cr.value_type = 'D' AND l_cr.old_value IS NOT NULL THEN
            l_val_list := l_val_list || 'TO_DATE(''';
          ELSIF l_cr.value_type = 'T' AND l_cr.Old_value IS NOT NULL THEN
            l_val_list := l_val_list || 'TO_TIMESTAMP(''';
          ELSIF l_cr.value_type = 'Z' AND l_cr.old_value IS NOT NULL THEN
            l_val_list := l_val_list || 'TO_TIMESTAMP_TZ(''';
          ELSIF l_cr.value_type = 'S' AND l_cr.old_value IS NOT NULL THEN
            l_val_list := l_val_list || '''';
          END IF;
          l_val_list := l_val_list || nvl(l_cr.old_value, 'NULL');
          IF l_cr.value_type = 'D' AND l_cr.old_value IS NOT NULL THEN
            l_val_list := l_val_list || ''',''YYYY.MM.DD HH24:MI:SS'')';
          ELSIF l_cr.value_type = 'T' AND l_cr.old_value IS NOT NULL THEN
            l_val_list := l_val_list || ''',''YYYY.MM.DD HH24:MI:SS.FF'')';
          ELSIF l_cr.value_type = 'Z' AND l_cr.old_value IS NOT NULL THEN
            l_val_list := l_val_list ||
                          ''',''YYYY.MM.DD HH24:MI:SS.FF TZH:TZM'')';
          ELSIF l_cr.value_type = 'S' AND l_cr.old_value IS NOT NULL THEN
            l_val_list := l_val_list || '''';
          END IF;
          l_val_list := l_val_list || ',';
        END IF;
      
        --- UPDATE -> UPDATE
      ELSIF l_cr.event_type_code = 'U' THEN
        IF NOT l_upd_flag THEN
          l_upd_flag := TRUE;
          l_sql      := 'UPDATE ' || l_schema_name || '.' || l_table_name ||
                        ' SET ';
        END IF;
        IF l_upd_flag THEN
          l_col_list := l_col_list || l_cr.column_name || '=';
          IF l_cr.value_type = 'D' AND l_cr.old_value IS NOT NULL THEN
            l_col_list := l_col_list || 'TO_DATE(''';
          ELSIF l_cr.value_type = 'T' AND l_cr.old_value IS NOT NULL THEN
            l_val_list := l_val_list || 'TO_TIMESTAMP(''';
          ELSIF l_cr.value_type = 'Z' AND l_cr.old_value IS NOT NULL THEN
            l_val_list := l_val_list || 'TO_TIMESTAMP_TZ(''';
          ELSIF l_cr.value_type = 'S' AND l_cr.old_value IS NOT NULL THEN
            l_col_list := l_col_list || '''';
          END IF;
          l_col_list := l_col_list || nvl(l_cr.old_value, 'NULL');
          IF l_cr.value_type = 'D' AND l_cr.old_value IS NOT NULL THEN
            l_col_list := l_col_list || ''',''YYYY.MM.DD HH24:MI:SS'')';
          ELSIF l_cr.value_type = 'T' AND l_cr.old_value IS NOT NULL THEN
            l_val_list := l_val_list || ''',''YYYY.MM.DD HH24:MI:SS.FF'')';
          ELSIF l_cr.value_type = 'Z' AND l_cr.old_value IS NOT NULL THEN
            l_val_list := l_val_list ||
                          ''',''YYYY.MM.DD HH24:MI:SS.FF TZH:TZM'')';
          ELSIF l_cr.value_type = 'S' AND l_cr.old_value IS NOT NULL THEN
            l_col_list := l_col_list || '''';
          END IF;
          l_col_list := l_col_list || ',';
        END IF;
      END IF;
    
      IF l_cr.row_log_id <> l_prev_rlID THEN
        l_prev_rlID   := l_cr.row_log_id;
        l_prev_pk_val := l_cr.primary_key;
      END IF;
    
    END LOOP;
    RETURN l_table;
  END;

  FUNCTION DMLS_BACKWARDS(i_table_name IN VARCHAR,
                          i_pk         IN VARCHAR DEFAULT NULL,
                          i_to_date    IN DATE DEFAULT NULL)
    RETURN t_dmls_list IS
    l_schema_name VARCHAR(50);
  BEGIN
    l_schema_name := GET_SCHEMA_FOR_TABLE(i_table_name);
    IF l_schema_name IS NOT NULL THEN
      RETURN DMLS_BACKWARDS(l_schema_name, i_table_name, i_pk, i_to_date);
    ELSE
      RAISE_APPLICATION_ERROR(-20012,
                              'Schema is ambiguous. Call DMLS_BACKWARDS(schema, table, ...) function!');
    END IF;
  END;
  ------------------------------------------------------------------------------------
  PROCEDURE CREATE_FUNCTION(i_schema_name IN VARCHAR,
                            i_table_name  IN VARCHAR) IS
    l_crlf        VARCHAR(2) := CHR(13) || CHR(10); -- $0D0A  CrLf
    l_fnc_name    VARCHAR(40) := '';
    l_int_name    VARCHAR(40) := '';
    l_sql         VARCHAR(32000) := '';
    l_col_list    VARCHAR(3200) := ''; -- List of columns
    l_null_list   VARCHAR(4000) := '';
    l_num_of_cols NUMBER;
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
    l_table_name  ALMGR_TABLES.table_name%TYPE;
  BEGIN
    l_schema_name := UPPER(SUBSTR(i_schema_name, 1, 40));
    l_table_name  := UPPER(SUBSTR(i_table_name, 1, 40));
    l_int_name    := INTERNAL_NAME(l_schema_name, l_table_name);
    l_fnc_name    := FUNCTION_NAME(l_schema_name, l_table_name);
    GET_COL_LISTS(l_schema_name,
                  l_table_name,
                  l_col_list,
                  l_null_list,
                  l_num_of_cols);
    l_sql := 'CREATE OR REPLACE FUNCTION ' || l_fnc_name ||
             '(i_pk IN VARCHAR) RETURN T_' || l_int_name ||
             '_T PIPELINED IS' || l_crlf;
    l_sql := l_sql || '  l_schema_name        VARCHAR(50)    := ''' ||
             l_schema_name || ''';' || l_crlf;
    l_sql := l_sql || '  l_table_name         VARCHAR(50)    := ''' ||
             l_table_name || ''';' || l_crlf;
    l_sql := l_sql || '  l_hr                 T_' || l_int_name ||
             '_R := T_' || l_int_name || '_R(NULL, ' || l_null_list || ');' ||
             l_crlf;
    l_sql := l_sql || '  l_ht                 T_' || l_int_name ||
             '_T := T_' || l_int_name || '_T();' || l_crlf;
    l_sql := l_sql || '  l_pk                 VARCHAR(400);' || l_crlf;
    l_sql := l_sql || '  l_sql                VARCHAR(4000);' || l_crlf;
    l_sql := l_sql || '  l_v                  VARCHAR(4000);' || l_crlf;
    l_sql := l_sql || 'BEGIN' || l_crlf;
    l_sql := l_sql ||
             '  FOR l_rr IN (SELECT * FROM ALMGR_ALL_ROW_LOGS_VW WHERE schema_name = l_schema_name AND table_name  = l_table_name' ||
             l_crlf;
    l_sql := l_sql ||
             '                  AND primary_key = i_pk ORDER BY row_log_id DESC) LOOP' ||
             l_crlf;
    l_sql := l_sql ||
             '    IF (l_hr.row_log_id IS NULL) AND (l_rr.event_type_code!=''D'') THEN' ||
             l_crlf;
    l_sql := l_sql ||
             '      l_pk := AUDIT_LOG_MANAGER.GET_PK(l_schema_name, l_table_name, null);' ||
             l_crlf;
    l_sql := l_sql || '      l_sql:= ''SELECT T_' || l_int_name || '_R(0, ' ||
             l_col_list || ') FROM ' || l_schema_name || '.' ||
             l_table_name ||
             ' WHERE ''||l_pk||'' = ''''''||i_pk||'''''' '';' || l_crlf;
    l_sql := l_sql || '      EXECUTE IMMEDIATE l_sql INTO l_hr;' || l_crlf;
    l_sql := l_sql || '    END IF;' || l_crlf;
    l_sql := l_sql || '    l_hr.row_log_id := l_rr.row_log_id;' || l_crlf;
    l_sql := l_sql || '    l_ht.EXTEND;' || l_crlf;
    l_sql := l_sql || '    l_ht(l_ht.COUNT) := l_hr;' || l_crlf;
    l_sql := l_sql ||
             '    FOR l_cr IN (SELECT * FROM ALMGR_ALL_COL_LOGS_VW WHERE row_log_id = l_rr.row_log_id) LOOP' ||
             l_crlf;
    l_sql := l_sql || '      l_v := l_cr.old_value;' || l_crlf;
    FOR l_cr IN (SELECT column_name, data_type
                   FROM all_tab_columns tc
                  WHERE owner = l_schema_name
                    AND table_name = l_table_name
                    AND (data_type IN ('CHAR',
                                       'DATE',
                                       'FLOAT',
                                       'NCHAR',
                                       'NUMBER',
                                       'NVARCHAR',
                                       'VARCHAR',
                                       'VARCHAR2',
                                       'NVARCHAR2') OR
                        data_type LIKE 'TIMESTAMP%')
                  ORDER BY column_id) LOOP
      l_sql := l_sql || '      IF (l_cr.column_name=''' || l_cr.column_name ||
               ''') THEN l_hr.' || l_cr.column_name || ' := ';
      IF (l_cr.data_type = 'DATE') OR
         (SUBSTR(l_cr.data_type, 1, 9) = 'TIMESTAMP') THEN
        l_sql := l_sql || 'TO_DATE(';
      ELSIF l_cr.data_type IN ('FLOAT', 'NUMBER') THEN
        l_sql := l_sql || 'TO_NUMBER(';
      END IF;
      l_sql := l_sql || 'l_v';
      IF (l_cr.data_type = 'DATE') OR
         (SUBSTR(l_cr.data_type, 1, 9) = 'TIMESTAMP') THEN
        l_sql := l_sql || ',''YYYY.MM.DD HH24:MI:SS'')';
      ELSIF l_cr.data_type IN ('FLOAT', 'NUMBER') THEN
        l_sql := l_sql || ')';
      END IF;
      l_sql := l_sql || '; END IF;' || l_crlf;
    END LOOP;
    l_sql := l_sql || '    END LOOP;' || l_crlf;
    l_sql := l_sql || '  END LOOP;' || l_crlf;
    l_sql := l_sql || '  FOR l_rn IN 1..l_ht.COUNT LOOP' || l_crlf;
    l_sql := l_sql || '    PIPE ROW (l_ht(l_rn));' || l_crlf;
    l_sql := l_sql || '  END LOOP;' || l_crlf;
    l_sql := l_sql || '  RETURN;' || l_crlf;
    l_sql := l_sql || 'END;';
    EXECUTE IMMEDIATE l_sql;
    IF l_schema_name != 'ALMGR' and
       sys_context('USERENV', 'CURRENT_SCHEMA') != i_schema_name THEN
      l_sql := 'GRANT EXECUTE ON ' || l_fnc_name || ' TO ' || l_schema_name;
      EXECUTE IMMEDIATE l_sql;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20013, sqlerrm);
  END;

  ------------------------------------------------------------------------------------
  -- Object collection
  ------------------------------------------------------------------------------------
  PROCEDURE CREATE_OBJECTS(i_table_name IN VARCHAR) IS
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
  BEGIN
    l_schema_name := GET_SCHEMA_FOR_TABLE(i_table_name);
    IF l_schema_name IS NOT NULL THEN
      CREATE_OBJECTS(l_schema_name, i_table_name);
    ELSE
      RAISE_APPLICATION_ERROR(-20014,
                              'Schema is ambiguous. Call CREATE_OBJECTS(schema, table)!');
    END IF;
  END;

  PROCEDURE CREATE_OBJECTS(i_schema_name IN VARCHAR,
                           i_table_name  IN VARCHAR) IS
  BEGIN
    CREATE_TYPES(i_schema_name, i_table_name);
    CREATE_TRIGGERS(i_schema_name, i_table_name);
    CREATE_FUNCTION(i_schema_name, i_table_name);
  END;

  ------------------------------------------------------------------------------------
  PROCEDURE DROP_OBJECTS(i_table_name IN VARCHAR) IS
    l_schema_name VARCHAR(50);
  BEGIN
    l_schema_name := GET_SCHEMA_FOR_TABLE(i_table_name);
    IF l_schema_name IS NOT NULL THEN
      DROP_OBJECTS(l_schema_name, i_table_name);
    ELSE
      RAISE_APPLICATION_ERROR(-20015,
                              'Schema is ambiguous. Call DROP_OBJECTS(schema, table)!');
    END IF;
  END;

  PROCEDURE DROP_OBJECTS(i_schema_name IN VARCHAR, i_table_name IN VARCHAR) IS
  BEGIN
    DROP_FUNCTION(i_schema_name, i_table_name);
    DROP_TRIGGERS(i_schema_name, i_table_name);
    DROP_TYPES(i_schema_name, i_table_name);
  END;

  ------------------------------------------------------------------------------------
  PROCEDURE RECREATE_OBJECTS(i_table_name IN VARCHAR) IS
    l_schema_name VARCHAR(50);
  BEGIN
    l_schema_name := GET_SCHEMA_FOR_TABLE(i_table_name);
    IF l_schema_name IS NOT NULL THEN
      RECREATE_OBJECTS(l_schema_name, i_table_name);
    ELSE
      RAISE_APPLICATION_ERROR(-20016,
                              'Schema is ambiguous. Call RECREATE_OBJECTS(schema, table)!');
    END IF;
  END;

  PROCEDURE RECREATE_OBJECTS(i_schema_name IN VARCHAR,
                             i_table_name  IN VARCHAR) IS
  BEGIN
    DROP_OBJECTS(i_schema_name, i_table_name);
    CREATE_OBJECTS(i_schema_name, i_table_name);
  END;

  ------------------------------------------------------------------------------------
  -- Add modify remove tables
  ------------------------------------------------------------------------------------

  PROCEDURE ADD_TABLE(i_table_name        IN VARCHAR,
                      i_keep_data_online  IN NUMBER DEFAULT NULL,
                      i_keep_data_archive IN NUMBER DEFAULT NULL) IS
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
  BEGIN
    l_schema_name := GET_SCHEMA_FOR_TABLE(i_table_name);
    IF l_schema_name IS NOT NULL THEN
      ADD_TABLE(l_schema_name,
                i_table_name,
                i_keep_data_online,
                i_keep_data_archive);
    ELSE
      RAISE_APPLICATION_ERROR(-20017,
                              'Schema is ambiguous. Call ADD_TABLE(schema, table, ...) !');
    END IF;
  END;

  PROCEDURE ADD_TABLE(i_schema_name       IN VARCHAR,
                      i_table_name        IN VARCHAR,
                      i_keep_data_online  IN NUMBER DEFAULT NULL,
                      i_keep_data_archive IN NUMBER DEFAULT NULL) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_schema_name       ALMGR_TABLES.schema_name%TYPE;
    l_table_name        ALMGR_TABLES.table_name%TYPE;
    l_keep_data_online  ALMGR_TABLES.keep_data_online%TYPE;
    l_keep_data_archive ALMGR_TABLES.keep_data_archive%TYPE;
    l_trg_number        NUMBER(10);
  BEGIN
    l_schema_name       := UPPER(SUBSTR(i_schema_name, 1, 40));
    l_table_name        := UPPER(SUBSTR(i_table_name, 1, 40));
    l_keep_data_online  := NVL(i_keep_data_online,
                               TO_NUMBER(NVL(GET_PARAMETER('DEFAULT_KDO'),
                                             100)));
    l_keep_data_archive := NVL(i_keep_data_archive,
                               TO_NUMBER(NVL(GET_PARAMETER('DEFAULT_KDA'),
                                             200)));
    IF (l_schema_name = 'ALMGR') AND (SUBSTR(l_table_name, 1, 4) = 'ROW_' or
       SUBSTR(l_table_name, 1, 4) = 'COL_') THEN
      RAISE_APPLICATION_ERROR(-20018, 'Forget it!');
    ELSE
      IF NOT IS_TABLE_ALMGR(i_schema_name, i_table_name) THEN
        l_trg_number := ALMGR_SEQ_TRG_ID.NEXTVAL;
        INSERT INTO ALMGR_TABLES
          (schema_name,
           table_name,
           trg_number,
           keep_data_online,
           keep_data_archive)
        VALUES
          (l_schema_name,
           l_table_name,
           l_trg_number,
           l_keep_data_online,
           l_keep_data_archive);
        CREATE_OBJECTS(l_schema_name, l_table_name);
        COMMIT;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      DROP_OBJECTS(l_schema_name, l_table_name);
      DELETE ALMGR_TABLES
       WHERE schema_name = l_schema_name
         AND table_name = l_table_name;
      COMMIT;
      RAISE_APPLICATION_ERROR(-20019, sqlerrm);
  END;

  ------------------------------------------------------------------------------------
  PROCEDURE MODIFY_TABLE(i_table_name        IN VARCHAR,
                         i_keep_data_online  IN NUMBER DEFAULT NULL,
                         i_keep_data_archive IN NUMBER DEFAULT NULL) IS
    l_schema_name VARCHAR(50);
  BEGIN
    l_schema_name := GET_SCHEMA_FOR_TABLE(i_table_name);
    IF l_schema_name IS NOT NULL THEN
      MODIFY_TABLE(l_schema_name,
                   i_table_name,
                   i_keep_data_online,
                   i_keep_data_archive);
    ELSE
      RAISE_APPLICATION_ERROR(-20020,
                              'Schema is ambiguous. Call MODIFY_TABLE(schema, table, ...) !');
    END IF;
  END;

  PROCEDURE MODIFY_TABLE(i_schema_name       IN VARCHAR,
                         i_table_name        IN VARCHAR,
                         i_keep_data_online  IN NUMBER DEFAULT NULL,
                         i_keep_data_archive IN NUMBER DEFAULT NULL) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_schema_name       ALMGR_TABLES.schema_name%TYPE;
    l_table_name        ALMGR_TABLES.table_name%TYPE;
    l_keep_data_online  ALMGR_TABLES.keep_data_online%TYPE;
    l_keep_data_archive ALMGR_TABLES.keep_data_archive%TYPE;
  BEGIN
    l_schema_name       := UPPER(SUBSTR(i_schema_name, 1, 40));
    l_table_name        := UPPER(SUBSTR(i_table_name, 1, 40));
    l_keep_data_online  := NVL(i_keep_data_online,
                               TO_NUMBER(NVL(GET_PARAMETER('DEFAULT_KDO'),
                                             100)));
    l_keep_data_archive := NVL(i_keep_data_archive,
                               TO_NUMBER(NVL(GET_PARAMETER('DEFAULT_KDA'),
                                             200)));
    IF IS_TABLE_ALMGR(l_schema_name, l_table_name) THEN
      -- Yes, update it
      UPDATE ALMGR_TABLES
         SET keep_data_online  = NVL(l_keep_data_online, keep_data_online),
             keep_data_archive = NVL(l_keep_data_archive, keep_data_archive)
       WHERE schema_name = l_schema_name
         AND table_name = l_table_name;
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20021,
                              'Modifying table has failed: ' || sqlerrm);
  END;

  ------------------------------------------------------------------------------------
  PROCEDURE REMOVE_TABLE(i_table_name IN VARCHAR) IS
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
  BEGIN
    l_schema_name := GET_SCHEMA_FOR_TABLE(i_table_name);
    IF l_schema_name IS NOT NULL THEN
      REMOVE_TABLE(l_schema_name, i_table_name);
    ELSE
      RAISE_APPLICATION_ERROR(-20022,
                              'Schema is ambiguous. Call REMOVE_TABLE(schema, table) !');
    END IF;
  END;

  PROCEDURE REMOVE_TABLE(i_schema_name IN VARCHAR, i_table_name IN VARCHAR) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
    l_table_name  ALMGR_TABLES.table_name%TYPE;
  BEGIN
    l_schema_name := UPPER(SUBSTR(i_schema_name, 1, 40));
    l_table_name  := UPPER(SUBSTR(i_table_name, 1, 40));
    IF IS_TABLE_ALMGR(l_schema_name, l_table_name) THEN
      -- Yes, remove it
      DROP_OBJECTS(l_schema_name, l_table_name);
      DELETE ALMGR_COLUMNS
       WHERE schema_name = l_schema_name
         AND table_name = l_table_name;
      DELETE ALMGR_TABLES
       WHERE schema_name = l_schema_name
         AND table_name = l_table_name;
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20023, sqlerrm);
  END;

  ------------------------------------------------------------------------------------
  PROCEDURE ADD_COLUMN(i_table_name IN VARCHAR, i_column_name IN VARCHAR) IS
    l_schema_name VARCHAR(50);
  BEGIN
    l_schema_name := GET_SCHEMA_FOR_TABLE(i_table_name);
    IF l_schema_name IS NOT NULL THEN
      ADD_COLUMN(l_schema_name, i_table_name, i_column_name);
    ELSE
      RAISE_APPLICATION_ERROR(-20024,
                              'Schema is ambiguous. Call ADD_COLUMN(schema, table, column) !');
    END IF;
  END;

  PROCEDURE ADD_COLUMN(i_schema_name IN VARCHAR,
                       i_table_name  IN VARCHAR,
                       i_column_name IN VARCHAR) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_schema_name ALMGR_COLUMNS.schema_name%TYPE;
    l_table_name  ALMGR_COLUMNS.table_name%TYPE;
    l_column_name ALMGR_COLUMNS.column_name%TYPE;
    l_cnt         NUMBER;
  BEGIN
    l_schema_name := UPPER(SUBSTR(i_schema_name, 1, 40));
    l_table_name  := UPPER(SUBSTR(i_table_name, 1, 40));
    l_column_name := UPPER(SUBSTR(i_column_name, 1, 40));
    -- exists?
    SELECT COUNT(*)
      INTO l_cnt
      FROM ALMGR_COLUMNS lc
     WHERE lc.schema_name = l_schema_name
       AND lc.table_name = l_table_name
       AND lc.column_name = l_column_name;
    IF l_cnt = 0 THEN
      -- No, insert it
      INSERT INTO ALMGR_COLUMNS
        (schema_name, table_name, column_name)
      VALUES
        (l_schema_name, l_table_name, l_column_name);
      COMMIT;
      RECREATE_OBJECTS(l_schema_name, l_table_name);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      DELETE ALMGR_COLUMNS
       WHERE schema_name = l_schema_name
         AND table_name = l_table_name
         AND column_name = l_column_name;
      COMMIT;
      RECREATE_OBJECTS(l_schema_name, l_table_name);
      RAISE_APPLICATION_ERROR(-20025, sqlerrm);
  END;

  ------------------------------------------------------------------------------------
  PROCEDURE ADD_ALL_COLUMNS(i_table_name IN VARCHAR) IS
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
  BEGIN
    l_schema_name := GET_SCHEMA_FOR_TABLE(i_table_name);
    IF l_schema_name IS NOT NULL THEN
      ADD_ALL_COLUMNS(l_schema_name, i_table_name);
    ELSE
      RAISE_APPLICATION_ERROR(-20026,
                              'Schema is ambiguous. Call ADD_ALL_COLUMNS(schema, table) !');
    END IF;
  END;

  PROCEDURE ADD_ALL_COLUMNS(i_schema_name IN VARCHAR,
                            i_table_name  IN VARCHAR) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_schema_name ALMGR_COLUMNS.schema_name%TYPE;
    l_table_name  ALMGR_COLUMNS.table_name%TYPE;
  BEGIN
    l_schema_name := UPPER(SUBSTR(i_schema_name, 1, 40));
    l_table_name  := UPPER(SUBSTR(i_table_name, 1, 40));
    DELETE ALMGR_COLUMNS
     WHERE schema_name = l_schema_name
       AND table_name = l_table_name;
    COMMIT;
    FOR l_cr IN (SELECT column_name
                   FROM all_tab_columns tc
                  WHERE owner = l_schema_name
                    AND table_name = l_table_name
                    AND (data_type IN ('CHAR',
                                       'DATE',
                                       'FLOAT',
                                       'NCHAR',
                                       'NUMBER',
                                       'NVARCHAR',
                                       'VARCHAR',
                                       'VARCHAR2',
                                       'NVARCHAR2') OR
                        data_type LIKE 'TIMESTAMP%')
                  ORDER BY column_id) LOOP
      BEGIN
        INSERT INTO ALMGR_COLUMNS
          (schema_name, table_name, column_name)
        VALUES
          (l_schema_name, l_table_name, l_cr.column_name);
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
      END;
    END LOOP;
    RECREATE_OBJECTS(l_schema_name, l_table_name);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RECREATE_OBJECTS(l_schema_name, l_table_name);
      RAISE_APPLICATION_ERROR(-20027, sqlerrm);
  END;

  ------------------------------------------------------------------------------------
  PROCEDURE REMOVE_COLUMN(i_table_name  IN VARCHAR,
                          i_column_name IN VARCHAR) IS
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
  BEGIN
    l_schema_name := GET_SCHEMA_FOR_TABLE(i_table_name);
    IF l_schema_name IS NOT NULL THEN
      REMOVE_COLUMN(l_schema_name, i_table_name, i_column_name);
    ELSE
      RAISE_APPLICATION_ERROR(-20028,
                              'Schema is ambiguous. Call REMOVE_COLUMN(schema, table, column) !');
    END IF;
  END;

  PROCEDURE REMOVE_COLUMN(i_schema_name IN VARCHAR,
                          i_table_name  IN VARCHAR,
                          i_column_name IN VARCHAR) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_schema_name ALMGR_COLUMNS.schema_name%TYPE;
    l_table_name  ALMGR_COLUMNS.table_name%TYPE;
    l_column_name ALMGR_COLUMNS.column_name%TYPE;
    l_cnt         NUMBER;
  BEGIN
    l_schema_name := UPPER(SUBSTR(i_schema_name, 1, 40));
    l_table_name  := UPPER(SUBSTR(i_table_name, 1, 40));
    l_column_name := UPPER(SUBSTR(i_column_name, 1, 40));
    SELECT COUNT(*)
      INTO l_cnt
      FROM ALMGR_COLUMNS
     WHERE schema_name = l_schema_name
       AND table_name = l_table_name
       AND column_name = l_column_name;
    IF l_cnt != 0 THEN
      DELETE ALMGR_COLUMNS
       WHERE schema_name = l_schema_name
         AND table_name = l_table_name
         AND column_name = l_column_name;
      COMMIT;
      RECREATE_OBJECTS(l_schema_name, l_table_name);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RECREATE_OBJECTS(l_schema_name, l_table_name);
      RAISE_APPLICATION_ERROR(-20030, sqlerrm);
  END;

  ------------------------------------------------------------------------------------
  PROCEDURE REMOVE_ALL_COLUMNS(i_table_name IN VARCHAR) IS
    l_schema_name ALMGR_TABLES.schema_name%TYPE;
  BEGIN
    l_schema_name := GET_SCHEMA_FOR_TABLE(i_table_name);
    IF l_schema_name IS NOT NULL THEN
      REMOVE_ALL_COLUMNS(l_schema_name, i_table_name);
    ELSE
      RAISE_APPLICATION_ERROR(-20031,
                              'Schema is ambiguous. Call REMOVE_ALL_COLUMNS(schema, table) !');
    END IF;
  END;

  PROCEDURE REMOVE_ALL_COLUMNS(i_schema_name IN VARCHAR,
                               i_table_name  IN VARCHAR) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_schema_name ALMGR_COLUMNS.schema_name%TYPE;
    l_table_name  ALMGR_COLUMNS.table_name%TYPE;
  BEGIN
    l_schema_name := UPPER(SUBSTR(i_schema_name, 1, 40));
    l_table_name  := UPPER(SUBSTR(i_table_name, 1, 40));
    DELETE ALMGR_COLUMNS
     WHERE schema_name = l_schema_name
       AND table_name = l_table_name;
    COMMIT;
    RECREATE_OBJECTS(l_schema_name, l_table_name);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RECREATE_OBJECTS(l_schema_name, l_table_name);
      RAISE_APPLICATION_ERROR(-20032, sqlerrm);
  END;

  ------------------------------------------------------------------------------------
  -- Managing the JOB
  ------------------------------------------------------------------------------------
  FUNCTION GET_JOB_ID RETURN NUMBER IS
    l_job_id NUMBER;
  BEGIN
    SELECT job
      INTO l_job_id
      FROM ALL_JOBS
     WHERE UPPER(SCHEMA_USER) = 'ALMGR'
       AND UPPER(WHAT) = 'AUDIT_LOG_MANAGER.JOB_PROC;';
    RETURN l_job_id;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  ------------------------------------------------------------------------------------
  PROCEDURE MODIFY_JOB(i_interval IN VARCHAR, i_next_date IN DATE) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_job_id NUMBER;
  BEGIN
    l_job_id := GET_JOB_ID;
    IF NVL(l_job_id, 0) > 0 THEN
      BEGIN
        SYS.DBMS_JOB.CHANGE(job       => l_job_id,
                            what      => 'AUDIT_LOG_MANAGER.JOB_PROC;',
                            next_date => i_next_date,
                            interval  => i_interval);
        COMMIT;
      END;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20033, sqlerrm);
  END;

  ------------------------------------------------------------------------------------
  -- Archive process
  ------------------------------------------------------------------------------------
  PROCEDURE MOVE_AN_ITEM(i_row_id IN NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO ALMGR_ROW_LOGS_archived
      SELECT rl.* FROM ALMGR_ROW_LOGS rl WHERE id = i_row_id;
    INSERT INTO ALMGR_COL_LOGS_archived
      SELECT cl.* FROM ALMGR_COL_LOGS cl WHERE row_log_id = i_row_id;
    DELETE ALMGR_COL_LOGS WHERE row_log_id = i_row_id;
    DELETE ALMGR_ROW_LOGS WHERE id = i_row_id;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  ------------------------------------------------------------------------------------
  PROCEDURE MOVE_TO_ARCHIVE IS
  BEGIN
    IF GET_PARAMETER('ARCHIVE') = 'ON' THEN
      FOR l_mr IN (SELECT * FROM ALMGR_NEED_TO_ARCHIVE_VW) LOOP
        MOVE_AN_ITEM(l_mr.id);
      END LOOP;
    END IF;
  END;

  ------------------------------------------------------------------------------------
  PROCEDURE PURGE_ARCHIVE IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF GET_PARAMETER('PURGE_ARCHIVE') = 'ON' THEN
      FOR l_mr IN (SELECT * FROM ALMGR_NEED_TO_PURGE_ARCHVD_VW) LOOP
        DELETE ALMGR_COL_LOGS_archived WHERE row_log_id = l_mr.id;
        DELETE ALMGR_ROW_LOGS_archived WHERE id = l_mr.id;
        COMMIT;
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  ------------------------------------------------------------------------------------
  PROCEDURE JOB_PROC IS
    l_rc NUMBER;
  BEGIN
    MOVE_TO_ARCHIVE;
    PURGE_ARCHIVE;
  END;

END AUDIT_LOG_MANAGER;
/
