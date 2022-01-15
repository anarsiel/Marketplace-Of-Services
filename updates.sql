-- 
-- Синтаксис:
-- _PersonId это аналог :PersonId из домашних заданий
-- 

--
-- insert (больше примеров см. data.sql)
--

-- создаем Человека
insert into Persons (Name, PersonType)
values (_name, _personType);

-- создаем LatLon
call CreateLatLon(_lat, _lot); 

-- создаем отзыв без текста
insert into Reviews (Raiting, AuthorId, RecipientId)
values (_raiting, _authorId, _recipientId);

-- создаем отзыв c текстом
insert into Reviews (Text, Raiting, AuthorId, RecipientId)
values (_text, _raiting, _authorId, _recipientId);

-- создаем задание
call CreateOrder(_textId, _clientId, _serviceId);

-- создаем чат
call createChat(_personId1, _personId2);

-- создаем сообщение
call sendMessage(_text, _senderId, _chatId);

-- создаем запись о видеозвонке
insert into VideoCalls (PersonId1, PersonId2, StartTime, EndTime)
values 
	(_PersonId1, _PersonId2, _StartTime, _EndTime);

-- 
-- updates
-- 

-- добавить регион в заказ
call AddRegionToOrder(_orderId, _regionId);


-- добавить в заказ геопозицию
call AddLatLonToOrder(_orderId, _latLonId);

-- добавить в заказ нижнюю границу рейтинга для исполнителя
call AddExpertRatingToOrder(_orderId, _expertRaiting);

-- Закрыть чат
сall CloseChat(_chatId)


-- 
-- deletes
-- 

-- удаление пользователя по заданному id
-- при помощи триггеров реализовано каскадированное удаление
delete from Persons
where PersonId = _personId;

-- удаление заказа по заданному id
-- при помощи триггеров реализовано каскадированное удаление
delete from Orders
where OrderId = _orderId;

-- удаление чата по заданному id
-- при помощи триггеров реализовано каскадированное удаление
delete from Chats
where ChatId = _chatId;