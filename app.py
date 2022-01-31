import random
import os
import urllib.parse as up
import psycopg2

from flask import Flask, render_template, url_for, request, redirect

UserLabel = ["Imie", "Nazwisko", "Telefon", "Data urodzin"]
AuthorLabel = ["Imie", "Nazwisko"]
BookLabel = ["Tytuł", "Data Wydania", "Opis", "Kategoria", "Autor", "Wydawnictwo"]
WorkerLabel = ["Imie", "Nazwisko", "Data Urodzenia", "Stanowisko"]
JobLabel = ["Nazwa Stanowiska", "Wypłata"]
FineLabel = ["Nazwa", "Kwota", "Ukarany"]
ActionLabel = ["Data Wypożyczenia ", "Data Oddania", "Książka", "Czytelnik", "Pracownik"]
UserSummaryLabel = ["Imie", "Nazwisko", "Telefon", "Data urodzin","Suma kar", "Wypożyczone książki"]

insertDictionary = {"autor": "(imie, nazwisko)", "pracownicy": "( nazwisko, imie, data_urodzenia, id_rola )",
                    "kategoria": "(nazwa)", "wydawnictwo": "(nazwa)",
                    "ksiazka": "( tytul, rok_wydania, opis, id_kategoria, id_autor, id_wydawnictwo )",
                    "czytelnicy": "(imie, nazwisko, telefon,  data_urodzenia )",
                    "kara": "(nazwa , kwota, id_czytelnik)",
                    "wypozyczenia": "(data_wypozyczenia, data_oddania, id_ksiazka, id_czytelnik, id_pracownik_wypozyczenie)",
                    "stanowisko": "(nazwa, wyplata)"}

temp = [AuthorLabel, AuthorLabel]
tempID = [0, 1]
up.uses_netloc.append("postgres")
url = up.urlparse("postgres://fmscfxoc:HhPFitX4onbLKUeKVTowuVXdPdXO6nT7@hattie.db.elephantsql.com/fmscfxoc")

app = Flask(__name__)
app.secret_key = b'_5#y2L"F4Q8z\n\xec]124wagEG$@#%@/'
cytaty = {1: "cytat1.jpg", 2: "cytat2.jpg", 3: "cytat3.jpg", 4: "cytat4.jpg", 5: "cytat1.png", 6: "cytat2.png"}


def find_person(table):
    sql = f"""SELECT * from proj.{table} ;"""
    conn = psycopg2.connect(database=url.path[1:],
                            user=url.username,
                            password=url.password,
                            host=url.hostname,
                            port=url.port
                            )
    id = []
    name = []
    try:
        cur = conn.cursor()
        cur.execute(sql)
        values = cur.fetchall()
        for row in values:
            id.append(row[0])
            name.append(row[1] + " " + row[2])
        cur.close()
        return zip(name, id)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
    return


def delete_event(table, requested_id ,id):
    sql = f"""DELETE from proj.{table} where {requested_id} = {id} ;"""
    conn = psycopg2.connect(database=url.path[1:],
                            user=url.username,
                            password=url.password,
                            host=url.hostname,
                            port=url.port
                            )
    try:
        cur = conn.cursor()
        cur.execute(sql)
        conn.commit()
        cur.close()
        return
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
    return


def find_instance(table, is_view = False):
    if is_view:
        sql = f"""SELECT * from {table} ;"""
    else:
        sql = f"""SELECT * from proj.{table} ;"""
    conn = psycopg2.connect(database=url.path[1:],
                            user=url.username,
                            password=url.password,
                            host=url.hostname,
                            port=url.port
                            )
    id = []
    name = []
    try:
        cur = conn.cursor()
        cur.execute(sql)
        values = cur.fetchall()
        for row in values:
            id.append(row[0])
            name.append(row[1])
        cur.close()
        return zip(name, id)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
    return


def base_display(table, is_view=False):
    if is_view:
        sql = f"""SELECT * from {table} ;"""
    else:
        sql = f"""SELECT * from proj.{table} ;"""
    conn = psycopg2.connect(database=url.path[1:],
                            user=url.username,
                            password=url.password,
                            host=url.hostname,
                            port=url.port
                            )
    id = []
    name = []
    try:
        cur = conn.cursor()
        cur.execute(sql)
        values = cur.fetchall()
        for row in values:
            print(row)
            id.append(row[0])
            name.append(row[1:])
        cur.close()
        print(name, id)
        return zip(name, id)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
    return


def insert_data(table, values):
    sql = f"INSERT INTO proj.{table} {insertDictionary[table]} VALUES {values};"
    conn = psycopg2.connect(database=url.path[1:],
                            user=url.username,
                            password=url.password,
                            host=url.hostname,
                            port=url.port
                            )
    try:
        cur = conn.cursor()
        cur.execute(sql)
        conn.commit()
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()


@app.route('/')
def home():
    image_file = url_for('static', filename=cytaty[random.randint(1, 6)])
    return render_template('login.html', src=image_file)


@app.route('/authors')
def authors():
    return render_template('authors.html', title="Autorzy", labels=AuthorLabel, data=base_display("autor"))


@app.route('/authors/<id>')
def author_books(id):
    return render_template('books.html', title="Książki", labels=BookLabel, category=find_instance("kategoria"),
                           publisher=find_instance("wydawnictwo"), author=find_person("autor"),
                           data=base_display(f"ksiazki_autora({id})", True))
@app.route('/authors/<id>/<d>')
def author_returner(id,d):
    return redirect(request.referrer)
@app.route('/books')
def books():
    return render_template('books.html', title="Książki", labels=BookLabel, category=find_instance("kategoria"),
                           publisher=find_instance("wydawnictwo"), author=find_person("autor"),
                           data=base_display("zobacz_ksiazke", True))


@app.route('/books/<id>')
def ret(id):
    return redirect(request.referrer)



@app.route('/publishers')
def publishers():
    return render_template('publishers.html', title="Wydawnictwa", data=base_display("wydawnictwo"))


@app.route('/publishers/<id>')
def publishers_books(id):
    return render_template('books.html', title="Książki", labels=BookLabel, category=find_instance("kategoria"),
                           publisher=find_instance("wydawnictwo"), author=find_person("autor"),
                           data=base_display(f"ksiazki_wydawnictwo({id})", True))

@app.route('/publishers/<id>/<d>')
def publishers_books_return(id,d):
    return redirect(request.referrer)


@app.route('/category')
def category():
    return render_template('categories.html', title="Kategorie", data=base_display("kategoria"))


@app.route('/category/<id>')
def category_books(id):
    return render_template('books.html', title="Książki", labels=BookLabel, category=find_instance("kategoria"),
                           publisher=find_instance("wydawnictwo"), author=find_person("autor"),
                           data=base_display(f"ksiazki_kategoria({id})", True))
@app.route('/category/<id>/<d>')
def category_books_returner(id,d):
    return redirect(request.referrer)


@app.route('/readers')
def readers():
    return render_template('users.html', title="Czytelnicy", labels=UserLabel, data=base_display("czytelnicy"))

@app.route('/readers/<id>')
def readers_data(id):
    return render_template('users.html', title="Czytelnik", labels=UserSummaryLabel, data=base_display(f"podsumowanie_uzytkownika where id_czytelnik = {id}",True))
@app.route('/readers/<id>/<d>')
def ress(id,d):
    return redirect(request.referrer)

@app.route('/workers')
def workers():
    return render_template('workers.html', title="Pracownicy", labels=WorkerLabel, roles=find_instance("stanowisko"),
                           data=base_display("zobacz_pracownika", True))


@app.route('/workers/<id>')
def workers_jobs(id):
    return render_template('actions.html', title="Wypożyczenia", labels=ActionLabel, users=find_person("czytelnicy"),
                           workers=find_person("Pracownicy"), books=find_instance("ksiazka"),
                           data=base_display(f"wypozyczenia_pracownik({id})", True))
@app.route('/workers/<id>/<d>')
def workers_jobs_return(id,d):
    return redirect(f"/events/{id}")

@app.route('/jobs')
def jobs():
    return render_template('jobs.html', title="Stanowiska", labels=JobLabel, data=base_display("stanowisko"))


@app.route('/jobs/<id>')
def jobs_workers(id):
    return render_template('workers.html', title="Pracownicy", labels=WorkerLabel, roles=find_instance("stanowisko"),
                           data=base_display(f"rola_pracownicy({id})", True))
@app.route('/jobs/<id>/<d>')
def jobs_workers_returner(id,d):
    return redirect(f"/workers/{id}")

@app.route('/events')
def events():
    return render_template('actions.html', title="Wypożyczenia", labels=ActionLabel, users=find_person("czytelnicy"),
                           workers=find_person("Pracownicy"), books=find_instance("wolne_ksiazki",True),
                           data=base_display(f"zobacz_wypozyczenie", True))


@app.route('/events/<id>')
def delete(id):
    delete_event("wypozyczenia","id_wypozyczenie",id)
    return redirect(request.referrer)


@app.route('/fine')
def fine():
    return render_template('fine.html', title="Kary", labels=FineLabel, data=base_display("zobacz_kare", True),
                           users=find_person("czytelnicy"))

@app.route('/fine/<id>')
def fine_delete(id):
    delete_event("kara","id_kara", id)
    return redirect(request.referrer)
@app.route('/authors/add', methods=['POST'])
def authors_add():
    name = request.form['name']
    surname = request.form['surname']
    print((name, surname))
    insert_data("autor", (name, surname))
    return redirect(request.referrer)


@app.route('/books/add', methods=['POST'])
def books_add():
    name = request.form['name']
    year = request.form['year']
    description = request.form['description']
    category = request.form['category']
    author = request.form['author']
    publisher = request.form['publisher']
    insert_data("ksiazka", (name, year, description, category, author, publisher))
    return redirect(request.referrer)


@app.route('/publishers/add', methods=['POST'])
def publishers_add():
    name = request.form['name']
    insert_data("wydawnictwo", "('" + name + "')")
    return redirect(request.referrer)


@app.route('/category/add', methods=['POST'])
def category_add():
    name = request.form['name']
    insert_data("kategoria", "('" + name + "')")
    return redirect(request.referrer)


@app.route('/readers/add', methods=['POST'])
def readers_add():
    name = request.form['name']
    surname = request.form['surname']
    tel = request.form['phone']
    date = request.form['year']
    insert_data("czytelnicy", (name, surname, tel, date))
    return redirect(request.referrer)


@app.route('/workers/add', methods=['POST'])
def workers_add():
    name = request.form['name']
    surname = request.form['surname']
    date = request.form['year']
    role = request.form['role']
    insert_data("pracownicy", (surname, name, date, role))
    return redirect(request.referrer)


@app.route('/jobs/add', methods=['POST'])
def jobs_add():
    name = request.form['name']
    salary = request.form['salary']
    insert_data("stanowisko", (name, salary))
    return redirect(request.referrer)


@app.route('/events/add', methods=['POST'])
def events_add():
    year1 = request.form['year1']
    year = request.form['year']
    book = request.form['book']
    user = request.form['user']
    worker = request.form['worker']
    if year1 < year:
        year1,year = year, year1
    insert_data("wypozyczenia", (year, year1, book, user, worker))
    return redirect(request.referrer)


@app.route('/fine/add', methods=['POST'])
def fine_add():
    name = request.form['name']
    fine1 = request.form['fine']
    user = request.form['user']
    insert_data("kara", (name, fine1, user))
    return redirect(request.referrer)


if __name__ == '__main__':
    app.run()
