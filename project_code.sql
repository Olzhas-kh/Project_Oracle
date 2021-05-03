Cursor: 1

SET SERVEROUTPUT ON;
declare 
    cursor book_genre(v_genre books.categories%TYPE) is 
        select title, authors, average_rating 
        from books
        where categories = v_genre;
        
    v_title books.title%TYPE;
    v_authors books.authors%TYPE;
    v_average_rating books.average_rating%TYPE;
begin
    open book_genre('History');
    loop
    fetch book_genre into v_title, v_authors,  v_average_rating;
    exit when book_genre%notfound;
    
    DBMS_OUTPUT.PUT_LINE('Categorie is History; ' || '    Title is ' || v_title || ';           Author is ' || v_authors || ';             Avegare rating is ' || v_average_rating);
    end loop;  
    close book_genre;
end;




					Cursor: 2
SET SERVEROUTPUT ON;
declare 
    cursor avg_rating is 
        select average_rating, title, authors, published_year
        from books
        where average_rating <= (select avg(average_rating) from books);
    v_lowest books.average_rating%TYPE;
    v_title books.title%TYPE;
    v_authors books.authors%TYPE;
    v_published_year books.published_year%TYPE;
begin
    open avg_rating;
    loop
    fetch avg_rating into v_lowest,v_title, v_authors,  v_published_year;
    exit when avg_rating%notfound;
    
    DBMS_OUTPUT.PUT_LINE('lowest ratings is: ' || v_lowest || ';    Title is ' || v_title || ';           Author is ' || v_authors || ';             Published year is ' || v_published_year);
    end loop;  
    close avg_rating;
end;



					Cursor: 3
SET SERVEROUTPUT ON;
declare 
    cursor page_number is 
        select num_pages, title, authors
        from books
        where num_pages >= 500;
    v_page_num books.num_pages%TYPE;
    v_title books.title%TYPE;
    v_authors books.authors%TYPE;
begin
    open page_number;
    loop
    fetch page_number into v_page_num,v_title, v_authors;
    exit when page_number%notfound;
    
    DBMS_OUTPUT.PUT_LINE('A book that is more than 500 pages: ' || '    Title is: ' || v_title || ';           Author is: ' || v_authors || ';     Pages is: ' || v_page_num);
    end loop;  
    close page_number;
end;



					Cursor: 4
SET SERVEROUTPUT ON;
declare 
    cursor descript is 
        select isbn13, title,subtitle, authors
        from books
        where authors = 'Georgette Heyer';
    v_isbn13 books.isbn13%TYPE;
    v_subtitle books.subtitle%TYPE;
    v_title books.title%TYPE;
    v_authors books.authors%TYPE;
begin
    open descript;
    loop
    fetch descript into v_isbn13,v_title, v_subtitle,v_authors;
    exit when descript%notfound;
    
    DBMS_OUTPUT.PUT_LINE('Books by the author Georgette Heyer: ' || '       ISBN13 is: '|| v_isbn13||'    Title is: ' || v_title || 'Subtitle is: '|| v_subtitle || ';           Author is: ' || v_authors);
    end loop;  
    close descript;
end;


				



						• Create derived columns - 1
ALTER TABLE books
ADD (
    rating AS (
            CASE 
                WHEN average_rating <3 THEN 'Low' 
                WHEN average_rating <4 and average_rating>=3  THEN 'Medium'
                WHEN average_rating >=4 and average_rating<=5 THEN 'High'
            END)
);

ALTER TABLE books
DROP COLUMN rating;





						• Create derived columns - 2
ALTER TABLE books
ADD (
    types_of_books AS (
            CASE 
                WHEN published_year <2000 THEN 'Old' 
                WHEN published_year >=2000 THEN 'New'
            END)
);

ALTER TABLE books
DROP COLUMN types_of_books;




						


					
					Dynamic_sql-3
SET SERVEROUTPUT ON;
DECLARE
    v_select     VARCHAR2 (150);
    v_int     NUMBER;
BEGIN
    
    v_select:= 'SELECT count (categories) FROM books WHERE categories = ''History''';
    EXECUTE IMMEDIATE v_select INTO v_int;
    DBMS_OUTPUT.PUT_LINE ('Total count is: '||v_int);

END;






					Triger-1
SET SERVEROUTPUT ON;
CREATE OR REPLACE TRIGGER CheckYear
BEFORE
INSERT OR UPDATE ON books
FOR EACH ROW
BEGIN
	IF :new.Published_year<=1950 THEN
		raise_application_error(-20001, 'Book release times should not be lower than 1950');
	END IF;
END;

SET SERVEROUTPUT ON;
begin 
UPDATE books set published_year=1945 where title='Gilead';
end;





					Trigger-2
SET SERVEROUTPUT ON; 

CREATE TABLE Action (
      table_name    VARCHAR2(255),
      action VARCHAR2(10),
      by_user    VARCHAR2(30),
      v_date DATE
);

CREATE OR REPLACE TRIGGER update_trg
    AFTER UPDATE  ON books
    FOR EACH ROW    

BEGIN

   
   INSERT INTO action (table_name, action, by_user, v_date)
   VALUES('books', 'UPDATE', USER, SYSDATE);
END;


UPDATE
   books
SET
   average_rating = 4
WHERE
   title ='I Am that';
   
   select*from action;



					Trigger-3
SET SERVEROUTPUT ON; 

CREATE TABLE Action (
      table_name    VARCHAR2(255),
      action VARCHAR2(10),
      by_user    VARCHAR2(30),
      v_date DATE
);

CREATE OR REPLACE TRIGGER delete_trg
    AFTER delete  ON books
    FOR EACH ROW    

BEGIN

   
   INSERT INTO action (table_name, action, by_user, v_date)
   VALUES('books', 'DELETE', USER, SYSDATE);
END;

DELETE FROM books
WHERE title = 'Tropic of Cancer';
   
   select*from action;

					


					Package-1, Procedure -1 , Function -3

SET SERVEROUTPUT ON; 
CREATE OR REPLACE PACKAGE book_pkg IS
function How_many_years_ago(v_title in varchar) return number;
procedure user_search(p_title in books.authors%TYPE,
    v_title out books.title%TYPE,
    vv_authors out books.authors%TYPE,
    v_categories out books.categories%TYPE,
    v_description out books.description%TYPE);
end book_pkg;

SET SERVEROUTPUT ON; 
CREATE OR REPLACE PACKAGE BODY book_pkg IS
    function how_many_years_ago(v_title in varchar)
    return number is
    v_count number;
    begin select (2021- published_year) 
    into v_count from books 
    where title =v_title;
    return v_count;
    end how_many_years_ago;
    
    PROCEDURE user_search(
    p_title in books.authors%TYPE,
    v_title out books.title%TYPE,
    vv_authors out books.authors%TYPE,
    v_categories out books.categories%TYPE,
    v_description out books.description%TYPE
)

as

BEGIN
    select title,authors,categories,description 
    into v_title,vv_authors,v_categories,v_description
    from books
    where title= p_title;
    
EXCEPTION WHEN NO_DATA_FOUND 
    THEN DBMS_OUTPUT.PUT_LINE('No data for this: ' || p_title);
    
    
END user_search;
    end book_pkg;


SET SERVEROUTPUT ON; 
begin
DBMS_OUTPUT.PUT_LINE('This book was published ' || book_pkg.how_many_years_ago('Spares') || ' years ago');
end;

SET SERVEROUTPUT ON;    
DECLARE
    v_title books.title%TYPE;
    vv_authors books.authors%TYPE;
    v_categories books.categories%TYPE;
    v_description books.description%TYPE;

BEGIN
book_pkg.user_search('A Quick Bite', v_title, vv_authors,v_categories,v_description );
DBMS_OUTPUT.PUT_LINE( 'Title: ' || v_title);
DBMS_OUTPUT.PUT_LINE('Author: ' || vv_authors);
DBMS_OUTPUT.PUT_LINE('Categories: ' || v_categories);
DBMS_OUTPUT.PUT_LINE('Description: ' || v_description);


END;





						Package-2                                Procedure-2, collections -1 , dynamic sql -1;                       Procedure-4, collections -2 , dynamic sql -2 

SET SERVEROUTPUT ON; 
CREATE OR REPLACE PACKAGE book_pkg_2 IS
PROCEDURE 
popular_books (
   table_in    IN VARCHAR2,
   column_in   IN VARCHAR2,
   where_in    IN VARCHAR2);
PROCEDURE 
old_books(
   table_in    IN VARCHAR2,
   column_in   IN VARCHAR2,
   where_in    IN VARCHAR2
   );   
   
end book_pkg_2;


SET SERVEROUTPUT ON; 
CREATE OR REPLACE PACKAGE BODY book_pkg_2 IS
    PROCEDURE 
popular_books (
   table_in    IN VARCHAR2,
   column_in   IN VARCHAR2,
   where_in    IN VARCHAR2)
IS
   TYPE bookss IS TABLE OF varchar2(255);

   v_books   bookss;
BEGIN
   EXECUTE IMMEDIATE
         'SELECT '
      || column_in
      || ' FROM '
      || table_in
      || ' WHERE '
      || where_in
      BULK COLLECT INTO v_books;

   FOR i IN 1 .. v_books.COUNT
   LOOP
      DBMS_OUTPUT.put_line 
      (v_books (i));
   END LOOP;
END;
    
    PROCEDURE 
old_books(
   table_in    IN VARCHAR2,
   column_in   IN VARCHAR2,
   where_in    IN VARCHAR2
   )
IS
   TYPE booktar IS TABLE OF number;

   v_books   booktar;
BEGIN
   EXECUTE IMMEDIATE
         'SELECT '
      || column_in
      || ' FROM '
      || table_in
      || ' WHERE '
      || where_in
      BULK COLLECT INTO v_books;

   FOR i IN 1 .. v_books.COUNT
   LOOP
      DBMS_OUTPUT.put_line('old books year ' || v_books (i));
   END LOOP;
END;
    end book_pkg_2;



SET SERVEROUTPUT ON; 
BEGIN
   book_pkg_2.old_books (
      'books',
      'published_year',
      'types_of_books = ''Old''
      order by published_year asc'
    );
END;

SET SERVEROUTPUT ON; 
BEGIN
   book_pkg_2.popular_books (
      'books',
      'title',
      'published_year = ''2004'' 
       order by average_rating desc');
END;







