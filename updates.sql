-- 
-- Синтаксис:
-- _PersonId это аналог :PersonId из домашних заданий
-- 

--
-- insert
--

-- 1.1 
insert into Persons (Name, PersonType)
values (_name, _personType);

-- 1.2 
insert into Reviews (Raiting, AuthorId, RecipientId)
values (_raiting, _authorId, _recipientId);

-- 1.3 
insert into Reviews (Text, Raiting, AuthorId, RecipientId)
values (_text, _raiting, _authorId, _recipientId);

-- 1.4 
insert into VideoCalls (PersonId1, PersonId2, StartTime, EndTime)
values 
	(_PersonId1, _PersonId2, _StartTime, _EndTime);

-- 
-- deletes
-- 

-- 2.1 удаление пользователя по заданному id
-- при помощи триггеров реализовано каскадированное удаление
delete from Persons
where PersonId = _personId;

-- 2.2 удаление заказа по заданному id
-- при помощи триггеров реализовано каскадированное удаление
delete from Orders
where OrderId = _orderId;

-- 2.3 удаление чата по заданному id
-- при помощи триггеров реализовано каскадированное удаление
delete from Chats
where ChatId = _chatId;

-- 2.4 удаление чата по заданному id
-- при помощи триггеров реализовано каскадированное удаление
delete from Messages
where MessageId = _messageId;

-- 
-- Procedures
-- 

-- 3.1 CreateOrder
create procedure CreateOrder(_text varchar(500), _clientId int, _serviceId int)
AS $$ 
BEGIN 
    insert into Orders 
    	(Text, ClientId, ServiceId)
	values 
		(_text, _clientId, _serviceId);
END 
$$ LANGUAGE plpgsql;

-- 3.2 TakeOrder
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

-- 3.3 GiveUpOrder
create procedure GiveUpOrder(_orderId int)
AS $$ 
BEGIN 
    delete from ExpertsOrders where OrderId = _orderId;

	update Orders
	set AcceptanceTime = null, OrderStatus = 'free'
	where OrderId = _orderId;
END 
$$ LANGUAGE plpgsql;

-- 3.4 CompleteOrder
create procedure CompleteOrder(_orderId int)
AS $$ 
BEGIN 
	update Orders
	set AcceptanceTime = now(), OrderStatus = 'complete'
	where OrderId = _orderId;
END
$$ LANGUAGE plpgsql;

-- 3.5 AddLatLonToOrder
create procedure AddLatLonToOrder(_orderId int, _latLonId int)
AS $$ 
BEGIN 
	insert into LatLonsOrders(OrderId, LatLonId)
		values (_orderId, _latLonId);
END
$$ LANGUAGE plpgsql;

-- 3.6 AddRegionToOrder
create procedure AddRegionToOrder(_orderId int, _regionId int)
AS $$ 
BEGIN 
	insert into RegionsOrders (OrderId, RegionId)
		values (_orderId, _regionId);
END
$$ LANGUAGE plpgsql;

-- 3.7 AddExpertRatingToOrder
create procedure AddExpertRatingToOrder(_orderId int, _expertRaiting float)
AS $$ 
BEGIN 
	update Orders
	set ExpertRating = _expertRaiting
	where OrderId = _orderId;
END
$$ LANGUAGE plpgsql;

-- 3.8 CreateLatLon
create procedure CreateLatLon(_lat float, _lon float)
AS $$ 
BEGIN
	insert into LatLons (Lat, Lon)
		values (_lat, _lon);
END 
$$ LANGUAGE plpgsql;

-- 3.9 CreateChat
create procedure CreateChat(_personId1 int, _personId2 int)
AS $$ 
BEGIN 
    insert into Chats 
    	(PersonId1, PersonId2)
	values 
		(_personId1, _personId2);
END 
$$ LANGUAGE plpgsql;

-- 3.10 CloseChat
create procedure CloseChat(_chatId int)
AS $$ 
BEGIN 
    update Chats
	set chat_status = 'closed'
	where ChatId = _chatId;
END 
$$ LANGUAGE plpgsql;

-- 3.11 SendMessage
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