--01
-- Zmienilem typ year na varchar2(12). Mniejszego rozmiaru nie chcialo przyjac
CREATE TABLE movies (
    id        NUMBER(12) PRIMARY KEY,
    title     VARCHAR2(400) NOT NULL,
    category  VARCHAR2(50),
    year      VARCHAR2(12),
    cast      VARCHAR2(4000),
    director  VARCHAR2(4000),
    story     VARCHAR2(4000),
    price     NUMBER(5, 2),
    cover     BLOB,
    mime_type VARCHAR2(50)
);

--02

INSERT INTO movies
    SELECT
        d.id,
        d.title,
        d.category,
        d.year,
        d.cast,
        d.director,
        d.story,
        d.price,
        c.image,
        c.mime_type
    FROM
        descriptions d LEFT JOIN covers c ON c.movie_id = d.id;
		
--03

SELECT id, title from movies where cover is null order by 1;

--04

SELECT id, title, dbms_lob.getlength(cover) filesize from movies where cover is not null order by 3 desc;

--05

SELECT id, title, dbms_lob.getlength(cover) filesize from movies where cover is null order by 3 desc;

--06

select * from all_directories

--07

UPDATE movies set cover = EMPTY_BLOB(), mime_type = 'image/jpeg' WHERE id = 66

--08

SELECT id, title, dbms_lob.getlength(cover) filesize from movies where id IN (65,66)

--09

DECLARE
 lobd blob;
 fils BFILE := BFILENAME('ZSBD_DIR','escape.jpg');
BEGIN
 SELECT cover INTO lobd
 FROM movies
 where id = 66
 FOR UPDATE;
 DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
 DBMS_LOB.LOADFROMFILE(lobd,fils,DBMS_LOB.GETLENGTH(fils));
 DBMS_LOB.FILECLOSE(fils);
 COMMIT;
END;
/

--10

CREATE TABLE temp_covers (
    movie_id  NUMBER(12),
    image     BFILE,
    mime_type VARCHAR2(50)
);

--11

insert into temp_covers values (65, BFILENAME('ZSBD_DIR', 'eagles.jpg'), 'image/jpeg');

--12

select movie_id, dbms_lob.getlength(image) filesize from temp_covers

--13

DECLARE
    lobd blob;
    fils TEMP_COVERS.IMAGE%TYPE;
    MIME TEMP_COVERS.MIME_TYPE%TYPE;
BEGIN
    SELECT IMAGE, MIME_TYPE INTO FILS, MIME
    FROM TEMP_COVERS
    WHERE MOVIE_ID = 65;
    DBMS_LOB.CREATETEMPORARY(LOBD, TRUE);
    DBMS_LOB.fileOPEN(fils, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADFROMFILE(lobd, fils, DBMS_LOB.getlength(fils));
    DBMS_LOB.FILECLOSE(fils);
    UPDATE MOVIES SET COVER = lobd, MIME_TYPE = MIME 
    WHERE ID = 65;   
    dbms_lob.freetemporary(LOBD);
    COMMIT;
END;

--14

SELECT id, title, dbms_lob.getlength(cover) filesize from movies where id IN (65,66)

--15

DROP TABLE MOVIES;
DROP TABLE TEMP_COVERS;
