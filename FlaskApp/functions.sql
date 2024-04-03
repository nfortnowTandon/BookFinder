--DELIMITER //

drop function isSelected //
CREATE FUNCTION isSelected (id1 INT, id2 INT )
RETURNS VARCHAR(255)

BEGIN
	
	DECLARE ret VARCHAR(255);

	IF id1=id2 then
		set ret = "selected";
	ELSE
		set ret = "";
	END IF;

	RETURN ret;

END //

--DELIMITER ;
