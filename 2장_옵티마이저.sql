-- �� RBO(Rull Based Optimizer)  ��Ģ��� ��Ƽ������
--- ��â����� ������
--- 15������ Rule�� �켱������ �Ͽ�, �����͸� ó����

-- �� CBO(Cost Based Optimizer)  ����� ��Ƽ������
--- v10g ���� �⺻���� �������� ����ǰ� ����
--- ��� row���� ó���ϴµ� �ʿ��� �ڿ� ����� �ּ�ȭ�ؼ�, �ñ������� �����͸� ���� ó���ϴµ� ������ �ִ�.
--- CBO�� ������ ��ġ�� ��� ���� ��� : ���� �������, Hint, ������, Index, Cluster, DBMS����, CPU/Memory �뷮, Disk I/O ��
---- ������� : CBO�� ������ ������ ���·� ������Ű�� ���ؼ� ���̺�, �ε���, Ŭ������ ���� ������� ��������� ������.
----- => ���������� ANALYZE �۾��� �ϴ� ���� ���� �߿���

-- 1) ANALYZE 
ANALYZE TABLE EMP COMPUTE STATISTICS;   -- COMPUTE : ���̺� ��ü�� ������� �м�
ANALYZE TABLE EMP ESTIMATE STATISTICS   -- ǥ��ũ�⸦ 10%�� �Ͽ� �м�
  SAMPLE 10 PERCENT;
ANALYZE TABLE EMP ESTIMATE STATISTICS  -- ǥ��ũ�⸦ 5rows�� �Ͽ� �м�
  SAMPLE 5 ROWS;

-- 2) ANAYLIZE ���� ���� Ȯ��
SELECT TABLE_NAME, NUM_ROWS, LAST_ANALYZED
FROM USER_TABLES
WHERE TABLE_NAME IN ('EMP', 'DPT');

-- 3) DBMS_STATS Package
exec DBMS_STATS.GATHER_TABLE_STATS('SYSTEM','EMP', NULL, 20, FALSE, 'FOR ALL COLUMNS', 4);
exec DBMS_STATS.GATHER_SCHEMA_STATS('SYSTEM');
exec DBMS_STATS.GATHER_DATABASE_STATS;

-- 4) ��Ƽ�������� ������ ����
--- 4.1) Instance Level : initSID.ora�� �̿��ؼ� ������
OPTIMIZER_MODE = [RULE/CHOOSE/FIRST_ROWS/ALL_ROWS] 
--- 4.2) Session Level
alter session set optimizer_mode = [RULE/CHOOSE/FIRST_ROWS/ALL_ROWS] --ex) alter session set optimizer_mode = ALL_ROWS;
