delimiter ;;

drop user if exists 'dbadmin1' , 'client1' , 'museum_manager1' , 'trucking_company_manager1' , 'guide1' ,'taskuser' ;;
create user 'dbadmin1' , 'client1' , 'museum_manager1' , 'trucking_company_manager1' , 'guide1','taskuser' ;;
grant 'dbadmin' to 'dbadmin1' ;; 
grant 'client' to 'client1' ;;
grant 'museum_manager' to 'museum_manager1';;
grant 'trucking_company_manager' to 'trucking_company_manager1';;
grant 'guide' to 'guide1';;
grant 'guide' to 'taskuser';;


set default role all to 'dbadmin'@'%',
						'client1'@'%',
                        'museum_manager1'@'%',
                        'trucking_company_manager1'@'%',
                        'guide1'@'%','guide1'@'%'
                       ;;
GRANT USAGE ON *.* TO 'taskuser'@`%`;



#set default role all to 'dbadmin1'

delimiter ;
