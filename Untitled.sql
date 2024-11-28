create database bookmyshow;

use bookmyshow;

create table location (
    location_ID int primary key, 
    country varchar(225) not null, 
    state varchar(225) not null, 
    city varchar(225) not null, 
    additional varchar(225), 
    pincode int(7)
);

create table users (
	user_ID int primary key auto_increment, 
    first_name varchar(225) not null, 
    last_name varchar(225), 
    phone_number varchar(11) not null, 
    email varchar(225) not null, 
    password varchar(225) not null, 
    location_ID int, 
    foreign key(location_ID) references location(location_ID) on delete cascade
);

create table events (
	event_id int primary key auto_increment, 
    event_type varchar(225) not null, 
    genre varchar(100) not null, 
    language varchar(50) not null, 
    duration int not null, 
    age_rating varchar(10) not null
); 

create table venue (
	venue_ID int primary key, 
    location_id int, 
    venue_name varchar(225) not null, 
    foreign key(location_id) references location(location_id) on delete cascade
);

create table screens (
	screen_id int primary key, 
	venue_id int, 
	screen_number int not null, 
	seating_capacity int(10) not null, 
	foreign key(venue_id) references venue(venue_id)
);

create table show_timings (
	show_id int primary key, 
    event_id int, 
    screen_id int, 
    show_date date not null, 
    show_time time not null, 
    foreign key(event_id) references events(event_id) on delete cascade, 
    foreign key(screen_id) references screens(screen_id) on delete cascade
);

create table seats (
	seat_id int primary key, 
    seat_column int not null, 
    seat_row int not null, 
    screen_id int, 
    is_available boolean, 
    foreign key(screen_id) references screens(screen_id) on delete cascade
);

create table booking (
	booking_id int primary key, 
    user_id int, 
    show_id int, 
    booking timestamp default current_timestamp, 
    booking_date date, 
    total_amount float not null, 
    status varchar(225) not null, 
    foreign key(user_id) references users(user_id) on delete cascade, 
    foreign key(show_id) references show_timings(show_id) on delete cascade
);

create table booked_seat (
	booking_seat_id int primary key, 
    seat_id int, 
    booking_id int, 
    foreign key(seat_id) references seats(seat_id) on delete cascade, 
    foreign key(booking_id) references booking(booking_id) on delete cascade
);

create table snacks (
	meal_id int primary key, 
    show_id int, 
    booking_seat_id int, 
    user_id int, 
    meal_type varchar(225) not null, 
    total_amount float, 
    foreign key(show_id) references show_timings(show_id) on delete cascade, 
    foreign key(booking_seat_id) references booked_seat(booking_seat_id) on delete cascade
);  

create table coupon (
	coupon_id int primary key, 
    coupon_code varchar(225), 
    booking_id int, 
    user_id int, 
    coupon_description text, 
    discount float not null, 
    foreign key(booking_id) references booking(booking_id) on delete cascade, 
    foreign key(user_id) references users(user_id) on delete cascade
);

-- Payment table with linked snack total and coupon discount
CREATE TABLE payment (
    payment_id INT PRIMARY KEY,
    booking_id INT,
    coupon_id INT,
    payment_date DATE,
    payment_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount FLOAT NOT NULL,
    snack_total FLOAT DEFAULT 0, -- Added snack_total column
    coupon_discount FLOAT DEFAULT 0, -- Added coupon_discount column
    final_amount FLOAT, -- This will store the calculated final amount
    FOREIGN KEY(booking_id) REFERENCES booking(booking_id) ON DELETE CASCADE,
    FOREIGN KEY(coupon_id) REFERENCES coupon(coupon_id) ON DELETE CASCADE
);

DELIMITER //

CREATE TRIGGER calculate_final_amount
BEFORE INSERT ON payment
FOR EACH ROW
BEGIN
    DECLARE snack_total FLOAT;
    DECLARE coupon_discount FLOAT;

    -- Calculate the snack total by summing the total_amount from snacks for this booking_id
    SELECT IFNULL(SUM(total_amount), 0) INTO snack_total
    FROM snacks
    WHERE booking_seat_id IN (
        SELECT booking_seat_id 
        FROM booked_seat 
        WHERE booking_id = NEW.booking_id
    );
    
    -- Get the coupon discount for the booking (if a coupon is applied)
    SELECT IFNULL(discount, 0) INTO coupon_discount
    FROM coupon
    WHERE booking_id = NEW.booking_id;

    -- Set the snack_total and coupon_discount into the new payment row
    SET NEW.snack_total = snack_total;
    SET NEW.coupon_discount = coupon_discount;

    -- Calculate the final amount (total_amount + snack_total - coupon_discount) * 1.08 for GST
    SET NEW.final_amount = ((NEW.total_amount + NEW.snack_total - NEW.coupon_discount) * 1.08);
END //

DELIMITER ;
