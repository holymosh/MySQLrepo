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
returns int
begin
set @transportId = (select `order`.transport from `order` where `order`.id = id);
set @transport_type = (select `transport`.type from transport where transport.id = transportId);
set @trans_comp = (select `transport`.companyId from transport where transport.id = transportId);
set @price = (select `price_list`.price from `price_list` where `price_list`.company = @trans_comp);
return 0;
end;;

delimiter ;