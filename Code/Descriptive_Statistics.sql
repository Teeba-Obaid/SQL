DO $$
DECLARE
    current_column TEXT;
BEGIN
    FOR current_column IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'search_strategies'
          AND data_type IN ('integer', 'numeric', 'real', 'double precision')
          AND column_name NOT IN ('index', 'Group')
    LOOP
        RAISE NOTICE 'Processing column: %', current_column;
        EXECUTE format('
            INSERT INTO summary_search_strategies(variable_name, sum, mean, median, max, min, std_dev)
            SELECT
                %L,
                SUM(%I),
                AVG(%I),
                percentile_cont(0.5) WITHIN GROUP (ORDER BY %I),
                MAX(%I),
                MIN(%I),
                stddev(%I)
            FROM
                search_strategies;',
            current_column, current_column, current_column, current_column, current_column, current_column, current_column);
    END LOOP;
END $$;

SELECT * FROM summary_search_strategies

DO $$
DECLARE
    current_column TEXT;
BEGIN
    FOR current_column IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'engineering_approaches'
          AND data_type IN ('integer', 'numeric', 'real', 'double precision')
          AND column_name NOT IN ('index', 'Group')
    LOOP
        RAISE NOTICE 'Processing column: %', current_column;
        EXECUTE format('
            INSERT INTO summary_engineering_approaches(variable_name, sum, mean, median, max, min, std_dev)
            SELECT
                %L,
                SUM(%I),
                AVG(%I),
                percentile_cont(0.5) WITHIN GROUP (ORDER BY %I),
                MAX(%I),
                MIN(%I),
                stddev(%I)
            FROM
                engineering_approaches;',
            current_column, current_column, current_column, current_column, current_column, current_column, current_column);
    END LOOP;
END $$;

SELECT * FROM summary_engineering_approaches