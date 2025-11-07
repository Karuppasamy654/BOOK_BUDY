drop table if exists order_detail cascade;
drop table if exists food_order cascade;
drop table if exists booking cascade;
drop table if exists room cascade;
drop table if exists hotel_facility cascade;
drop table if exists facility cascade;
drop table if exists room_type cascade;
drop table if exists assigned_task cascade;
drop table if exists food_item cascade;
drop table if exists hotel cascade;
drop table if exists "user" cascade;

create table "user" (
    user_id serial primary key,
    name varchar(100) not null,
    email varchar(100) unique not null,
    password_hash varchar(255) not null,
    role varchar(20) not null check (role in ('customer', 'staff', 'manager')),
    phone_number varchar(15),
    created_at timestamp default current_timestamp
);

create table hotel (
    hotel_id serial primary key,
    name varchar(150) unique not null,
    location varchar(100) not null,
    address text,
    rating numeric(2, 1) default 0.0,
    base_price_per_night numeric(10, 2) not null,
    image_url varchar(255)
);

create table room_type (
    room_type_id serial primary key,
    name varchar(50) unique not null,
    max_capacity int not null,
    price_multiplier numeric(3, 2) default 1.00
);

create table room (
    room_number varchar(10),
    hotel_id int not null,
    room_type_id int not null,
    status varchar(20) not null check (status in ('vacant', 'occupied', 'cleaning')),
    primary key (room_number, hotel_id),
    foreign key (hotel_id) references hotel(hotel_id) on delete cascade,
    foreign key (room_type_id) references room_type(room_type_id) on delete restrict
);

create table booking (
    booking_id serial primary key,
    user_id int not null,
    hotel_id int not null,
    room_number varchar(10) not null,
    check_in_date date not null,
    check_out_date date not null,
    total_nights int not null,
    grand_total numeric(10, 2) not null,
    booking_date timestamp default current_timestamp,
    foreign key (user_id) references "user"(user_id) on delete restrict,
    foreign key (room_number, hotel_id) references room(room_number, hotel_id) on delete restrict,
    check (check_out_date > check_in_date)
);

create table food_item (
    food_item_id serial primary key,
    name varchar(100) unique not null,
    price numeric(7, 2) not null,
    category varchar(20) not null check (category in ('breakfast', 'lunch', 'dinner', 'beverages')),
    type varchar(10) not null check (type in ('veg', 'non-veg', 'general'))
);

create table food_order (
    order_id serial primary key,
    booking_id int unique not null,
    order_date timestamp default current_timestamp,
    status varchar(20) not null check (status in ('pending', 'in progress', 'delivered', 'cancelled')),
    foreign key (booking_id) references booking(booking_id) on delete cascade
);

create table order_detail (
    order_id int not null,
    food_item_id int not null,
    quantity int not null,
    subtotal numeric(7, 2) not null,
    primary key (order_id, food_item_id),
    foreign key (order_id) references food_order(order_id) on delete cascade,
    foreign key (food_item_id) references food_item(food_item_id) on delete restrict,
    check (quantity > 0)
);

create table assigned_task (
    task_id serial primary key,
    staff_id int not null,
    title varchar(150) not null,
    details text,
    due_date date,
    status varchar(20) not null check (status in ('pending', 'in progress', 'complete', 'overdue')),
    assigned_at timestamp default current_timestamp,
    foreign key (staff_id) references "user"(user_id) on delete restrict
);

create table facility (
    facility_id serial primary key,
    name varchar(100) unique not null
);

create table hotel_facility (
    hotel_id int not null,
    facility_id int not null,
    primary key (hotel_id, facility_id),
    foreign key (hotel_id) references hotel(hotel_id) on delete cascade,
    foreign key (facility_id) references facility(facility_id) on delete cascade
);

create index idx_user_email on "user"(email);
create index idx_user_role on "user"(role);
create index idx_hotel_name on hotel(name);
create index idx_hotel_location on hotel(location);
create index idx_booking_user on booking(user_id);
create index idx_booking_hotel on booking(hotel_id);
create index idx_booking_dates on booking(check_in_date, check_out_date);
create index idx_food_item_category on food_item(category);
create index idx_food_item_type on food_item(type);
create index idx_assigned_task_staff on assigned_task(staff_id);
create index idx_assigned_task_status on assigned_task(status);
create index idx_room_hotel on room(hotel_id);
create index idx_room_status on room(status);

create or replace function calc_booking_total()
returns trigger as $$
declare
    price numeric(10, 2);
    mult numeric(3, 2);
begin
    new.total_nights := new.check_out_date - new.check_in_date;
    
    select h.base_price_per_night, rt.price_multiplier
    into price, mult
    from hotel h
    join room r on h.hotel_id = r.hotel_id
    join room_type rt on r.room_type_id = rt.room_type_id
    where r.room_number = new.room_number 
    and r.hotel_id = new.hotel_id;

    new.grand_total := price * mult * new.total_nights;
    return new;
end;
$$ language plpgsql;

create trigger trg_booking_total
before insert or update on booking
for each row
execute function calc_booking_total();

create or replace function check_room_free()
returns trigger as $$
declare
    taken int;
begin
    select count(*)
    into taken
    from booking
    where room_number = new.room_number
    and hotel_id = new.hotel_id
    and booking_id is distinct from new.booking_id
    and new.check_in_date < check_out_date
    and new.check_out_date > check_in_date;

    if taken > 0 then
        raise exception 'room % at hotel % already taken', new.room_number, new.hotel_id;
    end if;
    return new;
end;
$$ language plpgsql;

create trigger trg_room_free
before insert or update on booking
for each row
execute function check_room_free();

create or replace function update_room()
returns trigger as $$
begin
    update room
    set status = 'occupied'
    where room_number = new.room_number
    and hotel_id = new.hotel_id
    and new.check_in_date <= current_date;
    return new;
end;
$$ language plpgsql;

create trigger trg_room_update
after insert on booking
for each row
execute function update_room();

create or replace function calc_food_total()
returns trigger as $$
declare
    price numeric(7, 2);
begin
    select price into price
    from food_item
    where food_item_id = new.food_item_id;
    new.subtotal := price * new.quantity;
    return new;
end;
$$ language plpgsql;

create trigger trg_food_total
before insert or update on order_detail
for each row
execute function calc_food_total();

create view food_totals as
select
    fo.order_id,
    fo.booking_id,
    fo.order_date,
    fo.status,
    sum(od.subtotal) as total
from food_order fo
join order_detail od on fo.order_id = od.order_id
group by fo.order_id, fo.booking_id, fo.order_date, fo.status
order by fo.order_date desc;