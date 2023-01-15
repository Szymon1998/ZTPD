--01
CREATE TABLE QUOTES AS SELECT * FROM ZSBD_TOOLS.QUOTES;

--02
CREATE INDEX QUOTES_TEXT_IDX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT;

--03
SELECT AUTHOR, TEXT FROM QUOTES WHERE CONTAINS(TEXT, 'WORK', 1) > 0;
SELECT AUTHOR, TEXT FROM QUOTES WHERE CONTAINS(TEXT, '$WORK', 1) > 0;
SELECT AUTHOR, TEXT FROM QUOTES WHERE CONTAINS(TEXT, 'WORKING', 1) > 0;
SELECT AUTHOR, TEXT FROM QUOTES WHERE CONTAINS(TEXT, '$WORKING', 1) > 0;

--04
SELECT AUTHOR, TEXT FROM QUOTES WHERE CONTAINS(TEXT, 'IT', 1) > 0;
--stop_word

--05
SELECT * FROM CTX_STOPLISTS;
--default

--06
SELECT * FROM CTX_STOPWORDS;

--07
DROP INDEX QUOTES_TEXT_IDX;
CREATE INDEX QUOTES_TEXT_IDX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS ('stoplist CTXSYS.EMPTY_STOPLIST');

--08
SELECT AUTHOR, TEXT 
FROM QUOTES 
WHERE CONTAINS(TEXT, 'IT', 1) > 0;
--tak

--09
SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'FOOL OR HUMANS', 1) > 0;

--10
SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'FOOL OR COMPUTER', 1) > 0;

--11
SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, '(FOOL AND COMPUTER) WITHIN SENTENCE', 1) > 0;
--brak zdan

--12
DROP INDEX QUOTES_TEXT_IDX;

--13
BEGIN
    ctx_ddl.create_section_group('nullgroup', 'NULL_SECTION_GROUP');
    ctx_ddl.add_special_section('nullgroup',  'SENTENCE');
    ctx_ddl.add_special_section('nullgroup',  'PARAGRAPH');
END;

--14
CREATE INDEX QUOTES_TEXT_IDX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS ('
    stoplist CTXSYS.EMPTY_STOPLIST
    section group nullgroup
');

--15
SELECT AUTHOR, TEXT 
FROM QUOTES
WHERE CONTAINS(TEXT, '(FOOL AND HUMANS) WITHIN SENTENCE', 1) > 0;

SELECT AUTHOR, TEXT 
FROM QUOTES
WHERE CONTAINS(TEXT, '(FOOL AND COMPUTER) WITHIN SENTENCE', 1) > 0;

--16
SELECT AUTHOR, TEXT 
FROM QUOTES 
WHERE CONTAINS(TEXT, 'HUMANS', 1) > 0;
--ustawienia leksera

--17
DROP INDEX QUOTES_TEXT_IDX;

BEGIN
    ctx_ddl.create_preference('lex','BASIC_LEXER');
    ctx_ddl.set_attribute('lex', 'printjoins', '_-');
    ctx_ddl.set_attribute('lex', 'index_text', 'YES');
END;

CREATE INDEX QUOTES_TEXT_IDX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS ('
    stoplist CTXSYS.EMPTY_STOPLIST
    section group nullgroup
    LEXER lex
');

--18
SELECT AUTHOR, TEXT 
FROM QUOTES 
WHERE CONTAINS(TEXT, 'HUMANS', 1) > 0;
--nie

--19
SELECT AUTHOR, TEXT 
FROM QUOTES 
WHERE CONTAINS(TEXT, 'NON\-HUMANS', 1) > 0;

--20
DROP TABLE QUOTES;

BEGIN
    ctx_ddl.drop_preference('lex');
END;
