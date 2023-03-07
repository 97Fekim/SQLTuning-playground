-- 1) NESTED LOOPS JOIN
--- �� ��Ƽ�������� Drigin Table�� �����Ѵ� (Outer Table)
--- �� Drigin Table�� �ƴ� ���̺��� Driven Table�� ������
---   (Inner Table)�̶�� ��.
--- �� Driving Table�� �� row�� ���� �̵��� ����� ������ Driven Table�� ������ ��� row�� ���ο� ���� �׼���.
--- �� Ʃ�� ����Ʈ
---- * ���̺� �� ���� Ƚ���� �ּ�ȭ �� �� �ֵ��� Driving Table�� �����Ѵ� => ���� ���� ����
---- * Driven Table�� ����� Į���� ���� �ε��� ����


-- 2) NESTED LOOPS JOIN �� ��������
(����)
JOINKEY_A, JOINKEY_B, COLOR, SIZE  ���� ��� �ε�����

(������)
SELECT /*+ORDERED USE_NL(A B)*/
  A.COLOR, ..... , B.SIZE, .....
FROM 
  TABLE_A A, TABLE_B B
WHERE 1=1
  AND A.JOINKEY_A = B.JOINKEY_B
  AND A.COLOR = 'RED'
  AND B.SIZE = 'MED';

--- �� ��Ʈ���� �ִ� ORDERED USE_NL(A B) �� ���� A(TABLE_A) ���̺��� Driving Table�� ����, B(TABLE_B) ���̺��� Driven Table�� ���õȴ�.
--- �� ���� A.COLOR = 'RED'  ���� ���� ���� ����ǹǷ�, A���̺��� COLOR �ε����� ���ȴ�.
--- �� Driven Table�� TABLE_B �� �����ϱ� ���� ���Ǵ� �÷��� JOINKEY_B �� �ݵ�� �ε����� �־�� �Ѵ�.
--- �� ���������� B ���̺��� SIZE�÷����� �����͸� �Ÿ���.


-- 3) NESTED LOOPS JOIN �� �����
--- 3.1) �ε����� ���� ���� �׼����� ����ϰ� �ֱ� ������ �뷮�� ������ ó���� �������� ����
--- 3.2) Driving Table�δ� ���̺��� �����Ͱ� ���� ������ ���̺��̰ų�, WHERE�� �������� �����ϰ� row�� ������ �� �ִ� ���̾�� ��.
--- 3.3) Driven Table���� ������ ���� ������ �ε����� �����Ǿ� �־�� ��.

-- 4) ����� �÷��� ���� �ε����� �߿伺
--- 4.1) ���� ��� �ε����� �ִ� ���  :  �� ���̺� �� ��ȸ�Ǵ� ����� ���� ���̺��� �����Ͽ� Driving Table(Outer Table)�� ������
--- 4.2) ���ʸ� �ε����� �ִ� ���  :  �ε����� ���� �� ���̺��� Driving Table(Outer Table)�� �����
--- 4.3) ���� ��� �ε����� ���� ���  :  Nested Loops ���� ������� ������ �̷����� ����.

-- 5) ���� ���� ���� ���
--- 5.1) ���� ���� ��� ���� ��Ʈ ���
---- �� /*+ ORDERED*/   : FROM���� ����� ���̺� ������� ����
---- �� /*+ LEADING(���̺��)*/  : ��Ʈ ���� ������ ���̺��� ����̺����� ä�õ�.
--- 5.2) ��(VIEW) ���
--- 5.3) ��������(suppressing) Ȱ��
--- 5.4) FROM ���� ���̺� ���� ���� (CBO������ �� ����� �ǹ̰� ����)

-- 6) ���� ���� ���� �ε���
--- �� ��� ���̺� �ε��� �ݵ�� �־�� �ϴ� ���� �ƴϴ�. ������,, Driven Table�� Ž���Ҷ��� �ݵ�� �ε����� �־�� �Ѵ�.
---   (Driving Table�� Full Scan�� Ÿ����, �ѹ��� �Ͼ�� ������ ������.)
---   (Driven Table�� ���� �����Ϳ� ������ �����ؾ� �Ǳ� ������, Full Scan�� ������ �������ϰ� �Ͼ �� �ִ�)


-- 7) �ǽ�
(�ε���)
EC_COURSE_PK : COURSE_CODE
EC_EXAM_PK : COURSE_CODE + EXAM_NO
EC_EXAM_TERM_PK : COURSE_CODE + YEAR + COURSE_SQ_NO + EXAM_NO

(����)
�������� ��  :  EC_COURSE < EC_EXAM < EC_EXAM_TERM

(���� �� ������)
SELECT
  A.COURSE_CODE,
  A.COURSE_NAME,
  B.EXAM_NO,
  B.EXAM_KIND,
  C.COURSE_SQ_NO,
  C.YEAR,
  C.APPLY_TYPE,
  C.EVAL_RATE
FROM
  EC_COURSE A,
  EC_EXAM B,
  EC_EXAM_TERM C
WHERE 1=1
  AND A.COURCE_CODE = C.COURSE_CODE
  AND B.COURSE_CODE = C.COURSE_CODE
  AND B.EXAM_NO = C.EXAM_NO
  AND C.COURSE_CODE = 15;
 
(���� �� ������)
SELECT
  A.COURSE_CODE,
  A.COURSE_NAME,
  B.EXAM_NO,
  B.EXAM_KIND,
  C.COURSE_SQ_NO,
  C.YEAR,
  C.APPLY_TYPE,
  C.EVAL_RATE
FROM
  EC_COURSE A,
  EC_EXAM B,
  EC_EXAM_TERM C
WHERE 1=1
  AND A.COURCE_CODE = B.COURSE_CODE
  AND B.COURSE_CODE = C.COURSE_CODE
  AND B.EXAM_NO = C.EXAM_NO
  AND A.COURSE_CODE = 15;

(�ؼ�)
�������� ������ A < B < C �̱� ������,
JOIN�� ������ A -> B -> C   �� Driving Table�� A �� �Ǿ�� ������, ������ ������������ C�� �����Ǿ���.
�ʱ� ������ C.COURSE_CODE = 15�� A.COURSE_CODE = 16 �� �ٲٰ�,
A.COURSE_CODE = C.COURSE_CODE�� A.COURSE_CODE = B.COURSE_CODE �� �ٲ۴�.

