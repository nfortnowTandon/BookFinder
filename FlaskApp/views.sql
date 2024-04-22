drop view avgstars;
create view avgstars as
select BookId, AVG(stars) as stars
    from Reviews
    group by BookId;

drop view booklist;
CREATE VIEW booklist as
select Books.id as id, Title, concat(Authors.FirstName,' ',Authors.LastName) as Author, YearPublished, Genres.Name as Genre, ISBN, Authors.id as authId, 
    (case when avgstars.stars is null then 0 else avgstars.stars end) as Stars, Genres.id as GenreId
    from Books
    join Authors on Authorid=Authors.id
    join Genres on GenreId=Genres.id
    left outer join avgstars on Books.id=avgstars.BookId
    order by Authors.LastName,Title ASC;



drop view libraryaddrs;
create view libraryaddrs as
select Libraries.id as id, BranchName, StreetAddr, City, State, ZipCode
    from Libraries
    join Addresses on Libraries.AddressId=Addresses.id
    order by BranchName ASC;

drop view librarybooks;
create view librarybooks as
select LibraryCopies.id as id, BookId, LibraryId, Title, Author, YearPublished, Genre, ISBN, authId, Stars, Available
    from booklist 
    join LibraryCopies on booklist.id=BookId
    join Authors on authId=Authors.id
    order by Authors.LastName, Title ASC;

drop view librarycopies;
create view librarycopies as
select LibraryId, BranchName, concat(StreetAddr,', ',City,', ',State,', ',ZipCode) as Address, count(librarybooks.id) as cpnum, sum(Available) as avail
    from librarybooks
    join libraryaddrs on librarybooks.LibraryId=libraryaddrs.id
    order by BranchName, BookId asc;





drop view storeaddrs;
create view storeaddrs as
select Bookstores.id as id, Name, StreetAddr, City, State, ZipCode
    from Bookstores
    join Addresses on Bookstores.AddressId=Addresses.id
    order by Name ASC;

drop view storebooks;
create view storebooks as
select StoreCopies.id as id, BookId, BookstoreId, Title, Author, YearPublished, Genre, ISBN, authId, Stars, Price
    from booklist
    join StoreCopies on booklist.id=BookId
    join Authors on authId=Authors.id
    order by Authors.LastName, Title ASC;

drop view storecopies;
create view storecopies as
select storebooks.id as cpid, BookstoreId, Name as storename, concat(StreetAddr,', ',City,', ',State,', ',ZipCode) as Address, BookId, Title, Author, YearPublished, Genre, ISBN, authId, Stars, Price
    from storebooks
    join storeaddrs on storebooks.BookstoreId=storeaddrs.id
    order by storename, BookId asc;