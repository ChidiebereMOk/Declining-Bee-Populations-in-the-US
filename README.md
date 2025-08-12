# Declining Bee Colony Populations in the United States
This project investigates the trends in honey bee populations across various regions over a period of 15 years, from 2002 to 2017, using publicly available datasets retrieved from the US Department of Agriculture.
---

As of 2025, honey bee populations are a vital ecological and agricultural resource in the United States. Their role in pollinating crops and supporting biodiversity makes it crucial to monitor their population dynamics. Recent concerns over colony collapse disorder, environmental stressors, and land-use changes have heightened the need for detailed data analysis on regional bee colony trends.

### Task
The task was to clean and transform raw bee colony data and perform a comprehensive analysis of trends from 2002 to 2017. This involved identifying which regions experienced the most significant population changes, analyzing statistical patterns, and building a forecast model to project future colony counts.

### Actions
- Cleaned and structured multiple datasets using SQL, including standardizing data types, parsing geographical codes, handling missing values, and creating a relational schema for bee colonies, populations, and regions.
- Used Python to join datasets, map codes to readable state and county names, and compute colony totals and changes over time.
- Conducted data visualization with bar plots, histograms, and linear regression charts.
- Performed statistical analysis including descriptive statistics, Shapiro-Wilk normality testing, and Pearson correlation by region.
- Built a linear regression model to examine the trend in colony counts over time and used Prophet to forecast colony populations for five additional years.

### Results
- Discovered a net national increase in bee colonies from 2002 to 2017.
- Identified top states and counties that experienced the largest growth in bee populations.
- Found colony distributions were non-normal and skewed, with significant regional variation.
- Correlation analysis revealed strong positive trends in specific states.
- Forecasting models projected a continued increase in colonies nationwide under current conditions.

## Conclusion and Potential Next Steps:

The decline in bee populations in the U.S. is caused by multiple interconnected factors, including pesticide exposure, habitat loss, climate change, and poor management practices. Addressing these challenges requires a comprehensive approach involving better pesticide management, habitat restoration, sustainable farming practices, and improved beekeeping strategies.

---
