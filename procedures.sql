-- Function to split a show into blocks
DELIMITER //
CREATE PROCEDURE split_show_into_blocks(
    IN show_id VARCHAR(255),
    IN words_per_block INT
)
BEGIN
    DECLARE show_transcript TEXT;
    DECLARE show_word_count INT;
    DECLARE num_blocks INT;
    DECLARE i INT;
    DECLARE block_start TIME;
    DECLARE block_end TIME;
    DECLARE show_duration INT;
    DECLARE block_duration FLOAT;
    DECLARE current_pos INT;
    DECLARE next_pos INT;
    DECLARE remaining_text TEXT;
    DECLARE current_chunk TEXT;
    
    -- Get show details
    SELECT 
        transcript, 
        start_time, 
        stop_time, 
        date,
        TIMESTAMPDIFF(SECOND, TIMESTAMP(date, start_time), TIMESTAMP(date, stop_time)),
        LENGTH(transcript) - LENGTH(REPLACE(transcript, ' ', '')) + 1
    INTO 
        show_transcript, 
        block_start, 
        block_end,
        @show_date,
        show_duration,
        show_word_count
    FROM shows 
    WHERE identifier = show_id;
    
    -- Calculate number of blocks needed
    SET num_blocks = CEIL(show_word_count / words_per_block);
    SET block_duration = show_duration / num_blocks;
    SET remaining_text = show_transcript;
    SET current_pos = 1;
    
    -- Clear existing blocks for this show
    DELETE FROM blocks WHERE show_identifier = show_id;
    
    -- Split into blocks
    SET i = 0;
    WHILE i < num_blocks AND LENGTH(remaining_text) > 0 DO
        -- Find the end of the current block (word boundary)
        SET next_pos = current_pos;
        SET @word_count = 0;
        
        -- Find the position where we reach the desired word count
        WHILE @word_count < words_per_block AND next_pos <= LENGTH(remaining_text) DO
            SET next_pos = LOCATE(' ', remaining_text, next_pos + 1);
            IF next_pos = 0 THEN
                SET next_pos = LENGTH(remaining_text) + 1;
            END IF;
            SET @word_count = @word_count + 1;
        END WHILE;
        
        -- Extract the chunk
        IF next_pos = 0 THEN
            SET current_chunk = remaining_text;
        ELSE
            SET current_chunk = SUBSTRING(remaining_text, 1, next_pos - 1);
        END IF;
        
        -- Calculate block times
        SET block_start = SEC_TO_TIME(TIME_TO_SEC(TIME(@show_date, @start_time)) + i * block_duration);
        SET block_end = SEC_TO_TIME(TIME_TO_SEC(TIME(@show_date, @start_time)) + (i + 1) * block_duration);
        
        -- Insert the block
        INSERT INTO blocks (
            block_id,
            show_identifier,
            block_index,
            channel,
            start_time,
            stop_time,
            date,
            transcript_chunk
        ) VALUES (
            CONCAT(show_id, '__', i),
            show_id,
            i,
            (SELECT channel FROM shows WHERE identifier = show_id),
            block_start,
            block_end,
            @show_date,
            current_chunk
        );
        
        -- Prepare for next iteration
        SET remaining_text = SUBSTRING(remaining_text, next_pos + 1);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;