clear
local folder "/Users/haivanle/Downloads/EvaluativeAssignment_2024/Red_Sox/"
local filenames: dir "`folder'" files "red_sox*.csv"

tempfile building
save `building', emptyok

foreach f of local filenames {
    // Use the full path for the import command
    import delimited using `"`folder'`f'"', clear  // Combine folder and filename
   
    // Create a new variable to identify the file (get filename without path)
    gen file = substr("`f'", strrpos("`f'", "/") + 1, .)  
   
    // Append the current dataset to the temporary file
    append using `building'
   
    // Save the appended data back to the temporary file
    save `"`building'"', replace
}

save "/Users/haivanle/Downloads/EvaluativeAssignment_2024/Red_Sox/red_sox_combined.dta", replace

use red_sox_combined.dta


/*
~ On average, the mean price was highest when the purchase date was furthest from the game. It gradually became cheaper and reached its lowest point about a week before the game date.

summarize price_per_ticket if days_from_transaction_until_game < 7
summarize price_per_ticket if days_from_transaction_until_game >= 7 & days_from_transaction_until_game < 14
summarize price_per_ticket if days_from_transaction_until_game >= 14 & days_from_transaction_until_game < 21
summarize price_per_ticket if days_from_transaction_until_game >= 21 & days_from_transaction_until_game < 28
summarize price_per_ticket if days_from_transaction_until_game >= 28 & days_from_transaction_until_game < 35

summarize price_per_ticket if days_from_transaction_until_game >= 217 & days_from_transaction_until_game < 224
summarize price_per_ticket if days_from_transaction_until_game >= 224 & days_from_transaction_until_game < 231
summarize price_per_ticket if days_from_transaction_until_game >= 231 & days_from_transaction_until_game < 238
summarize price_per_ticket if days_from_transaction_until_game >= 238 & days_from_transaction_until_game < 245
summarize price_per_ticket if days_from_transaction_until_game >= 245 & days_from_transaction_until_game <= 251
*/

// extract year from the file column and convert to numeric
generate year = substr(file, -8, 4)
destring year, replace
// duplicates drop -- there is no transaction ID so we dont know if each observation is unique or not since for example, tickets can be bought on the same day with a same quantity

eststo clear
eststo reg1: regress price_per_ticket days_from_transaction_until_game i.year
eststo reg2: regress price_per_ticket c.days_from_transaction_until_game##i.year
esttab reg1 reg2 using "reg_table_redsox1.tex", label se b(3) star(* 0.05 ** 0.01 *** 0.001) 

eststo reg3: regress price_per_ticket days_from_transaction_until_game weekend_game i.year
eststo reg4: regress price_per_ticket weekend_game c.days_from_transaction_until_game##i.year 
esttab reg3 reg4 using "reg_table_redsox2.tex", label se b(3) star(* 0.05 ** 0.01 *** 0.001) 

eststo reg5: regress price_per_ticket days_from_transaction_until_game weekend_game day_game i.year
eststo reg6: regress price_per_ticket weekend_game day_game c.days_from_transaction_until_game##i.year 
esttab reg5 reg6 using "reg_table_redsox3.tex", label se b(3) star(* 0.05 ** 0.01 *** 0.001) 

tabulate sectiontype, gen(sectiontype)
eststo reg7: regress price_per_ticket days_from_transaction_until_game weekend_game day_game sectiontype5 sectiontype8 sectiontype17 sectiontype18 i.year
eststo reg8: regress price_per_ticket weekend_game day_game sectiontype5 sectiontype8 sectiontype17 sectiontype18 c.days_from_transaction_until_game##i.year 
esttab reg7 reg8 using "reg_table_redsox4.tex", label se b(3) star(* 0.05 ** 0.01 *** 0.001) 

collapse (mean) price_per_ticket, by(days_from_transaction_until_game year)
twoway (line price_per_ticket days_from_transaction_until_game if year == 2009)
twoway (line price_per_ticket days_from_transaction_until_game if year == 2010)
twoway (line price_per_ticket days_from_transaction_until_game if year == 2011)
twoway (line price_per_ticket days_from_transaction_until_game if year == 2012)
twoway (line price_per_ticket days_from_transaction_until_game, by(year))

