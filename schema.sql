create database bookmyshow;

-- this will help to open the database which we have to use
use bookmyshow;

create table location (
	location_id int primary key,
    country varchar (50) not null,
    state varchar(50)not null,
    city varchar(50) not null,
    additional varchar(100),
    pincode int(7) not null
);

create table users (
	user_id int primary key,
    first_name varchar(50) not null,
    last_name varchar(50),
    phone_number varchar(11) not null,
	email varchar(100) not null,
    password varchar(30) not null,
    location_id int,
    foreign key(location_id) references location(location_id) on delete cascade
);

create table events (
	event_id int primary key,
    event_type varchar(50) not null,
    genre varchar(100) not null,
    language varchar(50) not null,
    duration int not null,
    age_rating varchar(10) not null
);

create table venue (
	venue_id int primary key,
    location_id int, 
    venue_name varchar(100) not null,
    foreign key(location_id) references location(location_id) on delete cascade
);

create table screens (
	screen_id int primary key,
    venue_id int,
    screen_number int not null,
    seating_capacity int not null,
    foreign key(venue_id) references venue(venue_id) on delete cascade 
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
    show_id int,
    booking timestamp default current_timestamp,
    booking_amount float not null,
    status varchar(50) not null,
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
    meal_type varchar(50) not null,
    meal_amount float not null
);

create table coupon (
	coupon_id int primary key,
    coupon_code varchar(50) not null,
    coupon_description text,
    coupon_discount float not null
);

CREATE TABLE payment (
    payment_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    meal_id INT,
    coupon_id INT,
    payment_date DATE NOT NULL,
    payment_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    booking_amount INT NOT NULL CHECK (booking_amount >= 0),
    meal_amount INT DEFAULT 0, -- Updated by trigger
    coupon_discount INT DEFAULT 0, -- Updated by trigger
    total_amount FLOAT GENERATED ALWAYS AS (
        (
            (booking_amount + COALESCE(meal_amount, 0)) - 
            ((booking_amount + COALESCE(meal_amount, 0)) * (COALESCE(coupon_discount, 0) / 100))
        ) + 
        (
            (
                (booking_amount + COALESCE(meal_amount, 0)) - 
                ((booking_amount + COALESCE(meal_amount, 0)) * (COALESCE(coupon_discount, 0) / 100))
            ) * 0.08
        )
    ) STORED,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (meal_id) REFERENCES snacks(meal_id) ON DELETE SET NULL,
    FOREIGN KEY (coupon_id) REFERENCES coupon(coupon_id) ON DELETE SET NULL
);

DELIMITER //

CREATE TRIGGER before_payment_insert
BEFORE INSERT ON payment
FOR EACH ROW
BEGIN
    IF NEW.meal_id IS NOT NULL THEN
        SET NEW.meal_amount = (SELECT meal_amount FROM snacks WHERE snacks.meal_id = NEW.meal_id);
    ELSE
        SET NEW.meal_amount = 0;
    END IF;

    IF NEW.coupon_id IS NOT NULL THEN
        SET NEW.coupon_discount = (SELECT coupon_discount FROM coupon WHERE coupon.coupon_id = NEW.coupon_id);
    ELSE
        SET NEW.coupon_discount = 0;
    END IF;
END;
//

DELIMITER ;

DELIMITER //

CREATE TRIGGER before_payment_update
BEFORE UPDATE ON payment
FOR EACH ROW
BEGIN
    IF NEW.meal_id IS NOT NULL THEN
        SET NEW.meal_amount = (SELECT meal_amount FROM snacks WHERE snacks.meal_id = NEW.meal_id);
    ELSE
        SET NEW.meal_amount = 0;
    END IF;

    IF NEW.coupon_id IS NOT NULL THEN
        SET NEW.coupon_discount = (SELECT coupon_discount FROM coupon WHERE coupon.coupon_id = NEW.coupon_id);
    ELSE
        SET NEW.coupon_discount = 0;
    END IF;
END;
//

DELIMITER ;

INSERT INTO location (location_id, country, state, city, additional, pincode)
VALUES
(1001, 'India', 'Delhi', 'New Delhi', 'Connaught Place', 110001),
(1002, 'India', 'Maharashtra', 'Mumbai', 'Andheri', 400001),
(1003, 'India', 'Uttar Pradesh', 'Noida', 'Sector 18', 201301),
(1004, 'India', 'Tamil Nadu', 'Chennai', 'T Nagar', 600017),
(1005, 'India', 'Karnataka', 'Bangalore', 'Koramangala', 560034),
(1006, 'India', 'Kerala', 'Kochi', 'MG Road', 682011),
(1007, 'India', 'West Bengal', 'Kolkata', 'Park Street', 700016),
(1008, 'India', 'Rajasthan', 'Jaipur', 'C-Scheme', 302001),
(1009, 'India', 'Gujarat', 'Ahmedabad', 'SG Highway', 380054),
(1010, 'India', 'Madhya Pradesh', 'Indore', 'Vijay Nagar', 452010);

INSERT INTO users (user_id, first_name, last_name, phone_number, email, password, location_id)
VALUES
(2001, 'John', 'Doe', '9876543210', 'john.doe@example.com', 'password123', 1001),
(2002, 'Jane', 'Smith', '9988776655', 'jane.smith@example.com', 'password456', 1002),
(2003, 'Robert', 'Brown', '9556677889', 'robert.brown@example.com', 'password789', 1003),
(2004, 'Emily', 'Davis', '9223344556', 'emily.davis@example.com', 'password101', 1004),
(2005, 'David', 'Miller', '9445566777', 'david.miller@example.com', 'password202', 1005),
(2006, 'Sarah', 'Wilson', '9333221111', 'sarah.wilson@example.com', 'password303', 1006),
(2007, 'Michael', 'Taylor', '9112233445', 'michael.taylor@example.com', 'password404', 1007),
(2008, 'Jessica', 'Anderson', '9001122334', 'jessica.anderson@example.com', 'password505', 1008),
(2009, 'William', 'Thomas', '9877766554', 'william.thomas@example.com', 'password606', 1009),
(2010, 'Linda', 'Moore', '9612345678', 'linda.moore@example.com', 'password707', 1010);

INSERT INTO events (event_id, event_type, genre, language, duration, age_rating)
VALUES
(3001, 'Movie', 'Action', 'English', 120, 'PG-13'),
(3002, 'Concert', 'Rock', 'English', 180, '18+'),
(3003, 'Play', 'Drama', 'Hindi', 150, 'All'),
(3004, 'Movie', 'Comedy', 'English', 110, 'PG'),
(3005, 'Concert', 'Jazz', 'English', 120, '18+'),
(3006, 'Movie', 'Horror', 'English', 130, 'R'),
(3007, 'Play', 'Musical', 'Hindi', 140, 'All'),
(3008, 'Movie', 'Romance', 'English', 100, 'PG'),
(3009, 'Concert', 'Classical', 'Indian', 90, 'All'),
(3010, 'Play', 'Comedy', 'English', 110, 'PG-13');

INSERT INTO venue (venue_id, location_id, venue_name)
VALUES
(4001, 1001, 'PVR Cinemas'),
(4002, 1002, 'Inox Cinemas'),
(4003, 1003, 'Satyam Cinemas'),
(4004, 1004, 'Carnival Cinemas'),
(4005, 1005, 'Cinepolis'),
(4006, 1006, 'Film City'),
(4007, 1007, 'Raj Mandir Cinemas'),
(4008, 1008, 'Wave Cinemas'),
(4009, 1009, 'Big Cinemas'),
(4010, 1010, 'Cineplex');

INSERT INTO screens (screen_id, venue_id, screen_number, seating_capacity)
VALUES
(5001, 4001, 1, 200),
(5002, 4002, 2, 250),
(5003, 4003, 1, 150),
(5004, 4004, 3, 180),
(5005, 4005, 2, 300),
(5006, 4006, 1, 220),
(5007, 4007, 1, 180),
(5008, 4008, 3, 200),
(5009, 4009, 2, 250),
(5010, 4010, 1, 230);

INSERT INTO show_timings (show_id, event_id, screen_id, show_date, show_time)
VALUES
(6001, 3001, 5001, '2024-12-10', '10:00:00'),
(6002, 3002, 5002, '2024-12-11', '13:30:00'),
(6003, 3003, 5003, '2024-12-12', '16:45:00'),
(6004, 3004, 5004, '2024-12-13', '19:00:00'),
(6005, 3005, 5005, '2024-12-14', '21:15:00'),
(6006, 3006, 5006, '2024-12-15', '10:30:00'),
(6007, 3007, 5007, '2024-12-16', '14:00:00'),
(6008, 3008, 5008, '2024-12-17', '17:30:00'),
(6009, 3009, 5009, '2024-12-18', '20:45:00'),
(6010, 3010, 5010, '2024-12-19', '23:00:00');

INSERT INTO seats (seat_id, seat_column, seat_row, screen_id, is_available)
VALUES
(7001, 1, 1, 5001, TRUE),
(7002, 2, 1, 5001, TRUE),
(7003, 3, 1, 5001, FALSE),
(7004, 1, 2, 5002, TRUE),
(7005, 2, 2, 5002, FALSE),
(7006, 3, 2, 5002, TRUE),
(7007, 1, 3, 5003, TRUE),
(7008, 2, 3, 5003, FALSE),
(7009, 3, 3, 5004, TRUE),
(7010, 1, 4, 5004, FALSE);

INSERT INTO booking (booking_id, show_id, booking, booking_amount, status)
VALUES
(8001, 6001, '2024-12-10 09:00:00', 500.00, 'Confirmed'),
(8002, 6002, '2024-12-11 12:30:00', 600.00, 'Pending'),
(8003, 6003, '2024-12-12 15:00:00', 700.00, 'Cancelled'),
(8004, 6004, '2024-12-13 18:30:00', 400.00, 'Confirmed'),
(8005, 6005, '2024-12-14 21:00:00', 800.00, 'Pending'),
(8006, 6006, '2024-12-15 11:00:00', 450.00, 'Confirmed'),
(8007, 6007, '2024-12-16 13:30:00', 550.00, 'Cancelled'),
(8008, 6008, '2024-12-17 16:00:00', 600.00, 'Confirmed'),
(8009, 6009, '2024-12-18 19:30:00', 650.00, 'Pending'),
(8010, 6010, '2024-12-19 22:00:00', 750.00, 'Confirmed');

INSERT INTO booked_seat (booking_seat_id, seat_id, booking_id)
VALUES
(9001, 7001, 8001),
(9002, 7002, 8002),
(9003, 7003, 8003),
(9004, 7004, 8004),
(9005, 7005, 8005),
(9006, 7006, 8006),
(9007, 7007, 8007),
(9008, 7008, 8008),
(9009, 7009, 8009),
(9010, 7010, 8010);

INSERT INTO snacks (meal_id, meal_type, meal_amount)
VALUES
(1001, 'Popcorn', 150.00),
(1002, 'Soda', 100.00),
(1003, 'Nachos', 120.00),
(1004, 'Burger', 200.00),
(1005, 'Pizza', 350.00),
(1006, 'Sandwich', 180.00),
(1007, 'Ice Cream', 90.00),
(1008, 'French Fries', 130.00),
(1009, 'Hot Dog', 150.00),
(1010, 'Coffee', 80.00);

INSERT INTO coupon (coupon_id, coupon_code, coupon_description, coupon_discount)
VALUES
(1101, 'MOVIE10', '10% off on movie tickets', 10),
(1102, 'SNACK20', '20% off on snacks', 20),
(1103, 'SUMMER15', '15% off on all bookings', 15),
(1104, 'WELCOME5', '5% off on first booking', 5),
(1105, 'FESTIVAL25', '25% off on all tickets', 25),
(1106, 'VIP30', '30% off on VIP tickets', 30),
(1107, 'EXTRA10', '10% off on snacks with booking', 10),
(1108, 'HOLIDAY50', '50% off on bookings', 50),
(1109, 'STUDENT5', '5% off for students', 5),
(1110, 'LOYALTY15', '15% off for loyal customers', 15);

INSERT INTO payment (payment_id, user_id, meal_id, coupon_id, payment_date, booking_amount, meal_amount, coupon_discount)
VALUES
(1201, 2001, NULL, 1101, '2024-12-10', 500.00, 150.00, 10),
(1202, 2002, NULL, NULL, '2024-12-11', 600.00, 0.00, 0), 
(1203, 2003, 1003, NULL, '2024-12-12', 700.00, 120.00, 0),  
(1204, 2004, NULL, NULL, '2024-12-13', 400.00, 0.00, 5),   
(1205, 2005, 1005, 1105, '2024-12-14', 800.00, 350.00, 25),
(1206, 2006, 1006, NULL, '2024-12-15', 450.00, 180.00, 0),  
(1207, 2007, NULL, 1107, '2024-12-16', 550.00, 0.00, 10),   
(1208, 2008, 1008, NULL, '2024-12-17', 600.00, 130.00, 0),  
(1209, 2009, NULL, NULL, '2024-12-18', 650.00, 0.00, 5),   
(1210, 2010, 1010, 1110, '2024-12-19', 750.00, 80.00, 15);
