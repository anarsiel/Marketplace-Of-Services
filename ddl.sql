create type person_type as enum ('expert', 'client');
create type chat_status as enum ('opened', 'closed');
create type order_status as enum ('free', 'taken', 'complete');

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

    check(Lat between -90 and 90),
    check(Lon between -180 and 180),
    primary key (LatLonId)
);

create table Services
(
    ServiceId serial not null,
    Name varchar(50) not null,
    ServicesGroupId int not null,

    primary key (ServiceId),
    foreign key (ServicesGroupId) references ServicesGroup (ServicesGroupId),
    unique (Name)
);

create table Persons
(
    PersonId serial not null,
    Name varchar(80) not null,
    Raiting float DEFAULT 0 not null,
    PersonType person_type not null,

    primary key (PersonId),
    check(Raiting between 1 and 5 or Raiting = 0)
);

create table Reviews
(
    ReviewId serial not null,
    Text varchar(200),
    Raiting int not null,
    AuthorId int not null,
    RecipientId int not null,
    CreationTime timestamptz not null default now(),

    primary key (ReviewId),
    foreign key (AuthorId) references Persons (PersonId),
    foreign key (RecipientId) references Persons (PersonId),
    check(AuthorId <> RecipientId),
    check(Raiting between 1 and 5)
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
    Text varchar(500) not null,
    ExpertRating float,
    CreationTime timestamptz not null default now(),
    AcceptanceTime timestamptz,
    CompletionTime timestamptz,
    ClientId int not null,
    ServiceId int not null,
    OrderStatus order_status not null default 'free',

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
    StartTime timestamptz not null,
    EndTime timestamptz not null,
    PersonId1 int not null,
    PersonId2 int not null,

    primary key (VideocallId),
    foreign key (PersonId1) references Persons (PersonId),
    foreign key (PersonId2) references Persons (PersonId),
    check(StartTime < EndTime),
    check(EndTime < now())
);

create table Chats
(
    ChatId serial not null,
    PersonId1 int not null,
    PersonId2 int not null,
    ChatStatus chat_status not null default 'opened',

    primary key (ChatId),
    foreign key (PersonId1) references Persons (PersonId),
    foreign key (PersonId2) references Persons (PersonId)
);

create table Messages
(
    MessageId serial not null,
    Text varchar(200) not null,
    SendingTime timestamptz default now(),
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

-- 
-- Procedures
-- 

create procedure CreateOrder(_text varchar(500), _clientId int, _serviceId int)
AS $$ 
BEGIN 
    insert into Orders 
    	(Text, ClientId, ServiceId)
	values 
		(_text, _clientId, _serviceId);
END 
$$ LANGUAGE plpgsql;

create procedure TakeOrder(_orderId int, _expertId int)
AS $$ 
BEGIN 
    insert into ExpertsOrders 
    	(OrderId, PersonId)
	values 
		(_orderId, _expertId);

	update Orders
	set AcceptanceTime = now(), OrderStatus = 'taken'
	where OrderId = _orderId;
END 
$$ LANGUAGE plpgsql;

create procedure GiveUpOrder(_orderId int)
AS $$ 
BEGIN 
    delete from ExpertsOrders where OrderId = _orderId;

	update Orders
	set AcceptanceTime = null, OrderStatus = 'free'
	where OrderId = _orderId;
END 
$$ LANGUAGE plpgsql;

create procedure CompleteOrder(_orderId int)
AS $$ 
BEGIN 
	update Orders
	set AcceptanceTime = now(), OrderStatus = 'complete'
	where OrderId = _orderId;
END
$$ LANGUAGE plpgsql;


create procedure AddLatLonToOrder(_orderId int, _latLonId int)
AS $$ 
BEGIN 
	insert into LatLonsOrders(OrderId, LatLonId)
		values (_orderId, _latLonId);
END
$$ LANGUAGE plpgsql;

create procedure AddRegionToOrder(_orderId int, _regionId int)
AS $$ 
BEGIN 
	insert into RegionsOrders (OrderId, RegionId)
		values (_orderId, _regionId);
END
$$ LANGUAGE plpgsql;


create procedure AddExpertRatingToOrder(_orderId int, _expertRaiting float)
AS $$ 
BEGIN 
	update Orders
	set ExpertRating = _expertRaiting
	where OrderId = _orderId;
END
$$ LANGUAGE plpgsql;

create procedure CreateLatLon(_lat float, _lon float)
AS $$ 
BEGIN
	insert into LatLons (Lat, Lon)
		values (_lat, _lon);
END 
$$ LANGUAGE plpgsql;

create procedure CreateChat(_personId1 int, _personId2 int)
AS $$ 
BEGIN 
    insert into Chats 
    	(PersonId1, PersonId2)
	values 
		(_personId1, _personId2);
END 
$$ LANGUAGE plpgsql;

create procedure CloseChat(_chatId int)
AS $$ 
BEGIN 
    update Chats
	set chat_status = 'closed'
	where ChatId = _chatId;
END 
$$ LANGUAGE plpgsql;

create procedure SendMessage(_text varchar(200), _senderId int, _chatId int)
AS $$ 
BEGIN
	insert into Messages 
		(text, SenderId, ChatId)
	values 
		(_text, _senderId, _chatId);
END 
$$ LANGUAGE plpgsql;

-- 
--  Triggers
-- 

create or replace function person_from_chat()
returns trigger as
$$
begin
    if new.ChatId in (select ChatId
		from Chats
		where PersonId1 = new.SenderId or PersonId2 = new.SenderId
	) then return new;
    end if;
    raise exception 'Message sender does not belong to this chat';
end
$$
language plpgsql;

create trigger sendMessageTrigger
  before insert
  on Messages
  for each row
execute function person_from_chat();

create or replace function no_such_chat()
returns trigger as
$$
begin
    if exists (select ChatId
		from Chats
		where (PersonId1 = new.PersonId1 and PersonId2 = new.PersonId2) or (PersonId1 = new.PersonId2 and PersonId2 = new.PersonId1)
	) then raise exception 'These two people already have chat together';
    end if;
    return new;
end
$$
language plpgsql;

create or replace function person_is_expert()
returns trigger as
$$
begin
    if 'expert' in (select PersonType
		from Persons
		where PersonId = new.PersonId
	) then return new;
    end if;
    raise exception 'Only expert can take Order';
end
$$
language plpgsql;

create trigger takeOrderTrigger
  before insert
  on ExpertsOrders
  for each row
execute function person_is_expert();

create or replace function deleteBeforeOrder()
returns trigger as
$$
begin
    delete from ExpertsOrders
    where OrderId = old.orderId;

    delete from RegionsOrders
    where OrderId = old.orderId;

    delete from LatLonsOrders
    where OrderId = old.orderId;

    delete from Files
    where OrderId = old.orderId;

    return old;
end
$$
language plpgsql;

create trigger deleteOrderTrigger
  before delete
  on Orders
  for each row
execute function deleteBeforeOrder();

create or replace function deleteBeforePerson()
returns trigger as
$$
begin
    delete from Reviews
    where RecipientId = old.PersonId or AuthorId = old.PersonId;

    delete from Videocalls
    where PersonId1 = old.PersonId or PersonId2 = old.PersonId;

    delete from Chats
    where PersonId1 = old.PersonId or PersonId2 = old.PersonId;

    delete from Orders
    where ClientId = old.PersonId;

    delete from ExpertsOrders
    where PersonId = old.PersonId;

    return old;
end
$$
language plpgsql;

create trigger deletePersonTrigger
  before delete
  on Persons
  for each row
execute function deleteBeforePerson();

create or replace function deleteBeforeChat()
returns trigger as
$$
begin
    delete from Messages
    where ChatId = old.ChatId;

    return old;
end
$$
language plpgsql;

create trigger deleteChatTrigger
  before delete
  on Chats
  for each row
execute function deleteBeforeChat();

-- 
-- Indexes
-- 

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
create index on Chats using hash (PersonId1);
create index on Chats using hash (PersonId2);
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