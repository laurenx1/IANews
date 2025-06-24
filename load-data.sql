LOAD DATA LOCAL INFILE 'first_50_rows.csv'
INTO TABLE shows
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@col1,@col2,@col3,@col4,@col5,@col6,@col7,@col8,@col9,@col10,
 @col11,@col12,@col13,@col14,@col15,@col16,@col17,@col18,@col19,@col20,
 @col21,@col22,@col23,@col24,@col25,@col26,@col27,@col28,@col29,@col30,
 @col31,@col32,@col33,@col34,@col35,@col36,@col37,@col38,@col39,@col40,
 @col41,@col42,@col43,@col44,@col45,@col46,@col47,@col48,@col49,@col50)
SET 
    identifier = @col15,
    channel = @col37,
    start_time = TIME(STR_TO_DATE(@col36, '%H:%i:%s')),
    stop_time = TIME(STR_TO_DATE(@col38, '%H:%i:%s')),
    date = STR_TO_DATE(@col10, '%m/%d/%Y'),  # Adjust format if needed
    show_name = @col41,
    transcript = @col40;
