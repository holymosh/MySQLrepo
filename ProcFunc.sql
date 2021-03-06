delimiter ;;

#проверка uri

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


#Подсчет аренды экспоната
drop function if exists `CreateSum` ;;
create function `CreateSum` (exponentId int, exhibitionId int )
returns long
begin
declare firstDay date;
declare result long;
declare lastDay date;
declare days int default 0;
declare exponentPrice int default 0;
set exponentPrice = (select `exponent`.`price` from `exponent` where `exponent`.id = exponentId);
set firstDay = (select max(`schedule`.`first_day`) from `schedule` where `schedule`.`exhibition` = exhibitionId);
set lastDay = (select max(`schedule`.`last_day`) from `schedule` where `schedule`.`exhibition`= exhibitionId);
set days = datediff(lastDay , firstDay);
set result = days*exponentPrice;
return result;
end;;

# Возврат id музея в котором находится экспонта
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

#создание уведомлений

drop procedure if exists CreateNotification ;;
create procedure CreateNotification( museumid int , arrivalTime datetime , exponentId int)
begin
	insert into `notification` values(0,museumid , 0, arrivalTime, exponentId);
end;;


#история экспоната
drop procedure if exists ExponentStory ;;
create procedure ExponentStory( exponentId int)
begin
SELECT distinct `exhibition`.`name` , `schedule`.`first_day`,`schedule`.`last_day`, 
	`schedule`.`start_time`,`schedule`.`end_time`  , `exhibition`.museumId , `museum`.`city`
from `exponent` , `exhibition` , `schedule` , `order` ,`museum` join `exponentstoexhibitions`
 on `exponentstoexhibitions`.`exponent` = exponentId
 where `exponentstoexhibitions`.`exhibition` = `schedule`.`exhibition` and 
 `exhibition`.`id` = `exponentstoexhibitions`.`exhibition`
 and `order`.`exponent` = exponentId and `order`.`to` = `exhibition`.`museumId` and 
 `museum`.`id` = `exhibition`.`museumId` ;
end;; 

#получение уведомлений
drop procedure if exists GetNotifications ;;
create procedure GetNotifications(idMuseum int)
begin
	set SQL_SAFE_UPDATES=0;
	select `notification`.museumId ,`notification`.exponent , `notification`.time from `notification` where `notification`.museumId=idMuseum and `notification`.wasRead =0;
    update `notification` set wasRead =1 where `notification`.museumId = idMuseum;
	set SQL_SAFE_UPDATES=1;
end;;

#поиск выставок в городе
drop procedure if exists FindExhibitions ;; 
create procedure FindExhibitions(city varchar(30),beginDate date , endDate date)
begin

select `exhibition`.`name` , `schedule`.`first_day` , `schedule`.`last_day` , `schedule`.`start_time` , `schedule`.`end_time`
 from `exhibition`,`schedule` 
 join `museum` on `museum`.`city` = city 
 where `museum`.`id` = `exhibition`.`id` and `schedule`.`exhibition` = `exhibition`.`id` and
 (
 (`schedule`.`first_day`<=beginDate and beginDate<=`schedule`.last_day) or
 (`schedule`.`first_day`<=endDate and endDate<=`schedule`.last_day) or 
 (beginDate<=`schedule`.`first_day` and `schedule`.`first_day`<=endDate) or
 (beginDate<=`schedule`.`last_day` and `schedule`.`last_day`<=endDate)
 );
end;;

drop procedure if exists createSalary ;; 
create procedure createSalary(driverid int , beginDate datetime , endDate datetime )
begin
select sum(`order`.sum) from `order` where `order`.driver = driverid and (beginDate < `order`.departuretime and `order`.departuretime<endDate)
;
end;;

#занятые,свободные ,бронь
drop procedure if exists GetTicketsState ;; 
create procedure GetTicketsState(exhibitionId int)
begin
select `ticket`.`id` , `ticket`.`number` , `ticket`.`state` , `ticket`.`type` from `ticket` where `ticket`.`exhibition` = exhibitionId order by `ticket`.`state` desc;
end;; 

#задание на процедуру 
drop function if exists CreateSalary ;; 
create function CreateSalary(driverid int , beginDate date , endDate date )
returns long
begin 
declare i int default 0;
declare ordersCount int default 0;
declare result long default 0;
declare localValue int default 0;
declare transportId int default 0; 
declare companyId int default 0; 
set companyId = (select `driver`.`company`from `driver` where `driver`.id = driverid);
set ordersCount = (select count(*) from `order`); 
while i<ordersCount do
set transportId = (select `order`.transport from `order` where `order`.driver = driverid and `order`.id = i  and (
(`order`.`departuretime`<=beginDate and beginDate<=`order`.`arrivaltime`) or
 (`order`.`departuretime`<=endDate and endDate<=`order`.`arrivaltime`) or 
 (beginDate<=`order`.`departuretime` and `order`.`departuretime`<=endDate) or
 (beginDate<=`order`.`arrivaltime` and `order`.`arrivaltime`<=endDate)));
set i = i+1;
if (transportId = 0) then 
	begin
    set localValue = (select `transport`.`type` from `transport` where `transport`.companyId = companyId );
    set result = result +(select `price_list`.price from  `price_list` where `price_list`.company = companyId and `price_list`.trasport_type = localValue);
    end;
    end if;
end while ; 
return result;
end;; 

delimiter ;;