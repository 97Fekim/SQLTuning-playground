-- 1) SUB QUERY의 종류
--- 1.1) SELECT 절에 오는 SUB QUERY
--- 1.2) FROM 절에 오는 SUB QUERY (INLINE VIEW)
--- 1.3) WHERE 절에 오는 SUB QUERY (Correlated SubQuery, Nested SubQuery)
--- 1.4) ORDER BY 절에 오는 SUB QUERY
--- ※ SUB QUERY는 GROUP BY 절을 제외한 모든 절에 사용이 가능하다.


-- 2) NESTED SUB QUERY
--- NESTED SUQ QUERY는 WHERE 절의 SUB QUERY가 먼저 실행된 후, MAIN QUERY가 실행되는 쿼리의 동작을 뜻한다.
(예제)
SELECT EMPNO, ENAME
FROM EMP
WHERE DEPTNO = (SELECT DEPTNO
                FROM DEPT
                WHERE DNAME = 'SALES');

--- ※ EMP 테이블에 DEPTNO의 인덱스가 존재해야만, WHERE절의 SUB QUERY가 먼저 실행된 후 MAIN QUERY가 실행된다.


-- 3) CORRELATED SUB QUERY
--- CORRELATED SUQ QUERY는 MAIN QUERY의 동작 횟수만큼, WHERE 절의 SUB QUERY 가 실행되는 쿼리의 동작을 뜻한다.
(예제)
SELECT ENAME, EMPNO
FROM EMP
WHERE EXISTS (SELECT 'X' 
              FROM DEPT
              WHERE 1=1
              AND DEPT.DEPTNO = EMP.DEPTNO
              AND DEPT.DNAME = 'SALES')

--- ※ EMP.DEPTNO를 조회하지 않고는, SUB QUERY를 실행할 수 없다. 따라서 위의 예제는 MAIN QUERY가 먼저 실행되는 CORRELATED SUB QUERY이다.


-- 4) SCALAR SUB QUERY
--- ※ SCALAR SUB QUERY 란, 단 하나의 ROW와 단 하나의 COLUMN 만을 리턴하는 SUB QUERY 이다.
---    즉 찾는 데이터가 없다면 NULL을 리턴하며, 
---    두 개 이상의 데이터를 리턴하게 된다면 ERROR를 발생시킨다.
(예제)
1. JOIN을 활용
SELECT E.ENAME, D.DNAME
FROM EMP E, DEPT D
WHERE E.DEPTNO = D.DEPTNO;

2. SUB QUERY를 활용
SELECT 
  E.ENAME,
  (SELECT D.DNAME             
   FROM EMP E, DEPT D W      -- 이 SUB QUERY 역시, 여러번 조회되므로 비효율적이다.
   HERE E.DEPTNO = D.DEPTNO) AS DNAME
WHERE EMP E;

3. UDF(User Defined Function)로 변환
CREATE OR REPLACE FUNCTION F_DNM(A_DNO IN DEPT.DEPTNO%TYPE)
RETURN VARCHAR2
RESULT_CACHE
RELIES_ON(DEPT)
AS
  H_DNM DEPT.DNAME%TYPE := NULL;
BEGIN
  SELECT DNAME INTO H_DNM
  FROM DEPT
  WHERE DEPTNO = A_DNO;
  
  RETURN H_DNM;
END:
/

SELECT ENAME,
       F_DNM(DEPTNO) AS DNAME
FROM EMP;


-- 5) ROLLUP() & CUBE()
--- 5.1) GROUP BY YEAR, REGION
YEAR               REGION
           CENTRAL  EAST    WEST
1995        100     200     200
1996                        200

--- 5.2) GROUP BY ROLLUP(YEAR,REGION)
YEAR               REGION           TOT
           CENTRAL  EAST    WEST    
1995        100     200     200     500
1996                        200     200
                                    700

--- 5.3) GROUP BY CUBE(YEAR, REGION)
YEAR               REGION           TOT
           CENTRAL  EAST    WEST    
1995        100     200     200     500
1996                        200     200
TOT         100     200     400     700

(예제1) -- GROUP BY
SELECT D.DNAME, E.JOB
       COUNT(*) AS "Empl Cnt",
       SUM(E.SAL) AS "Tot Sal"
FROM DEPT D, EMP E
WHERE D.DEPTNO = E.DEPTNO
GROUP BY D.DNAME, E.JOB
ORDER BY 1,2;

(예제1 출력) 
DNAME          JOB         Tot Empl     Tot Sal
ACCOUNTING     CLERK       1            1300
ACCOUNTING     MANAGER     1            2450
ACCOUNTING     PRESIDENT   1            5000
RESEARCH       CLERK       2            1900 
RESEARCH       ANALYSIST   2            6000
RESEARCH       MANAGER     1            950
SALES          CLERK       1            2850
SALES          MANAGER     1            950
SALES          SALESMAN    4            5600

(예제2) -- ROLL UP
SELECT D.DNAME, E.JOB
       COUNT(*) AS "Empl Cnt",
       SUM(E.SAL) AS "Tot Sal"
FROM DEPT D, EMP E
WHERE D.DEPTNO = E.DEPTNO
GROUP BY ROLLUP(D.DNAME, E.JOB)
ORDER BY 1,2;

(예제2 출력)  -- 첫번째 ARGUMENT, 전체 데이터에 대해 집계를 해준다.
DNAME          JOB         Tot Empl     Tot Sal
ACCOUNTING     CLERK       1            1300
ACCOUNTING     MANAGER     1            2450
ACCOUNTING     PRESIDENT   1            5000
ACCOUNTING                 3            8750
RESEARCH       CLERK       2            1900 
RESEARCH       ANALYSIST   2            6000
RESEARCH       MANAGER     1            950
RESEARCH                   5            3450
SALES          CLERK       1            2850
SALES          MANAGER     1            950
SALES          SALESMAN    4            5600
SALES                      6            9400
                           14           21600

(예제3) -- CUBE
SELECT D.DNAME, E.JOB
       COUNT(*) AS "Empl Cnt",
       SUM(E.SAL) AS "Tot Sal"
FROM DEPT D, EMP E
WHERE D.DEPTNO = E.DEPTNO
GROUP BY ROLLUP(D.DNAME, E.JOB)
ORDER BY 1,2;

(예제2 출력) -- 모든 ARGUMENT 각각, 전체 데이터에 대해 집계를 해준다. 
DNAME          JOB         Tot Empl     Tot Sal
ACCOUNTING     CLERK       1            1300
ACCOUNTING     MANAGER     1            2450
ACCOUNTING     PRESIDENT   1            5000
ACCOUNTING                 3            8750
RESEARCH       CLERK       2            1900 
RESEARCH       ANALYSIST   2            6000
RESEARCH       MANAGER     1            950
RESEARCH                   5            3450
SALES          CLERK       1            2850
SALES          MANAGER     1            950
SALES          SALESMAN    4            5600
SALES                      6            9400
               CLERK       4            6000
               MANAGER     3            4150
               PRESIDENT   1            8275
               ANALYSIST   2            5000
               SALEMAN     4            5600
                           14           21600

-- 6) GROUPIN SETS()

(예제1) -- GROUPIN SETS()으로 ROLLUP 만들기
SELECT D.DNAME, E.JOB
       COUNT(*) AS "Empl Cnt",
       SUM(E.SAL) AS "Tot Sal"
FROM DEPT D, EMP E
WHERE D.DEPTNO = E.DEPTNO
GROUP BY GROUPING SETS((D.DNAME, E.JOB), (D.DNAME), ())
ORDER BY 1,2;
==> ROLLUP과 동일

(예제2) -- GROUPING SETS()으로 CUBE 만들기
SELECT D.DNAME, E.JOB
       COUNT(*) AS 'Empl Cnt',
       SUM(E.SAL) AS 'Tot Sal'
FROM DEPT D, EMP E
WHERE D.DEPTNO = E.DEPTNO
GROUP BY GROUPING SETS((D.DNAME, E.JOB), (D.DNAME), (E.JOB), ())
ORDER BY 1,2;
==> CUBE와 동일


-- 7) ANALYTICAL FUNCTIONS
--- 7.1) SYNTAX
SELECT ANALYTIC_FUNCTION (ARGUMENTS) OVER
    ([PARTITION BY 칼럼] [ORDER BY 절] [WINDOWING 절]
FROM 테이블명 .....  WHERE ....;
※ ARGUMENTS : 함수에 따라 0~3 개의 인자가 지정됨
※ PARTITION BY 절 : 전체 집합을 기준에 의해 소그룹으로 나눔
※ ORDER BY 절 : 어떤 항목에 대한 정렬 기준을 기술함
※ WINDOWING 절 : 함수에 의해서 제어하고자 하는 데이터 범위를 정의함.


