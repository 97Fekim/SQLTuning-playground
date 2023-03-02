-- 1) 인덱스의 필요성
--- 인덱스를 사용하는 이유 : 데이터베이스에 저장된 자료를 더욱 빠르게 조회하기 위함.
--- 모든 SQL이 인덱스를 사용해야만 하는가?
---  >> 일반적으로, 인덱스는 테이블의 전체 데이터 중에서 10~15% 이하의 데이터를 처리하는 경우에 효율적이며, 그 이상의 데이터를 처리할 땐 인덱스를 사용하지 않는 편이 더 나음.

-- 2) B*Tree 구조
--- 2.1) 가장 많이 사용되는 인덱스의 구조라 할 수 있으며, 인덱스의 데이터 저장 방식이기도 함.
--- 2.2) Root(기준) / Branch(중간) / Leaf(말단)  Node로 구성됨
--- 2.3) Branch 노드는 Leaf 노드에 연결되어 있으며, 조회하려는 값이 있는 Leaf 노드까지 도달하기 위해 비교/분기해야 될 값들이 저장됨.
--- 2.4) Leaf 노드     =       인덱스 컬럼의 값      +          ROWID
---                       (오름(내림)차순 정렬)        (테이블에 있는 해당 row를 찾기 위해 사용되는 논리적인 정보)  
--- 2.5) B*Tree의 구조의 핵심은 Sort!!
---- ※ order by에 의한 Sort를 피할 수 있음.
---- ※ MAX/MIN의 효율적인 처리가 가능함.
--- 2.6) B*Tree 구조 활용의 예1
COURSE_CODE, YEAR, COURSE_SQ_NO 로 구성된 인덱스 EC_COURSE_SQ_PK 가 있음

SELECT 
  COURSE_CODE,
  YEAR,
  COURSE_SQ_NO
FROM 
  EC_COURSE_SQ
WHERE 1=1
  AND COURSE_CODE = 1960
  AND YEAR = '2002'
ORDER BY COURSE_SQ_NO DESC;
-- >> select 하는 3개 모두 인덱스 구성 요소로 존재하므로, 실행 계획은 INDEX RANGE SCAN DESCENDING. 즉 이미 정렬이 필요 없음

--- 2.7) B*Tree 구조 활용의 예2
SELECT 
  MAX(COURSE_SQ_NO)
FROM
  EC_COURSE_SQ
WHERE 1=1
  AND COURSE_CODE = 1960
  AND YEAR = '2002';
-- >> WHERE절에 1)COURSE_CODE, 2)YEAR 가 있고, SELECT 하려는 절에 3)COURSE_SQ_NO 가 있으므로, 실행 계획은 INDEX RANGE SCAN (MIN/MAX). 즉 정렬한 후, MAX를 구하지 않아도 됨




