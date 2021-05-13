drop PROCEDURE _SBLogin_Check;

DELIMITER $$
CREATE PROCEDURE _SBLogin_Check
	(
		 InData_OperateFlag		CHAR(2)			-- 작업표시
		,InData_CompanySeq		INT				-- 법인내부코드
		,InData_UserId			VARCHAR(30)		-- 로그인ID
		,InData_LoginPwd		VARCHAR(50)		-- 로그인Pwd
        ,OUT RETURN_OUT 		INT				-- IsCheck 결과 내보내기
    )
Error_Out:BEGIN -- Error_Out : 오류가 발생했을 경우 프로시져 종료

	-- 오류 관리 변수---------------------------------------
	DECLARE CompanySeq 			INT;
	DECLARE IsCheck 			INT;
    DECLARE Result  			VARCHAR(500);
	-- -------------------------------------------------
    
    -- 변수선언 --
    DECLARE Var_UserSeq		 	INT;     
	DECLARE Var_LoginStatus     INT;
    
	-- 변수설정 --
	SET Var_UserSeq = (SELECT A.UserSeq FROM _TCBaseUser AS A WHERE A.CompanySeq = InData_CompanySeq AND A.UserId = InData_UserId);
  

  
	-- 오류 관리 테이블---------------------------------------
	CREATE TEMPORARY TABLE IsCheck_TEMP
    (CompanySeq INT, IsCheck INT, Result VARCHAR(500));
	INSERT INTO IsCheck_TEMP VALUES(InData_CompanySeq, 1111, '');    
	-- -------------------------------------------------	



    -- LoginDate(로그인한 일시)가 180일(약 6개월)이 지날경우 휴먼계정으로 설정------------------------------------------------------------------------------
	UPDATE _TCBaseUser AS A
       SET A.LoginStatus = 1005005 -- 휴먼계정
	 WHERE (SELECT(CONVERT(DATE_FORMAT(NOW(), "%Y%m%d"), DATE)) >= (SELECT CONVERT(date_add(A.LoginDate,INTERVAL 180 DAY),DATE)));
     

    -- OperateFlag의 값이 'U' 외의 값이 들어갈 경우 에러발생------------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.UserSeq	, 1111)   AS UserSeq 
				FROM _TCBaseUser	 		  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON InData_OperateFlag <> 'U'
		 limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '[ (U) : 업데이트 ] 외의 명령을 입력할 수 없습니다.';
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;  
    
    

 	-- InData_CompanySeq, InData_UserId, InData_LoginPwd 를 필수로 입력하지 않을 경우 에러발생 ------------------------------------------------
    IF ((SELECT IFNULL(A.ERR	, 1111)       AS UserSeq 
				FROM (SELECT 9999 AS ERR)	  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON (
																	   (InData_CompanySeq		= 0 ) 
																	OR (InData_UserId       	= '')
                                                                    OR (InData_LoginPwd   	   	= '')
																 )   
															  AND (InData_OperateFlag LIKE 'U')
		 limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE    
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '법인내부코드, 로그인ID, 패스워드 는 필수값 입니다.'
	   WHERE (InData_OperateFlag LIKE 'U');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);      
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF; -- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;   



    -- InData_CompanySeq의 값이 _TSBaseCompany.CompanySeq의 데이터에 존재하는 값이 없을 경우 에러발생 ------------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.CompanySeq, 1111)  	AS CompanySeq 
				FROM _TSBaseCompany 		  	AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON  (InData_CompanySeq  <>    	A.CompanySeq ) 
															  AND (InData_OperateFlag LIKE      'U'			 )
		 limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '등록된 법인 정보가 아닙니다.'
	   WHERE (InData_OperateFlag LIKE 'U');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;  
    
    
    
    -- Update할 때, UserId가 존재하지 않을 경우 에러발생----------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.UserSeq	, 1111)   AS UserSeq 
				FROM _TCBaseUser	 		  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq       =    InData_CompanySeq
															 AND A.UserId			=	 InData_UserId
															 AND (InData_OperateFlag LIKE 'U') 
		 limit 1
         ) = (SELECT Var_UserSeq)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '존재하지 않는 계정입니다.'
	   WHERE (InData_OperateFlag LIKE 'U');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;  
    
    
    
    -- 로그인 상태 체크 ----------------------------------------------------------------------------
    SET Var_LoginStatus = (SELECT IFNULL(A.LoginStatus, 1005001) AS LoginStatus   -- NULL값일 경우 우선 진행
						     FROM _TCBaseUser 			  AS A 
						    RIGHT OUTER JOIN (SELECT '')  AS LoginStatus_CHECK  ON A.CompanySeq       = InData_CompanySeq
																			   AND A.UserId 		  = InData_UserId 
																			   AND A.LoginPwd 		  = InData_LoginPwd 
						   );
    
    
    IF (Var_LoginStatus = 1005001 OR Var_LoginStatus = 1005002) -- 정상진입 및 비밀번호 틀림
    THEN 
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
	
    ELSE
	   -- FALES
        IF Var_LoginStatus = 1005003 -- 임시계정정지
		THEN
			UPDATE IsCheck_TEMP AS A
			SET  A.IsCheck = 9999
				,A.Result  = '[ 임시계정정지 ] 된 아이디입니다.'
			WHERE (InData_OperateFlag LIKE 'U') ;
  
        ELSEIF Var_LoginStatus = 1005004 -- 비밀번호교체
		THEN
			UPDATE IsCheck_TEMP AS A
			SET  A.IsCheck = 9999
				,A.Result  = '비밀번호 변경 후 로그인 해주세요.'
			WHERE (InData_OperateFlag LIKE 'U') ;

        ELSEIF Var_LoginStatus = 1005005 -- 휴정계정
		THEN
			UPDATE IsCheck_TEMP AS A
			SET  A.IsCheck = 9999
				,A.Result  = '[ 휴정계정 ] 된 아이디입니다.'
			WHERE (InData_OperateFlag LIKE 'U') ;
	
        ELSEIF Var_LoginStatus = 1005006 -- 폐기계정
		THEN
			UPDATE IsCheck_TEMP AS A
			SET  A.IsCheck = 9999
				,A.Result  = '[ 폐기계정 ] 된 아이디입니다.'
			WHERE (InData_OperateFlag LIKE 'U') ;
        END IF;
        
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;   

    
    
 	-- PwdChgDate 기준으로 90일 경과할 경우 LoginPwd 교체 메시지와 함께 에러발생 (LoginStatus '1005004')----------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.UserSeq	, 1111)   AS UserSeq 
				FROM _TCBaseUser	 		  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq       =    InData_CompanySeq
															 AND A.LoginPwd			=    InData_LoginPwd 
															 AND (SELECT CONVERT(DATE_FORMAT(NOW(), "%Y%m%d"), DATE)) >= (SELECT CONVERT(date_add(A.PwdChgDate,INTERVAL 90 DAY),DATE))
															 AND (InData_OperateFlag LIKE 'U') 
		limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   -- FALES
       UPDATE _TCBaseUser AS A
          SET A.LoginStatus = 1005004 -- 비밀번호 교체
		WHERE A.CompanySeq = InData_CompanySeq
          AND A.UserSeq    = Var_UserSeq;       
       
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '비밀번호를 변경한지 90일이 지났습니다. 비밀번호 변경 후 로그인해주시길 바랍니다.'
	   WHERE (InData_OperateFlag LIKE 'U') ;
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;     
 
 
 
  	-- LoginFailCnt가 5회 초과되면 에러발생 //LoginStatus 값이 '1005003'으로 변경----------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.UserSeq	, 1111)   AS UserSeq 
				FROM _TCBaseUser	 		  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq       =    InData_CompanySeq
															 AND A.UserId			=    InData_UserId
                                                             AND A.LoginPwd			<>   InData_LoginPwd 
															 AND A.LoginFailCnt		>=	 5
															 AND (InData_OperateFlag LIKE 'U') 
		limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   -- FALES
       UPDATE _TCBaseUser AS A
          SET A.LoginStatus = 1005003 -- 임시계정정지
		WHERE A.CompanySeq = InData_CompanySeq
          AND A.UserSeq    = Var_UserSeq;       
       
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '계정이 정지되었습니다. 관리자에게 문의주시길 바랍니다.'
	   WHERE (InData_OperateFlag LIKE 'U') ;
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;          
          
          
    
    -- Update할 때, UserId에 맞는 LoginPwd가 틀릴 경우 에러발생 //InData_LoginPwd가 LoginPwd의 데이터와 틀릴경우 Count + 1----------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.UserSeq	, 1111)   AS UserSeq 
				FROM _TCBaseUser	 		  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq       =    InData_CompanySeq
															 AND A.UserId			=    InData_UserId
                                                             AND A.LoginPwd			<>   InData_LoginPwd
															 AND (InData_OperateFlag LIKE 'U') 
		limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   -- FALES       
       UPDATE _TCBaseUser AS A
          SET A.LoginFailCnt = A.LoginFailCnt + 1
             ,A.LoginStatus = 1005002 -- 비밀번호 틀림
		WHERE A.CompanySeq = InData_CompanySeq
          AND A.UserSeq    = Var_UserSeq;       
       
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '틀린 패스워드입니다. 다시 입력해주세요.'
	   WHERE (InData_OperateFlag LIKE 'U') ;
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;          
    

    
	DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
END $$
DELIMITER ;