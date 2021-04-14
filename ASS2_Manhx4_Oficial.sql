
USE BTL_CSDL

-- 1.
CREATE PROCEDURE Them_du_lieu_vao_Nha_Cung_Cap
	@id INT,
	@CongTy NVARCHAR(50),
	@SLSanPham INT,
	@GiayPhep NVARCHAR(50),
	@LienHe NVARCHAR(50),
	@ChatLuong NVARCHAR(50),
	@SDT CHAR(12)
AS
BEGIN
	DECLARE @Before INT, @After INT;

	SET @Before = (SELECT COUNT(*) FROM NhaCungCap);

	INSERT INTO NhaCungCap(ID, CongTy, SLSanPham, GiayPhep, LienHe, ChatLuong, SDT) VALUES
	(@id, @CongTy, @SLSanPham, @GiayPhep, @LienHe, @ChatLuong, @SDT);

	SET @After = (SELECT COUNT(*) FROM NhaCungCap);

	IF(@Before = @After - 1)
		BEGIN
			PRINT N'Dữ liệu đã được thêm vào thành công'
		END
	ELSE
		BEGIN
			RAISERROR(N'Lỗi: Thêm vào thất bại!',1,1)
		END
END
GO
-- 2. Trigger
-- Trigger After kiểm soát Insert, Update dữ liệu trên bảng Nhà cung cấp, trong đó số lượng sản phẩm phải lớn 100
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
-- 


-- 3. Thủ tục in ra id, giá, tên những sản phẩm có giá lớn hơn 200000 và tên nhà cung cấp
CREATE PROCEDURE In_SanPham_GiaHon200_VaTenNCC
AS
	BEGIN
		SELECT S.id, S.Gia, S.Ten, N.CongTy
		FROM NhaCungCap N, SanPham S
		WHERE S.Gia > 200000 AND N.ID = S.id_NCC
		ORDER BY S.Gia ASC
	END
GO


-- 4. 
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
							(SELECT ID
							FROM NhaCungCap
							WHERE CongTy = @CongTy) A
						WHERE S.id_NCC = A.ID)
RETURN @SoSanPham;
END
GO
SELECT dbo.So_SANPHAM_Theo_TENNHACUNGCAP(N'Công ty ABB001');