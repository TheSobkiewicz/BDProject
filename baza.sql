
CREATE TABLE proj.Stanowisko (
                id_rola Serial NOT NULL,
                nazwa VARCHAR NOT NULL,
                wyplata INTEGER NOT NULL,
                CONSTRAINT stanowisko_pk PRIMARY KEY (id_rola)
);


CREATE TABLE proj.Pracownicy (
                id_pracownik Serial NOT NULL,
                nazwisko VARCHAR NOT NULL,
                imie VARCHAR NOT NULL,
                data_urodzenia DATE NOT NULL,
                id_rola INTEGER NOT NULL,
                CONSTRAINT pracownicy_pk PRIMARY KEY (id_pracownik)
);


CREATE TABLE proj.Kategoria (
                id_kategoria Serial NOT NULL,
                nazwa VARCHAR NOT NULL,
                CONSTRAINT kategoria_pk PRIMARY KEY (id_kategoria)
);


CREATE TABLE proj.Wydawnictwo (
                id_wydawnictwo Serial NOT NULL,
                nazwa VARCHAR NOT NULL,
                CONSTRAINT wydawnictwo_pk PRIMARY KEY (id_wydawnictwo)
);


CREATE TABLE proj.Autor (
                id_autor Serial NOT NULL,
                imie VARCHAR NOT NULL,
                nazwisko VARCHAR NOT NULL,
                CONSTRAINT autor_pk PRIMARY KEY (id_autor)
);


CREATE TABLE proj.Ksiazka (
                id_ksiazka Serial NOT NULL,
                tytul VARCHAR NOT NULL,
                rok_wydania VARCHAR NOT NULL,
                opis VARCHAR NOT NULL,
                id_kategoria INTEGER NOT NULL,
                id_autor INTEGER NOT NULL,
                id_wydawnictwo INTEGER NOT NULL,
                CONSTRAINT ksiazka_pk PRIMARY KEY (id_ksiazka)
);


CREATE TABLE proj.Czytelnicy (
                id_czytelnik Serial NOT NULL,
                imie VARCHAR NOT NULL,
                nazwisko VARCHAR NOT NULL,
                telefon VARCHAR NOT NULL,
                data_urodzenia DATE NOT NULL,
                CONSTRAINT czytelnicy_pk PRIMARY KEY (id_czytelnik)
);


CREATE TABLE proj.Kara (
                id_kara Serial NOT NULL,
                nazwa VARCHAR(255) NOT NULL,
                kwota INTEGER NOT NULL,
                id_czytelnik INTEGER NOT NULL,
                CONSTRAINT kara_pk PRIMARY KEY (id_kara)
);


CREATE TABLE proj.Wypozyczenia (
                id_wypozyczenie Serial NOT NULL,
                data_wypozyczenia DATE NOT NULL,
                data_oddania DATE NOT NULL,
                id_ksiazka INTEGER NOT NULL,
                id_czytelnik INTEGER NOT NULL,
                id_pracownik_wypozyczenie INTEGER NOT NULL,
                CONSTRAINT wypozyczenia_pk PRIMARY KEY (id_wypozyczenie)
);


ALTER TABLE proj.Pracownicy ADD CONSTRAINT stanowisko_pracownicy_fk
FOREIGN KEY (id_rola)
REFERENCES proj.Stanowisko (id_rola)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj.Wypozyczenia ADD CONSTRAINT pracownicy_wypozyczenia_fk
FOREIGN KEY (id_pracownik_wypozyczenie)
REFERENCES proj.Pracownicy (id_pracownik)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;



ALTER TABLE proj.Ksiazka ADD CONSTRAINT kategoria_ksiazka_fk
FOREIGN KEY (id_kategoria)
REFERENCES proj.Kategoria (id_kategoria)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj.Ksiazka ADD CONSTRAINT wydawnictwo_ksiazka_fk
FOREIGN KEY (id_wydawnictwo)
REFERENCES proj.Wydawnictwo (id_wydawnictwo)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj.Ksiazka ADD CONSTRAINT autor_ksiazka_fk
FOREIGN KEY (id_autor)
REFERENCES proj.Autor (id_autor)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj.Wypozyczenia ADD CONSTRAINT ksiazka_wypozyczenia_fk
FOREIGN KEY (id_ksiazka)
REFERENCES proj.Ksiazka (id_ksiazka)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj.Wypozyczenia ADD CONSTRAINT czytelnicy_wypozyczenia_fk
FOREIGN KEY (id_czytelnik)
REFERENCES proj.Czytelnicy (id_czytelnik)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj.Kara ADD CONSTRAINT czytelnicy_kara_fk
FOREIGN KEY (id_czytelnik)
REFERENCES proj.Czytelnicy (id_czytelnik)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;
--------------------------------------------------------------------------------------------------------------------------------
CREATE or Replace VIEW zobacz_kare AS
SELECT Kara.id_kara, Kara.nazwa, Kara.kwota, CONCAT(Czytelnicy.imie , ' ' , Czytelnicy.nazwisko ) 
FROM proj.Kara
INNER JOIN proj.Czytelnicy 
ON kara.id_czytelnik=Czytelnicy.id_czytelnik;
----------------------------------------------------------------
CREATE or Replace VIEW zobacz_pracownika AS
SELECT pracownicy.id_pracownik, pracownicy.imie, pracownicy.nazwisko,pracownicy.data_urodzenia, stanowisko.nazwa
FROM proj.pracownicy
INNER JOIN proj.stanowisko 
ON stanowisko.id_rola=pracownicy.id_rola;
----------------------------------------------------------------
CREATE or Replace VIEW zobacz_ksiazke AS
SELECT Ksiazka.id_ksiazka,Ksiazka.tytul, Ksiazka.rok_wydania, Ksiazka.opis, Kategoria.nazwa, CONCAT(autor.imie , ' ' , autor.nazwisko ), Wydawnictwo.nazwa as wydawnictwo
FROM proj.ksiazka
INNER JOIN proj.Wydawnictwo 
ON Ksiazka.id_wydawnictwo=Wydawnictwo.id_wydawnictwo
INNER JOIN proj.autor 
ON Ksiazka.id_autor=autor.id_autor
INNER JOIN proj.kategoria 
ON Ksiazka.id_kategoria=kategoria.id_kategoria;
----------------------------------------------------------------
CREATE or Replace VIEW zobacz_wypozyczenie AS
SELECT wypozyczenia.id_wypozyczenie,wypozyczenia.data_wypozyczenia, wypozyczenia.data_oddania, Ksiazka.tytul, CONCAT(Czytelnicy.imie , ' ' , Czytelnicy.nazwisko ) as czytelnik, CONCAT(pracownicy.imie , ' ' , pracownicy.nazwisko ) as pracownik
FROM proj.wypozyczenia
INNER JOIN proj.Ksiazka 
ON Ksiazka.id_ksiazka=wypozyczenia.id_ksiazka
INNER JOIN proj.Czytelnicy 
ON czytelnicy.id_czytelnik=wypozyczenia.id_czytelnik
INNER JOIN proj.pracownicy 
ON pracownicy.id_pracownik=wypozyczenia.id_pracownik_wypozyczenie;
----------------------------------------------------------------
CREATE or Replace function ksiazki_autora(id integer) Returns TABLE
(
    id_ksiazka INTEGER,
    tytul VARCHAR,
    rok_wydania VARCHAR,
    opis VARCHAR,
    nazwa VARCHAR,
    autor VARCHAR,
    wydawnictwo varchar
)
AS
$func$
SELECT Ksiazka.id_ksiazka,Ksiazka.tytul, Ksiazka.rok_wydania, Ksiazka.opis, Kategoria.nazwa, CONCAT(autor.imie , ' ' , autor.nazwisko ), Wydawnictwo.nazwa as wydawnictwo
FROM proj.ksiazka
INNER JOIN proj.Wydawnictwo 
ON Ksiazka.id_wydawnictwo=Wydawnictwo.id_wydawnictwo
INNER JOIN proj.autor 
ON Ksiazka.id_autor=autor.id_autor
INNER JOIN proj.kategoria 
ON Ksiazka.id_kategoria=kategoria.id_kategoria
where Ksiazka.id_autor = id
$func$ LANGUAGE sql;
----------------------------------------------------------------
CREATE or Replace function ksiazki_wydawnictwo(id integer) Returns TABLE
(
    id_ksiazka INTEGER,
    tytul VARCHAR,
    rok_wydania VARCHAR,
    opis VARCHAR,
    nazwa VARCHAR,
    autor VARCHAR,
    wydawnictwo varchar
)
AS
$func$
SELECT Ksiazka.id_ksiazka,Ksiazka.tytul, Ksiazka.rok_wydania, Ksiazka.opis, Kategoria.nazwa, CONCAT(autor.imie , ' ' , autor.nazwisko ), Wydawnictwo.nazwa as wydawnictwo
FROM proj.ksiazka
INNER JOIN proj.Wydawnictwo 
ON Ksiazka.id_wydawnictwo=Wydawnictwo.id_wydawnictwo
INNER JOIN proj.autor 
ON Ksiazka.id_autor=autor.id_autor
INNER JOIN proj.kategoria 
ON Ksiazka.id_kategoria=kategoria.id_kategoria
where Ksiazka.id_wydawnictwo = id
$func$ LANGUAGE sql;
----------------------------------------------------------------
CREATE or Replace function ksiazki_kategoria(id integer) Returns TABLE
(
    id_ksiazka INTEGER,
    tytul VARCHAR,
    rok_wydania VARCHAR,
    opis VARCHAR,
    nazwa VARCHAR,
    autor VARCHAR,
    wydawnictwo varchar
)
AS
$func$
SELECT Ksiazka.id_ksiazka,Ksiazka.tytul, Ksiazka.rok_wydania, Ksiazka.opis, Kategoria.nazwa, CONCAT(autor.imie , ' ' , autor.nazwisko ), Wydawnictwo.nazwa as wydawnictwo
FROM proj.ksiazka
INNER JOIN proj.Wydawnictwo 
ON Ksiazka.id_wydawnictwo=Wydawnictwo.id_wydawnictwo
INNER JOIN proj.autor 
ON Ksiazka.id_autor=autor.id_autor
INNER JOIN proj.kategoria 
ON Ksiazka.id_kategoria=kategoria.id_kategoria
where Ksiazka.id_kategoria = id
$func$ LANGUAGE sql;
----------------------------------------------------------------
CREATE or Replace function wypozyczenia_pracownik(id integer) Returns TABLE
(
    id_wypozyczenie INTEGER,
    data_wypozyczenia DATE,
    data_oddania DATE,
    tytul VARCHAR,
    czytelnik VARCHAR,
    pracownik VARCHAR
)
AS
$func$
SELECT wypozyczenia.id_wypozyczenie, wypozyczenia.data_wypozyczenia, wypozyczenia.data_oddania, Ksiazka.tytul, CONCAT(Czytelnicy.imie , ' ' , Czytelnicy.nazwisko ) as czytelnik, CONCAT(pracownicy.imie , ' ' , pracownicy.nazwisko ) as pracownik
FROM proj.wypozyczenia
INNER JOIN proj.Ksiazka 
ON Ksiazka.id_ksiazka=wypozyczenia.id_ksiazka
INNER JOIN proj.Czytelnicy 
ON czytelnicy.id_czytelnik=wypozyczenia.id_czytelnik
INNER JOIN proj.pracownicy 
ON pracownicy.id_pracownik=wypozyczenia.id_pracownik_wypozyczenie
where pracownicy.id_pracownik = id

$func$ LANGUAGE sql;
----------------------------------------------------------------
CREATE or Replace function rola_pracownicy(id integer) Returns TABLE
(
    id_pracownik INTEGER,
    imie VARCHAR,
    nazwisko VARCHAR,
    urodziny DATE,
    stanowisko VARCHAR
)
AS
$func$
SELECT pracownicy.id_pracownik, pracownicy.imie, pracownicy.nazwisko,pracownicy.data_urodzenia, stanowisko.nazwa
FROM proj.pracownicy
INNER JOIN proj.stanowisko 
ON stanowisko.id_rola=pracownicy.id_rola
where pracownicy.id_rola=id
$func$ LANGUAGE sql;
----------------------------------------------------------------
CREATE or Replace VIEW podsumowanie_uzytkownika AS
SELECT czytelnicy.id_czytelnik, czytelnicy.imie, czytelnicy.nazwisko, czytelnicy.telefon, czytelnicy.data_urodzenia, SUM(kara.kwota), COUNT(wypozyczenia.id_wypozyczenie)
FROM proj.czytelnicy
left JOIN proj.kara 
ON kara.id_czytelnik=czytelnicy.id_czytelnik
left JOIN proj.wypozyczenia 
ON czytelnicy.id_czytelnik=wypozyczenia.id_czytelnik
group by czytelnicy.id_czytelnik, czytelnicy.imie, czytelnicy.nazwisko,czytelnicy.telefon, czytelnicy.data_urodzenia;
----------------------------------------------------------------
CREATE or Replace VIEW wolne_ksiazki AS
SELECT  Ksiazka.id_ksiazka, Ksiazka.tytul
FROM proj.Ksiazka
Left JOIN proj.wypozyczenia 
ON Ksiazka.id_ksiazka=wypozyczenia.id_ksiazka
where wypozyczenia.id_ksiazka is null;