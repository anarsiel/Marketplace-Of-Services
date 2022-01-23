-- эти две сроки можешь удалить к хуям собачьим
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

create table City
(
    id bigserial not null,
    Name varchar(64) not null,

    primary key (id)
    -- unique (Name) 
);

create table Museum
(
    id bigserial not null,
    Name varchar(64) not null,
    Description varchar(1024),
    CityId bigint not null,

    primary key (id),
    foreign key (CityId) references City (id)
    -- unique (Name) 
);

create table Category
(
    id bigserial not null,
    Name varchar(64) not null,
    Description varchar(1024),

    primary key (id),
    unique (Name) 
);

create table Piece
(
    id bigserial not null,
    Name varchar(64) not null,
    Description varchar(1024),
    MuseumId bigint not null,
    CategoryId bigint not null,

    primary key (id),
    foreign key (MuseumId) references Museum (id),
    foreign key (CategoryId) references Category (id)
);


-- добавить название выставки в PDM
create table Exhibition
(
    id bigserial not null,
    Name varchar(64),
    Description varchar(1024),
    MuseumId bigint not null,
    CategoryId bigint not null,
    BeginDate date not null,
    EndDate date,
    -- мб надо сделать optional enddate (если выставка постоянная или временная но еще не закончилась или с неизвестными сроками)

    primary key (id),
    foreign key (MuseumId) references Museum (id),
    foreign key (CategoryId) references Category (id),
	
	check(BeginDate <= EndDate)
);

-- у тебя не может выходить два одинаковых FK (у тебя должно быть FK1 FK2 FK3 ... а не FK1 FK1 FK2 FK2)
create table Exhibited
(
    PieceId bigint not null,
    ExhibitionId bigint not null,

    primary key (PieceId, ExhibitionId),
    foreign key (PieceId) references Piece (id),
    foreign key (ExhibitionId) references Exhibition (id)
 	-- добавить триггер on insert
);

-- заменить тип id на bigint в PDM
create table Person
(
    id bigserial not null,
    Name varchar(64) not null,
    Bio varchar(1024),
    CityId bigint not null,

    primary key (id),
    foreign key (CityId) references City (id)
);

create table Review
(
    Text varchar(1024),
    Raiting int not null,
    VisitDate date not null, -- мб стоит сделать оптионал
    PieceId bigint not null,
    PersonId bigint not null, -- опечатка в PDM

    primary key (PieceId, PersonId),
    foreign key (PieceId) references Piece (id),
    foreign key (PersonId) references Person (id),

    check (VisitDate < Now()),
    check(Raiting between 1 and 5)

    -- СЛОЖНО: добавить триггер on insert - проверить что в VisitDate Кусок был где-то выставлен.
    -- мб стоит просто заменит на CreationDate
);

-- INDEXES

-- FK indexes for Museum, Piece, Exhibition, Exhibited, Person and Review
create index on Museum using hash (CityId);
create index on Piece using hash (MuseumId);
create index on Piece using hash (CategoryId);
create index on Exhibition using hash (MuseumId);
create index on Exhibition using hash (CategoryId);
create index on Exhibited using hash (PieceId);
create index on Exhibited using hash (ExhibitionId);
create index on Person using hash (CityId);
create index on Review using hash (PieceId);
create index on Review using hash (PersonId);

-- covering indexed for varchars and for joins
create unique index on City(id) include(Name);
create unique index on Museum(id) include(Name);
create unique index on Category(id) include(Name);
create unique index on Piece(id) include(Name);
create unique index on Person(id) include(Name);

-- for joins
create index on Exhibited using btree (PieceId, ExhibitionId);
create index on Exhibited using btree (ExhibitionId, PieceId);


-- Triggers (перенести в updates.sql)
create or replace function piece_on_exhibition()
returns trigger as
$$
begin
    if (select CategoryId
        from Piece
        where id = new.PieceId
    ) in (select CategoryId
        from Exhibition
        where id = new.ExhibitionId
    ) then return new;
    end if;

    raise exception 'Piece category must be equal to Exhibition category';
end
$$
language plpgsql;

create trigger insert_exhibited
  before insert
  on Exhibited
  for each row
execute function piece_on_exhibition();

create or replace function visit_time_valid()
returns trigger as
$$
begin
    if exists (select BeginDate, EndDate
        from Piece natural join Exhibited natural join Exhibition
        where id = new.PieceId 
            and BeginDate <= new.VisitDate
            and new.VisitDate <= EndDate
    ) then return new;
    end if;

    raise exception 'VisitDate must be in range for BeginDate to EndDate';
end
$$
language plpgsql;

create trigger insert_review
  before insert
  on Review
  for each row
execute function visit_time_valid();