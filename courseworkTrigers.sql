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
	declare softType varchar(20) default null;
    set softType = (select(`software`.`type`) from `software` where `software`.`id` = new.`poId`);
    if(softType = 'malware') then
		call ex();
    end if;
end;;

drop trigger if exists `noPatentForMalware` ;;
create trigger `noPatentForMalware` before update on `patent`
for each row
begin
	declare softType varchar(20) default null;
    set softType = (select(`software`.`type`) from `software` where `software`.`id` = new.`poId`);
    if(softType = 'malware') then
		call ex();
    end if;
end;;

#8 15

drop trigger if exists `noRepeatForSoftwareToCompany` ;; 
create trigger `noRepeatForSoftwareToCompany` before insert on `company_to_software`
for each row
begin
	declare rowsCount int default 0;
    set rowsCount = (select count(*) from `company_to_software` where `company_to_software`.`companyId` = new.`companyId` 
		and `company_to_software`.`softwareId`= new.`softwareId`);
	if(rowsCount >0) then
		call exc();
    end if;
    
end;;

drop trigger if exists `noRepeatForSoftwareToCompany` ;; 
create trigger `noRepeatForSoftwareToCompany` before update on `company_to_software`
for each row
begin
	declare rowsCount int default 0;
    set rowsCount = (select count(*) from `company_to_software` where `company_to_software`.`companyId` = new.`companyId` 
		and `company_to_software`.`softwareId`= new.`softwareId`);
	if(rowsCount >0) then
		call exc();
    end if;
    
end;;


# 9 6
drop trigger if exists `documentationWithControlVersion` ;; 
create trigger `documentationWithControlVersion` before insert on `documentation`
for each row
begin
	declare valid tinyint default 0;
    set valid = (select count(*) from `versions_controls` where `versions_controls`.`name` = new.`uri`);
    if(valid=0) then
		call exc();
    end if;
end;;

drop trigger if exists `documentationWithControlVersion` ;; 
create trigger `documentationWithControlVersion` before update on `documentation`
for each row
begin
	declare valid tinyint default 0;
    set valid = (select count(*) from `versions_controls` where `versions_controls`.`name` = new.`uri`);
    if(valid=0) then
		call exc();
    end if;
end;;

#10 11

drop trigger if exists `cantBeSpecialistsAtAll` ;;
create trigger `cantBeSpecialistsAtAll` before insert on `programer_to_type`
for each row
begin
	declare valid int default 0;
    set valid = (select count(*) from `programer_to_type` where `programer_to_type`.`programerId` = new.`programerId`);
    declare typesCount int default 0;
    set typesCount = (select count(*) from `programer_type`);
    if(typesCount = valid+1) then
		call exception();
	end if;
end;;

drop trigger if exists `cantBeSpecialistsAtAll` ;;
create trigger `cantBeSpecialistsAtAll` before update on `programer_to_type`
for each row
begin
	declare valid int default 0;
    set valid = (select count(*) from `programer_to_type` where `programer_to_type`.`programerId` = new.`programerId`);
    declare typesCount int default 0;
    set typesCount = (select count(*) from `programer_type`);
    if(typesCount = valid+1) then
		call exception();
	end if;
end;;

#11 13
drop trigger if exists `programPrice` ;; 
create trigger `programPrice` before insert on `program_to_framework`
for each row
begin
	update `program` set `program`.`sum` = `program`.`sum`+'20000' where new.`programId` = `program`.`id`;
end;;

#12  2

drop trigger if exists `system_requirement_trigger_cpu` ;; 
create trigger `system_requirement_trigger_cpu` before insert on `requirement_to_cpu`
for each row
begin
	declare rowsCount int default 0;
    set rowsCount = (select count(*) from `requirement_to_cpu` where `requirement_to_cpu`.`cpuId` = new.`cpuId`);
	if(rowsCount >0) then
		call exc();
    end if;
    
end;;

drop trigger if exists `system_requirement_trigger_harddisk` ;; 
create trigger `system_requirement_trigger_harddisk` before insert on `requirement_to_harddisk`
for each row
begin
	declare rowsCount int default 0;
    set rowsCount = (select count(*) from `requirement_to_harddisk` where `requirement_to_harddisk`.`diskId` = new.`diskId`);
	if(rowsCount >0) then
		call exc();
    end if;
    
end;;

drop trigger if exists `system_requirement_trigger_ram` ;; 
create trigger `system_requirement_trigger_ram` before insert on `requirement_to_ram`
for each row
begin
	declare rowsCount int default 0;
    set rowsCount = (select count(*) from `requirement_to_ram` where `requirement_to_ram`.`ramId` = new.`ramId`);
	if(rowsCount >0) then
		call exc();
    end if;
    
end;;

drop trigger if exists `system_requirement_trigger_cpu` ;; 
create trigger `system_requirement_trigger_cpu` before update on `requirement_to_cpu`
for each row
begin
	declare rowsCount int default 0;
    set rowsCount = (select count(*) from `requirement_to_cpu` where `requirement_to_cpu`.`cpuId` = new.`cpuId`);
	if(rowsCount >0) then
		call exc();
    end if;
    
end;;

drop trigger if exists `system_requirement_trigger_harddisk` ;; 
create trigger `system_requirement_trigger_harddisk` before update on `requirement_to_harddisk`
for each row
begin
	declare rowsCount int default 0;
    set rowsCount = (select count(*) from `requirement_to_harddisk` where `requirement_to_harddisk`.`diskId` = new.`diskId`);
	if(rowsCount >0) then
		call exc();
    end if;
    
end;;

drop trigger if exists `system_requirement_trigger_ram` ;; 
create trigger `system_requirement_trigger_ram` before update on `requirement_to_ram`
for each row
begin
	declare rowsCount int default 0;
    set rowsCount = (select count(*) from `requirement_to_ram` where `requirement_to_ram`.`ramId` = new.`ramId`);
	if(rowsCount >0) then
		call exc();
    end if;
    
end;;

#13 7
drop trigger if exists `aboutVirtualMachines` ;;
create trigger `aboutVirtualMachines` before insert on `framework_to_library`
for each row
begin
	declare vmCount int default 0;
    declare vm varchar(50) default null;
    set vm = (select `programming_language`.`virtualMachine` from `programming_language` join `library` on `library`.`languageId` = new.`library` 
		where `library`.`languageId` = `programming_language`.`id`);
    set vmCount = (select count(*) from `framework_to_library` join `library` on `library`.`id`=`new`.`library` 
						join `programming_language` on `programming_language`.id = `library`.`languageId`
                        where `programming_language`.`virtualMachine` <> vm or `programming_language`.`virtualMachine`<> null );
	if(vmCount>0) then
		call exception();
	end if;
end;;

drop trigger if exists `aboutVirtualMachines` ;;
create trigger `aboutVirtualMachines` before update on `framework_to_library`
for each row
begin
	declare vmCount int default 0;
    declare vm varchar(50) default null;
    set vm = (select `programming_language`.`virtualMachine` from `programming_language` join `library` on `library`.`languageId` = new.`library` 
		where `library`.`languageId` = `programming_language`.`id`);
    set vmCount = (select count(*) from `framework_to_library` join `library` on `library`.`id`=`new`.`library` 
						join `programming_language` on `programming_language`.id = `library`.`languageId`
                        where `programming_language`.`virtualMachine` <> vm or `programming_language`.`virtualMachine`<> null );
	if(vmCount>0) then
		call exception();
	end if;
end;;

#14 14

drop trigger if exists `programWithoutLicenseIsFree` ;;
create trigger `programWithoutLicenseIsFree` after insert on `program`
for each row
begin
	if(new.`licenseId` = null) then
		update `program` set `program`.`sum` =0 where `program`.`id` = new.`id`;
	end if;
end;;

#15

drop trigger if exists `additional_requirement_trigger` ;; 
create trigger `additional_requirement_trigger` after insert on `additional requirement`
for each row 
begin
	declare requirementCount int default 0;
    declare needParse int default 0;
    set requirementCount = (select count(*) from `additional requirement`);
    declare currentRequirement varchar(100) default null;
    while requirementCount > 0 do
		set currentRequirement = (select `additional requirement`.`description`
			from `additional requirement` where `additional requirement`.`id` = requirementCount);
		set needParse = (select locate(currentRequirement , new.`description`));
        if(needParse > 0) then 
			new.`description` = (select trim(both currentRequirement from new.`description`));
        end if;
		set requirementCount = requirementCount -1;
    end while;
end;;
