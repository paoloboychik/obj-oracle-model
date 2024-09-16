WITH
combs(num, volume, weight) AS (
    SELECT TO_CHAR(num) num, volume, weight
    FROM objects
   UNION ALL
    SELECT combs.num || ', ' || objects.num, 
        combs.volume + objects.volume, combs.weight + objects.weight
    FROM objects, combs
    WHERE TO_NUMBER(REGEXP_SUBSTR(combs.num, '\d+$')) < TO_NUMBER(objects.num)
),
filter AS (
    SELECT id, max_weight, max_volume, num, volume, weight
    FROM (
        SELECT ROWNUM id, num, volume, weight FROM combs
       MINUS 
        SELECT ROWNUM, TO_CHAR(num), volume, weight FROM objects
    )
    MODEL 
    DIMENSION BY (id)
    MEASURES (num, volume, weight, 
        (SELECT MAX(weight) FROM objects) max_weight, 
        (SELECT MAX(volume) FROM (
            SELECT volume FROM objects 
            WHERE weight = (SELECT MAX(weight) FROM objects)
        )) max_volume)
    RULES (
        num[ANY] = CASE
            WHEN volume[CV()] > max_volume[CV()]
            OR weight[CV()] > max_weight[CV()] THEN NULL
            ELSE num[CV()] END
    )
    ORDER BY volume DESC, weight, LENGTH(num), num
)
SELECT max_weight "Max weight", 
    max_volume "Max volume", num "Object list"
FROM filter
WHERE num IS NOT NULL AND ROWNUM = 1; 
