-- 1) �ε����� �ʿ伺
--- �ε����� ����ϴ� ���� : �����ͺ��̽��� ����� �ڷḦ ���� ������ ��ȸ�ϱ� ����.
--- ��� SQL�� �ε����� ����ؾ߸� �ϴ°�?
---  >> �Ϲ�������, �ε����� ���̺��� ��ü ������ �߿��� 10~15% ������ �����͸� ó���ϴ� ��쿡 ȿ�����̸�, �� �̻��� �����͸� ó���� �� �ε����� ������� �ʴ� ���� �� ����.

-- 2) B*Tree ����
--- 2.1) ���� ���� ���Ǵ� �ε����� ������ �� �� ������, �ε����� ������ ���� ����̱⵵ ��.
--- 2.2) Root(����) / Branch(�߰�) / Leaf(����)  Node�� ������
--- 2.3) Branch ���� Leaf ��忡 ����Ǿ� ������, ��ȸ�Ϸ��� ���� �ִ� Leaf ������ �����ϱ� ���� ��/�б��ؾ� �� ������ �����.
--- 2.4) Leaf ���     =       �ε��� �÷��� ��      +          ROWID
---                       (����(����)���� ����)        (���̺� �ִ� �ش� row�� ã�� ���� ���Ǵ� ������ ����)  
--- 2.5) B*Tree�� ������ �ٽ��� Sort!!
---- �� order by�� ���� Sort�� ���� �� ����.
---- �� MAX/MIN�� ȿ������ ó���� ������.
--- 2.6) B*Tree ���� Ȱ���� ��1
COURSE_CODE, YEAR, COURSE_SQ_NO �� ������ �ε��� EC_COURSE_SQ_PK �� ����

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
-- >> select �ϴ� 3�� ��� �ε��� ���� ��ҷ� �����ϹǷ�, ���� ��ȹ�� INDEX RANGE SCAN DESCENDING. �� �̹� ������ �ʿ� ����

--- 2.7) B*Tree ���� Ȱ���� ��2
SELECT 
  MAX(COURSE_SQ_NO)
FROM
  EC_COURSE_SQ
WHERE 1=1
  AND COURSE_CODE = 1960
  AND YEAR = '2002';
-- >> WHERE���� 1)COURSE_CODE, 2)YEAR �� �ְ�, SELECT �Ϸ��� ���� 3)COURSE_SQ_NO �� �����Ƿ�, ���� ��ȹ�� INDEX RANGE SCAN (MIN/MAX). �� ������ ��, MAX�� ������ �ʾƵ� ��


-- 3) �ε��� ���� ����
--- 1. ���α׷� ���߿� �̿�� ��� ���̺� ���Ͽ� Access Path ����
--- 2. �ε��� Į�� ���� �� ������ ����
--- 3. Critical Access Path ���� �� �켱���� ���� ��
--- 4. �ε��� Į���� ���� �� ���� ���� (�����ε��� ���� ����)
--- 5. ���� ���� �� �׽�Ʈ
--- 6. ������ �ε����� �������� ���α׷� �ݿ�
--- 7. ���� ����

-- 4) �ε��� ���� �� ���� �� ����� ����
--- 1. ���� ���α׷��� ���ۿ� ���⼺ ����
--- 2. �ʿ��� ������ �ε��� �������� ���� �ε��� ������ ������ �̷� ���� DML �۾��� �ӵ�
--- 3. ��� ���� Į���� �������� ���� ��������, �ٸ� Į���� �����Ͽ� ���� ���ǰ� ������ ��쿡 �������� ��ȣ�ϴٸ�, ���� �ε��� ������ ���������� ����

-- 5) �ε��� ��ĵ�� ����
--- 1. ������ �����ϴ� ������ �ε��� row�� ã��
--- 2. Access�� �ε��� row�� ROWID�� �̿��ؼ� ���̺� �ִ� row�� ã��(Random Access)
--- 3. ó�� ������ ���� ������ ���ʴ�� ���� �ε��� row�� ã���鼭(Scan) 2.�� �ݺ���.

--- �� ROWID�� ����
SELECT 
  ENAME,
  ROWID,
  DBMS_ROWID.ROWID_OBJECT(ROWID)        AS TAB_NO,
  DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)  AS FILE_NO,
  DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)  AS BLOCK_NO,
  DBMS_ROWID.ROWID_ROW_NUMBER(ROWID)    AS ROW_NO
FROM EMP;

-- 6) �ε��� ���
--- 6.1) ����(Unique) �ε����� Equal(=) �˻�    --> UNIQUE INDEX SCAN �� Ž
SELECT * FROM EMP ;WHERE EMPNO = 1036;

--- 6.2) ����(UNIQUE) �ε����� ����(RANGE) �˻�  --> INDEX RANGE SCAN �� Ž
SELECT * FROM EMP WHERE EMPNO >= 1036;
SELECT * FROM EMP WHERE EMPNO > 1036;
SELECT * FROM EMP WHERE EMPNO <= 1036;
SELECT * FROM EMP WHERE EMPNO < 1036;

--- 6.3) �ߺ�(Non-Unique) �ε����� ����(Range) �˻�  --> INDEX RANGE SCAN �� Ž
CREATE INDEX JOB_INDEX ON EMP(JOB);

SELECT * FROM EMP WHERE JOB LIKE 'SALE%';
SELECT * FROM EMP WHERE JOB = 'SALESMAN';

--- 6.4) OR & IN ���� - ����� ����   --> INDEX UNIQUE SCAN �� INLIST ITERATOR �� N�� �ݺ���
SELECT * FROM EMP WHERE EMPNO IN (1036, 1037);
SELECT * FROM EMP WHERE EMPNO = 1036 OR EMPNO = 1037;

--- 6.5) NOT BETWEEN �˻�  --> INDEX RANGE SCAN�� CONTATENATION ���� �����
SELECT /*+ USE_CONCAT*/
  *
FROM EMP
WHERE EMPNO NOT BETWEEN 1036 AND 1037;



-- 5) �ǽ�
�ε��� 
EC_COURSE_SQ_PK     : COURSE_CODE + YEAR + COURSE_SQ_NO
EC_COURSE_SQ_IDX_01 : YEAR (Non Unique)

--- ����
������
SELECT 
  MIN(COURSE_SQ_NO)  AS MIN_SQ,
  MAX(COURSE_SQ_NO)  AS MAX_SQ,
FROM
  EC_COURSE_SQ
WHERE
  COURSE_CODE = 1960
  AND YEAR = '2002';
---> ���� ������ EC_COURSE_SQ_PK �� ����, ������ �÷����� �ε��� ��ĵ�� �Ѵ�.
---> ������ MIN, MAX�� ��� ã�ƾ� �ϱ⿡ ��� ROW�� ã�� �� �����ϰ� �ȴ�.

--- ������
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