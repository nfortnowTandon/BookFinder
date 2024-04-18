--delimiter //
drop trigger Libraries_BEFORE_DELETE;//
CREATE TRIGGER Libraries_BEFORE_DELETE BEFORE DELETE ON Libraries FOR EACH ROW
BEGIN
	delete from LibraryCopies
	where LibraryId=OLD.id;
END;//


drop trigger Libraries_AFTER_DELETE;//
CREATE TRIGGER Libraries_AFTER_DELETE AFTER DELETE ON Libraries FOR EACH ROW
BEGIN
	delete from Addresses
	where id=OLD.AddressId;
END;//

drop trigger Books_BEFORE_DELETE;//
CREATE TRIGGER Books_BEFORE_DELETE BEFORE DELETE ON Books FOR EACH ROW
BEGIN
	delete from Reviews
	where BookId=OLD.id;
	
	delete from LibraryCopies
	where BookId=OLD.id;

	delete from StoreCopies
	where BookId=OLD.id;

END;//


--delimiter ;//
