# BookFinder
## BookFinder Web App (for databases class)

To run:
1. start/restart your mysql service and make sure you can log in as root:
```
sudo service mysql restart
mysql -u root
```
2. If this is your first time running the app, make sure to uncomment the first part of the init() function to initialize the database.

3. In the FlaskApp folder, call app.py:
```
python3 app.py
```

4. In your browser, navigate to http://127.0.0.1:5000

5. The application should be running, and you can go to the search page to start by adding books to the database!