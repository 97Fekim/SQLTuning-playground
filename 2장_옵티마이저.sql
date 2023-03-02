-- ※ RBO(Rull Based Optimizer)  규칙기반 옵티마이저
--- 초창기부터 제공함
--- 15가지의 Rule을 우선순위로 하여, 데이터를 처리함

-- ※ CBO(Cost Based Optimizer)  비용기반 옵티마이저
--- v10g 부터 기본적인 설정으로 적용되고 있음
--- 대상 row들을 처리하는데 필요한 자원 사용을 최소화해서, 궁극적으로 데이터를 빨리 처리하는데 목적이 있다.
--- CBO에 영향을 미치는 비용 산정 요소 : 각종 통계정보, Hint, 연산자, Index, Cluster, DBMS버전, CPU/Memory 용량, Disk I/O 등
---- 통계정보 : CBO의 선능을 최적의 상태로 유지시키기 위해서 테이블, 인덱스, 클러스터 등을 대상으로 통계정보를 생성함.
----- => 정기적으로 ANALYZE 작업을 하는 것이 가장 중요함

-- 1) ANALYZE 
ANALYZE TABLE EMP COMPUTE STATISTICS;   -- COMPUTE : 테이블 전체를 대상으로 분석
ANALYZE TABLE EMP ESTIMATE STATISTICS   -- 표본크기를 10%로 하여 분석
  SAMPLE 10 PERCENT;
ANALYZE TABLE EMP ESTIMATE STATISTICS  -- 표본크기를 5rows로 하여 분석
  SAMPLE 5 ROWS;

-- 2) ANAYLIZE 실행 여부 확인
SELECT TABLE_NAME, NUM_ROWS, LAST_ANALYZED
FROM USER_TABLES
WHERE TABLE_NAME IN ('EMP', 'DPT');

-- 3) DBMS_STATS Package
exec DBMS_STATS.GATHER_TABLE_STATS('SYSTEM','EMP', NULL, 20, FALSE, 'FOR ALL COLUMNS', 4);
exec DBMS_STATS.GATHER_SCHEMA_STATS('SYSTEM');
exec DBMS_STATS.GATHER_DATABASE_STATS;

-- 4) 옵티마이저의 레벨별 설정
--- 4.1) Instance Level : initSID.ora를 이용해서 지정함
OPTIMIZER_MODE = [RULE/CHOOSE/FIRST_ROWS/ALL_ROWS] 
--- 4.2) Session Level
alter session set optimizer_mode = [RULE/CHOOSE/FIRST_ROWS/ALL_ROWS] --ex) alter session set optimizer_mode = ALL_ROWS;
--- 4.3) Statement Level
select /*+first_rows*/
  ename
from emp;


-- 5) 연습문제

-- 제한조건
--- 인덱스
EC_TASK_PK : COURSE_CODE + TASK_NO
EC_TASK_TERM_IDX00 : COURSE_CODE + TASK_NO + YEAR + COURSE_SQ_NO

-- 쿼리문
SELECT 
  A.COURSE_CODE, 
  A.TASK_NO, 
  A.BBS_YN, 
  A.UPDATE_DATE,
  B.YEAR,
  B.S_DATE,
  B.E_DATE
FROM 
  EC_TASK A,
  EC_TASK_TERM B
WHERE 1=1
  AND A.TASK_NO = B.COURSE_CODE
  AND A.TASK_NO = B.TASK_NO
  AND B.COURSE_CODE = 36
  AND B.TASK_NO = 1
  AND B.COURSE_SQ_NO = 1;

--- 해설 : WHERE 절에 EC_TASK_TERM 컬럼에 대한 조건이 많기때문에 
---       얼핏보기에는 EC_TASK_TERM 테이블을 Driving Table로 하여, 먼저 탐색할 것 같지만
---       사실 YEAR에 대한 조건이 없기 때문에, EC_TASK_TERM는 다건 조회(PK가 전부 존재하지는 않음), EC_TASK는 단건 조회이다.(PK가 전부 조회)
---       이 SQL은 그래서 RBO와 CBO가 다르고, 가독성역시 좋지 않다.
---       따라서 아래와 같이 SQL을 수정할 필요가 있다.
SELECT 
  A.COURSE_CODE, 
  A.TASK_NO, 
  A.BBS_YN, 
  A.UPDATE_DATE,
  B.YEAR,
  B.S_DATE,
  B.E_DATE
FROM 
  EC_TASK A,
  EC_TASK_TERM B
WHERE 1=1
  AND A.TASK_NO = B.COURSE_CODE
  AND A.TASK_NO = B.TASK_NO
  AND A.COURSE_CODE = 36         -- B.COURSE_COE ==> A.COURSE_CODE
  AND A.TASK_NO = 1              -- B.TASK_NO    ==> A.TASK_NO
  AND B.COURSE_SQ_NO = 1;
