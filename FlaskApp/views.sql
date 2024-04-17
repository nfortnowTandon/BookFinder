drop view avgstars;
create view avgstars as
select BookId, AVG(stars) as stars
    from Reviews
    group by BookId;

drop view booklist;
CREATE VIEW booklist as
select Books.id, Title, concat(Authors.FirstName,' ',Authors.LastName) as Author, YearPublished, Genres.Name as Genre, ISBN, Authors.id as authId, 
    (case when avgstars.stars is null then 0 else avgstars.stars end) as Stars
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

drop view storeaddrs;
create view storeaddrs as
select Bookstores.id as id, Name, StreetAddr, City, State, ZipCode
    from Bookstores
    join Addresses on Bookstores.AddressId=Addresses.id
    order by Name ASC;