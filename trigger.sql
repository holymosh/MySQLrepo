
delimiter ;;
#1
drop trigger if exists `checkTimeSnippet`;;
create trigger `checkTimeSnippet` before insert on `schedule`
for each row
begin
	if(new.first_day>new.last_day or new.start_time>new.end_time) then
		call excp();
	end if;
end;;

#1
drop trigger if exists `checkTimeSnippetOnUpdate`;;
create trigger `checkTimeSnippetOnUpdate` before update on `schedule`
for each row
begin
	if(new.first_day>new.last_day or new.start_time>new.end_time) then
		call excp();
	end if;
end;;

#2
drop trigger if exists `deleteExhibition`;;
create trigger `deleteExhibition` before delete on `exhibition`
for each row
begin
	delete from `schedule` where schedule.id = old.id;
	delete from `ticket` where ticket.exhibition = old.id;
end;;
#sdrop trigger if exists `deleteExhibition`;;

#3
drop trigger if exists `checkUriOnCreate`;;
create trigger `checkUriOnCreate` before insert on `museums_company`
for each row
begin
	set @uri = new.site;
    set @locateres = (select locate(".ru",@uri));
		if(@locateres =0) then
		call exception();
		end if;
end;;

#4
drop trigger if exists `checkContactNumber`;;
create trigger `checkContactNumber` before insert on `contact`
for each row 
begin
set @contactNumber = new.phone_number;
	if(@contactNumber<100000) then 
      call exception();
      end if;
end;;

#5
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

#7
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

#8
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

#9
drop trigger if exists `ifContractExists` ;;
create trigger `ifContractExists` before insert on `contract`
for each row
begin
set @ifExists = (select count(*) from `contract` where new.museum_company_id = `contract`.museum_company_id and new.trucking_company_id = `contract`.trucking_company_id);
if(@ifExists>0) then
call exception();
end if;
end;;

#10
drop trigger if exists `checkPassportOnInsert` ;;
create trigger `checkPassportOnInsert` before insert on `driver`
for each row 
begin
set @passportsCount = (select count(*) from `driver` where new.passport_num=`driver`.passport_num and new.passport_ser=`driver`.passport_ser);
	if(@passportsCount>0) then 
		call exception();
	end if;
end;;

#10
drop trigger if exists `checkPassportOnUpdate` ;;
create trigger `checkPassportOnUpdate` before update on `driver`
for each row 
begin
set @passportsCount = (select count(*) from `driver` where driver.passport_num=new.passport_num and driver.passport_ser=new.passport_ser);
	if(@passportsCount>0) then 
		call exception();
	end if;
end;;

delimiter ;