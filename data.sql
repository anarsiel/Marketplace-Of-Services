insert into ServicesGroup (Name)
values ('Tutoring'),
       ('Health and Beauty'),
       ('Appliances repair');

insert into Countries (Name)
values ('Russian Federation'),
       ('Ukraine'),
       ('Republic of Belarus'),
       ('The French Republic'),
       ('Republic of Bulgaria'),
       ('United States of America'),
       ('Japan'),
       ('Arab Republic of Egypt'),
       ('The United Kingdom of Great Britain and Northern Ireland');

insert into Services (Name, ServicesGroupId)
values ('Math Tutoring', 1),
       ('Informatics Tutoring', 1),
       ('Java Tutoring', 1),
       ('Massage', 2),
       ('Makeup', 2),
       ('Manicure', 2),
       ('Сoffee makers repair', 3),
       ('Vacuum cleaners repair', 3);

insert into Persons (Name, PersonType)
values ('Dimitrov Blagoi', 'client'),
       ('Ivanov Ivan', 'expert'),
       ('Slivov Stepan', 'client'),
       ('Krivonosov Alexey', 'client'),
       ('Vronskiy Alexey', 'client'),
       ('Krylov Ivan', 'expert'),
       ('Oskar Schindler', 'client'),
       ('Tikhonova Sofia', 'expert');

insert into Reviews (Text, Raiting, AuthorId, RecipientId)
values ('Массаж просто сказка!! Всем рекоммендую', 5, 1, 8),
       ('Делает качественный, но очень уж дорогой ремонт', 4, 7, 6),
       ('Хамло и грубиян! Заказ взял, а работу так и не выполнил!', 1, 3, 2),
       ('Очень приятный заказчик. Мне заплатили 30% стоимости вперед и покрыли расходы на дорогу.', 5, 8, 1);

insert into Reviews (Raiting, AuthorId, RecipientId)
values (4, 4, 2),
       (4, 2, 4);

call CreateLatLon(59.938480, 30.312481);   -- Saint Petersburg
call CreateLatLon(55.755825, 37.617298);   -- Moscow
call CreateLatLon(63.391522, -155.076621); -- Alaska
call CreateLatLon(59.943663, 30.239423);   -- Some adress in Saint P.

insert into Regions (Name, LatLonId, CountryId)
values ('Saint Petersburg', 1, 1),
	   ('Moscow', 2, 1),
	   ('Alaska', 3, 6);

call CreateOrder('Необходим массаж спины. Срочно!!', 1, 4);
call CreateOrder('Памагите с домашкой по матиматике. 8 класс.', 3, 1);

call createChat(1, 7);
call sendMessage('Привет!', 7, 1);


insert into VideoCalls (PersonId1, PersonId2, StartTime, EndTime)
values 
	(1, 2, '2016-06-22 19:10:25-07', '2018-06-22 19:10:25-07'),
	(1, 7, '2020-07-09 13:10:08-07', '2020-07-09 13:26:54-07');


call AddRegionToOrder(1, 1);
call AddLatLonToOrder(1, 4);