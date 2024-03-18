USE QLDA;

-- 1. Cho biết thông tin nhân viên có tổng thời gian làm việc lớn hơn hoặc bằng tổng
-- thời gian làm việc cuả Nguyễn Thanh Tùng. Không xuất ra thông tin của Nguyễn
-- Thanh Tùng

SELECT PC.MANV, CONCAT(NV.HONV, ' ', NV.TENLOT, ' ',  NV.TENNV) AS HOTEN, SUM(PC.THOIGIAN) AS TONGTHOIGIAN
FROM NHANVIEN NV JOIN PHANCONG PC ON NV.MANV = PC.MANV 
GROUP BY NV.MANV, NV.HONV, NV.TENLOT, NV.TENNV
HAVING SUM(PC.THOIGIAN) >= (SELECT SUM(THOIGIAN) 
								FROM PHANCONG PC, NHANVIEN NV1
								WHERE PC.MANV = NV1.MANV AND
                                NV1.HONV = N'Nguyễn' AND
                                NV1.TENLOT = N'Thanh' AND
                                NV1.TENNV = N'Tùng' AND NV.MANV != NV1.MANV);
                                
-- 2. Với mỗi nhân viên, cho biết họ tên của nhân viên và số lượng đề án mà nhân
-- viên đó đã tham gia.

SELECT CONCAT(NV.HONV, ' ', NV.TENLOT, ' ', NV.TENNV) AS HOTEN, COUNT(PC.MADA) AS SOLUONGDA
FROM NHANVIEN NV, PHANCONG PC
WHERE NV.MANV = PC.MANV
GROUP BY PC.MANV;

-- 3. Cho biết những nhân viên (HONV, TENLOT, TENNV) được phân công tất cả đề án
-- do phòng số 4 chủ trì

-- > K TON TAI DEAN O PHONG 4 KHONG DUOC PHAN CONG CHO MANV 
SELECT CONCAT(NV.HONV, ' ', NV.TENLOT, ' ', NV.TENNV) AS HOVATEN, MANV
FROM NHANVIEN NV
WHERE NOT EXISTS (SELECT PC.MANV
					FROM PHANCONG PC
                    WHERE PC.MANV = NV.MANV
                    AND PC.MADA NOT IN (SELECT MADA FROM DEAN WHERE PHONG = 4));
                    
-- 4. Với mỗi đề án, liệt kê tên đề án và tổng số công việc của đề án đó
SELECT TENDA, SOLUONGCONGVIEC
FROM DEAN DA JOIN (SELECT MADA, COUNT(MADA) AS SOLUONGCONGVIEC FROM CONGVIEC GROUP BY MADA) AS CONGVIECGROUP ON DA.MADA = CONGVIECGROUP.MADA;

-- 5. Cho biết tên phòng ban và mức lương lớn nhất của phòng ban có lương trung bình > 31,000.

SELECT TENPHG, MAX(LUONG)
FROM PHONGBAN PB JOIN NHANVIEN NV ON NV.PHG = PB.PHG
GROUP BY PB.PHG
HAVING AVG(LUONG) > 31000;

-- 6. Cho biết nhân viên làm việc tại phòng ban ở một thành phố và tham gia đề án có
-- địa điểm ở một thành phố khác

SELECT CONCAT(NV.HONV, ' ', NV.TENLOT, ' ', NV.TENNV) AS HOTEN, NV.PHG, DDP.DIADIEM AS DIADIEMPHONG, PC.MADA, DA.DDIEM_DA
FROM NHANVIEN NV JOIN PHANCONG PC ON PC.MANV = NV.MANV JOIN DEAN DA ON DA.MADA = PC.MADA JOIN DIADIEM_PHG DDP ON DDP.PHG = NV.PHG
GROUP BY NV.MANV, DDP.DIADIEM, PC.MADA
HAVING DA.DDIEM_DA NOT IN (SELECT DIADIEM FROM DIADIEM_PHG WHERE DIADIEM_PHG.PHG = NV.PHG);

-- 7. Cho biết thông tin đề án có nhân viên thuộc phòng nghiên cứu tham gia và có tổng
-- thời gian của các công việc trong đề án > 25.

SELECT CONCAT(NV.HONV, ' ', NV.TENLOT, ' ', NV.TENNV) AS HOTEN, DA.MADA, DA.TENDA, DA.DDIEM_DA, DA.PHONG, SUM(PC.THOIGIAN) THOIGIAN
FROM NHANVIEN NV JOIN PHANCONG PC ON NV.MANV = PC.MANV JOIN DEAN DA ON DA.MADA = PC.MADA
WHERE NV.MANV IN (SELECT NV1.MANV FROM NHANVIEN NV1, PHONGBAN PB WHERE PB.PHG = NV1.PHG AND PB.TENPHG = N'Nghiên cứu')
GROUP BY PC.MANV, PC.MADA
HAVING SUM(PC.THOIGIAN) > 25;

-- 8. Cho biết những nhân viên (HONV, TENLOT, TENNV) được phân công tất cả đề
-- án mà nhân viên 'Đinh Bá Tiến' làm việc
-- KHONG TON TAI DE AN DBT THUC HIEN NHUNG NV KHONG THUC HIEN
SELECT *
FROM NHANVIEN NV
WHERE NOT EXISTS (SELECT * FROM NHANVIEN NV1, PHANCONG PC
					WHERE NV1.HONV = N'Đinh' AND NV1.TENLOT = N'Bá' AND NV1.TENNV = N'Tiến' AND PC.MANV = NV1.MANV
                    AND NOT EXISTS (SELECT PC1.MADA FROM PHANCONG PC1 WHERE NV1.MANV != NV.MANV AND PC1.MANV = NV.MANV AND PC.MADA = PC1.MADA));

-- 9. Với mỗi nhân viên, cho biết tên nhân viên và số lượng nhân viên mà nhân viên đó
-- quản lý trực tiếp.

SELECT CONCAT(QL.HONV, ' ', QL.TENLOT, ' ', QL.TENNV) AS HOTENQUANLY, COUNT(NV.MANV)
FROM NHANVIEN NV JOIN NHANVIEN QL ON QL.MANV = NV.MA_NQL
GROUP BY QL.MANV;

-- 10. Cho biết mã nhân viên, họ tên nhân viên, số lượng công việc được phân công,
-- tổng thời gian làm việc và số lượng đề án đã tham gia.

SELECT NV.MANV, CONCAT(NV.HONV, ' ', NV.TENLOT, ' ', NV.TENNV) AS HOTEN,
	(SELECT COUNT(PC.STT) FROM PHANCONG PC WHERE PC.MANV = NV.MANV) AS SLCVDUOCPHANCONG,
    (SELECT SUM(PC.THOIGIAN) FROM PHANCONG PC WHERE PC.MANV = NV.MANV) AS TONGTHOIGIANLAM,
    COUNT(PC.MADA) AS SLDATHAMGIA
FROM NHANVIEN NV JOIN PHANCONG PC ON PC.MANV = NV.MANV
GROUP BY PC.MANV;

-- 11. Cho biết tên thành phố vừa là địa điểm đề án có trên 2 nhân viên tham gia vừa là
-- địa điểm phòng quản lí đề án đó

SELECT *
FROM DEAN DA, DIADIEM_PHG DDP
WHERE DA.PHONG = DDP.PHG AND DA.DDIEM_DA = DDP.DIADIEM 
	AND DA.MADA IN (SELECT PC.MADA FROM PHANCONG PC GROUP BY PC.MADA HAVING COUNT(PC.MANV) > 2);
    
    
 -- 12. Cho biết tên phòng ban phụ trách tất cả các đề án ở Vũng Tàu
-- KHONG TON TAI DEAN O VUNG TAU MA PHONG BAN KHONG PHU TRACH
SELECT *
FROM PHONGBAN PB
WHERE NOT EXISTS (SELECT * FROM DEAN DA1 WHERE DA1.DDIEM_DA = N'Vũng Tàu' 
					AND NOT EXISTS (SELECT * FROM DEAN DA2 WHERE PB.PHG = DA2.PHONG AND DA1.MADA = DA2.MADA));
                    
-- 13. PHONG BAN CO SO LUONG DEAN O VUNG TAU BANG VOI SO LUONG DEAN O VUNG TAU CUA TOAN DATABASE

SELECT PB.TENPHG
FROM PHONGBAN PB JOIN DEAN DA ON PB.PHG = DA.PHONG
WHERE DA.DDIEM_DA = N'Vũng Tàu'
GROUP BY PB.PHG
HAVING COUNT(PB.DDIEM_DA) = (SELECT COUNT(DA1.DDIEM_DA) FROM DEAN DA1 WHERE DA1.DDIEM_DA = N'Vũng Tàu');

-- 14. Với mỗi đề án, cho biết có bao nhiêu nhân viên tham gia đề án đó. Xuất ra mã đề
-- án, tên đề án và số lượng nhân viên tham gia.
SELECT DA.MADA, DA.TENDA, COUNT(PC.MANV) AS SOLUONGNHANVIEN
FROM DEAN DA JOIN PHANCONG PC ON DA.MADA = PC.MADA
GROUP BY PC.MADA;

-- 15. Cho biết nhân viên hoặc có tổng thời gian làm việc > các nhân viên tên Tùng hoặc
-- trực thuộc phòng mà Nguyễn Thanh Tùng trực thuộc

SELECT CONCAT(NV.HONV, ' ', NV.TENLOT, ' ', NV.TENNV) AS HOTEN, SUM(PC.THOIGIAN) AS TONGTHOIGIAN
FROM PHANCONG PC JOIN NHANVIEN NV ON PC.MANV = NV.MANV
GROUP BY PC.MANV
HAVING (SUM(PC.THOIGIAN) > ALL(SELECT(SUM(PC1.THOIGIAN)) 
								FROM PHANCONG PC1, NHANVIEN NV1
                                WHERE NV1.TENNV = N'Tùng' AND PC1.MANV = NV1.MANV))
	OR PC.MANV = (SELECT NV2.PHG FROM NHANVIEN NV2 WHERE CONCAT(NV2.HONV, ' ', NV2.TENLOT, ' ', NV2.TENNV) = N'Nguyễn Thanh Tùng');
    
-- 16. Cho biết tên các đề án có tất cả các nhân viên ở phòng Quản lý tham gia
SELECT DA.TENDA 
FROM DEAN DA JOIN PHANCONG PC ON PC.MADA = DA.MADA JOIN NHANVIEN NV ON NV.MANV = PC.MANV JOIN PHONGBAN PB ON PB.PHG = NV.PHG
WHERE PB.TENPHG = N'Quản lý'
GROUP BY DA.MADA
HAVING COUNT(PC.MANV) = (SELECT COUNT(NV1.MANV) FROM NHANVIEN NV1 JOIN PHONGBAN PB1 ON PB1.PHG = NV1.PHG WHERE PB1.TENPHG = N'Quản lý');

-- 17. Cho biết phòng có nhiều nhân viên nhất
SELECT PB.PHG, PB.TENPHG, COUNT(NV.MANV) AS SOLUONGNHANVIEN
FROM NHANVIEN NV JOIN PHONGBAN PB ON PB.PHG = NV.PHG
GROUP BY PB.PHG
HAVING COUNT(NV.MANV) >= ALL (SELECT COUNT(NV1.MANV) FROM NHANVIEN NV1 JOIN PHONGBAN PB1 ON PB1.PHG = NV1.PHG GROUP BY PB1.PHG);

-- 18. Cho biết những nhân viên (HONV, TENLOT, TENNV) được phân công cho tất cả
-- các công việc trong đề án 'Sản phẩm X'. 
-- > KHONG TON TAI CONG VIEC NAO TRONG SAN PHAM X MA NHAN VIEN KHONG LAM
SELECT DISTINCT CONCAT(NV.HONV, ' ', NV.TENLOT, ' ', NV.TENNV) AS HOTEN
FROM NHANVIEN NV JOIN PHANCONG PC ON PC.MANV = NV.MANV
WHERE NOT EXISTS (SELECT * 
					FROM CONGVIEC CV JOIN DEAN DA ON DA.MADA = CV.MADA 
                    WHERE DA.TENDA = N'Sản phẩm X' AND NOT EXISTS (SELECT * 
																	FROM PHANCONG PC 
                                                                    WHERE PC.MANV = NV.MANV 
                                                                    AND CV.MADA = PC.MADA AND CV.STT = PC.STT))
                                                                    