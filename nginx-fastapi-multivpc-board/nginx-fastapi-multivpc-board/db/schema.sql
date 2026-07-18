-- =========================================================
-- AWS 멀티 VPC 기반 3-Tier 게시판/방명록 서비스 - DB 스키마
-- VPC-2 (DB 전용 VPC) / Aurora MySQL (RDS Proxy 경유)
-- =========================================================

-- 1. 데이터베이스 생성 (이미 있다면 생략 가능)
CREATE DATABASE IF NOT EXISTS `std5-db-mysql` CHARACTER
SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2. 해당 데이터베이스 사용
USE `std5-db-mysql`;

-- -----------------------------------------------------
-- 3. 게시판 테이블 (VPC-1 FastAPI용)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS board (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------
-- 4. 방명록 테이블 (VPC-3 FastAPI용 / idx, user_name, user_password 포함)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS guest (
    idx INT AUTO_INCREMENT PRIMARY KEY,
    user_name VARCHAR(50) NOT NULL,
    user_password VARCHAR(255) NOT NULL,
    content TEXT,                                  -- 실제 남길 말
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------
-- 5. 테스트 데이터 삽입 (화면에 데이터가 나오는지 확인용)
-- -----------------------------------------------------

-- 게시판용 데이터
INSERT INTO board (title, content) VALUES
('VPC 1 메인 게시판입니다', '이 데이터는 VPC 1의 백엔드에서 불러옵니다.'),
('RDS Proxy 연결 테스트', '프록시를 통해 안정적으로 DB에 접속 중입니다.');

-- 방명록용 데이터 (idx, user_name, user_password)
INSERT INTO guest (user_name, user_password, content) VALUES
('관리자', '1234', 'VPC 3 방명록 시스템 가동 중.'),
('테스터', 'qwer', 'idx와 user_name 컬럼이 정상 작동합니다.');
