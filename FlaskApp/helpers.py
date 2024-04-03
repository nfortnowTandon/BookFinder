def listbooks():
    #cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    conn = mysql.connection
    cursor = conn.cursor()
    cursor.callproc('booklist', [])
    list=cursor.fetchall()
    return list;
