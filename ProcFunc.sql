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