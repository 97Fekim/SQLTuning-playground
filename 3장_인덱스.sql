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


-- 3) 인덱스 설정 절차
--- 1. 프로그램 개발에 이용된 모든 테이블에 대하여 Access Path 조사
--- 2. 인덱스 칼럼 선정 및 분포도 조사
--- 3. Critical Access Path 결정 및 우선순위 선정 ★
--- 4. 인덱스 칼럼의 조합 및 순서 결정 (결합인덱스 생성 결정)
--- 5. 시험 생성 및 테스트
--- 6. 결정된 인덱스를 기준으로 프로그램 반영
--- 7. 실제 적용

-- 4) 인덱스 생성 및 변경 시 고려할 사항
--- 1. 기존 프로그램의 동작에 영향성 검토
--- 2. 필요할 때마다 인덱스 생성으로 인한 인덱스 개수의 증가와 이로 인한 DML 작업의 속도
--- 3. 비록 개별 칼럼의 분포도가 좋지 않을지라도, 다른 칼럼과 결합하여 자주 사용되고 결합할 경우에 분포도가 양호하다면, 결합 인덱스 생성을 긍정적으로 검토

-- 5) 인덱스 스캔의 원리
--- 1. 조건을 만족하는 최초의 인덱스 row를 찾음
--- 2. Access된 인덱스 row의 ROWID를 이용해서 테이블에 있는 row를 찾음(Random Access)
--- 3. 처리 범위가 끝날 때까지 차례대로 다음 인덱스 row를 찾으면서(Scan) 2.를 반복함.

--- ※ ROWID의 분해
SELECT 
  ENAME,
  ROWID,
  DBMS_ROWID.ROWID_OBJECT(ROWID)        AS TAB_NO,
  DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)  AS FILE_NO,
  DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)  AS BLOCK_NO,
  DBMS_ROWID.ROWID_ROW_NUMBER(ROWID)    AS ROW_NO
FROM EMP;

-- 6) 인덱스 사용
--- 6.1) 고유(Unique) 인덱스의 Equal(=) 검색    --> UNIQUE INDEX SCAN 을 탐
SELECT * FROM EMP ;WHERE EMPNO = 1036;

--- 6.2) 고유(UNIQUE) 인덱스의 범위(RANGE) 검색  --> INDEX RANGE SCAN 을 탐
SELECT * FROM EMP WHERE EMPNO >= 1036;
SELECT * FROM EMP WHERE EMPNO > 1036;
SELECT * FROM EMP WHERE EMPNO <= 1036;
SELECT * FROM EMP WHERE EMPNO < 1036;

--- 6.3) 중복(Non-Unique) 인덱스의 범휘(Range) 검색  --> INDEX RANGE SCAN 을 탐
CREATE INDEX JOB_INDEX ON EMP(JOB);

SELECT * FROM EMP WHERE JOB LIKE 'SALE%';
SELECT * FROM EMP WHERE JOB = 'SALESMAN';

--- 6.4) OR & IN 조건 - 결과의 결합   --> INDEX UNIQUE SCAN 을 INLIST ITERATOR 로 N번 반복함
SELECT * FROM EMP WHERE EMPNO IN (1036, 1037);
SELECT * FROM EMP WHERE EMPNO = 1036 OR EMPNO = 1037;

--- 6.5) NOT BETWEEN 검색  --> INDEX RANGE SCAN의 CONTATENATION 으로 수행됨
SELECT /*+ USE_CONCAT*/
  *
FROM EMP
WHERE EMPNO NOT BETWEEN 1036 AND 1037;



-- 5) 실습
인덱스 
EC_COURSE_SQ_PK     : COURSE_CODE + YEAR + COURSE_SQ_NO
EC_COURSE_SQ_IDX_01 : YEAR (Non Unique)

--- 원본
쿼리문
SELECT 
  MIN(COURSE_SQ_NO)  AS MIN_SQ,
  MAX(COURSE_SQ_NO)  AS MAX_SQ,
FROM
  EC_COURSE_SQ
WHERE
  COURSE_CODE = 1960
  AND YEAR = '2002';
---> 위의 쿼리는 EC_COURSE_SQ_PK 에 의해, 세가지 컬럼으로 인덱스 스캔을 한다.
---> 하지만 MIN, MAX를 모두 찾아야 하기에 모든 ROW를 찾은 후 정렬하게 된다.

--- 수정문
SELECT 
  SUM(MIN_SQ) AS MIN_SQ,
  SUM(MAX_SQ) AS MAX_SQ
FROM
  (SELECT /*+ INDEX_ASC(A EC_COURSE_SQ_PK)*/
     A.COURSE_SQ_NO AS MIN_SQ, 
     0              AS MAX_SQ
   FROM 
     EC_COURSE_SQ A
   WHERE
     A.COURSE_CODE = 1960
     AND A.YEAR = '2002'
     AND ROWNUM = 1
   UNION ALL
   SELECT /*+ INDEX_DESC(A EC_COURSE_SQ_PK)*/
     0              AS MIN_SQ,
     A.COURSE_SQ_NO AS MAX_SQ
   FROM
     EC_COURSE_SQ A
   WHERE
     A.COURSE_CODE = 1960
     AND A.YEAR = '2002'
     AND ROWNUM = 1
  );   