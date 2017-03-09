delimiter ;;

#Администратор
drop role if exists 'dbadmin' ;; 
create role 'dbadmin';;


grant all on `university`.* to 'dbadmin';;


#2.	Заведующий грузоперевозками 
drop role if exists 'trucking_company_manager' ;;
create role 'trucking_company_manager' ;;
grant select,update,insert,delete  on `university`.`price_list` to 'trucking_company_manager';;
grant select,update,insert,delete  on `university`.`transport` to 'trucking_company_manager';;
grant select,update,insert,delete  on `university`.`driver` to 'trucking_company_manager';;
grant select,update,insert  on `university`.`trucking_company` to 'trucking_company_manager';;
#grant select on procedure BuyTicket to 'trucking_company_manager';;

#экскурсовод

drop role if exists 'guide';;
create role 'guide' ;;
grant select,update,insert on `university`.`exhibition` to 'guide';;
grant select,update,insert on `university`.`schedule` to 'guide';;
grant select,update,insert on `university`.`exhibition_hall` to 'guide';;
grant select,update,insert on `university`.`exponent` to 'guide';;
grant select,update,insert on `university`.`owner` to 'guide';;
grant select,update,insert on `university`.`author` to 'guide';;
grant select,update,insert on `university`.`museum` to 'guide';;
grant select,update,insert on `university`.`order` to 'guide';;
grant execute on procedure `university`.`ExponentStory` to 'guide';;

#Менеджер по связи с музеями сделать так чтобы один из пользователей смог создавать пользователя и давал ему роль

drop role if exists 'museum_manager';;
create role 'museum_manager' ;;
grant select,insert,update on `university`.`museum` to 'museum_manager';
grant create user on *.* to 'museum_manager';;
grant super on *.* to 'museum_manager';;
grant grant option on *.* to 'museum_manager';;
grant all on `university`.* to 'dbadmin';;

#Клиент
drop role if exists 'client';;
create role 'client' ;;
grant select,update,insert on `university`.`ticket` to 'client';;
grant select on `university`.`exhibition` to 'client';;

delimiter ;