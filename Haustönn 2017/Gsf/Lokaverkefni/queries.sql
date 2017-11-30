use 1612002390_gsflokaverkefni;

#3
select movie_title, movie_year, movie_cost from movie
where movie_title like '%Hope%';

#4
select movie_title, movie_year, movie_genre from movie
where movie_genre = 'Action';

#5
select movie_num, movie_title, movie_cost from movie
where movie_cost > 40;

#6
select movie_num, movie_title, movie_cost, movie_genre from movie
where movie_genre = 'Action' and movie_cost < 50 or movie_genre = 'Comedy' and movie_cost < 50;

#7
select movie_num, concat(movie_title,' (',movie_year,') ',movie_genre) as movie_description from movie;

#8
select movie_genre, count(movie_genre) as Number_of_Movies from movie
group by movie_genre;

#9
select avg(movie_cost) as Average_Movie_Cost from movie;

#10
select movie_genre,avg(movie_cost) as Average_Movie_Cost from movie
group by movie_genre;

#11
select movie_title,movie_genre, price.price_desc, price.price_rentfee from movie
inner join price
where movie.price_code = price.price_code;

#12
select movie_genre, avg(price.price_rentfee) as Average_Rental_Fee from movie
inner join price
where movie.price_code = price.price_code
group by movie_genre;

#13
select movie_title, movie_year, movie_cost/price.price_rentfee as Breakeven_Rentals from movie
inner join price
where movie.price_code = price.price_code;

#14
select movie_title,movie_year from movie
where price_code > 0;

#15
select movie_title, movie_year, movie_cost from movie
where movie_cost > 44.99 and movie_cost < 49.99;

#16
select movie_title, movie_year, price.price_desc, price.price_rentfee, movie_genre
from movie inner join price
where movie.price_code = price.price_code and movie_genre = 'Family' or movie.price_code = price.price_code and movie_genre = 'Comedy' or movie.price_code = price.price_code and movie_genre = 'Drama';

#17
select min(mem_balance), max(mem_balance), avg(mem_balance)
from membership inner join rental
where membership.mem_num = rental.mem_num;

#18
select concat(mem_fname,' ',mem_lname) as Nafn, concat(mem_street,' ',mem_city,' ',mem_state,' ',mem_zip) as Address
from membership;

#19
select rental.rent_num, rental.rent_date, video.vid_num, movie.movie_title, detailrental.detail_duedate, detailrental.detail_returndate
from rental inner join video, movie, detailrental
where rental.rent_num = detailrental.rent_num and detailrental.vid_num = video.vid_num and video.movie_num = movie.movie_num and detailrental.detail_returndate > detailrental.detail_duedate
order by rental.rent_num;

#20
select rental.rent_num, rental.rent_date, video.vid_num, movie.movie_title, detailrental.detail_duedate, detailrental.detail_returndate, datediff(detailrental.detail_returndate,detailrental.detail_duedate) as DaysPassed
from rental inner join video, movie, detailrental
where rental.rent_num = detailrental.rent_num and detailrental.vid_num = video.vid_num and video.movie_num = movie.movie_num and detailrental.detail_returndate > detailrental.detail_duedate
order by rental.rent_num;

#21
select rental.rent_num, rental.rent_date, movie.movie_title, detailrental.detail_fee
from rental inner join movie, detailrental, video
where rental.rent_num = detailrental.rent_num and detailrental.vid_num = video.vid_num and video.movie_num = movie.movie_num and detailrental.detail_returndate <= detailrental.detail_duedate;

#22
select membership.mem_num, membership.mem_lname, membership.mem_fname, sum(detailrental.detail_fee)
from membership inner join rental, detailrental
where membership.mem_num = rental.mem_num and rental.rent_num = detailrental.rent_num
group by mem_num;

#23!!!!!!!
select movie_num, movie_genre, avg(movie_cost), movie_cost, ((movie_cost - avg(movie_cost))/avg(movie_cost) * 100) as PercentDiff
from movie
group by movie_genre
order by movie_num;

#24
alter table detailrental
add detail_dayslate int(3);

#25
alter table video
add vid_status varchar(4) not null default 'in' check(vid_status='in' or vid_status='out' or vid_status = 'lost') ;

#26
update video, detailrental
set vid_status = 'out'
where video.vid_num in (select detailrental.vid_num from detailrental where detailrental.detail_returndate = null);

select * from detailrental;
select * from video;

#27
alter table price
add price_rentdays int(2) not null default 3;

#28
update price
set price_rentdays = 5
where price_code = 1;
update price
set price_rentdays = 5
where price_code = 3;
update price
set price_rentdays = 7
where price_code = 4;

#29
delimiter //
create trigger trg_late_return
before update on detailrental.detail_returndate
for each row
begin
	if detailrental.detail_returndate is null then
		update detailrental
        set detail_dayslate = null
        where detail_returndate = detailrental.detail_returndate;
    else if detailrental.detail_returndate is not null then
		update detailrental
        set detail_dayslate = datediff(detail_duedate, detail_returndate)
        where detail_returndate = detailrental.detail_returndate;
    else if convert(detail_returndate,time) < '12:00:00' then
		update detailrental
        set detail_dayslate = 0
        where detail_returndate = detailrental.detail_returndate;
	else if convert(detail_returndate,time) > '12:00:00' then
		update detailrental
        set detail_dayslate = datediff(detail_duedate, detail_returndate)
        where detail_returndate = detailrental.detail_returndate;
	end if;
delimiter ;