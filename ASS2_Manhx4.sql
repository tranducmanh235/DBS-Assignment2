
USE BTL_CSDL2
GO
-- 1
-- 1.1 Thủ tục để insert dữ liệu vào bảng Nhà cung cấp
CREATE PROCEDURE insert_Nha_Cung_Cap
	@CongTy NVARCHAR(50),
	@SLSanPham INT,
	@GiayPhep NVARCHAR(50),
	@LienHe NVARCHAR(50),
	@ChatLuong NVARCHAR(50),
	@SDT CHAR(12)
AS
BEGIN
	IF @CongTy = N''
		BEGIN
			PRINT N'Lỗi: Thiếu tên công ty!'
			ROLLBACK TRAN
		END
	ELSE IF @SLSanPham = 0
		BEGIN
			PRINT N'Lỗi: Không có sản phẩm!'
			ROLLBACK TRAN
		END
	ELSE IF @GiayPhep = N''
		BEGIN
			PRINT N'Lỗi: Thiếu giấy phép!'
			ROLLBACK TRAN
		END
	ELSE IF @LienHe = N''
		BEGIN
			PRINT N'Lỗi: Thiếu địa chỉ liên hệ!'
			ROLLBACK TRAN
		END
	ELSE IF @ChatLuong = N''
		BEGIN
			PRINT N'Lỗi: Thiếu chất lượng!'
			ROLLBACK TRAN
		END
	ELSE IF @SDT = ''
		BEGIN
			PRINT N'Lỗi: Thiếu số điện thoại!'
			ROLLBACK TRAN
		END
	ELSE
		BEGIN
			INSERT INTO NhaCungCap(CongTy, SLSanPham, GiayPhep, LienHe, ChatLuong, SDT) VALUES
			(@CongTy, @SLSanPham, @GiayPhep, @LienHe, @ChatLuong, @SDT);

			PRINT N'Thêm dữ liệu thành công!'
		END	
END
GO

EXEC insert_Nha_Cung_Cap N'Công ty abcdefgh', 2530, N'Tốt', N'Quận Tân Bình - TP.Hồ Chí Minh', N'Chất lượng cao','0909060025' 
EXEC insert_Nha_Cung_Cap N'', 2530, N'Tốt', N'Quận Tân Bình - TP.Hồ Chí Minh', N'Chất lượng cao','0909060025' 
EXEC insert_Nha_Cung_Cap N'Công ty Apple', 1223, N'', N'Quận Tân Bình - TP.Hồ Chí Minh', N'Chất lượng cao','0909060025'

-- 1.2 Thủ tục để hiện thị dữ liệu
CREATE PROCEDURE Show_Data_NhaCungCap
AS
BEGIN
	SELECT * FROM NhaCungCap
END

EXEC Show_Data_NhaCungCap


--DELETE FROM NhaCungCap WHERE ID = 8 OR ID = 5 or id = 6 
--drop procedure insert_Nha_Cung_Cap


-- 2. Trigger
-- 2.1 Trigger Before: Trước khi insert dữ liệu vào bảng NhaCungCap, kiểm tra xem 
CREATE TRIGGER Before_NhaCungCap_Delete ON NhaCungCap
INSTEAD OF DELETE
AS
BEGIN
	IF (SELECT COUNT(*)
		FROM NhaCungCap) = 1
		BEGIN
			PRINT N'Phải có ít nhất một nhà cung cấp!'
			ROLLBACK;
		END
END

DELETE FROM NhaCungCap WHERE ID = 11

-- Trigger kiem soat viec xoa
CREATE TRIGGER Delete_NhaCungCap2 ON NhaCungCap
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @idx int
	SELECT @idx = id FROM deleted 
	DELETE SanPham WHERE id_NCC = @idx
DELETE NhaCungCap WHERE id = @idx
END
GO





-- 2.2 Trigger After kiểm soát Insert, Update dữ liệu trên bảng Nhà cung cấp, trong đó số lượng sản phẩm phải lớn 100
CREATE TRIGGER AFTER_NhaCungCap_INSERT_UPDATE ON NhaCungCap
AFTER INSERT, UPDATE
AS
BEGIN
	IF(EXISTS(
				SELECT SLSanPham
				FROM NhaCungCap
				WHERE SLSanPham <= 100))
	BEGIN
		RAISERROR(N'số lượng sản phẩm phải lớn hơn 100.',16,1);
		ROLLBACK;
	END
END
GO

EXEC insert_Nha_Cung_Cap N'Công ty Hòa Phát', 70, N'Tốt', N'Quận Tân Bình - TP.Hồ Chí Minh', N'Chất lượng cao','0909060025'  


-- 3. Viết 3 câu truy vấn:
-- 3.1 In ra id, giá, tên những sản phẩm có giá lớn hơn 200000 và tên nhà cung cấp
CREATE PROCEDURE In_SanPham_GiaHon200_VaTenNCC
AS
	BEGIN
		SELECT S.id, S.Gia, S.Ten, N.CongTy
		FROM NhaCungCap N, SanPham S
		WHERE S.Gia > 200000 AND N.ID = S.id_NCC
		ORDER BY S.Gia ASC
	END
GO

EXEC In_SanPham_GiaHon200_VaTenNCC

-- 3.2 Liệt kê id, tên công ty của những công ty có số sản phẩm cung cấp lớn hơn 2
CREATE PROCEDURE In_Id_TenCongTy_SPCC_Hon2
AS
	BEGIN
		SELECT N.ID, N.CongTy, COUNT(S.id_NCC) SoSP_CungCap
		FROM NhaCungCap N, SanPham S
		WHERE N.ID = S.id_NCC
		GROUP BY N.ID, N.CongTy
		HAVING COUNT(S.id_NCC) > 2
		ORDER BY N.ID ASC
	END
GO

EXEC In_Id_TenCongTy_SPCC_Hon2

-- 3.3 

-- 4.
-- 4.1 Viết hàm in ra số lượng sản phẩm theo tên nhà cung cấp
CREATE FUNCTION So_SANPHAM_Theo_TENNHACUNGCAP (@CongTy NVARCHAR(50))
RETURNS INT
AS
BEGIN
	IF(@CongTy NOT IN (SELECT CongTy FROM NhaCungCap))
	BEGIN
		RETURN 0;
	END
	DECLARE @SoSanPham INT;
	SET @SoSanPham = (
						SELECT COUNT(*)
						FROM SanPham S,	
							(SELECT ID	-- tạo bảng ID từ nhà cung cấp có tên công ty được nhập vào
							FROM NhaCungCap
							WHERE CongTy = @CongTy) A
						WHERE S.id_NCC = A.ID)
RETURN @SoSanPham;
END
GO
SELECT dbo.So_SANPHAM_Theo_TENNHACUNGCAP(N'Công ty ABB001');
SELECT dbo.So_SANPHAM_Theo_TENNHACUNGCAP(N'Công ty ABB002');

--drop function So_SANPHAM_Theo_TENNHACUNGCAP

