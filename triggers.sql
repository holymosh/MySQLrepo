delimiter ;;

drop trigger if exists `deleteExhibition`;;
create trigger `deleteExhibition` before delete on `exhibition`
for each row
begin
delete from `schedule` where schedule.id = old.id;
delete from `ticket` where ticket.exhibition = old.id;
end;;

drop trigger if exists `checkTimeSnippet`;;
create trigger `checkTimeSnippet` before insert on `schedule`
for each row
begin

end;;