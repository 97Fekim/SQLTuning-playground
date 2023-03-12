-- 1) SORT/MERGE JOIN
--- 1.1) SORT/MERGE JOIN�� ���
---- �� ������� �ε����� ���� ���� ���
---- �� ��뷮�� �ڷḦ �����ؾ� �����ν� �ε��� ��뿡 ���� ���� �׼����� ������尡 ���� ���
--- 1.2) SORT/MERGE JOIN�� ����
---- 1st) �� ���̺� ���� ���ÿ� ���������� �����͸� ���� �о����
---- 2nd) ���� �� ���̺��� �����͸� ������ ���� ������� ���Ͽ� ������ ������
---- 3rd) ������ ��� ���� �Ŀ� ���� �۾��� �����. (������ ������ ������ ������ �Ͼ�� ����)
---- �� Ʃ������Ʈ :  �� ���̺�κ��� �����͸� ���� �о� ���̵��� ��,  �޸�(SORT_AREA_SIZE)�� ����ȭ��

-- 2) SORT/MERGE JOIN�� ���� ����
(����) 
TABLE_A�� COLOR �� �ε�����

(������)
SELECT /*+ USE_MERGE(A B)*/
  A.COLOR, 
  ..., 
  B.SIZE,
  ...
FROM
  TABLE_A A,
  TABLE_B B
WHERE 1=1 
  AND A.JOINKEY_A = B.JOINKEY_B  -- 3) A�� JOINKEY_A �� Sorting,  B�� JOINKEY_B �� Sorting
  AND A.COLOR = 'RED'            -- 1) A�� A���  INDEX UNIQUE SCAN
  AND B.SIZE = 'MED';            -- 2) B�� B���  FULL SCAN
  

-- 3) SORT/MERGE JOIN�� �Ҹ��� ���
--- �� �� ���̺��� Sorting �� �������� ���� ũ�� �ٸ����. (���� ���� ���� ������ �� ���� ��ٷ��� �ϱ� ������)


-- 4) SORT/MERGE JOIN�� �����
--- 4.1) ������� �ε����� �����Ǿ� ���� ���� ��쿡 ���� ������ ���Ͽ� ����.
--- 4.2) �����ϰ��� �ϴ� �� ���̺� ���ؼ� ���������� �����͸� �о� ���� ��, �̸� �󸶳� ������ �� ���ΰ��� �߿���.
--- 4.3) �� ���̺�κ��� ���� �����͸� ������� ���� ������ ������ �� �̸� �󸶳� ������ �� ���ΰ��� �߿���.


-- 5) HASH JOIN
--- �� NESTED LOOPS JOIN�� ���� : �ε��� ��뿡 ���� ���� �������� �������
--- �� SORT/MERGE JOIN�� ����   : ���� �۾����� ���� �������
---- SORT/MERGE ���ΰ� ���� ����, �� ���̺� ���� ó���� ���������� �ϴ� ���� ������, HASH JOIN������ Driving Table�� ����.
---- �о���� �� ���̺��� �����͸� ���� �����ϱ� ���� �ؽ�(Hashing)�� �̿��ؼ� �ؽ� ���� ����.  =>  �ؽ� ������ ������ ������.
--- �� HASH JOIN�� Ʃ�� ����Ʈ
---- 1st) Driving Table�� ������
---- 2nd) �� ���̺�κ��� �����͸� �о� ���϶�, ���� ���� �� �ֵ��� ��.
---- 3rd) �޸�(HASH_AREA_SIZE)�� ����ȭ��.  (HASH_AREA_SIZE�� �⺻������ SORT_AREA_SIZE�� �ι��̴�.)


-- 6) HASH JOIN�� ���� ����.


-- 7) HASH JOIN�� �����
--- �� Hash Bucket�� ���� ���տ� �����Ǿ� �ؽ� �Լ� ����� �����ؾ� �ϴµ� �̷��� ó������ ���� �޸𸮿� CPU �ڿ��� �Ҹ��ϰ� ��.
--- �� �⺻������ HASH_JOIN_SIZE�� ������ ũ�⸸ŭ�� �޸𸮰� �Ҵ�Ǿ� ����.
----  (������ �����ϱ⿡ �޸𸮰� �����ϴٸ� ���� ū ������� Hash Bucket�� Temporary Tablespace�� �������� ������.
----   ��ũ�� ������ Hash Bucket�� ������ �Ͼ ������ ��ũ I/O�� �߻��ϰ� �Ǿ� ������ �����ϰ� ���ϵ�.
----   �ϵ���� �ڿ��� �˳��� ��Ȳ������ �ٸ� ���ο� ���� ���� ȿ������ ������ ����������, ������ ��Ȳ������ ������ �ٸ� ���κ��� ������ ���� ����)


-- 8) �ǽ�
( ���̺� ���� (1:N) )
EC_COURSE_SQ : ������������  (�� 20,000 ROWS)   -- 1
EC_PROGRESS : ��������  (�� 10,978,123 ROWS)    -- N

(�ε��� ����)
EC_COURSE_SQ_PK : COURSE_CODE + YEAR + COURSE_SQ_NO
EC_PROGRESS_PK : COURSE_CODE + YEAR + COURSE_SQ_NO + MEMBER_TYPE + MEMBER_ID + CHAP_NO + PARAG_NO

(������ ������)
SELECT /*+ USE_MERGE(A B)*/
  B.COURSE_CODE,
  B.YEAR,
  B.COURSE_SQ_NO,
  B.MEMBER_TYPE,
  B.MEMBER_ID,
  B.CHAP_NO,
  B.PARAG_NO,
  A.OPEN_YN,
  A.END_YN
FROM 
  EC_COURSE_SQ A,
  EC_PROGRESS B
WHERE 1=1
  AND A.COURSE_CODE = B.COURSE_CODE
  AND A.YEAR = B.YEAR
  AND A.COURSE_SQ_NO = B.COURSE_SQ_NO;
  
(�ؼ�)
���� ������ �������� SORTED MERGE JOIN ����� �̿��ϴµ�, ���̺� ROW COUNT�� �ұ������� ���� ��ȿ������ ���ٹ���� �ȴ�.
���� HASH JOIN���� �������� �����ϴ�. (Driving Table�� ������ ROW COUNT�� ���� EC_COURSE_SQ ���̺�� �������� �ٶ����ϴ�.)

(������ ������)
SELECT /*+ USE_HASH(A B)*/
  B.COURSE_CODE,
  B.YEAR,
  B.COURSE_SQ_NO,
  B.MEMBER_TYPE,
  B.MEMBER_ID,
  B.CHAP_NO,
  B.PARAG_NO,
  A.OPEN_YN,
  A.END_YN
FROM 
  EC_COURSE_SQ A,
  EC_PROGRESS B
WHERE 1=1
  AND A.COURSE_CODE = B.COURSE_CODE
  AND A.YEAR = B.YEAR
  AND A.COURSE_SQ_NO = B.COURSE_SQ_NO;