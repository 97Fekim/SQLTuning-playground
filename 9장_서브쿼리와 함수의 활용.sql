-- 1) SUB QUERY�� ����
--- 1.1) SELECT ���� ���� SUB QUERY
--- 1.2) FROM ���� ���� SUB QUERY (INLINE VIEW)
--- 1.3) WHERE ���� ���� SUB QUERY (Correlated SubQuery, Nested SubQuery)
--- 1.4) ORDER BY ���� ���� SUB QUERY
--- �� SUB QUERY�� GROUP BY ���� ������ ��� ���� ����� �����ϴ�.


-- 2) NESTED SUB QUERY
--- NESTED SUQ QUERY�� WHERE ���� SUB QUERY�� ���� ����� ��, MAIN QUERY�� ����Ǵ� ������ ������ ���Ѵ�.
(����)
SELECT EMPNO, ENAME
FROM EMP
WHERE DEPTNO = (SELECT DEPTNO
                FROM DEPT
                WHERE DNAME = 'SALES');

--- �� EMP ���̺� DEPTNO�� �ε����� �����ؾ߸�, WHERE���� SUB QUERY�� ���� ����� �� MAIN QUERY�� ����ȴ�.


-- 3) CORRELATED SUB QUERY
--- CORRELATED SUQ QUERY�� MAIN QUERY�� ���� Ƚ����ŭ, WHERE ���� SUB QUERY �� ����Ǵ� ������ ������ ���Ѵ�.
(����)
SELECT ENAME, EMPNO
FROM EMP
WHERE EXISTS (SELECT 'X' 
              FROM DEPT
              WHERE 1=1
              AND DEPT.DEPTNO = EMP.DEPTNO
              AND DEPT.DNAME = 'SALES')

--- �� EMP.DEPTNO�� ��ȸ���� �ʰ��, SUB QUERY�� ������ �� ����. ���� ���� ������ MAIN QUERY�� ���� ����Ǵ� CORRELATED SUB QUERY�̴�.


-- 4) SCALAR SUB QUERY
--- �� SCALAR SUB QUERY ��, �� �ϳ��� ROW�� �� �ϳ��� COLUMN ���� �����ϴ� SUB QUERY �̴�.
---    �� ã�� �����Ͱ� ���ٸ� NULL�� �����ϸ�, 
---    �� �� �̻��� �����͸� �����ϰ� �ȴٸ� ERROR�� �߻���Ų��.
(����)
1. JOIN�� Ȱ��
SELECT E.ENAME, D.DNAME
FROM EMP E, DEPT D
WHERE E.DEPTNO = D.DEPTNO;

2. SUB QUERY�� Ȱ��
SELECT 
  E.ENAME,
  (SELECT D.DNAME             
   FROM EMP E, DEPT D W      -- �� SUB QUERY ����, ������ ��ȸ�ǹǷ� ��ȿ�����̴�.
   HERE E.DEPTNO = D.DEPTNO) AS DNAME
WHERE EMP E;

3. UDF(User Defined Function)�� ��ȯ
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

(����1) -- GROUP BY
SELECT D.DNAME, E.JOB
       COUNT(*) AS "Empl Cnt",
       SUM(E.SAL) AS "Tot Sal"
FROM DEPT D, EMP E
WHERE D.DEPTNO = E.DEPTNO
GROUP BY D.DNAME, E.JOB
ORDER BY 1,2;

(����1 ���) 
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

(����2) -- ROLL UP
SELECT D.DNAME, E.JOB
       COUNT(*) AS "Empl Cnt",
       SUM(E.SAL) AS "Tot Sal"
FROM DEPT D, EMP E
WHERE D.DEPTNO = E.DEPTNO
GROUP BY ROLLUP(D.DNAME, E.JOB)
ORDER BY 1,2;

(����2 ���)  -- ù��° ARGUMENT, ��ü �����Ϳ� ���� ���踦 ���ش�.
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

(����3) -- CUBE
SELECT D.DNAME, E.JOB
       COUNT(*) AS "Empl Cnt",
       SUM(E.SAL) AS "Tot Sal"
FROM DEPT D, EMP E
WHERE D.DEPTNO = E.DEPTNO
GROUP BY ROLLUP(D.DNAME, E.JOB)
ORDER BY 1,2;

(����2 ���) -- ��� ARGUMENT ����, ��ü �����Ϳ� ���� ���踦 ���ش�. 
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

(����1) -- GROUPIN SETS()���� ROLLUP �����
SELECT D.DNAME, E.JOB
       COUNT(*) AS "Empl Cnt",
       SUM(E.SAL) AS "Tot Sal"
FROM DEPT D, EMP E
WHERE D.DEPTNO = E.DEPTNO
GROUP BY GROUPING SETS((D.DNAME, E.JOB), (D.DNAME), ())
ORDER BY 1,2;
==> ROLLUP�� ����

(����2) -- GROUPING SETS()���� CUBE �����
SELECT D.DNAME, E.JOB
       COUNT(*) AS 'Empl Cnt',
       SUM(E.SAL) AS 'Tot Sal'
FROM DEPT D, EMP E
WHERE D.DEPTNO = E.DEPTNO
GROUP BY GROUPING SETS((D.DNAME, E.JOB), (D.DNAME), (E.JOB), ())
ORDER BY 1,2;
==> CUBE�� ����


-- 7) ANALYTICAL FUNCTIONS
--- 7.1) SYNTAX
SELECT ANALYTIC_FUNCTION (ARGUMENTS) OVER
    ([PARTITION BY Į��] [ORDER BY ��] [WINDOWING ��]
FROM ���̺�� .....  WHERE ....;
�� ARGUMENTS : �Լ��� ���� 0~3 ���� ���ڰ� ������
�� PARTITION BY �� : ��ü ������ ���ؿ� ���� �ұ׷����� ����
�� ORDER BY �� : � �׸� ���� ���� ������ �����
�� WINDOWING �� : �Լ��� ���ؼ� �����ϰ��� �ϴ� ������ ������ ������.


