--01

CREATE TABLE dokumenty (
    id       NUMBER(12) PRIMARY KEY,
    dokument CLOB
);

--02

declare
    l_clob CLOB;
begin
FOR i IN 1..1000 
LOOP
    l_clob := l_clob || 'Oto tekst. ' ;
END LOOP;
    INSERT INTO dokumenty VALUES (1, l_clob);
end;

--03

SELECT * FROM dokumenty;

SELECT UPPER(dokument) from dokumenty;

SELECT length(dokument) from dokumenty;

SELECT dbms_lob.getlength(dokument) from dokumenty;

SELECT SUBSTR(dokument, 5, 1000) from dokumenty;

SELECT DBMS_LOB.SUBSTR(dokument, 1000, 5) from dokumenty;

--04

INSERT INTO dokumenty values (2, EMPTY_CLOB());

--05

INSERT INTO dokumenty values (3, null);

--06

SELECT * FROM dokumenty;

SELECT UPPER(dokument) from dokumenty;

SELECT length(dokument) from dokumenty;

SELECT dbms_lob.getlength(dokument) from dokumenty;

SELECT SUBSTR(dokument, 5, 1000) from dokumenty;

SELECT DBMS_LOB.SUBSTR(dokument, 1000, 5) from dokumenty;

--07

SELECT * FROM ALL_DIRECTORIES;

--08

declare
    l_clob clob;
    l_file BFILE := BFILENAME('ZSBD_DIR','dokument.txt');
    doffset integer := 1;
    soffset integer := 1;
    langctx integer := 0;
    warn integer := null;

begin
    SELECT dokument INTO l_clob FROM dokumenty WHERE id=2 FOR UPDATE;
    
    DBMS_LOB.fileopen(l_file, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADCLOBFROMFILE(l_clob, l_file, DBMS_LOB.LOBMAXSIZE, doffset, soffset, 873, langctx, warn);
    DBMS_LOB.FILECLOSE(l_file);
    COMMIT;
end;

--09

UPDATE dokumenty SET dokument = TO_CLOB(BFILENAME('ZSBD_DIR','dokument.txt')) WHERE id = 3;

--10

SELECT * FROM dokumenty;

--11

SELECT DBMS_LOB.GETLENGTH(dokument) filesize FROM dokumenty;

--12

DROP TABLE DOKUMENTY;

--13

CREATE OR REPLACE PROCEDURE clob_censor (
    P_CLOB_IN_OUT IN OUT CLOB,
    P_TEXT_IN VARCHAR2
) AS
l_position NUMBER;
l_dot VARCHAR2(2000);
BEGIN
    FOR i IN 1..length(P_TEXT_IN) LOOP
        l_dot := l_dot || '.';
    END LOOP;
    
    LOOP
        l_position := dbms_lob.instr(P_CLOB_IN_OUT, P_TEXT_IN);
        EXIT WHEN l_position = 0;
        dbms_lob.write(P_CLOB_IN_OUT, LENGTH(P_TEXT_IN), l_position, l_dot);
	END LOOP;

END;

--tests

declare
    v_clob clob := '1234567890 qwerty1234567890qwerty567890qwertysofognfgoqwerty';
begin
    DBMS_OUTPUT.PUT_LINE(v_clob);
    clob_censor(v_clob, 'qwerty');
    DBMS_OUTPUT.PUT_LINE(v_clob);
end;

--14

CREATE TABLE BIOGRAPHIES AS SELECT * FROM ZSBD_TOOLS.BIOGRAPHIES;

DECLARE
    v_clob CLOB;
BEGIN
    SELECT bio INTO v_clob FROM biographies WHERE id=1 FOR UPDATE;  
    CLOB_CENSOR(v_clob, 'Cimrman');
    COMMIT;
END;

SELECT bio FROM biographies WHERE id=1;


--15

DROP TABLE BIOGRAPHIES;
