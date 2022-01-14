create type person_type as enum ('expert', 'client');
create type chat_status as enum ('not_started', 'opened', 'closed');
create type order_status as enum ('free', 'taken', 'finished');

create table ServicesGroup
(
    ServicesGroupId serial not null,
    Name varchar(50) not null,

    primary key (ServicesGroupId),
    unique (Name)
);

create table Countries
(
    CountryId serial not null,
    Name varchar(60) not null,

    primary key (CountryId),
    unique (Name)
);

create table LatLons
(
    LatLonId serial not null,
    Lat float not null,
    Lon float not null,

    check(Lat between 0 and 90),
    check(Lon between 0 and 180),
    primary key (LatLonId)
);

create table Services
(
    ServiceId serial not null,
    Name varchar(20) not null,
    ServicesGroupId int not null,

    primary key (ServiceId),
    foreign key (ServicesGroupId) references ServicesGroup (ServicesGroupId),
    unique (Name)
);

create table Persons
(
    PersonId serial not null,
    Name varchar(80) not null,
    Raiting float not null,
    PersonType person_type not null,

    primary key (PersonId),
    check(Raiting between 1 and 5)
);

create table Reviews
(
    ReviewId serial not null,
    Text varchar(200),
    Raiting int not null,
    AuthorId int not null,
    RecipientId int not null,

    primary key (ReviewId),
    foreign key (AuthorId) references Persons (PersonId),
    foreign key (RecipientId) references Persons (PersonId),
    check(AuthorId <> RecipientId)
);

create table Regions
(
    RegionId serial not null,
    Name varchar(100) not null,
    LatLonId int not null,
    CountryId int not null,

    primary key (RegionId),
    foreign key (LatLonId) references LatLons (LatLonId),
    foreign key (CountryId) references Countries (CountryId),
    unique(LatLonId)
);

create table Orders
(
    OrderId serial not null,
    ExpertRating float,
    CreationDate date not null,
    AcceptanceDate date not null,
    CompletionDate date not null,
    ClientId int not null,
    ServiceId int not null,
    OrderStatus order_status not null,

    primary key (OrderId),
    foreign key (ClientId) references Persons (PersonId),
    foreign key (ServiceId) references Services (ServiceId)
);

create table ExpertsOrders
(
    OrderId int not null,
    PersonId int not null,

    primary key (OrderId),
    foreign key (OrderId) references Orders (OrderId),
    foreign key (PersonId) references Persons (PersonId)
);

create table VideoCalls
(
    VideocallId serial not null,
    StartDate date not null,
    EndDate date not null,
    PersonId1 int not null,
    PersonId2 int not null,
    OrderId int not null,

    primary key (VideocallId),
    foreign key (PersonId1) references Persons (PersonId),
    foreign key (PersonId2) references Persons (PersonId),
    foreign key (OrderId) references Orders (OrderId),
    check(StartDate < EndDate)
);

create table Chats
(
    ChatId serial not null,
    PersonId1 int not null,
    PersonId2 int not null,
    OrderId int not null,
    ChatStatus chat_status not null,

    primary key (ChatId),
    foreign key (PersonId1) references Persons (PersonId),
    foreign key (PersonId2) references Persons (PersonId),
    foreign key (OrderId) references Orders (OrderId)
);

create table Messages
(
    MessageId serial not null,
    Text varchar(200) not null,
    SendingDate date,
    ChatId int not null,
    SenderId int not null,

    primary key (MessageId),
    foreign key (ChatId) references Chats (ChatId),
    foreign key (SenderId) references Persons (PersonId)
);

create table RegionsOrders
(
    OrderId int not null,
    RegionId int not null,

    primary key (OrderId),
    foreign key (OrderId) references Orders (OrderId),
    foreign key (RegionId) references Regions (RegionId)
);

create table LatLonsOrders
(
    OrderId int not null,
    LatLonId int not null,

    primary key (OrderId),
    foreign key (OrderId) references Orders (OrderId),
    foreign key (LatLonId) references LatLons (LatLonId)
);

create table Files
(
    FileId serial not null,
    Location varchar(90) not null,
    OrderId int not null,

    primary key (FileId),
    foreign key (OrderId) references Orders (OrderId),
    unique (Location)
);

-- Foreign keys
create index on Services using hash (ServicesGroupId);
create index on Reviews using hash (AuthorId);
create index on Reviews using hash (RecipientId);
create index on Regions using hash (LatLonId);
create index on Regions using hash (CountryId);
create index on Orders using hash (ClientId);
create index on Orders using hash (ServiceId);
create index on ExpertsOrders using hash (OrderId);
create index on ExpertsOrders using hash (PersonId);
create index on VideoCalls using hash (PersonId1);
create index on VideoCalls using hash (PersonId2);
create index on VideoCalls using hash (OrderId);
create index on Chats using hash (PersonId1);
create index on Chats using hash (PersonId2);
create index on Chats using hash (OrderId);
create index on Messages using hash (ChatId);
create index on Messages using hash (SenderId);
create index on RegionsOrders using hash (OrderId);
create index on RegionsOrders using hash (RegionId);
create index on LatLonsOrders using hash (OrderId);
create index on LatLonsOrders using hash (LatLonId);
create index on Files using hash (OrderId);

-- Names and Strings
create unique index on ServicesGroup using btree (Name);
create unique index on Countries using btree (Name);
create unique index on Services using btree (Name);
create index on Persons using btree (Name);
create index on Regions using btree (Name);
create unique index on Files using btree (Location);

-- Raiting queries
create index on Persons using btree (Raiting);
create index on Reviews using btree (Raiting);
create index on Orders using btree (ExpertRating);

---- Table join
create index on ExpertsOrders using btree (PersonId, OrderId);
create index on RegionsOrders using btree (RegionId, OrderId);