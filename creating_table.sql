DROP TABLE objects;
CREATE TABLE objects(
    num NUMBER PRIMARY KEY, 
    volume NUMBER NOT NULL, 
    weight NUMBER NOT NULL,
    CONSTRAINT ch_n CHECK (num > 0),
    CONSTRAINT ch_v CHECK (volume > 0),
    CONSTRAINT ch_w CHECK (weight > 0)
);