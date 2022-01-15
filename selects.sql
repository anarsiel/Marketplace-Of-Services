-- 1. getAllTaken 
select OrderId
from ExpertsOrders
where PersonId = _PersonId;

-- 2. getAllCreated 
select OrderId
from Orders
where ClientId = _PersonId;

-- 3. getAllAvailable 
select OrderId
from Orders
where (ExpertRating = null or _Raiting = 0 or _Raiting >= ExpertRating) and OrderStatus = 'free';

-- 4. getAllInRegion
select OrderId
from Orders natural join RegionsOrder
where RegionId = _RegionId and OrderStatus = 'free';

-- 5. getAllTakenTypes
select distinct Name
from ExpertsOrders natural join Orders natural join Services
where PersonId = _PersonId;

-- 6. getReviewStat
select Raiting, count(ReviewId)
from Reviews
where RecipientId = _PersonId;
group by
	Raiting;

-- 7. getOrderTypesStat
select ServiceId, count(OrderId)
from Orders
group by
	ServiceId;

-- 8. getRegionStat
select RegionId, count(OrderId)
from RegionsOrders
group by
	RegionId;

-- 9. getFilesInOrder
select RegionId, count(OrderId)
from RegionsOrders
group by
	RegionId;

-- 10. getAllPersonChats
select ChatId
from Chats
where PersonId1 = _PersonId or PersonId2 = _PersonId;

-- 11. getAllChatMessages
select MessageId
from Messages
where ChatId = _ChatId;

-- 12. getPersonVideoCallsHistory
select VideoCallId
from Videocalls
where PersonId1 = _PersonId or PersonId2 = _PersonId;

-- 13. getAllPersonReviews
select ReviewId
from Reviews
where RecipientId = _PersonId;


-- 14. getAllPersonReviewsRatings
select Raiting
from Reviews
where RecipientId = _PersonId;