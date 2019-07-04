
show user

prompt *************************************************************************
PROMPT ***            C O M P I L I N G                                      ***
PROMPT ***       A U D I T   L O G     M A N A G E R                         ***
PROMPT *************************************************************************

SET DEFINE ON;

EXEC DBMS_UTILITY.compile_schema(UPPER('&&NewUserName'),FALSE);
EXEC DBMS_UTILITY.compile_schema(UPPER('&&NewUserName'),FALSE);
EXEC DBMS_UTILITY.compile_schema(UPPER('&&NewUserName'),FALSE);

Prompt  *********** C O M P I L E D ***********
