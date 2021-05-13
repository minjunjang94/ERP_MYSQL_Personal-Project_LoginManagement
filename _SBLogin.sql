drop PROCEDURE _SBLogin;

DELIMITER $$
CREATE PROCEDURE _SBLogin
	(        
		 InData_OperateFlag		CHAR(2)			-- 작업표시
		,InData_CompanySeq		INT				-- 법인내부코드
		,InData_UserId			VARCHAR(30)		-- 로그인ID
		,InData_LoginPwd		VARCHAR(50)		-- 로그인Pwd
    )
BEGIN
    
    DECLARE State INT;
    
    -- ---------------------------------------------------------------------------------------------------
    -- Check --
	call _SBLogin_Check
		(
			 InData_OperateFlag		
			,InData_CompanySeq		
			,InData_UserId			
			,InData_LoginPwd			
			,@Error_Check
		);
    

	IF( @Error_Check = (SELECT 9999) ) THEN
		
        SET State = 9999; -- Error 발생
        
	ELSE

	    SET State = 1111; -- 정상작동
    
		-- ---------------------------------------------------------------------------------------------------
		-- Update --
		IF( InData_OperateFlag = 'U' AND STATE = 1111 ) THEN
			call _SBLogin_Update
				(
					 InData_OperateFlag		
					,InData_CompanySeq		
					,InData_UserId			
					,InData_LoginPwd							
				);		
		END IF;	    

	END IF;
END $$
DELIMITER ;