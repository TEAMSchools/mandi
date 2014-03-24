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

+ Use the flag / * --UPDATE FIELD FOR CURRENT TERM-- * / for code that requires regular turnover (hex, trimester, etc.) to allow for easy Find/Replace action

## Code Reviews
tba.
