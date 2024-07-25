# SQL Analysis Project on Search Strategies and Engineering Approaches

This repository contains a comprehensive SQL project focused on analyzing data from studies involving search strategies and engineering approaches. The project employs advanced SQL techniques to perform statistical tests, generate descriptive statistics, and provide insightful visualizations. It is structured to showcase methodologies in data analysis and database management.

## Project Structure

- **Data/**: Contains the initial datasets in SQL table format. This includes `search_strategies` and `engineering_approaches` tables.
- **Code/**: SQL scripts for creating database tables, executing statistical analyses, and populating tables with results.
- **Results/**: CSV files storing outputs from the SQL analyses, such as ANOVA tests, correlation coefficients, Cohen’s d results, and various descriptive statistics.
- **Visuals/**: Graphical representations of the analysis results, focusing on comparisons and distributions within the data.

## Installation

To set up this project, follow these steps:

1. Clone this repository to your local machine.
2. Ensure you have PostgreSQL installed and set up on your system.
3. Import the SQL files into your PostgreSQL environment.

## Running the Analysis

Follow these detailed steps to execute the analysis scripts:

### 1. Table Creation
Begin by running the `CREATE TABLE` SQL scripts to establish the necessary database schema. This step sets up tables that will store the results of subsequent analyses.

### 2. Analysis Execution
Execute the PL/pgSQL blocks to perform the analysis. The scripts include:

- **ANOVA Analysis**: Determines the significance of differences in post-test results across various groups and conditions.
- **Correlation and Cohen's d**: Measures the relationships and effect sizes between different variables.
- **Descriptive Statistics**: Provides summary statistics for the datasets, aiding in a basic understanding and further analysis.

Run each script block in sequence to build upon the initial database schema.

### 3. View Results
Use the `SELECT * FROM...` SQL statements to retrieve and review the results directly from your SQL client.

### 4. Generate Visuals
Refer to scripts or manual steps in the `Visuals` directory to create visual representations of the results using tools like R, Python, or Excel.
