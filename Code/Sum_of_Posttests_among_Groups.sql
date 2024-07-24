CREATE TABLE summarized_posttest_sums AS
SELECT 
    "Group",
    SUM("Post-test: Current non-normative") AS sum_current_non_normative,
    SUM("Post-test: Voltage Drop non-normative") AS sum_voltage_drop_non_normative,
    SUM("Post-test: Current partial") AS sum_current_partial,
    SUM("Post-test: Voltage Drop partial") AS sum_voltage_drop_partial,
    SUM("Post-test: Current 1 Valid link") AS sum_current_1_valid_link,
    SUM("Post-test: Voltage Drop 1 Valid link") AS sum_voltage_drop_1_valid_link,
    SUM("Post-test: Current 2 Valid links") AS sum_current_2_valid_links,
    SUM("Post-test: Voltage Drop 2 Valid links") AS sum_voltage_drop_2_valid_links
FROM search_strategies
GROUP BY "Group";

SELECT * FROM summarized_posttest_sums;
