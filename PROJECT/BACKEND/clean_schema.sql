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

create table if not exists user_archive (
    user_id integer not null,
    name varchar(100) not null,
    email varchar(100) not null,
    role varchar(20) not null check (role in ('customer','staff','manager')),
    phone_number varchar(15),
    archived_at timestamp not null default now()
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
create index idx_user_archive_user_id on user_archive(user_id);
create index idx_user_archive_email on user_archive(email);
create index idx_user_archive_archived_at on user_archive(archived_at);

create or replace function recompute_room_status(p_hotel_id int, p_room_number varchar)
returns void as $$
begin
    if exists (
        select 1
        from booking b
        where b.hotel_id = p_hotel_id
        and b.room_number = p_room_number
        and b.check_in_date <= current_date
        and b.check_out_date > current_date
    ) then
        update room
        set status = 'occupied'
        where hotel_id = p_hotel_id
        and room_number = p_room_number
        and status <> 'occupied';
    else
        update room
        set status = 'vacant'
        where hotel_id = p_hotel_id
        and room_number = p_room_number
        and status <> 'vacant';
    end if;
end;
$$ language plpgsql;

create or replace function trg_refresh_room_status()
returns trigger as $$
declare
    v_hotel_id int;
    v_room_number varchar(10);
begin
    v_hotel_id := coalesce(new.hotel_id, old.hotel_id);
    v_room_number := coalesce(new.room_number, old.room_number);
    perform recompute_room_status(v_hotel_id, v_room_number);
    return coalesce(new, old);
end;
$$ language plpgsql;

drop trigger if exists booking_refresh_status_ins on booking;
drop trigger if exists booking_refresh_status_upd on booking;
drop trigger if exists booking_refresh_status_del on booking;

create trigger booking_refresh_status_ins
after insert on booking
for each row
execute function trg_refresh_room_status();

create trigger booking_refresh_status_upd
after update of check_in_date, check_out_date, room_number, hotel_id
on booking
for each row
execute function trg_refresh_room_status();

create trigger booking_refresh_status_del
after delete on booking
for each row
execute function trg_refresh_room_status();

create or replace function calculate_order_detail_subtotal()
returns trigger as $$
declare
    v_item_price numeric(7, 2);
begin
    select price into v_item_price
    from food_item
    where food_item_id = new.food_item_id;
    new.subtotal := v_item_price * new.quantity;
    return new;
end;
$$ language plpgsql;

create or replace function check_assigned_task_role()
returns trigger as $$
declare
    v_user_role varchar(20);
begin
    select role into v_user_role
    from "user"
    where user_id = new.staff_id;
    if v_user_role not in ('staff', 'manager') then
        raise exception 'user id % cannot be assigned a task. role must be staff or manager, found %.', new.staff_id, v_user_role;
    end if;
    return new;
end;
$$ language plpgsql;

create view v_order_summary as
select
    fo.order_id,
    fo.booking_id,
    fo.order_date,
    fo.status,
    sum(od.subtotal) as order_total_amount
from
    food_order fo
join
    order_detail od on fo.order_id = od.order_id
group by
    fo.order_id, fo.booking_id, fo.order_date, fo.status
order by
    fo.order_date desc;