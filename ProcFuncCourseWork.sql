delimiter ;;

#4 проверка uri

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

#1 стоимость программыalter
drop function if exists `CreateProgramPrice` ;;
create function `CreateProgramPrice`(id int)
returns int
begin
	declare programmersCount int default 0;
    declare frameworksCount int default 0;
    declare result int default 0;
    set frameworksCount = (select count(*) from `program_to_framework` where `program_to_framework`.`programId` = id);
    set programmersCount = (select count(*) from `programmer_to_program` where `programmer_to_program`.`programId` = id);
    set result = frameworksCount*15000 + programmersCount*15000;
    return result;
end;;

#2 определяем наличие  типа программиста 

drop function if exists `IfCompetenceExists` ;;
create function `IfCompetenceExists`(competence varchar(50))
returns boolean 
begin 
	declare ifExists boolean default false;
    set ifExists = (select count(`programer_type`.`type`) from `programer_type` where `programer_type`.`type` = competence)>0;
    return ifExists;
end;;


# 3 расчет минимальной стоимости системного требования
drop function if exists `CreatePriceForSystem` ;;
create function `CreatePriceForSystem` (id int)
returns int
begin
	declare result int default 0;
    declare minCpu int default 0;
    declare minDisk int default 0;
    declare minRam int default 0;
    declare requirementId int default 0;
    set requirementId = (select `program`.`systemRequirementId` from `program` where `program`.`id` = id);
    set minCpu = (select min(`cpu`.`price`) from `cpu` join `requirement_to_cpu` on `requirement_to_cpu`.`requirementId` = requirementId);
    set minDisk = (select min(`harddisk`.`price`) from `harddisk` join `requirement_to_harddisk` on `requirement_to_harddisk`.`requirementId` = requirementId);
    set minRam = (select min(`ram`.`price`) from `ram` join `requirement_to_ram` on `requirement_to_ram`.`requirementId` = requirementId);
    set result = minCpu+ minRam + minDisk;
    return result;
    
end;;

#5 расчет стоимости всего по