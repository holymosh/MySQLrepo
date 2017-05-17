delimiter ;;

#проверка uri

drop function if exists `CheckUri` ;;
create function `CheckUri` (uri varchar(50))
returns bool 
begin
declare valuesCount int default 0;
declare currentValue int default 1;
declare locateResult int default 0;
declare domenFromTable varchar(10);
set valuesCount = (select count(*) from `domen`);
while currentValue <= valuesCount do 
	set domenFromTable = (select `domen`.`value` from `domen` where currentValue = `domen`.`id`);
	set currentValue = currentValue + 1 ;
	set locateResult = (select locate(domenFromTable , uri));
    if(locateResult > 0 and domenFromTable <> uri) then 
		return true;
	end if;
end while ;
return false;
end;; 