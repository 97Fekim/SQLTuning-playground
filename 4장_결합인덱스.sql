-- 1) 인덱스 머지 VS 결합인덱스
--- 1.1) 인덱스 머지 : 하나의 테이블에서 조회시, 각각 다른 컬럼의 인덱스를 병합하여 사용하는 방법.
--- 1.2) 결합인덱스  : 하나의 테이블에, 각각 다른 컬럼를 하나의 인덱스로 생성하여 사용하는 방법.

-- 2) 결합인덱스의 구성
--- 2.1) 결합인덱스 칼럼 선택 조건
---- ※ WHERE절에서 AND 조건으로 자주 결합되어 사용되면서, 각각의 분포도보다 두개 이상의 칼럼이 결합될 때 분포도가 좋아지는 칼럼들
----- (여기서 분포도가 좋아진다는 말은,, Cardinality가 좋아진다는 말과 동일 = 중복이 제거됨) ex) 성 + 이름 을 결합하면 Cardinality 가 좋아진다.
---- ※ 다른 테이블과 조인의 연결고리로 자주 사용되는 칼럼들
---- ※ 하나 이상의 키 칼럼 조건으로 같은 테이블의 칼럼들이 자주 조회될 때, 이러한 칼럼을 모두 포함(결합)
--- 2.2) 결합인덱스의 칼럼 순서 결정
---- 1st) WHERE 절 조건에 많이 사용되는 칼럼 우선
---- 2nd) Equal('=')로 사용되는 칼럼 우선
---- 3rd) 분포도가 좋은 칼럼 우선
---- 4rd) 자주 이용되는 Sort의 순서로 결정

-- 3) 결합인덱스 사용 방범
--- 3.1) 결합인덱스 사용 가능한 예
EMP_PAY_IDX1  :  (급여연월, 급여코드, 사원번호)
CASE1) WHERE 급여연월 = '201610';  -- 첫번째 칼럼인 급여연월은, 독립적으로 하나만 사용해도 된다.
CASE2) WHERE 급여연월 = '201610';  -- 첫번째 칼럼인 급여연월은, 반드시 사용해야 한다.
         AND 급여코드 = '정기급여';
CASE3) WHERE 급여연월 = '201610'   -- 첫번째 칼럼인 급여연월은 반드시 사용해야 한다.
         AND 급여코드 = '정기급여';
         AND 사원번호 = '33139649';
--- 3.2) INDEX SKIP SCANNING
---- 정의 : 결합인덱스의 첫번째 칼럼이 WHERE절에서 제외되어 있고, 두번째 칼럼부터 WHERE절에 조건으로 기술된 경우에도, 그 인덱스가 사용되는 경우
SKIP SCANNING을 위한 힌트
CASE1) INDEX_SS (TABLE명 INDEX명)
CASE2) INDEX_SS_ASC (TABLE명 INDEX명)
CASE3) INDEX_SS_DESC (TABLE명 INDEX명)

-- 4) 결합인덱스 칼럼에 대한 '='의 의미
--- 4.1) 범위 제한 조건
AREA_IDX1  :  (시, 구, 동)
CASE1) WHERE 시 = '서울시';
CASE2) WHERE 시 = '서울시'
         AND 구 = '강남구';
CASE3) WHERE 시 = '서울시'
         AND 구 = '강남구'
         AND 동 = '역삼동';

--- 4.2) 체크 조건  (체크조건이란, 범위를 좁혀나갈 수 있는 조건이 아닌 조건)
AREA_IDX1  :  (시, 구, 동)
CASE1) WHERE 시 LIKE '서%'
         AND 구 = '강남구'   -- 체크조건
         AND 동 = '역삼동';  -- 체크조건
CASE2) WHERE 시 = '서울시'   -- 범위 제한 조건
         AND 구 LIKE '강'%
         AMD 동 = '역삼동';  -- 체크조건
CASE3) WHERE 시 = '서울시'   -- 범위 제한 조건
         AND 동 = '역삼동';  -- 체크조건

--- 4.3) 인덱스 매칭률
---- 인덱스 매칭률 = WHERE절에서 1st 칼럼부터 연속된 칼럼에 대해서 상수(값)를 '='로 비교하는 칼럼의 개수 / 인덱스를 구성하는 칼럼으 총 개수
AREA_IDX1  :  (시, 구, 동)
CASE1) WHERE 시 = '서울시'   -- 매칭률 = 1/3
CASE2) WHERE 시 = '서울시'
         AND 구 = '강남구'   -- 매칭률 = 2/3
         
--- 4.4) 인덱스 매칭률 향상을 통한 속도 개선
EMP_PAY_IDX1 : (급여연월, 급여코드, 사원번호)
수정전) WHERE 급여연월 LIKE '2016%'
         AND 급여코드 = '정기급여';
수정후) WHERE 급여연월 IN ('201612', '201611', '201610',
                         '201609', '201608', '201607',
                         '201606', '201605', '201604',
                         '201603', '201602', '201601')
         AND 급여코드 = '정기급여';                

--- 5) 실습
(인덱스)
EC_PROGRESS_PK : COURSE_CODE + YEAR + COURSE_SQ_NO + MEMBER_TYPE + MEMBER_ID + CHAP_NO + PARAG_NO

(수정전 쿼리문)
SELECT /*+ RULE*/
  COURSE_CODE, COUNT(COURSE_DATE) AS CNT
FROM
  EC_PROGRESS
WHERE 1=1
  AND COURSE_CODE < 1000
  AND YEAR = '2000'
GROUP BY COURSE_CODE;

(수정후 쿼리문)
SELECT /*+ RULE ORDERED USE_NL(B A) */
  A.COURSE_CODE, COUNT(A.COURSE_DATE) AS CNT
FROM 
  EC_COURSE B, EC_PROGRESS A
WHERE 1=1 
  AND A.COURSE_CODE = B.COURSE_CODE
  AND B.COURSE_CODE < 1000
  AND A.YEAR = '2000'
GROUP BY A.COURSE_CODE;
