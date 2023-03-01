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
