#flask app created with tutorial from https://www.geeksforgeeks.org/mysql-database-files/#

from flask import Flask, render_template, json, request
from flask_mysqldb import MySQL
import MySQLdb.cursors
import re

app = Flask(__name__)
app.app_context().push()
mysql = MySQL()

app.config["MYSQL_HOST"]="127.0.0.1"
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = 'password'
app.config['MYSQL_DATABASE_DB'] = 'BookFinder'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'

mysql.init_app(app)

conn = mysql.connect()
cursor = conn.cursor()

with open('initialize.sql') as f:
    cursor.execute(f.read().decode('utf-8'), multi=True)

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

#@app.route('/api/signUp',methods=['POST'])
#def signUp():
#    # read the posted values from the UI
#    _name = request.form['inputName']
#    _email = request.form['inputEmail']
#    _password = request.form['inputPassword']
    # validate the received values
    #if _name and _email and _password:
    #    return json.dumps({'html':'<span>All fields good !!</span>'})
    #else:
    #    return json.dumps({'html':'<span>Enter the required fields</span>'})


if __name__ == "__main__":
    app.run()

