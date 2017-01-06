delimiter ;;

#Администратор
drop role if exists 'dbadmin' ;; 
create role 'dbadmin';;


grant all on `university`.* to 'dbadmin';;


#2.	Заведующий грузоперевозками 
drop role if exists 'trucking_company_manager' ;;
create role 'trucking_company_manager' ;;
grant select  on `university`.`price_list` to 'trucking_company_manager';;
grant select  on `university`.`transport` to 'trucking_company_manager';;
grant select  on `university`.`driver` to 'trucking_company_manager';;
grant select  on `university`.`trucking_company` to 'trucking_company_manager';;

#экскурсовод

drop role if exists 'guide';;
create role 'guide' ;;
grant select on `university`.`exhibition` to 'guide';;
grant select on `university`.`schedule` to 'guide';;
grant select on `university`.`exhibition_hall` to 'guide';;
grant select on `university`.`exponent` to 'guide';;
grant select on `university`.`owner` to 'guide';;
grant select on `university`.`author` to 'guide';;

#Менеджер по связи с музеямиalter

drop role if exists 'museum_manager';;
create role 'museum_manager' ;;
grant select,insert,update on `university`.`museum` to 'museum_manager';

#Клиент
drop role if exists 'client';;
create role 'client' ;;
grant select on `university`.`ticket` to 'client';;

#delimiter;