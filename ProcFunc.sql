delimiter ;;

drop function if exists `CheckUri` ;;
create function `CheckUri` (uri varchar(50))
returns bool 
begin
set @locateres = (select locate(".",uri));
		if(@locateres =0) then
			return false;
		else 
				return true;
		end if;
end;; 

drop function if exists `CheckDriver` ;;
create function `CheckDriver` ( id int, snippetBegin datetime , snippetEnd datetime)
returns bool
begin 
set @result = (select count(*) from `order` where id=`order`.driver and (
(`order`.departuretime<snippetBegin and snippetBegin < `order`.arrivaltime) or 
(`order`.departuretime<snippetEnd and snippetEnd < `order`.arrivaltime) or
(snippetBegin<`order`.departuretime and `order`.departuretime<snippetEnd) or
(snippetBegin<`order`.arrivaltime and `order`.arrivaltime<snippetEnd)));

if(@result >0 ) then
	  return false;
	else 
	  return true;
	end if;
end;;

drop function if exists `CreateSum` ;;
create function `CreateSum` (id int)
returns long
begin
declare transportId int default 0;
declare transport_type varchar(50);
declare trans_comp int default 0;
declare beginTime datetime;
declare result long;
declare endTime datetime;
declare unixBegin long;
declare unixEnd long;
declare price int default 0;
set transportId = (select `order`.transport from `order` where `order`.id = id);
set transport_type = (select `transport`.type from transport where transport.id = transportId);
set beginTime = (select `order`.departuretime from `order` where `order`.id = id);
set endTime = (select `order`.arrivaltime from `order` where `order`.id = id);
set trans_comp = (select `transport`.companyId from transport where transport.id = transportId);
set price = (select `price_list`.price from `price_list` where `price_list`.company = trans_comp and `price_list`.trasport_type = transport_type);
set unixBegin = unix_timestamp(beginTime);
set unixEnd = unix_timestamp(endTime);
set result = (unixEnd - unixBegin)/3600*price;
return result;
end;;

drop function if exists `FindExponent` ;; 
create function `FindExponent` (id int)
returns int
begin
declare lastTime datetime ;
declare museumId int default 0;
set lastTime = (select max(`order`.arrivaltime) from `order` where `order`.exponent = id);
set museumId = (select `order`.to from `order` where `order`.arrivaltime = lastTime);
return museumId;
end;;  

delimiter ;;