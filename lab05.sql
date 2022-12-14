--01A

INSERT INTO USER_SDO_GEOM_METADATA VALUES (
    'FIGURY',
    'KSZTALT',
    MDSYS.SDO_DIM_ARRAY(
        MDSYS.SDO_DIM_ELEMENT('X', 0, 100, 0.01),
        MDSYS.SDO_DIM_ELEMENT('Y', 0, 100, 0.01)
    ),
    NULL
);

--01B

SELECT SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000, 8192, 10, 2, 0) FROM FIGURY WHERE ROWNUM <= 1;

--01C

CREATE INDEX figury_ksztalt_idx ON FIGURY(KSZTALT) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

--01D

SELECT ID FROM FIGURY WHERE SDO_FILTER(KSZTALT, SDO_GEOMETRY(2001, NULL, SDO_POINT_TYPE(3,3, NULL), NULL, NULL)) = 'TRUE';
--Nie odpowiada rzeczywistosci.

--01E

SELECT ID FROM FIGURY WHERE SDO_RELATE(KSZTALT, SDO_GEOMETRY(2001, NULL, SDO_POINT_TYPE(3,3, NULL), NULL, NULL), 'mask=ANYINTERACT') = 'TRUE';
--Tak

--02A

SELECT mc1.CITY_NAME MIASTO, ROUND(SDO_NN_DISTANCE(1), 7) ODL
FROM MAJOR_CITIES mc1, MAJOR_CITIES mc2
WHERE SDO_NN(mc1.GEOM, MDSYS.SDO_GEOMETRY(2001, 8307, mc2.GEOM.SDO_POINT, mc2.GEOM.SDO_ELEM_INFO, mc2.GEOM.SDO_ORDINATES), 'sdo_num_res=10 unit=km', 1) = 'TRUE'
AND mc2.CITY_NAME = 'Warsaw'
AND mc1.CITY_NAME <> 'Warsaw';
	
--02B

SELECT mc1.CITY_NAME MIASTO
FROM MAJOR_CITIES mc1, MAJOR_CITIES mc2
WHERE SDO_WITHIN_DISTANCE(mc1.GEOM, MDSYS.SDO_GEOMETRY(2001, 8307, mc2.GEOM.SDO_POINT, mc2.GEOM.SDO_ELEM_INFO, mc2.GEOM.SDO_ORDINATES), 'distance=100 unit=km') = 'TRUE'
AND mc2.CITY_NAME = 'Warsaw'
AND mc1.CITY_NAME <> 'Warsaw';

--02C

SELECT cb.CNTRY_NAME KRAJ, mc.CITY_NAME MIASTO
FROM COUNTRY_BOUNDARIES cb, MAJOR_CITIES mc
WHERE SDO_RELATE(mc.GEOM, cb.GEOM, 'mask=INSIDE') = 'TRUE' 
AND cb.CNTRY_NAME = 'Slovakia';

--02D

SELECT cb1.CNTRY_NAME PANSTWO, ROUND(SDO_GEOM.SDO_DISTANCE(cb1.GEOM, cb2.GEOM, 1, 'unit=km'), 7) ODL
FROM COUNTRY_BOUNDARIES cb1, COUNTRY_BOUNDARIES cb2
WHERE SDO_RELATE(cb1.GEOM, SDO_GEOMETRY(2001, 8307, cb2.GEOM.SDO_POINT, cb2.GEOM.SDO_ELEM_INFO, cb2.GEOM.SDO_ORDINATES), 'mask=ANYINTERACT') != 'TRUE'
AND cb2.CNTRY_NAME = 'Poland';

--03A

SELECT cb1.CNTRY_NAME, ROUND(SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(cb1.GEOM, cb2.GEOM, 0.01), 1, 'unit=km'), 7) ODLEGLOSC
FROM COUNTRY_BOUNDARIES cb1, COUNTRY_BOUNDARIES cb2
WHERE SDO_FILTER(cb1.GEOM, cb2.GEOM) = 'TRUE' 
AND cb2.CNTRY_NAME = 'Poland';

--03B

SELECT CNTRY_NAME
FROM COUNTRY_BOUNDARIES
WHERE SDO_GEOM.SDO_AREA(GEOM) = (SELECT MAX(SDO_GEOM.SDO_AREA(GEOM)) FROM COUNTRY_BOUNDARIES);


--03C

SELECT ROUND(SDO_GEOM.SDO_AREA(SDO_GEOM.SDO_MBR(SDO_GEOM.SDO_UNION(mc1.GEOM, mc2.GEOM, 0.01)), 1, 'unit=SQ_KM'), 5) SQ_KM
FROM MAJOR_CITIES mc1, MAJOR_CITIES mc2
WHERE mc1.CITY_NAME = 'Warsaw' AND mc2.CITY_NAME = 'Lodz';

--03D

SELECT SDO_GEOM.SDO_UNION(cb.GEOM, mc.GEOM, 0.01).GET_DIMS() ||
SDO_GEOM.SDO_UNION(cb.GEOM, mc.GEOM, 0.01).GET_LRS_DIM() ||
LPAD(SDO_GEOM.SDO_UNION(cb.GEOM, mc.GEOM, 0.01).GET_GTYPE(), 2, '0') GTYPE
FROM COUNTRY_BOUNDARIES cb, MAJOR_CITIES mc
WHERE cb.CNTRY_NAME = 'Poland' AND mc.CITY_NAME = 'Prague';

--03E

SELECT mc.CITY_NAME, cb.CNTRY_NAME
FROM COUNTRY_BOUNDARIES cb, MAJOR_CITIES mc
WHERE cb.CNTRY_NAME = mc.CNTRY_NAME
AND SDO_GEOM.SDO_DISTANCE(SDO_GEOM.SDO_CENTROID(cb.GEOM, 1), mc.GEOM, 1) = (
SELECT MIN(SDO_GEOM.SDO_DISTANCE(SDO_GEOM.SDO_CENTROID(cb.GEOM, 1), mc.GEOM, 1)) FROM COUNTRY_BOUNDARIES cb, MAJOR_CITIES mc WHERE cb.CNTRY_NAME = mc.CNTRY_NAME);

--03F

SELECT NAME, ROUND(SUM(DLUGOSC), 7) DLUGOSC
FROM (
    SELECT r.NAME, SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(cb.GEOM, r.GEOM, 1), 1, 'unit=KM') DLUGOSC 
    FROM COUNTRY_BOUNDARIES cb, RIVERS r
    WHERE SDO_RELATE(cb.GEOM, SDO_GEOMETRY(2001, 8307, r.GEOM.SDO_POINT, r.GEOM.SDO_ELEM_INFO, r.GEOM.SDO_ORDINATES), 'mask=ANYINTERACT') = 'TRUE'
    AND cb.CNTRY_NAME = 'Poland')
GROUP BY NAME;
