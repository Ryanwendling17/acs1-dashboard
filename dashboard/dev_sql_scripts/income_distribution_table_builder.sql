
-- Define Vars
set @tableName = 'information_schema.columns';
set @startColName = 'B19001_002E';
set @endColName = 'B19001_017E';

-- Get Start Col Position
set @sql = concat('select ordinal_position into @startOrdinalPosition from ', @tableName, ' where table_name = "acs1_api_results" and column_name = "', @startColName, '"');
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;

-- Get End Col Position
set @sql = concat('select ordinal_position into @endOrdinalPosition from ', @tableName, ' where column_name = "', @endColName, '"');
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;

-- Get All Cols Inbetween
drop temporary table if exists col_list;
set @sql = concat(
	'create temporary table col_list as select column_name from ', 
	@tableName, 
	' where ordinal_position between ', 
	@startOrdinalPosition, 
	' and ', 
	@endOrdinalPosition
);
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;


-- Get Col List in Format for Feeding to Next SQL Statement
set @n = @endOrdinalPosition - @startOrdinalPosition + 1;
set @sql = concat(
	'with temp as (select column_name from col_list limit ',
    @n,
    ') ',
    'select group_concat(column_name) into @colList from temp'
);
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;


-- Construct the dynamic SQL statement to select columns from the main table
drop temporary table if exists main_results_stage;
set @sqlSelectColumns = concat(
    'create temporary table main_results_stage as select Name as State, Year, ', 
    @colList,
    ' from acs1_dashboard.acs1_api_results'
);

-- Execute the dynamic SQL to select columns from the main table
prepare stmt from @sqlSelectColumns;
execute stmt;
deallocate prepare stmt;

-- Create Income Dist Table
drop table if exists acs1_dashboard.income_distribution;
create table acs1_dashboard.income_distribution
(
		State varchar(25)
	,	Year int
	,	`00. $0 - $9,999` int
    ,	`01. $10,000 - $14,999` int
    ,	`02. $15,000 - $19,999` int
    ,	`03. $20,000 - $24,999` int
    ,	`04. $25,000 - $29,999` int
    ,	`05. $30,000 - $34,999` int
    ,	`06. $35,000 - $39,999` int
    ,	`07. $40,000 - $44,999` int
    ,	`08. $45,000 - $49,999` int
    ,	`09. $50,000 - $59,999` int
	,	`10. $60,000 - $74,999` int
    ,	`11. $75,000 - $99,999` int
    ,	`12. $100,000 - $124,999` int
    ,	`13. $125,000 - $149,999` int
    ,	`14. $150,000 - $199,999` int
    ,	`15. $200,000+` int
);
insert into acs1_dashboard.income_distribution
select * from main_results_stage

