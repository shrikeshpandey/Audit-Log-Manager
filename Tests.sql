

--exec AUDIT_LOG_MANAGER.REMOVE_TABLE('all_types'); 
--drop table all_types;

CREATE TABLE all_types(
c_smallint              SMALLINT,
c_integer               INTEGER,
c_real                  REAL,
c_float                 FLOAT(126),
c_double                DOUBLE PRECISION,
c_bigdecimal            DECIMAL(13,0),
c_number                NUMBER(3,2),
c_varchar2              VARCHAR2(254),
c_nvarchar2             NVARCHAR2(254),
c_varchar               VARCHAR(254),
c_char                  CHAR(254),
c_nchar                 NCHAR(254),
c_date                  DATE,
c_timestamp             TIMESTAMP(6),
c_timestamp_tz          TIMESTAMP(6) WITH TIME ZONE
);


exec AUDIT_LOG_MANAGER.ADD_TABLE('all_types'); 

exec AUDIT_LOG_MANAGER.ADD_ALL_COLUMNS('all_types'); 

DECLARE
    V_ALL_TYPES    ALL_TYPES%rowtype;
BEGIN

    V_ALL_TYPES.C_SMALLINT                                            := 1;
    V_ALL_TYPES.C_INTEGER                                             := 2;
    V_ALL_TYPES.C_REAL                                                := 33.1415;
    V_ALL_TYPES.C_FLOAT                                               := 1415;
    V_ALL_TYPES.C_DOUBLE                                              := 11;
    V_ALL_TYPES.C_BIGDECIMAL                                          := 22;
    V_ALL_TYPES.C_NUMBER                                              := 3;
    V_ALL_TYPES.C_VARCHAR2                                            := 'árvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP';
    V_ALL_TYPES.C_NVARCHAR2                                           := 'árvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP';
    V_ALL_TYPES.C_VARCHAR                                             := 'árvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP';
    V_ALL_TYPES.C_CHAR                                                := 'árvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP';
    V_ALL_TYPES.C_NCHAR                                               := 'árvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP';
    V_ALL_TYPES.C_DATE                                                := sysdate;
    V_ALL_TYPES.C_TIMESTAMP                                           := systimestamp;
    V_ALL_TYPES.C_TIMESTAMP_TZ                                        := systimestamp;
    insert into ALL_TYPES values V_ALL_TYPES;
    commit;

    V_ALL_TYPES.C_SMALLINT                                            := 2;
    V_ALL_TYPES.C_INTEGER                                             := 3;
    V_ALL_TYPES.C_REAL                                                := 44.1415;
    V_ALL_TYPES.C_FLOAT                                               := 6666;
    V_ALL_TYPES.C_DOUBLE                                              := 55;
    V_ALL_TYPES.C_BIGDECIMAL                                          := 66;
    V_ALL_TYPES.C_NUMBER                                              := 7;
    V_ALL_TYPES.C_VARCHAR2                                            := 'XXárvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP';
    V_ALL_TYPES.C_NVARCHAR2                                           := 'XXárvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP';
    V_ALL_TYPES.C_VARCHAR                                             := 'XXárvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP';
    V_ALL_TYPES.C_CHAR                                                := 'XXárvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP';
    V_ALL_TYPES.C_NCHAR                                               := 'XXárvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP';
    V_ALL_TYPES.C_DATE                                                := sysdate  + 1;
    V_ALL_TYPES.C_TIMESTAMP                                           := systimestamp + 1;
    V_ALL_TYPES.C_TIMESTAMP_TZ                                        := systimestamp + 1;
    update ALL_TYPES set row = V_ALL_TYPES; 
    commit;

END;
/



