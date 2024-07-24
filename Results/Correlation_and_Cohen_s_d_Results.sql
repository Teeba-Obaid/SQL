-- Create the table for correlation and Cohen's d results
CREATE TABLE correlation_and_cohensd_results (
    group_name VARCHAR,
    rule_column VARCHAR,
    posttest_column VARCHAR,
    correlation_coefficient NUMERIC,
    cohens_d NUMERIC
);

-- Define the columns and iterate through them
DO $$
DECLARE
    rule_column TEXT;
    posttest_column TEXT;
    group_name TEXT;
    correlation NUMERIC;
    mean_rule NUMERIC;
    mean_posttest NUMERIC;
    stddev_rule NUMERIC;
    stddev_posttest NUMERIC;
    n_rule INT;
    n_posttest INT;
    pooled_stddev NUMERIC;
    cohens_d NUMERIC;
BEGIN
    -- Iterate over the groups
    FOR group_name IN
        SELECT unnest(ARRAY['Control', 'Decision Table and Inductive Rules', 'Inductive Rules'])
    LOOP
        -- Define rule-related columns
        FOR rule_column IN
            SELECT unnest(ARRAY[
                'Rule Current: Confirming Redundancy',
                'Rule Voltage Drop: Confirming Redundancy',
                'Rule Current: Simultaneous scanning',
                'Rule Voltage Drop: Simultaneous scanning',
                'Rule Current: Successive scanning',
                'Rule Voltage Drop: Successive scanning',
                'Rule Current: Focus gambling',
                'Rule Voltage Drop: Focus gambling',
                'Rule Current: Conservative Focusing',
                'Rule Voltage Drop: Conservative Focusing'
            ])
        LOOP
            -- Define post-test-related columns
            FOR posttest_column IN
                SELECT unnest(ARRAY[
                    'Post-test: Current non-normative',
                    'Post-test: Voltage Drop non-normative',
                    'Post-test: Current partial',
                    'Post-test: Voltage Drop partial',
                    'Post-test: Current 1 Valid link',
                    'Post-test: Voltage Drop 1 Valid link',
                    'Post-test: Current 2 Valid links',
                    'Post-test: Voltage Drop 2 Valid links'
                ])
            LOOP
                -- Calculate the correlation coefficient
                EXECUTE format(
                    'SELECT CORR(%I, %I) FROM search_strategies WHERE "Group" = %L',
                    rule_column, posttest_column, group_name
                ) INTO correlation;

                -- Calculate means and standard deviations for Cohen's d
                EXECUTE format(
                    'SELECT AVG(%I), STDDEV(%I), COUNT(*) FROM search_strategies WHERE "Group" = %L',
                    rule_column, rule_column, group_name
                ) INTO mean_rule, stddev_rule, n_rule;

                EXECUTE format(
                    'SELECT AVG(%I), STDDEV(%I), COUNT(*) FROM search_strategies WHERE "Group" = %L',
                    posttest_column, posttest_column, group_name
                ) INTO mean_posttest, stddev_posttest, n_posttest;

                -- Calculate pooled standard deviation
                pooled_stddev := sqrt(((n_rule - 1) * stddev_rule^2 + (n_posttest - 1) * stddev_posttest^2) / (n_rule + n_posttest - 2));

                -- Calculate Cohen's d
                cohens_d := (mean_rule - mean_posttest) / pooled_stddev;

                -- Insert the result into the table
                INSERT INTO correlation_and_cohensd_results (group_name, rule_column, posttest_column, correlation_coefficient, cohens_d)
                VALUES (group_name, rule_column, posttest_column, correlation, cohens_d);
            END LOOP;
        END LOOP;
    END LOOP;
END $$;

SELECT * FROM correlation_and_cohensd_results