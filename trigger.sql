
delimiter ;;
# Проверка временного интервала
drop trigger if exists `checkTimeSnippet`;;
create trigger `checkTimeSnippet` before insert on `schedule`
for each row
begin
	if(new.first_day>new.last_day or new.start_time>new.end_time) then
		call excp();
	end if;
end;;

# Проверка временного интервала
drop trigger if exists `checkTimeSnippetOnUpdate`;;
create trigger `checkTimeSnippetOnUpdate` before update on `schedule`
for each row
begin
	if(new.first_day>new.last_day or new.start_time>new.end_time) then
		call excp();
	end if;
end;;

#Каскадное удаление выставки
drop trigger if exists `deleteExhibition`;;
create trigger `deleteExhibition` before delete on `exhibition`
for each row
begin
	delete from `schedule` where schedule.id = old.id;
	delete from `ticket` where ticket.exhibition = old.id;
end;;
#sdrop trigger if exists `deleteExhibition`;;

#Проверка uri 
drop trigger if exists `checkUriOnCreate`;;
create trigger `checkUriOnCreate` before insert on `museums_company`
for each row
begin
declare ifUriExists int default 0;
	set @uri = new.site;
    set @locateres = (select CheckUri(@uri));
	set ifUriExists = (select count(*) from `museums_company` where `museums_company`.`site` = @uri);
		if(@locateres =0) then
		call exception();
		end if;
end;;

# Проверка номера 
#drop trigger if exists `checkContactNumber`;;
#create trigger `checkContactNumber` before insert on `contact`
#for each row 
#begin
#set @contactNumber = new.phone_number;
#	if(@contactNumber<100000) then 
#      call exception();
#      end if;
#end;;

#Проверка на равенство места доставки и места отправления
drop trigger if exists `checkOrderMuseums`;;
create trigger `checkOrderMuseums` before insert on `order`
for each row
begin
set @fromId = new.from;
set @toId = new.to;
	if(@fromId = @toId) then 
		call exception();
	end if;
end;;

# Уведомление о доставке
drop trigger if exists `checkOrderMuseumsAfterInsert`;;
create trigger `checkOrderMuseumsAfterinsert` after insert on `order`
for each row
begin
call CreateNotification(new.to,new.arrivaltime , new.exponent);
end;;

#6
drop trigger if exists `checkUriCompany`;;
create trigger `checkUriCompany` before insert on `trucking_company`
for each row 
begin 
set @truckSite = new.site;
set @sitesCount = (select count(*) from `trucking_company` where trucking_company.site=@truckSite);
	if(@sitesCount>0) then 
	 call exception();
	end if;
end;;

#Проверка на существование текущего имени
drop trigger if exists `checkMuseumName`;;
create trigger `checkMuseumName` before insert on `museum`
for each row
begin
set @museumName = new.name;
set @namesCount = (select count(*) from `museum` where `museum`.name = @museumName);
	if(@namesCount >0) then
    call exception();
    end if;
end;;

# Валидность года экспоната
drop trigger if exists `checkExponentyear` ;; 
create trigger `checkExponentyear` before insert on `exponent`
for each row
begin
set @currentTime = (select now());
set @currentYear = (select extract(year from @currentTime));
if(new.year> @currentYear) then
call exception();
end if;
end;;

# Пролетевший тригер 
drop trigger if exists `ifContractExists` ;;
create trigger `ifContractExists` before insert on `contract`
for each row
begin
set @ifExists = (select count(*) from `contract` where new.museum_company_id = `contract`.museum_company_id and new.trucking_company_id = `contract`.trucking_company_id);
if(@ifExists>0) then
call exception();
end if;
end;;

#проверка паспорта сотрудника
drop trigger if exists `checkPassportOnInsert` ;;
create trigger `checkPassportOnInsert` before insert on `driver`
for each row 
begin
set @passportsCount = (select count(*) from `driver` where new.passport_num=`driver`.passport_num and new.passport_ser=`driver`.passport_ser);
	if(@passportsCount>0) then 
		call exception();
	end if;
end;;

#Проверка паспорта сотрудника
drop trigger if exists `checkPassportOnUpdate` ;;
create trigger `checkPassportOnUpdate` before update on `driver`
for each row 
begin
set @passportsCount = (select count(*) from `driver` where driver.passport_num=new.passport_num and driver.passport_ser=new.passport_ser);
	if(@passportsCount>0) then 
		call exception();
	end if;
end;;

#Заполнение строчек в прайс листе возможно только в том случае , если компания имеет тип транспорта. 
drop trigger if exists `CheckTransportTypeForCreatingRowsInPriceList` ;;
create trigger `CheckTransportTypeForCreatingRowsInPriceList` before insert on `price_list`
for each row
begin 
declare ifExists int default 0;
set ifExists = (select count(`transport`.`type`) from `transport` where `transport`.companyId = new.company and `transport`.`type` = new.`trasport_type` );
	if(ifExists = 0) then 
		call exception();
	end if;
end;;

# тригер на формат номера

drop trigger if exists `CheckPhoneNumber` ;;
create trigger `CheckPhoneNumber` before insert on `contact`
for each row
begin
declare leftSymbolPosition int default 0;
declare rightSymbolPosition int default 0;
declare plusPosition int default 0;
set leftSymbolPosition = (select locate('(' ,new.phone_number));
set rightSymbolPosition = (select locate(')', new.phone_number));
set plusPosition = (select position('+' in new.phone_number));
	if(rightSymbolPosition-leftSymbolPosition<1 or leftSymbolPosition<3) then 
		call exception();
	end if;
    
end;;

delimiter ;