-- Получение по id пользователя всех заказов, которые он взялся исполнять
select OrderId
from ExpertsOrders
where PersonId = _PersonId;

-- Получение по id пользователя, всех созданных им заказов
select OrderId
from Orders
where ClientId = _PersonId;

-- Получение по id региона, всех cвободных в нем заказов
select OrderId
from Orders natural join RegionsOrder
where RegionId = _RegionId and OrderStatus = 'free';

-- Получение по id пользователя, всех типов заказов, за которые он брался
select distinct Name
from ExpertsOrders natural join Orders natural join Services
where PersonId = _PersonId;

-- Получение по id пользователя, статистики по всем оценкам о нем
select Raiting, count(ReviewId)
from Reviews
where RecipientId = _PersonId;
group by
	Raiting;

-- Получение статистики о колличестве заказов, по типу услуги
select ServiceId, count(OrderId)
from Orders
group by
	ServiceId;

-- Получение статистики о колличестве заказов, по региону
select RegionId, count(OrderId)
from RegionsOrders
group by
	RegionId;

-- Получение файлов по номеру заказа
select RegionId, count(OrderId)
from RegionsOrders
group by
	RegionId;

-- Получение по id пользователя, всех его переписок
select ChatId
from Chats
where PersonId1 = _PersonId or PersonId2 = _PersonId;

-- Получение по id чата, всех его сообщений
select MessageId
from Messages
where ChatId = _ChatId;

-- Получение по id пользователя, всех его видеозвонков
select VideoCallId
from Videocalls
where PersonId1 = _PersonId or PersonId2 = _PersonId;

-- Получение по id пользователя, всех отзывов о нем
select ReviewId
from Reviews
where RecipientId = _PersonId;

-- Получение по id пользователя, всех оценок в отзывах о нем
select Raiting
from Reviews
where RecipientId = _PersonId;