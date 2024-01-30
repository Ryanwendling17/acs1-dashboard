
with state_year_rent_cte as
(
	select 	
			r.Name																										as State
		,	r.Year
		,	r.B25058_001E																								as MedianContractRent
		,	lag(r.B25058_001E) over (partition by r.Name order by r.Year)												as MedianContractRentLastYear
		,	r.B19013_001E																								as MedianHouseholdIncome
        
	from acs1_dashboard.acs1_api_results r

	where 1=1
)

select 

		c.*
	,	(c.MedianContractRent - c.MedianContractRentLastYear) / c.MedianContractRentLastYear		as RentPercentIncreaseYoY
    ,	(c.MedianContractRent - base.MedianContractRent) / base.MedianContractRent					as RentPercentIncreaseCumulativeFromBase
	,	(c.MedianHouseholdIncome - base.MedianHouseholdIncome) / base.MedianHouseholdIncome			as IncomePercentIncreaseCumulativeFromBase
    
from state_year_rent_cte c

join state_year_rent_cte base
	on c.State = base.State
    and base.Year = (select min(t.Year) from state_year_rent_cte t where t.State = c.State)
