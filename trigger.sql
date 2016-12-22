
delimiter ;;

drop trigger if exists `checkTimeSnippet`;;
create trigger `checkTimeSnippet` before insert on `schedule`
for each row
begin
	if(new.first_day>new.last_day or new.start_time>new.end_time) then
		call excp();
	end if;
end;;

drop trigger if exists `checkTimeSnippet`;;
create trigger `checkTimeSnippet` before update on `schedule`
for each row
begin
	if(new.first_day>new.last_day or new.start_time>new.end_time) then
		call excp();
	end if;
end;;

drop trigger if exists `deleteExhibition`;;
create trigger `deleteExhibition` before delete on `exhibition`
for each row
begin
	delete from `schedule` where schedule.id = old.id;
	delete from `ticket` where ticket.exhibition = old.id;
end;;
#sdrop trigger if exists `deleteExhibition`;;

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

drop trigger if exists `checkContactNumber`;;
create trigger `checkContactNumber` before insert on `contact`
for each row 
begin
set @contactNumber = new.phone_number;
	if(@contactNumber<100000) then 
      call exception();
      end if;
end;;

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

drop trigger if exists `checkMuseumName`;;
create trigger `checkMuseumName` before insert on `museum`
for each row
begin
set @museumName = new.name;
set @namesCount = (select count(*) from `museum` where `museum`.name = museumName);
	if(@namesCount >0) then
    call exception();
    end if;
end;;
delimiter ;