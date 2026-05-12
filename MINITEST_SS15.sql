DROP DATABASE IF EXISTS StudentManagement;
CREATE DATABASE StudentManagement;
USE StudentManagement;

CREATE TABLE students (
	student_id VARCHAR(5) PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    total_debt DECIMAL(10,2) DEFAULT 0
);

CREATE TABLE subjects  (
	subject_id VARCHAR(5) PRIMARY KEY,
    subject_name VARCHAR(50) NOT NULL,
    credits INT CHECK (credits > 0)
);

CREATE TABLE grades (
	student_id VARCHAR(5),
    subject_id VARCHAR(5),
    PRIMARY KEY(student_id,subject_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
    score DECIMAL(4,2) CHECK (score BETWEEN 0 AND 10)
);

CREATE TABLE grade_log (
	log_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id VARCHAR(5),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    old_score DECIMAL(4,2),
    new_score DECIMAL(4,2),
    change_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT students
VALUES 
	('S01','Nguyen Van A', 12200),
    ('S02','Nguyen Van B', 22200),
    ('S03','Tran Van A', 78900),
    ('S04','Pham Thi C', 4200),
    ('S05','Nguyen Thi D', 98200);

INSERT subjects
VALUES 
	('F01','Hóa', 3),
    ('F02','Toán', 6),
    ('F03','Văn', 1),
    ('F04','Sử', 4);
    
INSERT grades
VALUES 
	('S01','F02', 10),
    ('S02','F01', 7),
    ('S03','F03', 4),
    ('S04','F04', 4),
    ('S05','F01', 6),
    ('S01','F03', 9);
    
INSERT grades(student_id,old_score,new_score)
VALUES 
	('S02', 7,10),
    ('S04', 7),
    ('S05', 4);
    
DELIMITER //
CREATE TRIGGER tg_check_score
BEFORE INSERT ON grades
FOR EACH ROW
BEGIN 
	IF NEW.score < 0 THEN
		SET NEW.score = 0 ;
	ELSEIF NEW.score >10 THEN
		SET NEW.score = 10 ;
    END IF;
END //
DELIMITER ;


START Transaction;
	INSERT INTO students (student_id,full_name)
    VALUES ( 'SV02', 'Ha Bich Ngoc');
    
    UPDATE students SET total_debt = 5000000 WHERE student_id = 'SV02';
COMMIT;


DELIMITER //
CREATE TRIGGER tg_log_grade_update 
AFTER UPDATE ON grades
FOR EACH ROW
BEGIN 
	INSERT INTO grade_log (student_id,old_score ,new_score )
    VALUES (OLD.student_id,OLD.old_score,NEW.new_score);
END //
DELIMITER ;

DELIMITER //
CREATE Procedure sp_pay_tuition()
BEGIN 
	DECLARE v_total_debt DECIMAL(10,2);
	START Transaction;
    UPDATE students SET total_debt = total_debt - 2000000 WHERE student_id = 'SV01';
    SELECT total_debt INTO total_debt FROM students  WHERE student_id = 'SV01';
    IF v_total_debt < 0 THEN
		ROLLBACK ;
	ELSE 
		COMMIT;
	END IF;
END //
DELIMITER ;
CALL sp_pay_tuition();

DELIMITER //
CREATE TRIGGER tg_prevent_pass_update 
BEFORE UPDATE ON grades
FOR EACH ROW
BEGIN 
	IF OLD.score >= 4.0 THEN
    SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Lỗi";
    end if;
END //
DELIMITER ;


    

