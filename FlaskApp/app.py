#flask app created with tutorial from https://www.geeksforgeeks.org/mysql-database-files/#

from flask import Flask, render_template, json, request
from flask_mysqldb import MySQL
import MySQLdb.cursors
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

conn = mysql.connection
cursor = conn.cursor()

#with open('initialize.sql') as f:
#    cursor.execute(f.read().decode('utf-8'), multi=True)

#cursor.callproc('sp_createUser',(_name,_email,_hashed_password))

#data = cursor.fetchall()

#if len(data) is 0:
#    conn.commit()
#    return json.dumps({'message':'User created successfully !'})
#else:
#    return json.dumps({'error':str(data[0])})

@app.route("/")
def main():
    return render_template('index.html')

@app.route("/booklist")
def list():
    return render_template('booklist.html')

@app.route("/search")
def search():
    return render_template('search.html')

@app.route("/addbook", methods=['GET'])
def addbook():
    return render_template('addbook.html')

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
    if not (title and isbn and afname and alname and year and genre):
        return json.dumps({'html':'<span>Enter the required fields</span>'})
    else:
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute(
            'SELECT * FROM Books WHERE ISBN = % i', (isbn))
        book = cursor.fetchone()
        if book:
            return json.dumps({'html':'<span>Book Already in Database</span>'})
        else:
            #session['loggedin'] = True
            #session['id'] = account['id']
            #session['username'] = account['username']
            #msg = 'Logged in successfully !'
            #return render_template('index.html', msg=msg)
        else:
            msg = 'Incorrect username / password !'
    return render_template('login.html', msg=msg)

     #validate the received values
    if _name and _email and _password:

        
    else:
        

#@app.route('/api/signUp',methods=['POST'])
#def signUp():



if __name__ == "__main__":
    app.run()

