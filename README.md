mandi
=====

## General
Data management, warehousing, and reporting in SQL Server.

['mandi' (mun-dHee) is Telugu for 'storehouse, warehouse, godown.']

## Naming Conventions
These are important.
+ Always include the name of the 'product', and then a $. Otherwise things won't sort nicely and maintenance becomes a nightmare.  For example, if the view relates to MS grades, preface the name with `GRADES$`.

+ Generally speaking the 'product' name should match the subfolder that it lives in.

+ When picking a name, think about the class of __data__ in question, broadly.  There are a few notable exceptions to this rule, namely EMAIL$ (all things notifications) and PROG_TRACKER$ (views for the progress tracker).

+ Views don't get a 'v_' prefix database side, but use the prefix on the file name [views should be functionally interchangeable with tables, so no prefix].

+ If there is a school-specific aspect, use #SCHOOL ABBREVIATION to indicate.

+ Put '|refresh' after the file name if this is a script that refreshes a local table.

+ If it is a Powerschool table name, put it in ALL CAPS.  Otherwise generally use lower case for the name of your file. ('EMAIL$failure_monitoring#NCA').

+ Stored procedures should have 'sp_' in front of their name.

## Naming your commits
Jokes are fine but please be descriptive about what changed.

## Best Practices

+ Use the flag `/*--UPDATE FIELD FOR CURRENT TERM--*/` for code that requires regular turnover (hex, trimester, etc.) to allow for easy Find/Replace action

+ Avoid hard-coding __termid__ parameters.  Instead, use the scalar-valued function `dbo.fn_GlobalTermId()`

+ When creating or adjusting a cached refresh, use the following code to quickly set up the table structure from your view:
 
		SELECT *
		INTO [TABLE]
		FROM [VIEW]
		WHERE 1 = 2

+ All users are granted `READ` permission through the `db_data_tool_reader` server role.  Any public-facing views __must__ be explicity given access through `GRANT SELECT`:
 
		GRANT SELECT ON KIPP_NJ..[TABLE OR VIEW NAME] TO db_data_tool_reader

+ Avoid hard-coding dates.  If the date range is part of a regularly occuring reporting term, add an entry to the `REPORTING$dates` table.

## Code Reviews
tba.
