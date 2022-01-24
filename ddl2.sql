-- эти две сроки можешь удалить к хуям собачьим
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

create table City
(
    id bigserial not null,
    Name varchar(256) not null,

    primary key (id)
    -- unique (Name) 
);

create table Museum
(
    id bigserial not null,
    Name varchar(256) not null,
    Description text,
    CityId bigint not null,

    primary key (id),
    foreign key (CityId) references City (id)
    -- unique (Name) 
);

create table Category
(
    id bigserial not null,
    Name varchar(256) not null,
    Description text,

    primary key (id),
    unique (Name) 
);

create table Piece
(
    id bigserial not null,
    Name varchar(256) not null,
    Description text,
    MuseumId bigint not null,
    CategoryId bigint not null,

    primary key (id),
    foreign key (MuseumId) references Museum (id),
    foreign key (CategoryId) references Category (id)
);


create table Exhibition
(
    id bigserial not null,
    Name varchar(256),
    Description text,
    MuseumId bigint not null,
    CategoryId bigint not null,
    -- BeginDate date not null,
    -- EndDate date,

    primary key (id),
    unique(Name, MuseumId),
    foreign key (MuseumId) references Museum (id),
    foreign key (CategoryId) references Category (id)
);

create table Iteration
(
    id bigserial not null,
    exhibitionId bigint not null,
    BeginDate date not null,
    EndDate date,

    primary key (id),
    check(BeginDate <= EndDate)

    -- написать триггер на проверку того что все итерации не пересекаются для каждой конрктеной выставки в музее
);

create table Exhibited
(
    PieceId bigint not null,
    IterationId bigint not null,

    primary key (PieceId, IterationId),
    foreign key (PieceId) references Piece (id),
    foreign key (IterationId) references Iteration (id)
    -- добавить триггер on insert
);

create table Person
(
    id bigserial not null,
    Name varchar(256) not null,
    Bio text,
    CityId bigint not null,

    primary key (id),
    foreign key (CityId) references City (id)
);

create table Review
(
    Text text,
    Raiting int not null,
    VisitDate date not null, -- мб стоит сделать оптионал
    IterationId bigint not null,
    PersonId bigint not null,

    primary key (IterationId, PersonId),
    foreign key (IterationId) references Iteration (id),
    foreign key (PersonId) references Person (id),

    check (VisitDate < Now()),
    check(Raiting between 1 and 5)
);

-- INDEXES

-- FK indexes for Museum, Piece, Exhibition, Exhibited, Person and Review
create index on Museum using hash (CityId);
create index on Piece using hash (MuseumId);
create index on Piece using hash (CategoryId);
create index on Exhibition using hash (MuseumId);
create index on Exhibition using hash (CategoryId);
create index on Exhibited using hash (PieceId);
create index on Exhibited using hash (IterationId);
create index on Person using hash (CityId);
create index on Review using hash (IterationId);
create index on Review using hash (PersonId);

-- covering indexed for varchars and for joins
create unique index on City(id) include(Name);
create unique index on Museum(id) include(Name);
create unique index on Category(id) include(Name);
create unique index on Piece(id) include(Name);
create unique index on Person(id) include(Name);

-- for joins
create index on Exhibited using btree (PieceId, IterationId);
create index on Exhibited using btree (IterationId, PieceId);

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
        where id in (select ExhibitionId from Iteration where id = new.IterationId)
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
    if exists (select *
        from Iteration
        where id = new.IterationId
            and BeginDate <= new.VisitDate
            and (EndDate is null or new.VisitDate <= EndDate)
    ) then return new;
    end if;

    raise exception 'VisitDate must be in range from BeginDate to EndDate for at least one Exhibition Iteration';
end
$$
language plpgsql;

create trigger insert_review
  before insert
  on Review
  for each row
execute function visit_time_valid();

create or replace function no_date_intersections()
returns trigger as
$$
begin
    if exists (select *
        from Iteration
        where ExhibitionId = new.ExhibitionId
            and (
                BeginDate <= new.BeginDate and (EndDate is null or new.BeginDate <= EndDate)
                or (new.BeginDate <= BeginDate and (new.EndDate is null or BeginDate <= new.EndDate))
            )
    ) then raise exception 'VisitDate must be in range from BeginDate to EndDate for at least one Exhibition Iteration';
    end if;

    return new;
end
$$
language plpgsql;

create trigger insert_iteration
  before insert
  on Iteration
  for each row
execute function no_date_intersections();



