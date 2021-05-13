drop PROCEDURE _SBLogin_Update;

DELIMITER $$
CREATE PROCEDURE _SBLogin_Update
	(
		 InData_OperateFlag		CHAR(2)			-- 작업표시
		,InData_CompanySeq		INT				-- 법인내부코드
		,InData_UserId			VARCHAR(30)		-- 로그인ID
		,InData_LoginPwd		VARCHAR(50)		-- 로그인Pwd
    )
BEGIN

	-- 변수선언
    DECLARE Var_GetDateNow			VARCHAR(100);    
    
	SET Var_GetDateNow  = (SELECT DATE_FORMAT(NOW(), "%Y%m%d") AS GetDate); -- 작업일시는 Update 되는 시점의 일시를 Insert  
    
    -- ---------------------------------------------------------------------------------------------------
    -- Update --
	IF( InData_OperateFlag = 'U' ) THEN     
			UPDATE _TCBaseUser				AS A
			   SET   LoginDate				=  Var_GetDateNow	-- (정상진입) Login한 일시 Update
					,LoginStatus			=  1005001    		-- (정상진입) 로그인상태 (LoginStatus '1005001')
					,LoginFailCnt			=  0				-- (정상진입) 카운터 '0'으로 Update
			 WHERE   A.CompanySeq 			= InData_CompanySeq
               AND   A.UserId				= InData_UserId;
                     
              SELECT '저장되었습니다.' AS Result; 
                     
	ELSE
			  SELECT '저장이 완료되지 않았습니다.' AS Result;
	END IF;	


END $$
DELIMITER ;