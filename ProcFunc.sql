delimiter ;;

#func1

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

#func2
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

#func3
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
declare discountId int default 0;
declare discountPrice int default 0;
declare discountValue int default 0;
declare price int default 0;
set transportId = (select `order`.transport from `order` where `order`.id = id);
set transport_type = (select `transport`.type from transport where transport.id = transportId);
set beginTime = (select `order`.departuretime from `order` where `order`.id = id);
set endTime = (select `order`.arrivaltime from `order` where `order`.id = id);
set trans_comp = (select `transport`.companyId from transport where transport.id = transportId);
set price = (select `price_list`.price from `price_list` where `price_list`.company = trans_comp and `price_list`.trasport_type = transport_type);
set unixBegin = unix_timestamp(beginTime);
set unixEnd = unix_timestamp(endTime);
set discountId = (select `order`.discount from `order` where `order`.id = id);
set discountPrice = (select `discount`.price_for_discount from `discount` where `discount`.id = discountId);
set discountValue = (select `discount`.percent from `discount` where `discount`.id = discountId);
set result = (unixEnd - unixBegin)/3600*price;
if(result > discountPrice) then 
set result = result * ((100-discountValue)/100);
end if;
return result;
end;;

#func4  
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

#proc1 

drop procedure if exists CreateNotification ;;
create procedure CreateNotification( museumid int , arrivalTime datetime , exponentId int)
begin
	insert into `notification` values(0,museumid , 0, arrivalTime, exponentId);
end;;

#proc2

drop procedure if exists FindFreeDrivers ;;
create procedure FindFreeDrivers(companyId int , beginTime datetime , endTime datetime)
begin
select `driver`.id,`driver`.driver_name , `driver`.driver_surname , `driver`.experience_years from `driver` join `order` on `order`.driver=`driver`.id
 where `driver`.company = companyId and (`order`.arrivaltime< beginTime or `order`.departuretime>endTime) 
group by `driver`.id
having CheckDriver(`driver`.id,beginTime,endTime) = true;
end;;

#proc3 
drop procedure if exists ExponentStory ;;
create procedure ExponentStory( id int)
begin
select `order`.exponent , `order`.from , `order`.to ,`order`.departuretime , `order`.arrivaltime from `order` where `order`.exponent = id 
group by `order`.departuretime;
end;; 

#proc4
drop procedure if exists GetNotifications ;;
create procedure GetNotifications(idMuseum int)
begin
	set SQL_SAFE_UPDATES=0;
	select `notification`.exponent , `notification`.time from notification where `notification`.museumId=museumId and `notification`.wasRead =0;
	update `notification` set wasRead =1 where `notification`.museumId = idMuseum;
	set SQL_SAFE_UPDATES=1;
end;;
delimiter ;;