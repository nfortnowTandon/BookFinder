--DELIMITER //
-- here we are adding a new book//
drop procedure addbook;//
create procedure addbook (in isbnum VARCHAR(255), title VARCHAR(255), afname VARCHAR(255), alname VARCHAR (255), pyear INT, genreid INT)
begin
    declare aid int;
    if exists(select 1 from Authors where FirstName = afname and Lastname = alname) then
        select id into aid
        from Authors
        where FirstName = afname and Lastname = alname;
    else
        INSERT INTO Authors (FirstName, LastName)
        VALUES (afname, alname);
        
        select id into aid
	    from Authors
        where FirstName = afname and Lastname = alname;
    end if;
    if not exists(select 1 from Books where ISBN=isbnum) then
		INSERT INTO Books (ISBN, Title, AuthorId, YearPublished, GenreId)
		VALUES (isbnum, title, aid, pyear, genreid);
	end if; 
END //

-- get all the genres and select one if it's selected//
drop procedure getgenres;//
create procedure getgenres (in gid INT)
begin
    select id, Name, isSelected(id,gid) as selected
    from Genres;
end //

-- list all books//
-- I changed this to a view, so I'm gonna change it to just call the view
drop procedure booklistproc//
create procedure booklistproc ()
begin
    select * from booklist;
end //
--begin
--    select Books.id, Title, concat(Authors.FirstName,' ',Authors.LastName) as Author, YearPublished, Genres.Name as Genre, ISBN, Authors.id as authId
--    from Books
--    join Authors on Authorid=Authors.id
--    join Genres on GenreId=Genres.id
--    order by Authors.LastName,Title ASC;
--END //

-- find an existing book//
drop procedure findbook;//
create procedure findbook (in bookid int)
begin
    select Books.id, Title, ISBN, Authors.FirstName, Authors.LastName, YearPublished, GenreId, AuthorId
    from Books
    join Authors on Authorid=Authors.id
    where Books.id=bookid;
END //


--editing an existing book//
drop procedure editbook;//
create procedure editbook (in bid int, btitle VARCHAR(255), afname VARCHAR(255), alname VARCHAR (255), pyear INT, bgenreid INT)
begin
	
    declare aid int;
    
    if exists(select 1 from Authors where FirstName = afname and Lastname = alname) then
        select id into aid
        from Authors
        where FirstName = afname and Lastname = alname;

    else
        INSERT INTO Authors (FirstName, LastName)
        VALUES (afname, alname);
        
        select id into aid
	    from Authors
        where FirstName = afname and Lastname = alname;
    end if;
    
    UPDATE Books
    SET Title = btitle, AuthorId = aid, YearPublished=pyear, GenreId=bgenreid
    WHERE id=bid;

END //

--deleting a book from the database
--and also deleting the author if they have no other books in the database//
drop procedure delbook;//
create procedure delbook (in bid int)
begin

    declare aid int;

    select AuthorId into aid
    from Books
    where id=bid;

    delete from Reviews
    where BookId=bid;

	delete from Books
    WHERE id=bid;

    if not exists(select 1 from Books where AuthorId=aid) then
        delete from Authors
        where id=aid;
    end if;

END //

drop procedure findisbn;//
create procedure findisbn (in isbnum VARCHAR(255))
begin
    select Books.id, Title, ISBN, Authors.FirstName, Authors.LastName, YearPublished, GenreId, AuthorId
    from Books
    join Authors on Authorid=Authors.id
    where Books.ISBN=isbnum;
END //


drop procedure getreviews;//
create procedure getreviews (in book int)
begin
    select id, Date, ReviewerName, Stars, Review
    from Reviews
    where BookId = book
    order by Date desc;
end //

drop procedure submitreview;//
create procedure submitreview (in bid int, aname VARCHAR(255), rating INT, reviewtxt VARCHAR(1000))
begin
	
    declare timenow DATETIME;
    set timenow = NOW();
    
    if exists(select 1 from Books where id = bid) then
        INSERT INTO Reviews (BookId, ReviewerName, Stars, Review, Date)
        VALUES (bid, aname, rating, reviewtxt, timenow);
    end if;

END //


drop procedure getreview;//
create procedure getreview (in revid int)
begin
    select id, BookId, Date, ReviewerName, Stars, Review
    from Reviews
    where id=revid
    order by Date desc;
end //

drop procedure delreview;//
create procedure delreview (in revid int)
begin
    delete from Reviews
    where id=revid;
end //


drop procedure editreview;//
create procedure editreview (in rid int, rname VARCHAR(255), rating INT, rtext VARCHAR(255))
begin
	
    UPDATE Reviews
    SET ReviewerName = rname, Stars = rating, Review=rtext
    WHERE id=rid;

END //




drop procedure getauthor;//
create procedure getauthor (in aid int)
begin
    select * from Authors
    where id=aid;
end //


drop procedure authorbooks;//
create procedure authorbooks (in aid int)
begin
    select * from booklist
    where authid=aid
    order by Title asc;
end //

drop procedure editauthor;//
create procedure editauthor (in aid int, fname VARCHAR(255), lname VARCHAR(255))
begin
	
    UPDATE Authors
    SET FirstName = fname, LastName = lname
    WHERE id=aid;

END //






drop procedure addlib;//
create procedure addlib (in bname VARCHAR(255), street VARCHAR(255), icity VARCHAR(255), istate VARCHAR(255), zip VARCHAR(255))
begin
	
    declare aid int;

    insert into Addresses (StreetAddr, City, State, ZipCode)
    values (street, icity, istate, zip);

    SELECT LAST_INSERT_ID() into aid;

    INSERT INTO Libraries (BranchName, AddressId)
    values (bname, aid);

END //

drop procedure getlib;//
create procedure getlib (in lid int)
begin
    select * from libraryaddrs
    where id=lid;
end //

drop procedure liblist;//
create procedure liblist ()
begin
    select * from libraryaddrs;
end //


drop procedure libbooklist;//
create procedure libbooklist (in lid int)
begin
    select * from librarybooks
    where LibraryId=lid;
end //


drop procedure addlibcp;//
create procedure addlibcp (in bid int, lid int)
begin
    insert into LibraryCopies (BookId, LibraryId, Available)
    values (bid, lid, True);
end //


drop procedure getlibcp;//
create procedure getlibcp (in cid int)
begin
    select * from LibraryCopies
    where id=cid;
end //

drop procedure dellibcp;//
create procedure dellibcp (in cid int)
begin
    delete from LibraryCopies
    where id=cid;
end //


drop procedure toggleavail;//
create procedure toggleavail (in cid int)
begin
	
    declare avail tinyint;
    select Available into avail
    from LibraryCopies
    where id=cid;
    
    if avail then
        UPDATE LibraryCopies
        SET Available=False
        WHERE id=cid;
    else
        UPDATE LibraryCopies
        SET Available=True
        WHERE id=cid;
    end if;

END //


drop procedure editlib;//
create procedure editlib (in lid int, bname VARCHAR(255), street VARCHAR(255), icity VARCHAR(255), istate VARCHAR(255), zip VARCHAR(255))
begin
	
    declare aid int;

    select AddressId into aid
    from Libraries 
    where id=lid;

    update Addresses
    set StreetAddr=street, City=icity, State=istate, ZipCode=zip
    where id=aid;
    
    update Libraries 
    set BranchName=bname
    where id=lid;

END //


drop procedure dellib;//
create procedure dellib (in lid int)
begin
	    
    delete from Libraries 
    where id=lid;

END //




drop procedure addstore;//
create procedure addstore (in sname VARCHAR(255), street VARCHAR(255), icity VARCHAR(255), istate VARCHAR(255), zip VARCHAR(255))
begin
	
    declare aid int;
    set aid = 0;

    select id into aid
    from Addresses 
    where StreetAddr=street and City=icity and State=istate and ZipCode=zip;

    if aid=0 then
        insert into Addresses (StreetAddr, City, State, ZipCode)
        values (street, icity, istate, zip);

        SELECT LAST_INSERT_ID() into aid;
    end if;
    

    INSERT INTO Bookstores (Name, AddressId)
    values (sname, aid);

END //

drop procedure getstore;//
create procedure getstore (in sid int)
begin
    select * from storeaddrs
    where id=sid;
end //

drop procedure storelist;//
create procedure storelist ()
begin
    select * from storeaddrs;
end //

drop procedure storebooklist;//
create procedure storebooklist (in bid int)
begin
    select * from storebooks
    where BookstoreId=bid;
end //

drop procedure getstorecp;//
create procedure getstorecp (in cid int)
begin
    select * from StoreCopies
    where id=cid;
end //


drop procedure addstorecp;//
create procedure addstorecp (in bid int, bsid int, price float)
begin
    insert into StoreCopies (BookId, BookstoreId, Price)
    values (bid, bsid, Price);
end //

drop procedure delstorecp;//
create procedure delstorecp (in cid int)
begin
    delete from StoreCopies
    where id=cid;
end //

drop procedure editstore;//
create procedure editstore (in bid int, bname VARCHAR(255), street VARCHAR(255), icity VARCHAR(255), istate VARCHAR(255), zip VARCHAR(255))
begin
	
    declare aid int;

    select AddressId into aid
    from Bookstores 
    where id=bid;

    update Addresses
    set StreetAddr=street, City=icity, State=istate, ZipCode=zip
    where id=aid;
    
    update Bookstores 
    set Name=bname
    where id=bid;

END //

drop procedure delstore;//
create procedure delstore (in bid int)
begin
	    
    delete from Bookstores
    where id=bid;

END //


drop procedure search;//
create procedure search ()
begin
    select * from booklist;
end //


--	call addbook (9781250313195, 'Gideon the Ninth', 'Tamsyn', 'Muir', 2019, 2)
--	call addbook ('978-1-982185-82-4', "I'm Glad my Mom Died", 'Jenette', 'McCurdy', 2022, 4)//

    --declare aid int;
    --set aid = 0;

    --select id into aid
    --from Addresses 
    --where StreetAddr=street and City=icity and State=istate and ZipCode=zip;

    --if aid=0 then//


--DELIMITER ;

