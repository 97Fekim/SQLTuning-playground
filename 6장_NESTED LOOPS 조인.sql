-- 1) NESTED LOOPS JOIN
--- ※ 옵티마이저가 Drigin Table을 결정한다 (Outer Table)
--- ※ Drigin Table이 아닌 테이블은 Driven Table로 지정함
---   (Inner Table)이라고도 함.
--- ※ Driving Table의 각 row에 대해 이들이 추출될 때마다 Driven Table의 연관된 모든 row를 조인에 의해 액세스.
--- ※ 튜닝 포인트
---- * 테이블 간 조인 횟수를 최소화 할 수 있도록 Driving Table을 선택한다 => 조인 순서 제어
---- * Driven Table의 연결고리 칼럼에 대한 인덱스 구성


-- 2) NESTED LOOPS JOIN 의 수행절차
(가정)
JOINKEY_A, JOINKEY_B, COLOR, SIZE  등은 모두 인덱스임

(쿼리문)
SELECT /*+ORDERED USE_NL(A B)*/
  A.COLOR, ..... , B.SIZE, .....
FROM 
  TABLE_A A, TABLE_B B
WHERE 1=1
  AND A.JOINKEY_A = B.JOINKEY_B
  AND A.COLOR = 'RED'
  AND B.SIZE = 'MED';

--- ※ 힌트절에 있는 ORDERED USE_NL(A B) 에 의해 A(TABLE_A) 테이블이 Driving Table로 선택, B(TABLE_B) 테이블이 Driven Table로 선택된다.
--- ※ 따라서 A.COLOR = 'RED'  절이 가장 먼저 수행되므로, A테이블에서 COLOR 인덱스가 사용된다.
--- ※ Driven Table인 TABLE_B 에 접근하기 위해 사용되는 컬럼인 JOINKEY_B 는 반드시 인덱스가 있어야 한다.
--- ※ 마지막으로 B 테이블의 SIZE컬럼으로 데이터를 거른다.


-- 3) NESTED LOOPS JOIN 의 장단점
--- 3.1) 인덱스에 의한 랜덤 액세스에 기반하고 있기 때문에 대량의 데이터 처리시 적합하지 않음
--- 3.2) Driving Table로는 테이블의 데이터가 적은 마스터 테이블이거나, WHERE절 조건으로 적절하게 row를 제어할 수 있는 것이어야 함.
--- 3.3) Driven Table에는 조인을 위한 적절한 인덱스가 생성되어 있어야 함.

-- 4) 연결고리 컬럼에 대한 인덱스의 중요성
--- 4.1) 양쪽 모두 인덱스가 있는 경우  :  두 테이블 중 조회되는 결과가 적은 테이블을 선택하여 Driving Table(Outer Table)로 선택함
--- 4.2) 한쪽만 인덱스가 있는 경우  :  인덱스가 없는 쪽 테이블을 Driving Table(Outer Table)로 사용함
--- 4.3) 양쪽 모두 인덱스가 없는 경우  :  Nested Loops 조인 방식으로 조인이 이뤄지지 않음.

-- 5) 조인 순서 제어 방법
--- 5.1) 조인 순서 제어를 위한 힌트 사용
---- ※ /*+ ORDERED*/   : FROM절에 기술한 테이블 순서대로 제어
---- ※ /*+ LEADING(테이블명)*/  : 힌트 내에 제시한 테이블이 드라이빙으로 채택됨.
--- 5.2) 뷰(VIEW) 사용
--- 5.3) 서프레싱(suppressing) 활용
--- 5.4) FROM 절의 테이블 순서 변경 (CBO에서는 이 방법은 의미가 없음)

-- 6) 연결 고리에 대한 인덱스
--- ★ 모든 테이블에 인덱스 반드시 있어야 하는 것은 아니다. 하지만,, Driven Table을 탐색할때는 반드시 인덱스가 있어야 한다.
---   (Driving Table은 Full Scan을 타더라도, 한번만 일어나기 때문에 괜찮다.)
---   (Driven Table은 많은 데이터에 여러번 접근해야 되기 때문에, Full Scan시 막대한 성능저하가 일어날 수 있다)


-- 7) 실습
(인덱스)
EC_COURSE_PK : COURSE_CODE
EC_EXAM_PK : COURSE_CODE + EXAM_NO
EC_EXAM_TERM_PK : COURSE_CODE + YEAR + COURSE_SQ_NO + EXAM_NO

(조건)
데이터의 양  :  EC_COURSE < EC_EXAM < EC_EXAM_TERM

(수정 전 쿼리문)
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
 
(수정 후 쿼리문)
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

(해설)
데이터의 순서가 A < B < C 이기 때문에,
JOIN의 순서가 A -> B -> C   즉 Driving Table이 A 가 되어야 하지만, 수정전 쿼리문에서는 C가 선정되었다.
초기 조건절 C.COURSE_CODE = 15를 A.COURSE_CODE = 16 로 바꾸고,
A.COURSE_CODE = C.COURSE_CODE를 A.COURSE_CODE = B.COURSE_CODE 로 바꾼다.

