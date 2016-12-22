delimiter ;;

drop trigger if exists `deleteExhibition`;;
create trigger `deleteExhibition` after delete on `exhibition`
delete 