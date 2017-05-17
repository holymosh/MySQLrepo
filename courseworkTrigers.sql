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


