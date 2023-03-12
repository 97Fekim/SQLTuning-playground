-- 1) CARTESIAN PRODUCT �� ����
--- 1.1) CARTESIAN PRODUCT�� �߻��ϴ� ���
---- �� WHERE ���� ���� ���� ����
---- �� ������ ���� ���� ���� ���� ����
--- 1.2) '������ ����'��� ������ Ȱ���ϱ� ���� ���������, �߸� ����ϰ� �Ǹ� ������ �����͸� ��Ǯ���� ������ �Ǳ� ������, �����ս��� ������ ���ڰ� �� ���� ����.

-- 2) ���� ����ϴ� ���
SELECT *
FROM
 A, (?);
--- �� COPY_T, IMSI_T, DUMMY_T �� ���� temporary Table�� Ȱ����
--- �� DUAL�� Ȱ����
--- �� Ÿ SQL���� ����ϰ� �ִ� Table Ȱ�� �� ROWNUM�� ����� ==> �ַ� MASTER �� ���̺��� �����.

-- 3) CARTESIAN PRODUCT ���� ����
(������ ������)
SELECT 
  '������' AS CLASS, JOB, COUNT(*) AS CNT
FROM 
  EMP
GROUP BY JOB
UNION ALL
SELECT 
  '�μ���' AS CLASS, TO_CHAR(DEPTNO), COUNT(*)
FROM
  EMP
GROUP BY DEPTNO
UNION ALL
SELECT 
  '���ο�' AS CLASS, NULL, COUNT(*)
FROM 
  EMP;

(������ ������)
SELECT 
  DECODE(RN, 1, '������', 2, '�μ���', '���ο�') AS CLASS,
  DECODE(RN, 1, JOB, 2, DEPTNO),
  SUM(CNT)
FROM 
  (SELECT 
     JOB, 
     DEPTNO, 
     COUNT(*) AS CNT       -- ���� ������
   FROM EMP
   GROUP BY JOB, DEPTNO),
   (SELECT ROWNUM AS RN          -- 1, 2, 3
    FROM
      (SELECT LEVEL
       FROM DUAL
       CONNECT BY ROWNUM <= 3))
GROUP BY 
  RN,
  DECODE(RN, 1, '������', 2, '�μ���', '���ο�'),
  DECODE(RN, 1, JOB, 2, DEPTNO);


(������ ������)
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

(UNPIVOT�� �̿��� CARTESIAN PRODUCT ���� ���� -- ORACLE 11G �̻���� ����)
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

