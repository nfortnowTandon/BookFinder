drop view booklist
CREATE VIEW booklist as
select Books.id, Title, concat(Authors.FirstName,' ',Authors.LastName) as Author, YearPublished, Genres.Name as Genre, ISBN, Authors.id as authId
    from Books
    join Authors on Authorid=Authors.id
    join Genres on GenreId=Genres.id
    order by Authors.LastName,Title ASC;