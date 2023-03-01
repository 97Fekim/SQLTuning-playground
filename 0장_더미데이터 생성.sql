/*

CREATE TABLE DEPT (
  DEPTNO NUMBER(2) PRIMARY KEY,
  DNAME VARCHAR2(14),
  LOC VARCHAR2(13)
);

CREATE TABLE EMP (
  EMPNO NUMBER(4) PRIMARY KEY,
  ENAME VARCHAR2(10),
  JOB VARCHAR2(9),
  MGR NUMBER(4),
  HIREDATE DATE,
  SAL NUMBER(7,2),
  COMM NUMBER(7,2),
  DEPTNO NUMBER(2),
  CONSTRAINT EMP_DEPT_FK FOREIGN KEY (DEPTNO) REFERENCES DEPT (DEPTNO)
);

CREATE SEQUENCE EMP_SEQ
  START WITH 1000
  INCREMENT BY 1
  MAXVALUE 9999
  NOCACHE
  NOCYCLE;

CREATE SEQUENCE DEPT_SEQ
  START WITH 10
  INCREMENT BY 10
  MAXVALUE 100
  NOCACHE
  NOCYCLE;

CREATE INDEX DEPT_DEPTNO_IDX
ON DEPT (DEPTNO);

INSERT INTO DEPT(DEPTNO, DNAME, LOC) VALUES (DEPT_SEQ.NEXTVAL, 'MANAGE', 'DANGSAN');
INSERT INTO DEPT(DEPTNO, DNAME, LOC) VALUES (DEPT_SEQ.NEXTVAL, 'ACCOUNT', 'YEOEEDO');
INSERT INTO DEPT(DEPTNO, DNAME, LOC) VALUES (DEPT_SEQ.NEXTVAL, 'H/R', 'SUWON');


INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VALUES (EMP_SEQ.NEXTVAL, 'KIM', 'SALESMAN', 7698, TO_DATE('12-03-2022', 'DD-MM-YYYY'), 1000, NULL, 10);
INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VALUES (EMP_SEQ.NEXTVAL, 'LEE', 'MANAGER', 7839, TO_DATE('25-08-2022', 'DD-MM-YYYY'), 3000, 500, 20);
INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VALUES (EMP_SEQ.NEXTVAL, 'PARK', 'ANALYST', 7566, TO_DATE('10-05-2023', 'DD-MM-YYYY'), 5000, NULL, 20);
INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VALUES (EMP_SEQ.NEXTVAL, 'CHOI', 'CLERK', 7369, TO_DATE('03-01-2022', 'DD-MM-YYYY'), 800, NULL, 10);
INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VALUES (EMP_SEQ.NEXTVAL, 'YOO', 'CLERK', 7369, TO_DATE('09-02-2022', 'DD-MM-YYYY'), 900, NULL, 10);
INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VALUES (EMP_SEQ.NEXTVAL, 'KANG', 'SALESMAN', 7698, TO_DATE('14-06-2022', 'DD-MM-YYYY'), 1500, 300, 30);
INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VALUES (EMP_SEQ.NEXTVAL, 'KIM', 'CLERK', 7782, TO_DATE('30-11-2022', 'DD-MM-YYYY'), 1200, NULL, 20);
INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VALUES (EMP_SEQ.NEXTVAL, 'HWANG', 'SALESMAN', 7698, TO_DATE('17-07-2022', 'DD-MM-YYYY'), 1600, 500, 30);
INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VALUES (EMP_SEQ.NEXTVAL, 'RYU', 'ANALYST', 7788, TO_DATE('02-09-2022', 'DD-MM-YYYY'), 4500, NULL, 20);
INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VALUES (EMP_SEQ.NEXTVAL, 'JUNG', 'MANAGER', 7839, TO_DATE('22-04-2022', 'DD-MM-YYYY'), 4000, NULL, 30);

*/

