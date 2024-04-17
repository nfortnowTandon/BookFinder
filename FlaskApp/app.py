#flask app created with tutorial from https://www.geeksforgeeks.org/mysql-database-files/#

from ast import Try
from flask import Flask, render_template, json, request, redirect, url_for
from flask_mysqldb import MySQL
import MySQLdb
import re

app = Flask(__name__)
app.app_context().push()
#mysql = MySQL()

app.config["MYSQL_HOST"]="localhost"
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = ''
app.config['MYSQL_DB'] = 'BookFinder'
#app.config['MYSQL_DATABASE_HOST'] = 'localhost'

#mysql.init_app(app)
mysql = MySQL(app)

#conn = mysql.connection
#cursor = conn.cursor(MySQLdb.cursors.DictCursor)

def init():
    #with open('initialize.sql', 'r') as f:
    #    cursor = mysql.connection.cursor()
    #    procfile = f.read()
    #    #procs = procfile.split('//|;')
    #    queries = procfile.split(';')
    #    for q in queries:
    #        try:
    #            cursor.execute(q)
    #        except (MySQLdb.Error, MySQLdb.Warning) as e:
    #            print(e)

    with open('procedures.sql', 'r') as f:
        cursor = mysql.connection.cursor()
        procfile = f.read()
        #procs = procfile.split('//|;')
        procs = procfile.split('//')
        for p in procs:
            try:
                cursor.execute(p)
            except (MySQLdb.Error, MySQLdb.Warning) as e:
                print(e)

    with open('views.sql', 'r') as f:
        cursor = mysql.connection.cursor()
        viewfile = f.read()
        #procs = procfile.split('//|;')
        views = viewfile.split(';')
        for v in views:
            try:
                cursor.execute(v)
            except (MySQLdb.Error, MySQLdb.Warning) as e:
                print(e)
        mysql.connection.commit()
        cursor.close()


#HELPER FUNCTIONS
def listbooks():
    #cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor = mysql.connection.cursor()
    cursor.callproc('booklistproc', [])
    list=cursor.fetchall()
    #mysql.connection.commit()
    cursor.close()
    return list;

def getbook(id):
    #cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor = mysql.connection.cursor()
    cursor.callproc('findbook', [id])
    data = cursor.fetchone()
    print(data)
    #mysql.connection.commit()
    cursor.close()
    return data;

def getgenres(selid):
    #cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    conn = mysql.connection
    cursor = conn.cursor()
    cursor.callproc('getgenres', [selid])
    data = cursor.fetchall()
    #mysql.connection.commit()
    cursor.close()
    return data;

def getreviews(book):
    #cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor = mysql.connection.cursor()
    cursor.callproc('getreviews', [book])
    data=cursor.fetchall()
    #mysql.connection.commit()
    cursor.close()
    return data;

def getreview(revid):
    #cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor = mysql.connection.cursor()
    cursor.callproc('getreview', [revid])
    data=cursor.fetchone()
    #mysql.connection.commit()
    cursor.close()
    return data;

def getauthor(id):
    #cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor = mysql.connection.cursor()
    cursor.callproc('getauthor', [id])
    data = cursor.fetchone()
    print(data)
    #mysql.connection.commit()
    cursor.close()
    return data;

def authbooklist(id):
    #cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor = mysql.connection.cursor()
    cursor.callproc('authorbooks', [id])
    list=cursor.fetchall()
    #mysql.connection.commit()
    cursor.close()
    return list;

def getlib(id):
    cursor = mysql.connection.cursor()
    cursor.callproc('getlib', [id])
    data = cursor.fetchone()
    print(data)
    #mysql.connection.commit()
    cursor.close()
    return data;

def getstore(id):
    cursor = mysql.connection.cursor()
    cursor.callproc('getstore', [id])
    data = cursor.fetchone()
    print(data)
    #mysql.connection.commit()
    cursor.close()
    return data;

#END HELPER FUNCTIONS






@app.route("/")
def main():
    return render_template('index.html')

@app.route("/booklist")
def list():
    mode = request.args.get('mode')
    if mode == 'del':
        msg = "Book successfully deleted!"
    elif mode == 'delf':
        msg = "Failed to delete book, please try again or contact administrators"
    elif mode == 'edit':
        msg = "Book successfully updated!"
    elif mode == 'editf':
        msg = "Failed to edit book, please try again or contact administrators"
    else:
        msg = "Welcome to our book database :)"
    return render_template('booklist.html', msg=msg, list=listbooks())

@app.route("/search")
def search():
    return render_template('search.html')





@app.route("/addbook", methods=['GET'])
def addbook():
    genres = getgenres(0)
    return render_template('addbook.html', genres=genres)

@app.route("/addbook", methods=['POST'])
def submitbook():
    # read the posted values from the UI
    title = request.form['title']
    isbn = request.form['isbn']
    afname = request.form['afname']
    alname = request.form['alname']
    year = request.form['year']
    genre = request.form['genre']

    

    #validate we have all the values
    if not (title and isbn and afname and alname and year and genre!=0):
        msg = "Please enter all required fields"
        return render_template('addbook.html', msg=msg)
    else:
        #cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        #cursor.execute('SELECT * FROM Books WHERE ISBN = % s', [isbn])
        conn = mysql.connection
        cursor = conn.cursor()
        cursor.callproc('findisbn', [isbn])
        book = cursor.fetchone()
        cursor.close()
        if book:
            msg = "Book already in database"
            return render_template('addbook.html', msg=msg)


            #return json.dumps({'html':'<span>Book Already in Database</span>'})
        else:
            #cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
            conn = mysql.connection
            cursor = conn.cursor()
            try:
                cursor.callproc('addbook', [isbn, title, afname, alname, year, genre])
            except (MySQLdb.Error, MySQLdb.Warning) as e:
                msg=""
                print(e)
            else:
                msg = "Book successfully added!"
                mysql.connection.commit()
            cursor.close()
            return render_template('addbook.html', msg=msg)





@app.route("/editbook", methods=['GET'])
def editbook():
    msg=""
    book = request.args.get('book')
    mode = request.args.get('mode')
    if mode == 'add':
        msg = "Please enter all required fields"
    data = getbook(book)
    genres = getgenres(data[6])
    return render_template('editbook.html', data=data, genres=genres, msg=msg)

@app.route("/editbook", methods=['POST'])
def submitbookedit():
    # read the posted values from the UI
    title = request.form['title']
    afname = request.form['afname']
    alname = request.form['alname']
    year = request.form['year']
    genre = request.form['genre']
    id = request.args.get('book')

    conn = mysql.connection
    cursor = conn.cursor()

    #validate we have all the values
    if not (title and afname and alname and year and genre!=0):
        #return render_template('editbook.html', msg=msg)
        return redirect(f'/editbook?mode=add&book={id}')

    else:
        try:
            cursor.callproc('editbook', [id, title, afname, alname, year, genre])
        except (MySQLdb.Error, MySQLdb.Warning) as e:
            msg=""
            print(e)
            cursor.close()
            mode = "editf"
        else:
            mode="edit"
            mysql.connection.commit()
    cursor.close()
    return redirect(f'/booklist?mode={mode}')
        #return redirect('/booklist?mode=edit')


@app.route("/delbook", methods=['GET'])
def delbook():
    # read the posted values from the UI
    id = request.args.get('book')

    conn = mysql.connection
    cursor = conn.cursor()
    try:
        cursor.callproc('delbook', [id])
    except (MySQLdb.Error, MySQLdb.Warning) as e:
        mode='delf'
        print(e)
    else:
        mode='del'
        mysql.connection.commit()
    cursor.close()
    #return render_template('booklist.html', msg=msg, list=listbooks())
    return redirect(f'/booklist?mode={mode}')



# review page
@app.route("/review", methods=['GET'])
def reviewpage():
    #msg=""
    book = request.args.get('book')
    #mode = request.args.get('mode')
    #if mode == 'add':
    #    msg = "Please enter all required fields"
    data = getbook(book)
    reviews = getreviews(book)
    return render_template('review.html', data=data, reviews=reviews)

@app.route("/review", methods=['POST'])
def submitreview():
    print("made it here!")
    # read the posted values from the UI
    book = request.args.get('book')
    name = request.form['name']
    stars = request.form['rating']
    review = request.form['review']
    print(f'{book} {name}: {stars} stars, "{review}"')
    #date = request.form['afname']

    conn = mysql.connection
    cursor = conn.cursor()

    #validate we have all the values
    if not (name and book and stars!=0):
        #return render_template('editbook.html', msg=msg)
        return redirect(f'/review?book={book}')

    else:
        try:
            cursor.callproc('submitreview', [book, name, stars, review])
        except (MySQLdb.Error, MySQLdb.Warning) as e:
            msg=""
            print(e)
            cursor.close()
            #mode = "editf"
        else:
            #mode="edit"
            mysql.connection.commit()
    cursor.close()
    return redirect(f'/review?book={book}')
        #return redirect('/booklist?mode=edit')




# edit review page
@app.route("/editreview", methods=['GET', 'POST'])
def editreview():
    msg=""
    id = request.args.get('review')

    data = getreview(id)
    book = getbook(data[1])
    bid = book[0]

    if (request.method == 'GET'):
        return render_template('editreview.html', data=data, book=book)

    else:
        print("made it here!")
        # read the posted values from the UI
        name = request.form['name']
        stars = request.form['rating']
        review = request.form['review']
        print(f'{bid}, {name}, {stars} stars, "{review}"')
        #date = request.form['afname']

        conn = mysql.connection
        cursor = conn.cursor()
 
        #validate we have all the values
        if not (name and book and stars!=0):
            #return render_template('editbook.html', msg=msg)
            return render_template('editreview.html', data=reviewdata, book=book, msg="please enter all required fields")

        else:
            try:
                cursor.callproc('editreview', [id, name, stars, review])
            except (MySQLdb.Error, MySQLdb.Warning) as e:
                msg="error: try again"
                print(e)
                cursor.close()
                return render_template('editreview.html', data=reviewdata, book=book, msg=msg)
                #mode = "editf"
            else:
                #mode="edit"
                mysql.connection.commit()
        cursor.close()
        return redirect(f'/review?book={bid}')
            #return redirect('/booklist?mode=edit')


@app.route("/delreview", methods=['GET'])
def delreview():
    # read the posted values from the UI
    id = request.args.get('review')
    data = getreview(id)
    book = getbook(data[1])
    bid = book[0]


    conn = mysql.connection
    cursor = conn.cursor()
    try:
        cursor.callproc('delreview', [id])
    except (MySQLdb.Error, MySQLdb.Warning) as e:
        print(e)
    else:
        mysql.connection.commit()
    cursor.close()
    #return render_template('booklist.html', msg=msg, list=listbooks())
    return redirect(f'/review?book={bid}')




# author page
@app.route("/author", methods=['GET', 'POST'])
def authorpage():
    #msg=""
    id = request.args.get('id')
    author = getauthor(id)
    booklist = authbooklist(id)

    if (request.method == 'GET'):
        if author:
            return render_template('author.html', author=author, booklist=booklist)
        else:
            return render_template('error.html', msg="Author not found.")

    else:
        # read the posted values from the UI
        fname = request.form['fname']
        lname = request.form['lname']

        conn = mysql.connection
        cursor = conn.cursor()
 
        #validate we have all the values
        if not (fname and lname):
            #return render_template('editbook.html', msg=msg)
            return redirect(f'/author?id={id}')

        else:
            try:
                cursor.callproc('editauthor', [id, fname, lname])
            except (MySQLdb.Error, MySQLdb.Warning) as e:
                #msg="error: try again"
                print(e)
            else:
                #mode="edit"
                mysql.connection.commit()
        cursor.close()
        return redirect(f'/author?id={id}')
            #return redirect('/booklist?mode=edit')


# addlib
@app.route("/addlib", methods=['GET', 'POST'])
def addlib():
    msg=""
    id=0

    if (request.method == 'GET'):
        return render_template('addlib.html', msg=msg)

    else:
        # read the posted values from the UI
        bname = request.form['branchname']
        street = request.form['street']
        city = request.form['city']
        state = request.form['state']
        zip = request.form['zip']

        conn = mysql.connection
        cursor = conn.cursor()
 
        #validate we have all the values
        if not (bname and street and city and state and zip):
            msg= "please include all required fields"
            return render_template('addlib.html', msg=msg)


        else:
            try:
                cursor.callproc('addlib', [bname, street, city, state, zip])
            except (MySQLdb.Error, MySQLdb.Warning) as e:
                msg="error: try again"
                print(e)
                cursor.close()
                return render_template('addlib.html', msg=msg)

            else:
                #mode="edit"
                mysql.connection.commit()
                #print(conn.insert_id(), cursor.lastrowid)
                cursor.close()

                cursor = conn.cursor()
                cursor.execute('select LAST_INSERT_ID()')
                id = cursor.fetchone()[0]
                cursor.close()
                return redirect(f'/library?id={id}')
            #return redirect('/booklist?mode=edit')

@app.route("/library", methods=['GET', 'POST'])
def libpage():
    #msg=""
    id = request.args.get('id')
    library = getlib(id)
    #booklist = libbooklist(id)

    if (request.method == 'GET'):
        if library:
            return render_template('library.html', library=library)
        else:
            return render_template('error.html', msg="Library not found.")

    #else:
    #    # read the posted values from the UI
    #    fname = request.form['fname']
    #    lname = request.form['lname']

    #    conn = mysql.connection
    #    cursor = conn.cursor()
 
    #    #validate we have all the values
    #    if not (fname and lname):
    #        #return render_template('editbook.html', msg=msg)
    #        return redirect(f'/author?id={id}')

    #    else:
    #        try:
    #            cursor.callproc('editauthor', [id, fname, lname])
    #        except (MySQLdb.Error, MySQLdb.Warning) as e:
    #            #msg="error: try again"
    #            print(e)
    #        else:
    #            #mode="edit"
    #            mysql.connection.commit()
    #    cursor.close()
    #    return redirect(f'/author?id={id}')
    #        #return redirect('/booklist?mode=edit')
    #return render_template('library.html')


@app.route("/addstore", methods=['GET', 'POST'])
def addstore():
    msg=""
    id=0

    if (request.method == 'GET'):
        return render_template('addstore.html', msg=msg)

    else:
        # read the posted values from the UI
        sname = request.form['name']
        street = request.form['street']
        city = request.form['city']
        state = request.form['state']
        zip = request.form['zip']

        conn = mysql.connection
        cursor = conn.cursor()
 
        #validate we have all the values
        if not (sname and street and city and state and zip):
            msg= "please include all required fields"
            return render_template('addstore.html', msg=msg)


        else:
            try:
                cursor.callproc('addstore', [sname, street, city, state, zip])
            except (MySQLdb.Error, MySQLdb.Warning) as e:
                msg="error: try again"
                print(e)
                cursor.close()
                return render_template('addstore.html', msg=msg)

            else:
                mysql.connection.commit()
                cursor.close()

                cursor = conn.cursor()
                cursor.execute('select LAST_INSERT_ID()')
                id = cursor.fetchone()[0]
                cursor.close()
                return redirect(f'/bookstore?id={id}')

@app.route("/bookstore", methods=['GET', 'POST'])
def storepage():
    #msg=""
    id = request.args.get('id')
    store = getstore(id)
    #booklist = libbooklist(id)

    if (request.method == 'GET'):
        if store:
            return render_template('bookstore.html', store=store)
        else:
            return render_template('error.html', msg="Library not found.")







if __name__ == "__main__":
    init()
    app.run()

