CREATE TABLE anova_results (
    rule_column VARCHAR,
    posttest_column VARCHAR,
    "Group" VARCHAR,
    mean_difference NUMERIC,
    f_statistic NUMERIC,
    p_value NUMERIC
);
DO $$
DECLARE
    rule_col TEXT;
    posttest_col TEXT;
    grp TEXT;
    overall_mean NUMERIC;
    group_mean NUMERIC;
    group_size INT;
    total_size INT;
    ss_total NUMERIC;
    ss_within NUMERIC;
    ss_between NUMERIC;
    ms_within NUMERIC;
    ms_between NUMERIC;
    f_stat NUMERIC;
    mean_diff NUMERIC;
BEGIN
    -- Define rule-related columns
    FOR rule_col IN
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
        FOR posttest_col IN
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
            -- Calculate the overall mean for the dependent variable
            EXECUTE format('
                SELECT AVG(%I) 
                FROM search_strategies
                WHERE %I IS NOT NULL',
                posttest_col, posttest_col
            ) INTO overall_mean;

            ss_total := 0;
            ss_within := 0;
            ss_between := 0;
            total_size := 0;

            -- Iterate over the groups
            FOR grp IN
                SELECT unnest(ARRAY['Control', 'Decision Table and Inductive Rules', 'Inductive Rules'])
            LOOP
                -- Calculate the mean for the group
                EXECUTE format('
                    SELECT AVG(%I), COUNT(%I)
                    FROM search_strategies
                    WHERE "Group" = %L AND %I IS NOT NULL',
                    posttest_col, posttest_col, grp, posttest_col
                ) INTO group_mean, group_size;

                -- Sum of squares within
                EXECUTE format('
                    SELECT SUM(POWER(%I - %L, 2))
                    FROM search_strategies
                    WHERE "Group" = %L AND %I IS NOT NULL',
                    posttest_col, group_mean, grp, posttest_col
                ) INTO ss_within;

                -- Sum of squares between
                ss_between := ss_between + group_size * POWER(group_mean - overall_mean, 2);

                -- Calculate mean difference for group
                mean_diff := group_mean - overall_mean;

                -- Add to total size
                total_size := total_size + group_size;

                -- Insert the result into the table
                INSERT INTO anova_results (rule_column, posttest_column, "Group", mean_difference, f_statistic, p_value)
                VALUES (rule_col, posttest_col, grp, mean_diff, NULL, NULL); -- f_statistic and p_value to be calculated later
            END LOOP;

            -- Calculate the total sum of squares
            EXECUTE format('
                SELECT SUM(POWER(%I - %L, 2))
                FROM search_strategies
                WHERE %I IS NOT NULL',
                posttest_col, overall_mean, posttest_col
            ) INTO ss_total;

            -- Calculate mean squares
            IF (total_size - 3) > 0 THEN
                ms_within := ss_within / (total_size - 3);
                ms_between := ss_between / 2;

                -- Calculate the F-statistic
                IF ms_within > 0 THEN
                    f_stat := ms_between / ms_within;
                ELSE
                    f_stat := NULL;
                END IF;
            ELSE
                ms_within := NULL;
                ms_between := NULL;
                f_stat := NULL;
            END IF;

            -- Update the f_statistic and p_value for each group
            IF f_stat IS NOT NULL THEN
                UPDATE anova_results
                SET f_statistic = f_stat
                WHERE rule_column = rule_col
                AND posttest_column = posttest_col
                AND f_statistic IS NULL;
            END IF;
        END LOOP;
    END LOOP;
END $$;

SELECT * FROM anova_results