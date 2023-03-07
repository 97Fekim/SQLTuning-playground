-- 1) 인덱스 스캔을 하면 무조건 빠른가?
--- 조건에 의한 처리범위가 넒어짐으로 인해, 분포도가 나빠지는 경우가 있는데, 이 경우에는 FULL SCAN이 바람직함
--- FULL TABLE SCAN 시엔 한 번의 I/O 때마다 여러 개의 데이터 Blocks를 처리하기 때문에 I/O 횟수가 감소함.
--- DB_FILE_MULTIBLOCK_READ_COUNT = 4  ->  한번의 I/O 로 4 BLOCK Access

-- 2) 인덱스 사용이 불가능한 경우
--- 2.1) NOT 연산자 사용
---- 대부분의 데이터를 조회(15%이상)하므로, 비효율적임.
--- 2.2) IS NULL, IS NOT NULL 사용
---- 인덱스는 NULL값을 저장하지 않기때문에 사용할 수 없음.
--- 2.3) 옵티마이저의 취사 선택
---- 옵티마이저의 자의적 판단에 의해서 인덱스를 사용/미사용 할 수 있는데, 이를 취사선택이라함. 
---- 옵티마이저의 자의적 판단에 의한 잘못된 선택을 강제로 제어하기 위해서 Hint 사용
--- 2.4) External suppressing (INDEX 컬럼이 어떠한 형태로든 "변형"되면 인덱스 사용이 불가능해짐)
---- 2.4.1) 불필요한 함수를 사용한 경우
불가능CASE) WHERE SUBSTR(ENAME, 1, 1) = 'M';
가능CASE)  WHERE ENAME LIKE 'M%';
---- 2.4.2) 문자열 결합
불가능CASE) WHERE JOB||DEPTNO = 'MANAGER10';
가능CASE)  WHERE JOB = 'MANAGER' AND DEPTNO = 10;
---- 2.4.3) DATE 변수의 가공
불가능CASE) WHERE TO_CHAR(HIREDATE, 'YYYYMMDD') = 20221016;
가능CASE)  WHERE HIREDATE BETWEEN TO_DATE('20021016', 'YYYYMMDD') AND TO_DATE('20021016', 'YYYYMMDD');
--- 2.5) Internal suppressing (INDEX 컬럼이 어떠한 형태로든 "변형"되면 인덱스 사용이 불가능해짐)
불가능CASE) WHERE SAL*12 > 40000;
가능CASE)  WHERE SAL > 40000/12;
가능CASE)  WHERE HIREDATE = '2003-01-01';          -- '2003-01-01'이 DATE 타입으로 변환되기 때문에, 인덱스 사용 가능
가능CASE)  WHERE ROWID = 'AAAAaoAATAAAADAAA';      -- 'AA~~' 가 ROWID 타입으로 변환되기 때문에, 인덱스 사용 가능
불가능CASE) WHERE TO_NUMBER(RESNO) = 7402191550521 -- 인덱스 칼럼에 해당하느 RESNO가 VARCHAR2 -> NUMBER 로 변형됐기 때문에, 인덱스사용 불가능

-- 3) 옵티마이저에 의한 선택 절차
--- 특정 테이블에 대해서 SQL의 주어진 조건으로 인해 사용될 수 있는 인덱스가 두 개 이상인 경우
--- 3.1) 주어진 조건에 대한 각 인덱스 별로 매칭률을 계산해서 매칭률이 높은 것을 우선적으로 선택함 (범위제한 조건 多)
--- 3.2) 인덱스 별 매칭률이 같을 경우에는 인덱스를 구성하는 칼럼의 개수가 많은 것을 우선적으로 선택함. (2/4 > 1/2)
--- 3.3) 인덱스 별 매칭률과 인덱스를 구성하는 컬럼의 개수가 같을 경우에는 가장 최근에 생성된 것을 우선적으로 선택함. (수요일 > 화요일)

--- RBO와 CBO가 선택한 인덱스 차이
---- ※ RBO는 EC_COURSE_SQ_IDX_01를 선택한다. 이유는 인덱스 매칭률이 (1 > 2/3)이기 때문에
---- ※ CBO는 EC_COURSE_SQ_PK를 선택한다. 이유는 칼럼 갯수가 더 많아, 데이터를 더 좁혀갈 수 있기 때문에.
[인덱스현황]
EC_COURSE_SQ_PK : COURSE_CODE + YEAR + COURSE_SQ
EC_COURSE_SQ_IDX_01 : YEAR (Non Unique)

SELECT 
  MIN(COURSE_SQ_NO) AS MIN_SQ,
  MAX(COURSE_SQ_NO) AS MAX_SQ
FROM
  EC_COURSE_SQ
WHERE 1=1
  AND COURSE_CODE = 1960
  AND YEAR = '2002';
  
-- 4) 실습
