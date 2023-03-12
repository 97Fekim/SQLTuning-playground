-- 1) SORT/MERGE JOIN
--- 1.1) SORT/MERGE JOIN의 사용
---- ※ 연결고리에 인덱스가 전혀 없는 경우
---- ※ 대용량의 자료를 조인해야 함으로써 인덱스 사용에 따른 랜덤 액세스의 오버헤드가 많은 경우
--- 1.2) SORT/MERGE JOIN의 순서
---- 1st) 각 테이블에 대해 동시에 독립적으로 데이터를 먼저 읽어들임
---- 2nd) 읽힌 각 테이블의 데이터를 조인을 위한 연결고리에 대하여 정렬을 수행함
---- 3rd) 정렬이 모두 끝난 후에 조인 작업이 수행됨. (정렬이 끝나기 전까진 조인이 일어나지 않음)
---- ※ 튜닝포인트 :  각 테이블로부터 데이터를 빨리 읽어 들이도록 함,  메모리(SORT_AREA_SIZE)를 최적화함

-- 2) SORT/MERGE JOIN의 수행 절차
(가정) 
TABLE_A의 COLOR 만 인덱스임

(쿼리문)
SELECT /*+ USE_MERGE(A B)*/
  A.COLOR, 
  ..., 
  B.SIZE,
  ...
FROM
  TABLE_A A,
  TABLE_B B
WHERE 1=1 
  AND A.JOINKEY_A = B.JOINKEY_B  -- 3) A는 JOINKEY_A 로 Sorting,  B는 JOINKEY_B 로 Sorting
  AND A.COLOR = 'RED'            -- 1) A는 A대로  INDEX UNIQUE SCAN
  AND B.SIZE = 'MED';            -- 2) B는 B대로  FULL SCAN
  

-- 3) SORT/MERGE JOIN이 불리한 경우
--- ※ 두 테이블의 Sorting 한 데이터의 양이 크게 다른경우. (먼저 끝난 쪽이 나머지 한 쪽을 기다려야 하기 때문에)


-- 4) SORT/MERGE JOIN의 장단점
--- 4.1) 연결고리에 인덱스가 생성되어 있지 않은 경우에 빠른 조인을 위하여 사용됨.
--- 4.2) 조인하고자 하는 각 테이블에 대해서 독립적으로 데이터를 읽어 들일 때, 이를 얼마나 빠르게 할 것인가가 중요함.
--- 4.3) 각 테이블로부터 읽힌 데이터를 연결고리에 대해 정렬을 수행할 때 이를 얼마나 빠르게 할 것인가가 중요함.


-- 5) HASH JOIN
--- ※ NESTED LOOPS JOIN의 단점 : 인덱스 사용에 의한 랜덤 엑세스의 오버헤드
--- ※ SORT/MERGE JOIN의 단점   : 정렬 작업으로 인한 오버헤드
---- SORT/MERGE 조인과 비교해 보면, 각 테이블에 대한 처리를 독립적으로 하는 것은 같지만, HASH JOIN에서는 Driving Table이 있음.
---- 읽어들인 각 테이블의 데이터를 서로 조인하기 위해 해싱(Hashing)을 이용해서 해시 값을 만듦.  =>  해시 값으로 조인을 수행함.
--- ※ HASH JOIN의 튜닝 포인트
---- 1st) Driving Table을 결정함
---- 2nd) 각 테이블로부터 데이터를 읽어 들일때, 빨리 읽을 수 있도록 함.
---- 3rd) 메모리(HASH_AREA_SIZE)를 최적화함.  (HASH_AREA_SIZE는 기본적으로 SORT_AREA_SIZE의 두배이다.)


-- 6) HASH JOIN의 수행 절차.


-- 7) HASH JOIN의 장단점
--- ※ Hash Bucket이 조인 집합에 구성되어 해시 함수 결과를 저장해야 하는데 이러한 처리에는 많은 메모리와 CPU 자원을 소모하게 됨.
--- ※ 기본적으로 HASH_JOIN_SIZE에 지정된 크기만큼의 메모리가 할당되어 사용됨.
----  (조인을 수행하기에 메모리가 부족하다면 가장 큰 순서대로 Hash Bucket이 Temporary Tablespace로 내려가서 구성됨.
----   디스크로 내려간 Hash Bucket에 변경이 일어날 때마다 디스크 I/O가 발생하게 되어 성능이 현저하게 저하됨.
----   하드웨어 자원이 넉넉한 상황에서는 다른 조인에 비해 보다 효율적인 수행이 가능하지만, 부족한 상황에서는 오히려 다른 조인보다 느려질 수도 있음)


-- 8) 실습
( 테이블 정보 (1:N) )
EC_COURSE_SQ : 과정차수정보  (약 20,000 ROWS)   -- 1
EC_PROGRESS : 진도정보  (약 10,978,123 ROWS)    -- N

(인덱스 정보)
EC_COURSE_SQ_PK : COURSE_CODE + YEAR + COURSE_SQ_NO
EC_PROGRESS_PK : COURSE_CODE + YEAR + COURSE_SQ_NO + MEMBER_TYPE + MEMBER_ID + CHAP_NO + PARAG_NO

(수정전 쿼리문)
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
  
(해설)
위의 수정전 쿼리문은 SORTED MERGE JOIN 방식을 이용하는데, 테이블 ROW COUNT의 불균형으로 인해 비효율적인 접근방식이 된다.
따라서 HASH JOIN으로 변경함이 유리하다. (Driving Table은 여전히 ROW COUNT가 작은 EC_COURSE_SQ 테이블로 설정함이 바람직하다.)

(수정후 쿼리문)
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