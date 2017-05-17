delimiter ;;

#1)	Программа не должна два раза ссылаться на одну и ту же операционную систему

drop trigger if exists `checkProgramRelationToOs`;;
create trigger `checkProgramRelationToOs` before insert on `os_to_program`
for each row
begin
	declare rowCount int default 0;
    set rowCount = (select count(*) from `os_to_program` where `os_to_program`.`osId` = new.`osId` and `os_to_program`.`programId` = new.`programId`);
    if(rowCount>0) then
		call excp();
    end if;
end;;

drop trigger if exists `checkProgramRelationToOs`;;
create trigger `checkProgramRelationToOs` before update on `os_to_program`
for each row
begin
	declare rowCount int default 0;
    set rowCount = (select count(*) from `os_to_program` where `os_to_program`.`osId` = new.`osId` and `os_to_program`.`programId` = new.`programId`);
    if(rowCount>0) then
		call excp();
    end if;
end;;

# 2) нельзя зарегестрировать продукт с уже существующим названием

drop trigger if exists `ifProductNameExists` ;;
create trigger `ifProductNameExists` before insert on `product`
for each row
begin
	declare nameCount int default 0;
    set nameCount=(select count(*) from `product` where `product`.`name` = new.`name`);
    if(nameCount>0) then
		call excp();
        end if;
end;;

drop trigger if exists `ifProductNameExists` ;;
create trigger `ifProductNameExists` before update on `product`
for each row
begin
	declare nameCount int default 0;
    set nameCount=(select count(*) from `product` where `product`.`name` = new.`name`);
    if(nameCount>0) then
		call excp();
        end if;
end;;


# 3 
drop trigger if exists `noLicenseForMalware` ;;
create trigger `noLicenseForMalware` before insert on `software`
for each row
begin
	if(new.`type` = 'malware') then
    call ex();
    end if;
end;;

drop trigger if exists `noLicenseForMalware` ;;
create trigger `noLicenseForMalware` before update on `software`
for each row
begin
	if(new.`type` = 'malware') then
    call ex();
    end if;
end;;

#4 год выпуска ос не больше текущего
drop trigger if exists `yearValueIsLessThanCurrentYearOrEquals` ;;
create trigger `yearValueIsLessThanCurrentYearOrEquals` before insert on `os`
for each row
begin
	set @currentTime = (select now());
	set @currentYear = (select extract(year from @currentTime));
		if(new.year> @currentYear) then
		call exception();
	end if;
end;;

drop trigger if exists `yearValueIsLessThanCurrentYearOrEquals` ;;
create trigger `yearValueIsLessThanCurrentYearOrEquals` before update on `os`
for each row
begin
	set @currentTime = (select now());
	set @currentYear = (select extract(year from @currentTime));
		if(new.year> @currentYear) then
		call exception();
	end if;
end;;

# 5 Проверка uri 
drop trigger if exists `checkUriOnCreate`;;
create trigger `checkUriOnCreate` before insert on `company`
for each row
begin
declare ifUriExists int default 0;
	set @uri = new.`uri`;
    set @locateres = (select CheckUri(@uri));
	set ifUriExists = (select count(*) from `company` where `company`.`uri` = @uri);
		if(@locateres =0) then
		call exception();
		end if;
end;;

drop trigger if exists `checkUriOnCreate`;;
create trigger `checkUriOnCreate` before update on `company`
for each row
begin
declare ifUriExists int default 0;
	set @uri = new.`uri`;
    set @locateres = (select CheckUri(@uri));
	set ifUriExists = (select count(*) from `company` where `company`.`uri` = @uri);
		if(@locateres =0) then
		call exception();
        end if;
end;;

# 6 

drop trigger if exists `fileTriger` ;;
create trigger `fileTriger` before insert on `file`
for each row
begin
	declare fileNameCount int default 0;
    set fileNameCount = (select count(*) from `file` where new.`extension` = `file`.`extension`);
    if(fileNameCount>0) then
		call excp();
        end if;
    
end;;

drop trigger if exists `fileTriger` ;;
create trigger `fileTriger` before update on `file`
for each row
begin
	declare fileNameCount int default 0;
    set fileNameCount = (select count(*) from `file` where new.`extension` = `file`.`extension`);
    if(fileNameCount>0) then
		call excp();
        end if;
    
end;;

# 7 нет патента на зловредное по
drop trigger if exists `noPatentForMalware` ;;
create trigger `noPatentForMalware` before insert on `patent`
for each row
begin

end;;
