create table PersonTypes
(
    PersonTypeId serial not null,
    Name varchar(20) not null,

    primary key (PersonTypeId),
    unique (Name)
);

create table ServicesGroup
(
    ServicesGroupId serial not null,
    Name varchar(50) not null,

    primary key (ServicesGroupId),
    unique (Name)
);

create table ChatStatuses
(
    ChatStatusId serial not null,
    Name varchar(20) not null,

    primary key (ChatStatusId),
    unique (Name)
);

create table OrderStatuses
(
    OrderStatusId serial not null,
    Name varchar(20) not null,

    primary key (OrderStatusId),
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
    PersonTypeId int not null,

    primary key (PersonId),
    foreign key (PersonTypeId) references PersonTypes (PersonTypeId),
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
    OrderStatusId int not null,

    primary key (OrderId),
    foreign key (ClientId) references Persons (PersonId),
    foreign key (ServiceId) references Services (ServiceId),
    foreign key (OrderStatusId) references OrderStatuses (OrderStatusId)
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
    PersonId int not null,
    ClientId int not null,
    OrderId int not null,

    primary key (VideocallId),
    foreign key (PersonId) references Persons (PersonId),
    -- foreign key (ClientId) references Orders (ClientId),
    foreign key (OrderId) references Orders (OrderId),
    check(StartDate < EndDate)
);

create table Chats
(
    ChatId serial not null,
    PersonId int not null,
    ClientId int not null,
    OrderId int not null,
    ChatStatusId int not null,

    primary key (ChatId),
    foreign key (PersonId) references Persons (PersonId),
    -- foreign key (ClientId) references Orders (ClientId),
    foreign key (OrderId) references Orders (OrderId),
    foreign key (ChatStatusId) references ChatStatuses (ChatStatusId)
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
create index on Persons using hash (PersonTypeId);
create index on Reviews using hash (AuthorId);
create index on Reviews using hash (RecipientId);
create index on Regions using hash (LatLonId);
create index on Regions using hash (CountryId);
create index on Orders using hash (ClientId);
create index on Orders using hash (ServiceId);
create index on Orders using hash (OrderStatusId);
create index on ExpertsOrders using hash (OrderId);
create index on ExpertsOrders using hash (PersonId);
create index on VideoCalls using hash (PersonId);
create index on VideoCalls using hash (OrderId);
create index on Chats using hash (PersonId);
create index on Chats using hash (OrderId);
create index on Chats using hash (ChatStatusId);
create index on Messages using hash (ChatId);
create index on Messages using hash (SenderId);
create index on RegionsOrders using hash (OrderId);
create index on RegionsOrders using hash (RegionId);
create index on LatLonsOrders using hash (OrderId);
create index on LatLonsOrders using hash (LatLonId);
create index on Files using hash (OrderId);

-- Names and Strings
create unique index on PersonTypes using btree (Name);
create unique index on ServicesGroup using btree (Name);
create unique index on ChatStatuses using btree (Name);
create unique index on OrderStatuses using btree (Name);
create unique index on Countries using btree (Name);
create unique index on Services using btree (Name);
create index on Persons using btree (Name);
create index on Regions using btree (Name);
create unique index on Files using btree (Location);

-- Raiting queries
create index on Persons using btree (Rating);
create index on Reviews using btree (Rating);
create index on Reviews using btree (Rating);

---- Table join
create index on ExpertsOrders using btree (PersonId, OrderId);
create index on RegionsOrders using btree (RegionId, OrderId);