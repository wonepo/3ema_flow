# 🎉 Example of multi pair and multi timeframe signal scanner for MT4 🎉

**Hello geeks! 😎 **

This project is a template or example for programmers who want to write signal scanner algorithms for MT4. It allows scanning multiple currency pairs and multiple timeframe at the same time.

## Features
-	Multi pair scanner
-	Multi timeframe scanner

## How it works 🤯?
The scanner works by using a for loop to loop through all currency pairs and time units. For each pair and each time unit, the scanner calls a function which performs the signal calculation. The signal function should return a value indicating a sell, buy, or no signal.

### Signal example 
```javascript
//+------------------------------------------------------------------+
//| 3 EMA FILTER                                                     |
//+------------------------------------------------------------------+
int emaFilter(int i,string sb,int tf)
  {
   double ma1,ma2,ma3;
   int signal=0;

   ma1=iMA(sb,tf,MA1,0,MA1_METHOD,MA1_PRICE,i);
   ma2=iMA(sb,tf,MA2,0,MA2_METHOD,MA2_PRICE,i);
   ma3=iMA(sb,tf,MA3,0,MA3_METHOD,MA3_PRICE,i);

   if((ma1 > ma2) && (ma2 > ma3) && (ma1 > iHigh(sb,tf,i))) signal = 1;
   if((ma1 < ma2) && (ma2 < ma3) && (ma1 < iLow(sb,tf,i))) signal = -1;

   return signal;
  }
```
This function compares the prices of the chart's highs and lows to the prices of the 10, 50, and 200 exponential moving averages for possible retracement.

## Conclusion 🧐
This project is a valuable tool for programmers who want to write signal scanner algorithms for MT4. It allows scanning multiple currency pairs and multiple timeframe at the same time, 
