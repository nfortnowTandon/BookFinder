--DELIMITER //
-- here we are adding a new book
drop procedure addbook//
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

-- get all the genres and select one if it's selected
drop procedure getgenres//
create procedure getgenres (in gid INT)
begin
    select id, Name, isSelected(id,gid) as selected
    from Genres;
end //

-- list all books
drop procedure booklist//
create procedure booklist ()
begin
    select Books.id, Title, concat(Authors.FirstName,' ',Authors.LastName) as Author, YearPublished, Genres.Name as Genre, ISBN, Authors.id as authId
    from Books
    join Authors on Authorid=Authors.id
    join Genres on GenreId=Genres.id
    order by Authors.LastName,Title ASC;
END //

-- find an existing book
drop procedure findbook//
create procedure findbook (in bookid int)
begin
    select Books.id, Title, ISBN, Authors.FirstName, Authors.LastName, YearPublished, GenreId, AuthorId
    from Books
    join Authors on Authorid=Authors.id
    where Books.id=bookid;
END //

--editing an existing book
drop procedure editbook//
create procedure editbook (in bid int, btitle VARCHAR(255), afname VARCHAR(255), alname VARCHAR (255), pyear INT, bgenreid INT)
begin
	
    declare aid integer;
    
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

--	call addbook (9781250313195, 'Gideon the Ninth', 'Tamsyn', 'Muir', 2019, 2)
--	call addbook ('978-1-982185-82-4', "I'm Glad my Mom Died", 'Jenette', 'McCurdy', 2022, 4)//


--INSERT INTO Genres (id, Name) VALUES
--(1, 'Science Fiction'),
--(2, 'Fantasy'),
--(3, 'Romance'), 
--(4, 'Nonfiction')//


--DELIMITER ;