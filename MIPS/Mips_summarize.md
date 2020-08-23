#	MIP SUMMARIZE
---
##	Data Representation  
1. Representing Integers  
- Unsigned Binary Numbers
	- Conversion of Binary to Decimal

```
- Let X be a binary number, n digits in length composed of bits X<sub>n-1</sub> ... X<sub>0</sub>  
- Let D be a decimal number.
- Let i be a counter.
1.	Let D = 0
2.	Let i = 0
3. 	While i < n do:
	- If X<sub>i</sub> == 1, then set D = (D + 2<sup>i</sup>)
	- Set i = (i+1)

```

