-- 1) CARTESIAN PRODUCT 의 개념
--- 1.1) CARTESIAN PRODUCT가 발생하는 경우
---- ※ WHERE 절이 없는 조인 수행
---- ※ 조인을 위한 조건 없이 조인 수행
--- 1.2) '데이터 복제'라는 개념을 활용하기 위해 사용하지만, 잘못 사용하게 되면 오히려 데이터를 부풀리는 원인이 되기 때문에, 퍼포먼스를 오히려 나쁘게 할 수도 있음.

-- 2) 자주 사용하는 방법
SELECT *
FROM
 A, (?);
--- ※ COPY_T, IMSI_T, DUMMY_T 와 같은 temporary Table을 활용함
--- ※ DUAL을 활용함
--- ※ 타 SQL에서 사용하고 있는 Table 활용 및 ROWNUM을 사용함 ==> 주로 MASTER 성 테이블을 사용함.

-- 3) CARTESIAN PRODUCT 적용 예제
(수정전 쿼리문)
SELECT 
  '직군별' AS CLASS, JOB, COUNT(*) AS CNT
FROM 
  EMP
GROUP BY JOB
UNION ALL
SELECT 
  '부서별' AS CLASS, TO_CHAR(DEPTNO), COUNT(*)
FROM
  EMP
GROUP BY DEPTNO
UNION ALL
SELECT 
  '총인원' AS CLASS, NULL, COUNT(*)
FROM 
  EMP;

(수정후 쿼리문)
SELECT 
  DECODE(RN, 1, '직군별', 2, '부서별', '총인원') AS CLASS,
  DECODE(RN, 1, JOB, 2, DEPTNO),
  SUM(CNT)
FROM 
  (SELECT 
     JOB, 
     DEPTNO, 
     COUNT(*) AS CNT       -- 원본 데이터
   FROM EMP
   GROUP BY JOB, DEPTNO),
   (SELECT ROWNUM AS RN          -- 1, 2, 3
    FROM
      (SELECT LEVEL
       FROM DUAL
       CONNECT BY ROWNUM <= 3))
GROUP BY 
  RN,
  DECODE(RN, 1, '직군별', 2, '부서별', '총인원'),
  DECODE(RN, 1, JOB, 2, DEPTNO);


(수정후 쿼리문)
SELECT
  A.ENAME,
  B.RN
  DECODE(B.RN, 1, Q1, 2, Q2, 3, Q3, 4, Q4) AS SAL
FROM
   (SELECT ENAME, Q1, Q2, Q3, Q4, ROWNUM
     FROM EMP_SAL) A
   (SELECT
      ROWNUM AS RN
    FROM
      (SELECT LEVEL
         FROM DUAL
       CONNECT BY ROWNUM <= 4)) B
ORDER BY 1,2;

(UNPIVOT을 이용한 CARTESIAN PRODUCT 적용 예제 -- ORACLE 11G 이상부터 가능)
WITH MYTAB AS (
  SELECT ENAME, Q1, Q2, Q3, Q4
  FROM EMP_SAL)
  SELECT ENAME, GRP AS QTR, NO
  FROM MYTAB
  UNPIVOT (NO FOR GRP IN (Q1 AS 1,
                          Q2 AS 2,
                          Q3 AS 3,
                          Q4 AS 4))
  ORDER BY ENAME;

