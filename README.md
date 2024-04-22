# BookFinder
## BookFinder Web App (for databases class)

To run:
1. start/restart your mysql service and make sure you can log in as root:
```
sudo service mysql restart
mysql -u root
```

3. In the FlaskApp folder, call app.py:
```
python3 app.py
```

4. In your browser, navigate to http://127.0.0.1:5000

5. Now you can go to the booklist and add a new book, edit it, and delete it!

                <!--{% for cp in lcopies %}
    <tr>
        <td>
            <p>{{ cp[0] }}</p>
        </td>
    </tr>
        {% for i in range len(cp)-1 %}

        <tr>
            <td>
                <p>{{ cp[i+1][0] }}</p>
            </td>
        </tr>
        {% endfor %}
    {% endfor %}-->