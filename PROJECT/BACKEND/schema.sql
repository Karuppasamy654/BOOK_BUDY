

create table "user"(
    user_id serial primary key,
    name varchar(100) not null,
    email varchar(100) unique not null,
    password_hash varchar(255) not null,
    role varchar(20) not null check(role in('customer','staff','manager')),
    phone_number varchar(15),
    created_at timestamp default current_timestamp
);

create table hotel(
    hotel_id serial primary key,
    name varchar(150) unique not null,
    location varchar(100) not null,
    address text,
    rating numeric(2,1) default 0.0,
    base_price_per_night numeric(10,2) not null,
    image_url varchar(255)
);

create table room_type(
    room_type_id serial primary key,
    name varchar(50) unique not null,
    max_capacity int not null,
    price_multiplier numeric(3,2) default 1.00
);

create table room(
    room_number varchar(10),
    hotel_id int not null,
    room_type_id int not null,
    status varchar(20) not null check(status in('vacant','occupied','cleaning')),
    primary key(room_number,hotel_id),
    foreign key(hotel_id) references hotel(hotel_id) on delete cascade,
    foreign key(room_type_id) references room_type(room_type_id) on delete restrict
);

create table booking(
    booking_id serial primary key,
    user_id int not null,
    hotel_id int not null,
    room_number varchar(10) not null,
    check_in_date date not null,
    check_out_date date not null,
    total_nights int not null,
    grand_total numeric(10,2) not null,
    booking_date timestamp default current_timestamp,
    foreign key(user_id) references "user"(user_id) on delete restrict,
    foreign key(room_number,hotel_id) references room(room_number,hotel_id) on delete restrict,
    check(check_out_date>check_in_date)
);

create table food_item(
    food_item_id serial primary key,
    name varchar(100) unique not null,
    price numeric(7,2) not null,
    category varchar(20) not null check(category in('breakfast','lunch','dinner','beverages')),
    type varchar(10) not null check(type in('veg','non-veg','general'))
);

create table food_order(
    order_id serial primary key,
    booking_id int unique not null,
    order_date timestamp default current_timestamp,
    status varchar(20) not null check(status in('pending','in progress','delivered','cancelled')),
    foreign key(booking_id) references booking(booking_id) on delete cascade
);

create table order_detail(
    order_id int not null,
    food_item_id int not null,
    quantity int not null,
    subtotal numeric(7,2) not null,
    primary key(order_id,food_item_id),
    foreign key(order_id) references food_order(order_id) on delete cascade,
    foreign key(food_item_id) references food_item(food_item_id) on delete restrict,
    check(quantity>0)
);

create table assigned_task(
    task_id serial primary key,
    staff_id int not null,
    title varchar(150) not null,
    details text,
    due_date date,
    status varchar(20) not null check(status in('pending','in progress','complete','overdue')),
    assigned_at timestamp default current_timestamp,
    foreign key(staff_id) references "user"(user_id) on delete restrict
);

create table facility(
    facility_id serial primary key,
    name varchar(100) unique not null
);

create table hotel_facility(
    hotel_id int not null,
    facility_id int not null,
    primary key(hotel_id,facility_id),
    foreign key(hotel_id) references hotel(hotel_id) on delete cascade,
    foreign key(facility_id) references facility(facility_id) on delete cascade
);

create index idx_user_email on "user"(email);
create index idx_user_role on "user"(role);
create index idx_hotel_name on hotel(name);
create index idx_hotel_location on hotel(location);
create index idx_booking_user on booking(user_id);
create index idx_booking_hotel on booking(hotel_id);
create index idx_booking_dates on booking(check_in_date,check_out_date);
create index idx_food_item_category on food_item(category);
create index idx_food_item_type on food_item(type);
create index idx_assigned_task_staff on assigned_task(staff_id);
create index idx_assigned_task_status on assigned_task(status);
create index idx_room_hotel on room(hotel_id);
create index idx_room_status on room(status);


select 'Database schema created successfully!' as status;



insert into room_type(name,max_capacity,price_multiplier) values
('standard',2,1.00),
('deluxe',3,1.50),
('suite',4,2.00),
('presidential',6,3.00);

insert into facility(name) values
('wifi'),
('swimming pool'),
('gym'),
('restaurant'),
('spa'),
('parking'),
('room service'),
('business center'),
('conference room'),
('laundry service'),
('bar/lounge'),
('beach front'),
('city center'),
('pet friendly'),
('sun view'),
('resort property');

insert into hotel(name,location,address,rating,base_price_per_night,image_url) values
('trident hotel','chennai','37, mahatma gandhi road, nungambakkam, chennai',4.8,15000.00,'trident.jpg'),
('woodlands inn','chennai','72, dr. radhakrishnan salai, mylapore, chennai',3.5,7500.00,'woodland.jpg'),
('the leela palace','bangalore','23, old airport road, bangalore',4.9,22000.00,'the-leela-palace.jpg'),
('taj coromandel','chennai','37, mahatma gandhi road, nungambakkam, chennai',4.5,17000.00,'taj-coromandel.jpg'),
('novotel','chennai','457, anna salai, teynampet, chennai',4.0,10000.00,'novotel.jpg'),
('taz kamar inn','chennai','15, cathedral road, chennai',3.0,5000.00,'taz-kamar-inn.jpg'),
('benzz park','chennai','123, mount road, chennai',4.2,11000.00,'benzz-park.jpg'),
('sheraton grand','chennai','234, anna salai, chennai',4.5,14000.00,'sheraton.jpg'),
('ramada plaza','chennai','345, omr, chennai',3.8,7500.00,'ramada.jpg'),
('itc grand chola','chennai','63, mount road, guindy, chennai',4.7,25000.00,'itc-hotel.jpg');

insert into room(room_number,hotel_id,room_type_id,status) values
('101',1,1,'vacant'),('102',1,1,'vacant'),('103',1,1,'vacant'),('104',1,1,'vacant'),
('201',1,2,'vacant'),('202',1,2,'vacant'),('301',1,3,'vacant'),('401',1,4,'vacant');

insert into room(room_number,hotel_id,room_type_id,status) values
('101',2,1,'vacant'),('102',2,1,'vacant'),('103',2,1,'vacant'),
('201',2,2,'vacant'),('202',2,2,'vacant');

insert into room(room_number,hotel_id,room_type_id,status) values
('101',3,1,'vacant'),('102',3,1,'vacant'),('103',3,1,'vacant'),('104',3,1,'vacant'),
('201',3,2,'vacant'),('202',3,2,'vacant'),('203',3,2,'vacant'),
('301',3,3,'vacant'),('302',3,3,'vacant'),('401',3,4,'vacant');

insert into room(room_number,hotel_id,room_type_id,status) values
('101',4,1,'vacant'),('102',4,1,'vacant'),('103',4,1,'vacant'),
('201',4,2,'vacant'),('202',4,2,'vacant'),
('301',4,3,'vacant'),('401',4,4,'vacant');

insert into room(room_number,hotel_id,room_type_id,status) values
('101',5,1,'vacant'),('102',5,1,'vacant'),('103',5,1,'vacant'),
('201',5,2,'vacant'),('202',5,2,'vacant'),('301',5,3,'vacant');

insert into room(room_number,hotel_id,room_type_id,status) values
('101',6,1,'vacant'),('102',6,1,'vacant'),
('201',6,2,'vacant'),('202',6,2,'vacant');

insert into room(room_number,hotel_id,room_type_id,status) values
('101',7,1,'vacant'),('102',7,1,'vacant'),('103',7,1,'vacant'),
('201',7,2,'vacant'),('202',7,2,'vacant'),('203',7,2,'vacant'),
('301',7,3,'vacant'),('302',7,3,'vacant'),('401',7,4,'vacant');

insert into room(room_number,hotel_id,room_type_id,status) values
('101',8,1,'vacant'),('102',8,1,'vacant'),('103',8,1,'vacant'),('104',8,1,'vacant'),
('201',8,2,'vacant'),('202',8,2,'vacant'),
('301',8,3,'vacant'),('401',8,4,'vacant');

insert into room(room_number,hotel_id,room_type_id,status) values
('101',9,1,'vacant'),('102',9,1,'vacant'),
('201',9,2,'vacant'),('202',9,2,'vacant'),('301',9,3,'vacant');

insert into room(room_number,hotel_id,room_type_id,status) values
('101',10,1,'vacant'),('102',10,1,'vacant'),('103',10,1,'vacant'),('104',10,1,'vacant'),
('201',10,2,'vacant'),('202',10,2,'vacant'),('203',10,2,'vacant'),
('301',10,3,'vacant'),('302',10,3,'vacant'),('401',10,4,'vacant');

insert into hotel_facility(hotel_id,facility_id) values
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),(1,11),(1,13);

insert into hotel_facility(hotel_id,facility_id) values
(2,1),(2,6),(2,7),(2,10),(2,13);

insert into hotel_facility(hotel_id,facility_id) values
(3,1),(3,2),(3,3),(3,4),(3,5),(3,6),(3,7),(3,8),(3,9),(3,10),(3,11),(3,12),(3,15),(3,16);

insert into hotel_facility(hotel_id,facility_id) values
(4,1),(4,2),(4,3),(4,4),(4,6),(4,7),(4,8),(4,10),(4,11),(4,13);

insert into hotel_facility(hotel_id,facility_id) values
(5,1),(5,2),(5,3),(5,4),(5,6),(5,7),(5,10),(5,11),(5,13),(5,14);

insert into hotel_facility(hotel_id,facility_id) values
(6,1),(6,6),(6,7),(6,10),(6,13);

insert into hotel_facility(hotel_id,facility_id) values
(7,1),(7,2),(7,3),(7,4),(7,6),(7,7),(7,10),(7,11),(7,13);

insert into hotel_facility(hotel_id,facility_id) values
(8,1),(8,2),(8,3),(8,4),(8,5),(8,6),(8,7),(8,8),(8,10),(8,11),(8,12),(8,15),(8,16);

insert into hotel_facility(hotel_id,facility_id) values
(9,1),(9,4),(9,6),(9,7),(9,10),(9,11),(9,13);

insert into hotel_facility(hotel_id,facility_id) values
(10,1),(10,2),(10,3),(10,4),(10,5),(10,6),(10,7),(10,8),(10,9),(10,10),(10,11),(10,13);

insert into food_item(name,price,category,type) values
('idli sambar (2pcs)',100.00,'breakfast','veg'),
('masala dosa',120.00,'breakfast','veg'),
('bread omelette (2 eggs)',200.00,'breakfast','non-veg'),
('pongal',80.00,'breakfast','veg'),
('upma',60.00,'breakfast','veg'),
('puri with curry',90.00,'breakfast','veg'),
('chicken biryani',450.00,'lunch','non-veg'),
('paneer tikka masala',380.00,'lunch','veg'),
('fish curry',420.00,'lunch','non-veg'),
('dal makhani',180.00,'lunch','veg'),
('mutton biryani',500.00,'lunch','non-veg'),
('veg biryani',250.00,'lunch','veg'),
('butter chicken',550.00,'dinner','non-veg'),
('paneer butter masala',350.00,'dinner','veg'),
('tandoori chicken',480.00,'dinner','non-veg'),
('dal tadka',150.00,'dinner','veg'),
('mutton curry',520.00,'dinner','non-veg'),
('malai kofta',320.00,'dinner','veg'),
('coffee',80.00,'beverages','general'),
('tea',60.00,'beverages','general'),
('fresh juice',120.00,'beverages','general'),
('lassi',100.00,'beverages','general'),
('soft drink',50.00,'beverages','general'),
('mineral water',30.00,'beverages','general'),
-- Additional food items
('tandoori roti',40.00,'dinner','veg'),
('butter naan',60.00,'dinner','veg'),
('plain naan',50.00,'dinner','veg'),
('chicken gravy',400.00,'dinner','non-veg'),
('chicken fried rice',350.00,'lunch','non-veg'),
('veg fried rice',250.00,'lunch','veg'),
('bread jam',80.00,'breakfast','veg'),
('butter milk',40.00,'beverages','general'),
('rose milk',60.00,'beverages','general'),
('kesari',120.00,'beverages','general'),
('payasam',150.00,'beverages','general'),
('prawn gravy',450.00,'dinner','non-veg'),
('fish gravy',420.00,'dinner','non-veg'),
('mini lunch',200.00,'lunch','veg'),
('chai',40.00,'beverages','general'),
('vada (2pcs)',60.00,'breakfast','veg'),
('ice cream',100.00,'beverages','general'),
('water bottle',20.00,'beverages','general'),
('chicken curry',380.00,'lunch','non-veg'),
('lemon soda',50.00,'beverages','general');

select 'static data insertion completed successfully!' as status;
select 'users will be created via login/registration system' as note;




Trigger 2: Prevent Double Booking (Availability Check)
This is the most critical logic. It ensures a room cannot be booked if an existing booking overlaps the new dates.

Create the Function:


CREATE OR REPLACE FUNCTION check_room_availability()
RETURNS TRIGGER AS $$
DECLARE
    v_overlap_count INT;
BEGIN
    SELECT COUNT(*)
    INTO v_overlap_count
    FROM booking
    WHERE room_number = NEW.room_number
      AND hotel_id = NEW.hotel_id
      AND booking_id IS DISTINCT FROM NEW.booking_id -- Exclude current row on update
      AND NEW.check_in_date < check_out_date
      AND NEW.check_out_date > check_in_date;

    IF v_overlap_count > 0 THEN
        RAISE EXCEPTION 'Room % at Hotel % is already booked during the requested dates (overlap detected).', NEW.room_number, NEW.hotel_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
Create the Trigger:

SQL

CREATE TRIGGER trg_prevent_double_booking
BEFORE INSERT OR UPDATE ON booking
FOR EACH ROW
EXECUTE FUNCTION check_room_availability();


C. Trigger 3: Update room.status on Check-In/Check-Out (Simulated)
In a real system, status changes are API actions. This trigger enforces room status change upon booking completion/cancellation.

Create the Function:

SQL

CREATE OR REPLACE FUNCTION update_room_status_after_booking()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE room
    SET status = 'Occupied'
    WHERE room_number = NEW.room_number
      AND hotel_id = NEW.hotel_id
      AND NEW.check_in_date <= CURRENT_DATE;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
Create the Trigger:

SQL

CREATE TRIGGER trg_update_room_status
AFTER INSERT ON booking
FOR EACH ROW
EXECUTE FUNCTION update_room_status_after_booking();

Query for book.html (Hotel List with Facilities)
This query fetches all necessary data to display the hotel cards and enable filtering.

SQL

SELECT
    h.hotel_id,
    h.name,
    h.location,
    h.rating,
    h.base_price_per_night,
    h.image_url,
    json_agg(f.name) AS facilities
FROM
    hotel h
LEFT JOIN
    hotel_facility hf ON h.hotel_id = hf.hotel_id
LEFT JOIN
    facility f ON hf.facility_id = f.facility_id
GROUP BY
    h.hotel_id, h.name, h.location, h.rating, h.base_price_per_night, h.image_url
ORDER BY
    h.rating DESC;



Ys (like total_nights and grand_total) are accurate.

A. Trigger 1: Calculate total_nights and grand_total on BOOKING
This trigger ensures the booking calculation fields are always correct before insertion.

Create the Function:

SQL

CREATE OR REPLACE FUNCTION calculate_booking_totals()
RETURNS TRIGGER AS $$
DECLARE
    v_base_price NUMERIC(10, 2);
    v_multiplier NUMERIC(3, 2);
BEGIN
    NEW.total_nights := NEW.check_out_date - NEW.check_in_date;

    SELECT
        h.base_price_per_night,
        rt.price_multiplier
    INTO
        v_base_price,
        v_multiplier
    FROM hotel h
    JOIN room r ON h.hotel_id = r.hotel_id
    JOIN room_type rt ON r.room_type_id = rt.room_type_id
    WHERE r.room_number = NEW.room_number AND r.hotel_id = NEW.hotel_id;

    NEW.grand_total := v_base_price * v_multiplier * NEW.total_nights;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
Create the Trigger:

SQL

CREATE TRIGGER trg_calculate_booking_totals
BEFORE INSERT OR UPDATE ON booking
FOR EACH ROW
EXECUTE FUNCTION calculate_booking_totals();
B. Trigger 2: Prevent Double Booking (Availability Check)
This is the most critical logic. It ensures a room cannot be booked if an existing booking overlaps the new dates.

Create the Function:

SQL

CREATE OR REPLACE FUNCTION check_room_availability()
RETURNS TRIGGER AS $$
DECLARE
    v_overlap_count INT;
BEGIN
    SELECT COUNT(*)
    INTO v_overlap_count
    FROM booking
    WHERE room_number = NEW.room_number
      AND hotel_id = NEW.hotel_id
      AND booking_id IS DISTINCT FROM NEW.booking_id -- Exclude current row on update
      AND NEW.check_in_date < check_out_date
      AND NEW.check_out_date > check_in_date;

    IF v_overlap_count > 0 THEN
        RAISE EXCEPTION 'Room % at Hotel % is already booked during the requested dates (overlap detected).', NEW.room_number, NEW.hotel_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
Create the Trigger:

SQL

CREATE TRIGGER trg_prevent_double_booking
BEFORE INSERT OR UPDATE ON booking
FOR EACH ROW
EXECUTE FUNCTION check_room_availability();
C. Trigger 3: Update room.status on Check-In/Check-Out (Simulated)
In a real system, status changes are API actions. This trigger enforces room status change upon booking completion/cancellation.

Create the Function:

SQL

CREATE OR REPLACE FUNCTION update_room_status_after_booking()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE room
    SET status = 'Occupied'
    WHERE room_number = NEW.room_number
      AND hotel_id = NEW.hotel_id
      AND NEW.check_in_date <= CURRENT_DATE;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
Create the Trigger:

SQL

CREATE TRIGGER trg_update_room_status
AFTER INSERT ON booking
FOR EACH ROW
EXECUTE FUNCTION update_room_status_after_booking();
2. Advanced Queries for the Backend (API) 🔍
These queries are what your Node.js API will execute to retrieve data for the dashboard pages (home.html, book.html, manage.html).

A. Query for book.html (Hotel List with Facilities)
This query fetches all necessary data to display the hotel cards and enable filtering.

SQL

SELECT
    h.hotel_id,
    h.name,
    h.location,
    h.rating,
    h.base_price_per_night,
    h.image_url,
    json_agg(f.name) AS facilities
FROM
    hotel h
LEFT JOIN
    hotel_facility hf ON h.hotel_id = hf.hotel_id
LEFT JOIN
    facility f ON hf.facility_id = f.facility_id
GROUP BY
    h.hotel_id, h.name, h.location, h.rating, h.base_price_per_night, h.image_url
ORDER BY
    h.rating DESC;
B. Query for manage.html (Manager: Revenue Snapshot)
To quickly show management key metrics.

SQL

SELECT
    COUNT(booking_id) AS total_bookings,
    SUM(grand_total) AS total_revenue,
    (SELECT COUNT(user_id) FROM "user" WHERE role = 'Customer') AS total_customers,
    (SELECT COUNT(hotel_id) FROM hotel) AS total_hotels
FROM
    booking
WHERE
    booking_date >= DATE_TRUNC('month', CURRENT_DATE); 



A. Trigger 1: Calculate total_nights and grand_total on BOOKING
This trigger ensures the booking calculation fields are always correct before insertion.

Create the Function:

SQL

CREATE OR REPLACE FUNCTION calculate_booking_totals()
RETURNS TRIGGER AS $$
DECLARE
    v_base_price NUMERIC(10, 2);
    v_multiplier NUMERIC(3, 2);
BEGIN
    NEW.total_nights := NEW.check_out_date - NEW.check_in_date;

    SELECT
        h.base_price_per_night,
        rt.price_multiplier
    INTO
        v_base_price,
        v_multiplier
    FROM hotel h
    JOIN room r ON h.hotel_id = r.hotel_id
    JOIN room_type rt ON r.room_type_id = rt.room_type_id
    WHERE r.room_number = NEW.room_number AND r.hotel_id = NEW.hotel_id;

    NEW.grand_total := v_base_price * v_multiplier * NEW.total_nights;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
Create the Trigger:

SQL

CREATE TRIGGER trg_calculate_booking_totals
BEFORE INSERT OR UPDATE ON booking
FOR EACH ROW
EXECUTE FUNCTION calculate_booking_totals();
B. Trigger 2: Prevent Double Booking (Availability Check)
This is the most critical logic. It ensures a room cannot be booked if an existing booking overlaps the new dates.

Create the Function:

SQL

CREATE OR REPLACE FUNCTION check_room_availability()
RETURNS TRIGGER AS $$
DECLARE
    v_overlap_count INT;
BEGIN
    SELECT COUNT(*)
    INTO v_overlap_count
    FROM booking
    WHERE room_number = NEW.room_number
      AND hotel_id = NEW.hotel_id
      AND booking_id IS DISTINCT FROM NEW.booking_id -- Exclude current row on update
      AND NEW.check_in_date < check_out_date
      AND NEW.check_out_date > check_in_date;

    IF v_overlap_count > 0 THEN
        RAISE EXCEPTION 'Room % at Hotel % is already booked during the requested dates (overlap detected).', NEW.room_number, NEW.hotel_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
Create the Trigger:

SQL

CREATE TRIGGER trg_prevent_double_booking
BEFORE INSERT OR UPDATE ON booking
FOR EACH ROW
EXECUTE FUNCTION check_room_availability();
C. Trigger 3: Update room.status on Check-In/Check-Out (Simulated)
In a real system, status changes are API actions. This trigger enforces room status change upon booking completion/cancellation.

Create the Function:

SQL

CREATE OR REPLACE FUNCTION update_room_status_after_booking()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE room
    SET status = 'Occupied'
    WHERE room_number = NEW.room_number
      AND hotel_id = NEW.hotel_id
      AND NEW.check_in_date <= CURRENT_DATE;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
Create the Trigger:

SQL

CREATE TRIGGER trg_update_room_status
AFTER INSERT ON booking
FOR EACH ROW
EXECUTE FUNCTION update_room_status_after_booking();
2. Advanced Queries for the Backend (API) 🔍
These queries are what your Node.js API will execute to retrieve data for the dashboard pages (home.html, book.html, manage.html).

A. Query for book.html (Hotel List with Facilities)
This query fetches all necessary data to display the hotel cards and enable filtering.

SQL



C. Query for staff.html (Staff: Pending Tasks & Occupied Rooms)
To show staff relevant, immediate tasks and room status.

SQL

SELECT
    task_id,
    title,
    details,
    due_date
FROM
    assigned_task
WHERE
    staff_id = 2 AND status IN ('Pending', 'In Progress')
ORDER BY
    due_date ASC;

SELECT
    r.room_number,
    h.name AS hotel_name,
    b.check_out_date,
    u.name AS guest_name
FROM
    room r
JOIN
    hotel h ON r.hotel_id = h.hotel_id
LEFT JOIN
    booking b ON r.room_number = b.room_number AND r.hotel_id = b.hotel_id
LEFT JOIN
    "user" u ON b.user_id = u.user_id
WHERE
    r.status = 'Occupied'
    AND b.check_out_date >= CURRENT_DATE -- Only show current occupied bookings
ORDER BY
    h.name, r.room_number;






Trigger 4: Calculate order_detail.subtotal on Insertion/Update
This trigger automatically calculates the line-item subtotal by looking up the food_item price.

Create the Function:

SQL

CREATE OR REPLACE FUNCTION calculate_order_detail_subtotal()
RETURNS TRIGGER AS $$
DECLARE
    v_item_price NUMERIC(7, 2);
BEGIN
    SELECT price INTO v_item_price
    FROM food_item
    WHERE food_item_id = NEW.food_item_id;

    NEW.subtotal := v_item_price * NEW.quantity;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
Create the Trigger:

SQL

CREATE TRIGGER trg_calculate_order_detail_subtotal
BEFORE INSERT OR UPDATE ON order_detail
FOR EACH ROW
EXECUTE FUNCTION calculate_order_detail_subtotal();


Trigger 4: Calculate order_detail.subtotal on Insertion/Update
This trigger automatically calculates the line-item subtotal by looking up the food_item price.

Create the Function:

SQL

CREATE OR REPLACE FUNCTION calculate_order_detail_subtotal()
RETURNS TRIGGER AS $$
DECLARE
    v_item_price NUMERIC(7, 2);
BEGIN
    SELECT price INTO v_item_price
    FROM food_item
    WHERE food_item_id = NEW.food_item_id;

    NEW.subtotal := v_item_price * NEW.quantity;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
Create the Trigger:

SQL

CREATE TRIGGER trg_calculate_order_detail_subtotal
BEFORE INSERT OR UPDATE ON order_detail
FOR EACH ROW
EXECUTE FUNCTION calculate_order_detail_subtotal();

2. Staff & User Integrity Triggers 👤
This trigger enforces business rules about which users are allowed to perform certain roles (e.g., only staff/managers can be assigned tasks).

Trigger 5: Enforce Staff Role on ASSIGNED_TASK
The assigned_task table uses staff_id which references the user table. This trigger prevents managers from accidentally assigning tasks to a Customer account.

Create the Function:

SQL

CREATE OR REPLACE FUNCTION check_assigned_task_role()
RETURNS TRIGGER AS $$
DECLARE
    v_user_role VARCHAR(20);
BEGIN
    SELECT role INTO v_user_role
    FROM "user"
    WHERE user_id = NEW.staff_id;

    IF v_user_role NOT IN ('Staff', 'Manager') THEN
        RAISE EXCEPTION 'User ID % cannot be assigned a task. Role must be Staff or Manager, found %.', NEW.staff_id, v_user_role;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
Create the Trigger:

SQL

CREATE TRIGGER trg_check_assigned_task_role
BEFORE INSERT OR UPDATE ON assigned_task
FOR EACH ROW
EXECUTE FUNCTION check_assigned_task_role();



Trigger 4: Calculate order_detail.subtotal on Insertion/Update
This trigger automatically calculates the line-item subtotal by looking up the food_item price.

Create the Function

SQL

CREATE OR REPLACE FUNCTION calculate_order_detail_subtotal()
RETURNS TRIGGER AS $$
DECLARE
    v_item_price NUMERIC(7, 2);
BEGIN
    SELECT price INTO v_item_price
    FROM food_item
    WHERE food_item_id = NEW.food_item_id;

    NEW.subtotal := v_item_price * NEW.quantity;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
Create the Trigger:

SQL

CREATE TRIGGER trg_calculate_order_detail_subtotal
BEFORE INSERT OR UPDATE ON order_detail
FOR EACH ROW
EXECUTE FUNCTION calculate_order_detail_subtotal();
2. Staff & User Integrity Triggers 👤
This trigger enforces business rules about which users are allowed to perform certain roles (e.g., only staff/managers can be assigned tasks).

Trigger 5: Enforce Staff Role on ASSIGNED_TASK
The assigned_task table uses staff_id which references the user table. This trigger prevents managers from accidentally assigning tasks to a Customer account.

Create the Function:

SQL

CREATE OR REPLACE FUNCTION check_assigned_task_role()
RETURNS TRIGGER AS $$
DECLARE
    v_user_role VARCHAR(20);
BEGIN
    SELECT role INTO v_user_role
    FROM "user"
    WHERE user_id = NEW.staff_id;

    IF v_user_role NOT IN ('Staff', 'Manager') THEN
        RAISE EXCEPTION 'User ID % cannot be assigned a task. Role must be Staff or Manager, found %.', NEW.staff_id, v_user_role;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
Create the Trigger:

SQL

CREATE TRIGGER trg_check_assigned_task_role
BEFORE INSERT OR UPDATE ON assigned_task
FOR EACH ROW
EXECUTE FUNCTION check_assigned_task_role();
3. Recommended View (for Reporting/APIs) 📈
While triggers automate data changes, a View is essential for simplifying complex reports that your Manager dashboard (manage.html) will need.

View: v_order_summary (Calculate Total for Each Food Order)
This view calculates the final total for every food order, eliminating the need for your Node.js API to run a complex aggregation query every time the order list is displayed.

SQL

CREATE VIEW v_order_summary AS
SELECT
    fo.order_id,
    fo.booking_id,
    fo.order_date,
    fo.status,
    SUM(od.subtotal) AS order_total_amount
FROM
    food_order fo
JOIN
    order_detail od ON fo.order_id = od.order_id
GROUP BY
    fo.order_id, fo.booking_id, fo.order_date, fo.status
ORDER BY
    fo.order_date DESC;
How to use it in your API:

Instead of a complex SELECT query, your API can just use:

SQL

SELECT * FROM v_order_summary WHERE status = 'Pending';
This simplifies the backend code for displaying pending food orders on the Staff Portal or Manager Dashboard.


WITH pwd AS (
  SELECT '$2a$12$uG1v8KCe90uTgk2bT9FJ7OmF0O3S7J6vZ3U3gAjC8Y6Xb4lO6wA2S' AS ph
)
INSERT INTO "user" (name, email, password_hash, role, phone_number)
SELECT
  'Manager ' || h.name AS name,
  'mgr.' || regexp_replace(lower(h.name), '[^a-z0-9]+', '', 'g') || '@bookbuddy.com' AS email,
  (SELECT ph FROM pwd) AS password_hash,
  'Manager' AS role,
  '900' || lpad(h.hotel_id::text, 7, '0') AS phone_number
FROM hotel h
ON CONFLICT (email) DO NOTHING;

WITH pwd AS (
  SELECT '$2a$12$uG1v8KCe90uTgk2bT9FJ7OmF0O3S7J6vZ3U3gAjC8Y6Xb4lO6wA2S' AS ph
),
series AS (
  SELECT h.hotel_id, h.name, generate_series(1,4) AS n
  FROM hotel h
)
INSERT INTO "user" (name, email, password_hash, role, phone_number)
SELECT
  'Staff ' || s.n || ' - ' || s.name AS name,
  'staff' || s.n || '.' || regexp_replace(lower(s.name), '[^a-z0-9]+', '', 'g') || '@bookbuddy.com' AS email,
  (SELECT ph FROM pwd) AS password_hash,
  'Staff' AS role,
  '91' || lpad(s.hotel_id::text, 6, '0') || lpad(s.n::text, 2, '0') AS phone_number
FROM series s
ON CONFLICT (email) DO NOTHING;

ALTER TABLE public."user"
  ADD COLUMN password TEXT;

UPDATE public."user"
SET password = 'Password@123'
WHERE email ~ '^(mgr\\.|staff[0-9]+\\.)[a-z0-9]+@bookbuddy\\.com$'
  AND role IN ('Manager','Staff')
  AND password IS NULL;

  WITH pwd AS (
  SELECT '$2a$12$uG1v8KCe90uTgk2bT9FJ7OmF0O3S7J6vZ3U3gAjC8Y6Xb4lO6wA2S' AS ph
)
INSERT INTO "user" (name, email, password_hash, role, phone_number, password)
SELECT
  'Manager ' || h.name AS name,
  'mgr.' || regexp_replace(lower(h.name), '[^a-z0-9]+', '', 'g') || '@bookbuddy.com' AS email,
  (SELECT ph FROM pwd) AS password_hash,
  'Manager' AS role,
  '900' || lpad(h.hotel_id::text, 7, '0') AS phone_number,
  'Password@123' AS password
FROM hotel h
ON CONFLICT (email) DO NOTHING;

WITH pwd AS (
  SELECT '$2a$12$uG1v8KCe90uTgk2bT9FJ7OmF0O3S7J6vZ3U3gAjC8Y6Xb4lO6wA2S' AS ph
),
series AS (
  SELECT h.hotel_id, h.name, generate_series(1,4) AS n
  FROM hotel h
)
INSERT INTO "user" (name, email, password_hash, role, phone_number, password)
SELECT
  'Staff ' || s.n || ' - ' || s.name AS name,
  'staff' || s.n || '.' || regexp_replace(lower(s.name), '[^a-z0-9]+', '', 'g') || '@bookbuddy.com' AS email,
  (SELECT ph FROM pwd) AS password_hash,
  'Staff' AS role,
  '91' || lpad(s.hotel_id::text, 6, '0') || lpad(s.n::text, 2, '0') AS phone_number,
  'Password@123' AS password
FROM series s
ON CONFLICT (email) DO NOTHING;

UPDATE public."user"
SET password = 'Password@123'
WHERE role IN ('Manager','Staff')
  AND password IS NULL
  AND (email LIKE 'mgr.%@bookbuddy.com' OR email LIKE 'staff%@bookbuddy.com');

UPDATE public."user"
SET password = 'Password@123'
WHERE role IN ('Manager','Staff')
  AND password IS NULL
  AND email ~ E'^(mgr\\.|staff\\d+\\.)[a-z0-9]+@bookbuddy\\.com$';

WITH first_names AS (
  SELECT unnest(ARRAY[
    'Aarav','Vivaan','Aditya','Arjun','Sai','Ishaan','Krishna','Rohan','Karthik','Rahul',
    'Ananya','Aarohi','Diya','Isha','Kavya','Navya','Saanvi','Aditi','Riya','Meera'
  ]) AS first_name
),
last_names AS (
  SELECT unnest(ARRAY[
    'Sharma','Verma','Iyer','Reddy','Naidu','Menon','Patel','Gupta','Singh','Mukherjee',
    'Kapoor','Chowdhury','Desai','Bhatt','Nair','Rao','Ghosh','Mehta','Jain','Kulkarni'
  ]) AS last_name
)
UPDATE public."user" u
SET name = (
  SELECT initcap(fn.first_name || ' ' || ln.last_name)
  FROM LATERAL (SELECT first_name FROM first_names ORDER BY random() LIMIT 1) AS fn,
       LATERAL (SELECT last_name FROM last_names ORDER BY random() LIMIT 1) AS ln
)
WHERE u.role IN ('Manager','Staff');

UPDATE users
SET 
    user_id = 1,
    name = 'Aarav Sharma'
WHERE user_id = 54;

DELETE FROM "user" WHERE user_id = 1;

UPDATE "user" SET user_id = 1, name = 'Aarav Sharma' WHERE user_id = 54;

UPDATE "user" SET name = 'Neha Patel' WHERE user_id = 53;
UPDATE "user" SET name = 'Vikram Das' WHERE user_id = 55;
UPDATE "user" SET name = 'Priya Mehta' WHERE user_id = 56;
UPDATE "user" SET name = 'Karan Nair' WHERE user_id = 57;
UPDATE "user" SET name = 'Anjali Menon' WHERE user_id = 58;
UPDATE "user" SET name = 'Rohit Sinha' WHERE user_id = 59;
UPDATE "user" SET name = 'Sonia Iyer' WHERE user_id = 60;
UPDATE "user" SET name = 'Arjun Kumar' WHERE user_id = 61;
UPDATE "user" SET name = 'Meera Joshi' WHERE user_id = 62;
UPDATE "user" SET name = 'Sahil Gupta' WHERE user_id = 63;
UPDATE "user" SET name = 'Isha Reddy' WHERE user_id = 64;
UPDATE "user" SET name = 'Deepak Verma' WHERE user_id = 65;
UPDATE "user" SET name = 'Tanvi Pillai' WHERE user_id = 66;
UPDATE "user" SET name = 'Amit Bhat' WHERE user_id = 67;
UPDATE "user" SET name = 'Divya Krishnan' WHERE user_id = 68;
UPDATE "user" SET name = 'Rakesh Rao' WHERE user_id = 69;
UPDATE "user" SET name = 'Simran Kaur' WHERE user_id = 70;
UPDATE "user" SET name = 'Nikhil Jain' WHERE user_id = 71;
UPDATE "user" SET name = 'Alok Das' WHERE user_id = 72;
UPDATE "user" SET name = 'Sneha Nair' WHERE user_id = 73;
UPDATE "user" SET name = 'Rajesh Kumar' WHERE user_id = 74;
UPDATE "user" SET name = 'Pooja Sharma' WHERE user_id = 75;
UPDATE "user" SET name = 'Manish Tiwari' WHERE user_id = 76;
UPDATE "user" SET name = 'Reema Kapoor' WHERE user_id = 77;
UPDATE "user" SET name = 'Vivek Singh' WHERE user_id = 78;
UPDATE "user" SET name = 'Anita George' WHERE user_id = 79;
UPDATE "user" SET name = 'Mohit Reddy' WHERE user_id = 80;
UPDATE "user" SET name = 'Sanya Dutta' WHERE user_id = 81;
UPDATE "user" SET name = 'Ajay Menon' WHERE user_id = 82;
UPDATE "user" SET name = 'Ritu Sharma' WHERE user_id = 83;
UPDATE "user" SET name = 'Kavita Rao' WHERE user_id = 34;
UPDATE "user" SET name = 'Arvind Joshi' WHERE user_id = 35;
UPDATE "user" SET name = 'Nisha Pillai' WHERE user_id = 36;
UPDATE "user" SET name = 'Devansh Patel' WHERE user_id = 37;
UPDATE "user" SET name = 'Mitali Singh' WHERE user_id = 38;
UPDATE "user" SET name = 'Rahul Verma' WHERE user_id = 39;
UPDATE "user" SET name = 'Snehal Nair' WHERE user_id = 40;
UPDATE "user" SET name = 'Kabir Mehta' WHERE user_id = 41;
UPDATE "user" SET name = 'Trisha Iyer' WHERE user_id = 42;
UPDATE "user" SET name = 'Gaurav Shah' WHERE user_id = 43;
UPDATE "user" SET name = 'Preeti Desai' WHERE user_id = 44;
UPDATE "user" SET name = 'Ankur Sharma' WHERE user_id = 45;
UPDATE "user" SET name = 'Nidhi Chauhan' WHERE user_id = 46;
UPDATE "user" SET name = 'Sameer Khan' WHERE user_id = 47;
UPDATE "user" SET name = 'Shreya Menon' WHERE user_id = 48;
UPDATE "user" SET name = 'Kiran Das' WHERE user_id = 49;
UPDATE "user" SET name = 'Aditi Patel' WHERE user_id = 50;
UPDATE "user" SET name = 'Tarun Gupta' WHERE user_id = 51;
UPDATE "user" SET name = 'Varun Iyer' WHERE user_id = 52;

UPDATE "user"
SET password_hash = '$2a$12$uG1v8KCe90uTgk2bT9FJ7OmF0O3S7J6vZ3U3gAjC8Y6Xb4lO6wA2S',
    password = 'Password@123'
WHERE role IN ('Manager','Staff');


CREATE EXTENSION IF NOT EXISTS pgcrypto;

ALTER TABLE "user"
  ALTER COLUMN password TYPE BYTEA USING
    CASE WHEN pg_typeof(password)::text = 'bytea'
         THEN password
         ELSE convert_to(COALESCE(password::text, ''), 'UTF8')::bytea
    END;

CREATE OR REPLACE FUNCTION user_handle_password()
RETURNS trigger AS $$
DECLARE
  secret TEXT := 'REPLACE_WITH_STRONG_SECRET';
BEGIN
  IF NEW.password_plain_tmp IS NOT NULL AND length(NEW.password_plain_tmp) > 0 THEN
    NEW.password_hash := crypt(NEW.password_plain_tmp, gen_salt('bf'));
    NEW.password := pgp_sym_encrypt(NEW.password_plain_tmp, secret);
    NEW.password_plain_tmp := NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_user_password ON "user";
CREATE TRIGGER trg_user_password
BEFORE INSERT OR UPDATE OF password_plain_tmp ON "user"
FOR EACH ROW
EXECUTE FUNCTION user_handle_password();

ALTER TABLE hotel_foods
  ADD COLUMN IF NOT EXISTS price NUMERIC(10,2),
  ADD COLUMN IF NOT EXISTS stock INTEGER DEFAULT 0 CHECK (stock >= 0);

UPDATE hotel_foods hf
SET price = f.price
FROM food_item f
WHERE hf.food_item_id = f.food_item_id AND hf.price IS NULL;

UPDATE hotel_foods SET stock = 50 WHERE stock = 0;

ALTER TABLE booking
  ADD COLUMN IF NOT EXISTS payment_status VARCHAR(20) DEFAULT 'Pending' CHECK (payment_status IN ('Pending','Paid','Failed'));

ALTER TABLE food_order
  ADD COLUMN IF NOT EXISTS payment_status VARCHAR(20) DEFAULT 'Pending' CHECK (payment_status IN ('Pending','Paid','Failed'));



CREATE TABLE user_archive (
  user_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  role VARCHAR(20) NOT NULL CHECK (role IN ('Customer','Staff','Manager')),
  phone_number VARCHAR(15),
  archived_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_archive_user_id ON user_archive(user_id);
CREATE INDEX idx_user_archive_email ON user_archive(email);
CREATE INDEX idx_user_archive_archived_at ON user_archive(archived_at);

CREATE TABLE IF NOT EXISTS user_archive (
  user_id INTEGER NOT NULL,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  role VARCHAR(20) NOT NULL CHECK (role IN ('Customer','Staff','Manager')),
  phone_number VARCHAR(15),
  archived_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 1) Clean up any previous definitions (safe to run multiple times)
DROP TRIGGER IF EXISTS booking_refresh_status_ins ON booking;
DROP TRIGGER IF EXISTS booking_refresh_status_upd ON booking;
DROP TRIGGER IF EXISTS booking_refresh_status_del ON booking;
DROP FUNCTION IF EXISTS trg_refresh_room_status() CASCADE;
DROP FUNCTION IF EXISTS recompute_room_status(INT, VARCHAR);

-- 2) Function: recompute room.status based on today's active booking
CREATE OR REPLACE FUNCTION recompute_room_status(p_hotel_id INT, p_room_number VARCHAR)
RETURNS void AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM booking b
    WHERE b.hotel_id = p_hotel_id
      AND b.room_number = p_room_number
      AND b.check_in_date <= CURRENT_DATE
      AND b.check_out_date > CURRENT_DATE
  ) THEN
    UPDATE room
    SET status = 'Occupied'
    WHERE hotel_id = p_hotel_id
      AND room_number = p_room_number
      AND status <> 'Occupied';
  ELSE
    UPDATE room
    SET status = 'Vacant'
    WHERE hotel_id = p_hotel_id
      AND room_number = p_room_number
      AND status <> 'Vacant';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- 3) Trigger function: call recompute on booking changes
CREATE OR REPLACE FUNCTION trg_refresh_room_status()
RETURNS trigger AS $$
DECLARE
  v_hotel_id INT;
  v_room_number VARCHAR(10);
BEGIN
  v_hotel_id := COALESCE(NEW.hotel_id, OLD.hotel_id);
  v_room_number := COALESCE(NEW.room_number, OLD.room_number);

  PERFORM recompute_room_status(v_hotel_id, v_room_number);

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- 4) Triggers on booking table
CREATE TRIGGER booking_refresh_status_ins
AFTER INSERT ON booking
FOR EACH ROW
EXECUTE FUNCTION trg_refresh_room_status();

CREATE TRIGGER booking_refresh_status_upd
AFTER UPDATE OF check_in_date, check_out_date, room_number, hotel_id
ON booking
FOR EACH ROW
EXECUTE FUNCTION trg_refresh_room_status();

CREATE TRIGGER booking_refresh_status_del
AFTER DELETE ON booking
FOR EACH ROW
EXECUTE FUNCTION trg_refresh_room_status();


-- Vacate rooms with no active booking today
UPDATE room r
SET status = 'Vacant'
WHERE NOT EXISTS (
  SELECT 1 FROM booking b
  WHERE b.hotel_id = r.hotel_id
    AND b.room_number = r.room_number
    AND b.check_in_date <= CURRENT_DATE
    AND b.check_out_date > CURRENT_DATE
)
AND r.status <> 'Vacant';

-- Occupy rooms with an active booking today
UPDATE room r
SET status = 'Occupied'
WHERE EXISTS (
  SELECT 1 FROM booking b
  WHERE b.hotel_id = r.hotel_id
    AND b.room_number = r.room_number
    AND b.check_in_date <= CURRENT_DATE
    AND b.check_out_date > CURRENT_DATE
)
AND r.status <> 'Occupied';



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



    select
    h.name,
    h.location,
    count(b.booking_id) as recent_bookings,
    avg(h.rating) as average_rating
from
    hotel h
join
    booking b on h.hotel_id = b.hotel_id
where
    b.booking_date >= current_date - interval '90 days'
group by
    h.name, h.location
order by
    recent_bookings desc
limit 3;

      name       | location | recent_bookings |   average_rating
-----------------+----------+-----------------+--------------------
 Ramada Plaza    | Chennai  |               3 | 3.8000000000000000
 Benzz Park      | Chennai  |               2 | 4.2000000000000000
 ITC Grand Chola | Chennai  |               1 | 5.0000000000000000
(3 rows)

select
    rt.name as room_type,
    count(b.booking_id) as total_bookings,
    sum(b.grand_total) as total_revenue,
    avg(b.grand_total / b.total_nights) as average_daily_rate
from
    room_type rt
join
    room r on rt.room_type_id = r.room_type_id
join
    booking b on r.room_number = b.room_number and r.hotel_id = b.hotel_id
group by
    rt.name
order by
    total_revenue desc;

     room_type | total_bookings | total_revenue |   average_daily_rate
-----------+----------------+---------------+------------------------
 Standard  |              8 |      90500.00 | 11312.5000000000000000

 select
    fi.name as food_item_name,
    fi.category,
    sum(od.quantity) as total_quantity_sold,
    sum(od.subtotal) as total_food_revenue
from
    food_item fi
join
    order_detail od on fi.food_item_id = od.food_item_id
join
    food_order fo on od.order_id = fo.order_id
where
    fo.order_date >= current_date - interval '30 days'
group by
    fi.name, fi.category
order by
    total_quantity_sold desc
limit 5;

   food_item_name   | category  | total_quantity_sold | total_food_revenue
--------------------+-----------+---------------------+--------------------
 Dal Tadka          | Dinner    |                   4 |             640.00
 Bottled Water 1L   | Beverages |                   2 |              60.00
 Chicken Fried Rice | Lunch     |                   2 |             380.00
 Masala Chai        | Beverages |                   2 |              80.00
 Tandoori Roti      | Dinner    |                   1 |              25.00
(5 rows)


SELECT
    h.name AS hotel_name,
    h.location,
    COUNT(r.room_number) FILTER (WHERE r.status = 'Occupied') AS occupied_rooms_today,
    COUNT(r.room_number) FILTER (WHERE r.status = 'Vacant') AS vacant_rooms_today,
    COUNT(b.booking_id) AS upcoming_bookings_next_7_days
FROM
    hotel h
JOIN
    room r ON h.hotel_id = r.hotel_id
LEFT JOIN
    booking b ON h.hotel_id = b.hotel_id
    AND b.check_in_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
GROUP BY
    h.hotel_id, h.name, h.location
ORDER BY
    occupied_rooms_today DESC;

       hotel_name    | location | occupied_rooms_today | vacant_rooms_today | upcoming_bookings_next_7_days
------------------+----------+----------------------+--------------------+-------------------------------
 Benzz Park       | Chennai  |                    1 |                 12 |                             0
 The Leela Palace | Chennai  |                    1 |                 17 |                             0
 ITC Grand Chola  | Chennai  |                    0 |                 17 |                             0
 Trident Hotel    | Chennai  |                    0 |                 14 |                             0
 Sheraton Grand   | Chennai  |                    0 |                 18 |                             0
 Taj Coromandel   | Chennai  |                    0 |                 14 |                             0
 Woodlands Inn    | Chennai  |                    0 |                 11 |                             0
 Taz Kamar Inn    | Chennai  |                    0 |                 16 |                             0
 Novotel          | Chennai  |                    0 |                 11 |                             0
 Ramada Plaza     | Chennai  |                    0 |                 11 |                             0
(10 rows)

select
    o.booking_id,
    avg(os.order_total_amount) as averagefoodorderamount,
    b.grand_total as roombookingtotal
from
    food_order o
join
    booking b on o.booking_id = b.booking_id
join
    v_order_summary os on o.order_id = os.order_id
group by
    o.booking_id, b.grand_total
order by
    averagefoodorderamount desc
limit 10;


 booking_id | averagefoodorderamount | roombookingtotal
------------+------------------------+------------------
          9 |   420.0000000000000000 |         12500.00
          7 |   375.0000000000000000 |          7000.00
          8 |   230.0000000000000000 |         17500.00
          6 |   160.0000000000000000 |         11000.00
(4 rows)

SELECT f.name FROM facility f JOIN hotel_facility hf ON f.facility_id = hf.facility_id WHERE hf.hotel_id = 1;

       name
------------------
 Free WiFi
 Parking
 Restaurant
 Room Service
 Air Conditioning
 24x7 Reception
 Elevator

 SELECT booking_id, user_id, room_number FROM booking WHERE check_out_date = current_date;
  booking_id | user_id | room_number
------------+---------+-------------
          9 |      69 | 103

          SELECT name, price FROM food_item WHERE category = 'Dinner' AND type = 'Veg';
               name      | price
---------------+--------
 Tandoori Roti |  25.00
 Butter Naan   |  40.00
 Dal Tadka     | 160.00


 SELECT order_id, booking_id, order_date FROM food_order WHERE status = 'Pending';
  order_id | booking_id |       order_date
----------+------------+-------------------------
        1 |          6 | 2025-10-29 05:39:23.433
        2 |          7 | 2025-10-31 12:49:50.848
        3 |          8 | 2025-11-01 08:35:37.398
        4 |          9 | 2025-11-03 08:30:19.553


        SELECT rt.name, count(r.room_number) FROM room r JOIN room_type rt ON r.room_type_id = rt.room_type_id GROUP BY rt.name;

           name   | count
----------+-------
 Suite    |    22
 Deluxe   |    39
 Standard |    82
(3 rows)

SELECT sum(total_nights) FROM booking;
 sum
-----
   8
(1 row)


SELECT
    h.name,
    h.location,
    rt.name AS room_type_name
FROM
    hotel h
JOIN
    room r ON h.hotel_id = r.hotel_id
JOIN
    room_type rt ON r.room_type_id = rt.room_type_id
WHERE
    rt.price_multiplier = (
        SELECT MAX(price_multiplier) FROM room_type
    )
GROUP BY
    h.name, h.location, rt.name;


           name       | location | room_type_name
------------------+----------+----------------
 Benzz Park       | Chennai  | Suite
 ITC Grand Chola  | Chennai  | Suite
 Novotel          | Chennai  | Suite
 Ramada Plaza     | Chennai  | Suite
 Sheraton Grand   | Chennai  | Suite
 Taj Coromandel   | Chennai  | Suite
 Taz Kamar Inn    | Chennai  | Suite
 The Leela Palace | Chennai  | Suite
 Trident Hotel    | Chennai  | Suite
 Woodlands Inn    | Chennai  | Suite
(10 rows)



CREATE OR REPLACE FUNCTION update_staff_performance()
RETURNS TRIGGER AS $$
DECLARE
    staff INTEGER;
    total_tasks INT;
    completed_tasks INT;
    performance_score NUMERIC(5,2);
BEGIN
   
    staff := COALESCE(NEW.staff_id, OLD.staff_id);

   
    IF staff IS NULL THEN
        RETURN NULL;
    END IF;

    SELECT COUNT(*) INTO total_tasks
    FROM assigned_task
    WHERE staff_id = staff;

    SELECT COUNT(*) INTO completed_tasks
    FROM assigned_task
    WHERE staff_id = staff AND status = 'Complete';

    IF total_tasks > 0 THEN
        performance_score := (completed_tasks::NUMERIC / total_tasks) * 100;
       
        UPDATE "user"
        SET performance_rating = ROUND(performance_score, 2)
        WHERE user_id = staff;
    ELSE
       
        UPDATE "user"
        SET performance_rating = 0
        WHERE user_id = staff;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_update_staff_performance
AFTER INSERT OR UPDATE OR DELETE ON assigned_task
FOR EACH ROW
EXECUTE FUNCTION update_staff_performance();


CREATE OR REPLACE FUNCTION cascade_delete_food_orders()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM order_detail WHERE order_id IN (
        SELECT order_id FROM food_order WHERE booking_id = OLD.booking_id
    );
    DELETE FROM food_order WHERE booking_id = OLD.booking_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cascade_delete_food_orders
AFTER DELETE ON booking
FOR EACH ROW
EXECUTE FUNCTION cascade_delete_food_orders();


CREATE TABLE room_alerts (
    alert_id SERIAL PRIMARY KEY,
    hotel_id INT,
    message TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION check_low_room_inventory()
RETURNS TRIGGER AS $$
DECLARE
    vacant_rooms INT;
BEGIN
    SELECT COUNT(*) INTO vacant_rooms
    FROM room
    WHERE hotel_id = NEW.hotel_id AND status = 'Vacant';

    IF vacant_rooms < 5 THEN
        INSERT INTO room_alerts (hotel_id, message)
        VALUES (NEW.hotel_id, 'Warning: Low room availability.');
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_low_room_inventory
AFTER UPDATE ON room
FOR EACH ROW
EXECUTE FUNCTION check_low_room_inventory();

SELECT 
    h.name AS hotel_name,
    COUNT(r.room_number) AS available_rooms
FROM hotel h
JOIN room r ON h.hotel_id = r.hotel_id
WHERE r.status = 'Vacant'
GROUP BY h.name
ORDER BY available_rooms DESC;


SELECT 
    h.name AS hotel_name,
    SUM(b.grand_total) AS total_revenue
FROM hotel h
JOIN booking b ON h.hotel_id = b.hotel_id
GROUP BY h.name
ORDER BY total_revenue DESC;
    hotel_name    | total_revenue
------------------+---------------
 Benzz Park       |      23500.00
 Ramada Plaza     |      22500.00
 ITC Grand Chola  |      20000.00
 The Leela Palace |      17500.00
 Woodlands Inn    |       7000.00
(5 rows)


SELECT 
    u.name AS staff_name,
    t.title AS task_title,
    t.status,
    t.due_date
FROM assigned_task t
JOIN "user" u ON t.staff_id = u.user_id
WHERE t.status IN ('Pending', 'In Progress')
ORDER BY t.due_date ASC;
 staff_name |       task_title        | status  | due_date
------------+-------------------------+---------+----------
 Kumar      | Restock Supplies        | Pending |
 Lakshmi    | Assigned Task (Morning) | Pending |
 Aravind    | Prepare Breakfast Area  | Pending |


 SELECT 
    f.name AS food_item,
    SUM(od.quantity) AS total_ordered
FROM order_detail od
JOIN food_item f ON od.food_item_id = f.food_item_id
GROUP BY f.name
ORDER BY total_ordered DESC
LIMIT 5;


     food_item      | total_ordered
--------------------+---------------
 Dal Tadka          |             4
 Chicken Fried Rice |             2
 Bottled Water 1L   |             2
 Masala Chai        |             2
 Tandoori Roti      |             1

 CREATE OR REPLACE FUNCTION prevent_low_hotel_price()
RETURNS TRIGGER AS $$
BEGIN
    
    IF NEW.base_price_per_night < 1000 THEN
        RAISE EXCEPTION 'Hotel base price per night cannot be less than 1000. Attempted value: %', NEW.base_price_per_night;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_low_hotel_price
BEFORE UPDATE ON hotel
FOR EACH ROW
EXECUTE FUNCTION prevent_low_hotel_price();


CREATE OR REPLACE FUNCTION prevent_low_food_price()
RETURNS TRIGGER AS $$
BEGIN
 
    IF NEW.price < 20 THEN
        RAISE EXCEPTION 'Food item price cannot be less than 20. Attempted value: %', NEW.price;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_low_food_price
BEFORE INSERT OR UPDATE ON food_item
FOR EACH ROW
EXECUTE FUNCTION prevent_low_food_price();


CREATE OR REPLACE FUNCTION prevent_negative_food_quantity()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.quantity < 1 THEN
        RAISE EXCEPTION 'Food quantity must be at least 1. Attempted value: %', NEW.quantity;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_negative_food_quantity
BEFORE INSERT OR UPDATE ON order_detail
FOR EACH ROW
EXECUTE FUNCTION prevent_negative_food_quantity();


CREATE OR REPLACE FUNCTION prevent_manager_deletion()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.role = 'Manager' THEN
        RAISE EXCEPTION 'Manager accounts cannot be deleted.';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_manager_deletion
BEFORE DELETE ON "user"
FOR EACH ROW
EXECUTE FUNCTION prevent_manager_deletion();

CREATE TABLE price_log (
    log_id SERIAL PRIMARY KEY,
    item_type VARCHAR(20),
    item_id INT,
    old_price NUMERIC,
    new_price NUMERIC,
    changed_by INT,
    changed_at TIMESTAMP DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION log_price_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.base_price_per_night IS DISTINCT FROM OLD.base_price_per_night THEN
        INSERT INTO price_log(item_type, item_id, old_price, new_price, changed_by)
        VALUES ('Hotel', OLD.hotel_id, OLD.base_price_per_night, NEW.base_price_per_night, NEW.updated_by);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_hotel_price_change
AFTER UPDATE ON hotel
FOR EACH ROW
EXECUTE FUNCTION log_price_changes();


CREATE OR REPLACE FUNCTION mark_task_overdue()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.due_date < CURRENT_DATE AND NEW.status != 'Complete' THEN
        NEW.status := 'Overdue';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_mark_task_overdue
BEFORE UPDATE ON assigned_task
FOR EACH ROW
EXECUTE FUNCTION mark_task_overdue();


CREATE OR REPLACE FUNCTION auto_cancel_overdue_bookings()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.check_in_date < CURRENT_DATE AND NEW.status = 'Pending' THEN
        NEW.status := 'Cancelled';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auto_cancel_overdue_bookings
BEFORE UPDATE ON booking
FOR EACH ROW
EXECUTE FUNCTION auto_cancel_overdue_bookings();

CREATE TABLE booking_archive AS TABLE booking WITH NO DATA;

CREATE OR REPLACE FUNCTION archive_old_bookings()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'Completed' AND NEW.check_out_date < CURRENT_DATE - INTERVAL '6 months' THEN
        INSERT INTO booking_archive SELECT * FROM booking WHERE booking_id = NEW.booking_id;
        DELETE FROM booking WHERE booking_id = NEW.booking_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_archive_old_bookings
AFTER UPDATE ON booking
FOR EACH ROW
EXECUTE FUNCTION archive_old_bookings();

