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
    with open('initialize.sql', 'r') as f:
        cursor = mysql.connection.cursor()
        procfile = f.read()
        #procs = procfile.split('//|;')
        queries = procfile.split(';')
        for q in queries:
            try:
                cursor.execute(q)
            except (MySQLdb.Error, MySQLdb.Warning) as e:
                print(e)

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

    with open('procedures.sql', 'r') as f:
        cursor = mysql.connection.cursor()
        viewfile = f.read()
        #procs = procfile.split('//|;')
        views = viewfile.split('//')
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













if __name__ == "__main__":
    init()
    app.run()

