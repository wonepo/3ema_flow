//+------------------------------------------------------------------+
//|                                                    3ema_flow.mq4 |
//|                                                2017-2024, Wonepo |
//|                                           https://www.wonepo.win |
//+------------------------------------------------------------------+
#property copyright   "2017-2024, Wonepo"
#property link        "https://www.wonepo.win"
#property description "This is a simple 3 ema winning strategie"
#property version   "1.00"
#property strict

//--- indicator settings
#property indicator_separate_window

//--- indicator parameter
extern string Group = "Major";//Instrument Group

extern string MA_Settings="<========================================>"; // MA Settings
input int MA1=10; //MA Fast Period
input int MA1_SHIFT=0; //MA Fast Shift
input ENUM_MA_METHOD MA1_METHOD=MODE_EMA; //MA Fast Method
input ENUM_APPLIED_PRICE MA1_PRICE=PRICE_CLOSE; //MA Fast Applied To

input int MA2=50; //MA Medium Period
input int MA2_SHIFT=0; //MA Medium Shift 
input ENUM_MA_METHOD MA2_METHOD=MODE_EMA; //MA Medium Method
input ENUM_APPLIED_PRICE MA2_PRICE=PRICE_CLOSE; //MA Medium Applied To

input int MA3=200; //MA Slow Period
input int MA3_SHIFT=0; //MA Slow Shift 
input ENUM_MA_METHOD MA3_METHOD=MODE_EMA; //MA Slow Method
input ENUM_APPLIED_PRICE MA3_PRICE=PRICE_CLOSE; //MA Slow Applied To

extern string Separator2="<=======================>"; //Multi Time Frame Settings
extern string SblPrefix = ""; //Symbol Prefix
extern string PairStr = "AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,GBPUSD,NZDCAD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY,USDSGD"; //Symbols
extern string TFStr ="M5,M15,H1,H4,D1,W1,MN";
extern int index = 1; //Bar to watch, 0 Real Time, 1 Previous bar 

extern string Separator4="<=======================>"; //Alert Settings
extern bool alertOn=true; //With Alert 
extern bool alertsSound=true; //Sound  
extern bool alertsMessage=true; //Popup
extern bool alertsEmail=true; //Email
extern bool alertsNotification=true; //Notification

extern string Separator5="<=======================>"; //Style Settings
extern int TextSize = 8; //Font Size
extern color HeadTextColor = clrGold; // Head Text Color
extern color HeadBGColor = clrNONE; // Head BackGround Color
extern color TextColor = clrBlack; //Text Color
extern color SignalTextColor = clrBlue; //Signal Text Color
extern color UP = clrGreen; // Up Color
extern color MUP = clrLime; //Medium Up Color
extern color DW = clrRed; // Down Color
extern color MDW = clrLightPink; //Medium Down Color
extern color NO = clrGray; //No Signal Color

//--- Symbol and Time Frames
int TotalSB;
int TotalTF;
string ArraySB[];
string ArrayTF[];

//---
int corner=0;
string sname;
long chart_id;
string Font = "Tahoma";

struct dynamic_2D
   {
    int nbr[];
    datetime col[];
   };

dynamic_2D Tab2D[];

//--- spacing
int scaleX=60,scaleY=20,offsetX=100,offsetY=5,width=60,height=20; // coordinate

//+------------------------------------------------------------------+
//| ExcelSior                                                        | 
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   sname="3 EMA FLOW ("+MA1+","+MA2+","+MA3+")";
   
   IndicatorShortName(sname);
   IndicatorDigits(Digits);

   chart_id=ChartID();   
   
  
//--- Load time frame and symbol in array
   StringToArray(PairStr,",",ArraySB);
   StringToArray(TFStr,",",ArrayTF);

   TotalSB = ArraySize(ArraySB);
   TotalTF = ArraySize(ArrayTF);

//--- Prevent Alert   
   ArrayResize(Tab2D,TotalTF);
   for(int i=0; i<=TotalTF-1; i++) 
   { 
      ArrayResize(Tab2D[i].col,TotalSB); 
      ArrayResize(Tab2D[i].nbr,TotalSB); 
      
      ArrayInitialize(Tab2D[i].col,D'1970.01.01 00:00:00');       
      ArrayInitialize(Tab2D[i].nbr,0); 
    }
   
   for(int i=0; i<=TotalSB-1; i++) 
   { 
      ArraySB[i] = ArraySB[i] + SblPrefix;
   }        
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ArrayFree(Tab2D);    
   ArrayFree(ArraySB);
   ArrayFree(ArrayTF);
   
   ObjectsDeleteAll(ChartWindowFind());
  }
//+------------------------------------------------------------------+ 
  
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {

    ResetLastError();
    RefreshRates();
    
   int x=0,y=0;
   
   //--- create timeframe text labels 
   for(x=0; x<TotalTF; x++)
    {
      ObjectCreate(chart_id,"TF_"+ArrayTF[x],OBJ_LABEL,WindowFind(sname),0,0);
      ObjectSetString(chart_id,"TF_"+ArrayTF[x],OBJPROP_TEXT,ArrayTF[x]);
      ObjectSetString(chart_id,"TF_"+ArrayTF[x],OBJPROP_FONT,Font);
      ObjectSetInteger(chart_id,"TF_"+ArrayTF[x],OBJPROP_BGCOLOR,HeadBGColor);
      ObjectSetInteger(chart_id,"TF_"+ArrayTF[x],OBJPROP_FONTSIZE,TextSize);
      ObjectSetInteger(chart_id,"TF_"+ArrayTF[x],OBJPROP_COLOR,HeadTextColor);
      ObjectSetInteger(chart_id,"TF_"+ArrayTF[x],OBJPROP_CORNER,corner);
      ObjectSetInteger(chart_id,"TF_"+ArrayTF[x],OBJPROP_XDISTANCE,x*scaleX+offsetX+30); 
      ObjectSetInteger(chart_id,"TF_"+ArrayTF[x],OBJPROP_YDISTANCE,y*scaleY+offsetY+13);
    }

   //--- create symbol text labels        
    for(y=0; y<TotalSB; y++)
    {
      ObjectCreate(chart_id,"SB_"+ArraySB[y],OBJ_LABEL,WindowFind(sname),0,0);
      ObjectSetString(chart_id,"SB_"+ArraySB[y],OBJPROP_TEXT,ArraySB[y]);
      ObjectSetString(chart_id,"SB_"+ArraySB[y],OBJPROP_FONT,Font);
      ObjectSetInteger(chart_id,"SB_"+ArraySB[y],OBJPROP_BGCOLOR,HeadBGColor);      
      ObjectSetInteger(chart_id,"SB_"+ArraySB[y],OBJPROP_FONTSIZE,TextSize);
      ObjectSetInteger(chart_id,"SB_"+ArraySB[y],OBJPROP_COLOR,HeadTextColor);
      ObjectSetInteger(chart_id,"SB_"+ArraySB[y],OBJPROP_CORNER,corner);
      ObjectSetInteger(chart_id,"SB_"+ArraySB[y],OBJPROP_XDISTANCE,offsetX-80); 
      ObjectSetInteger(chart_id,"SB_"+ArraySB[y],OBJPROP_YDISTANCE,y*scaleY+offsetY+48);
    }

    for(x=0; x<TotalTF; x++)
    {
       for(y=0; y<TotalSB; y++)
       {
          int rs= emaFilter(index,ArraySB[y],StringToTF(ArrayTF[x]));
                          
          ObjectDelete("rec"+string(x)+string(y)+string(ChartWindowFind()));
          ObjectDelete("val"+string(x)+string(y)+string(ChartWindowFind()));
          
          ObjectCreate(chart_id,"rec"+string(x)+string(y)+string(ChartWindowFind()),OBJ_RECTANGLE_LABEL,WindowFind(sname),0,0);
          ObjectSetInteger(chart_id,"rec"+string(x)+string(y)+string(ChartWindowFind()),OBJPROP_BACK,true);
          ObjectSetInteger(chart_id,"rec"+string(x)+string(y)+string(ChartWindowFind()),OBJPROP_XSIZE,width);
          ObjectSetInteger(chart_id,"rec"+string(x)+string(y)+string(ChartWindowFind()),OBJPROP_YSIZE,height);
          ObjectSetInteger(chart_id,"rec"+string(x)+string(y)+string(ChartWindowFind()),OBJPROP_CORNER,corner);
          ObjectSetInteger(chart_id,"rec"+string(x)+string(y)+string(ChartWindowFind()),OBJPROP_BORDER_TYPE,BORDER_RAISED);
          ObjectSetInteger(chart_id,"rec"+string(x)+string(y)+string(ChartWindowFind()),OBJPROP_XDISTANCE,x*scaleX+offsetX+10); 
          ObjectSetInteger(chart_id,"rec"+string(x)+string(y)+string(ChartWindowFind()),OBJPROP_YDISTANCE,y*scaleY+offsetY+42);
   
          if(rs==0)
          {
            ObjectSetInteger(chart_id,"rec"+string(x)+string(y)+string(ChartWindowFind()),OBJPROP_BGCOLOR,NO);       
          }       
          else
          {
            ObjectCreate(chart_id,"val"+string(x)+string(y)+string(ChartWindowFind()),OBJ_LABEL,WindowFind(sname),0,0);       
            ObjectSetString(chart_id,"val"+string(x)+string(y)+string(ChartWindowFind()),OBJPROP_FONT,Font);
            if(rs==1)
            {
               if(Tab2D[x].col[y]<iTime(ArraySB[y],StringToTF(ArrayTF[x]),0) && alertOn) 
               {
                  Tab2D[x].col[y] = TimeCurrent();
                  doAlert("BUY",index,ArraySB[y],StringToTF(ArrayTF[x]));
               }

               ObjectSetInteger(chart_id,"rec"+string(x)+string(y)+string(ChartWindowFind()),OBJPROP_BGCOLOR,UP);       
               ObjectSetString(chart_id,"val"+string(x)+string(y)+string(ChartWindowFind()),OBJPROP_TEXT,string(index));
               ObjectSetInteger(chart_id,"val"+string(x)+string(y)+string(ChartWindowFind()),OBJPROP_COLOR,TextColor);
            }  
            if(rs==-1)
            {
              if(Tab2D[x].col[y]<iTime(ArraySB[y],StringToTF(ArrayTF[x]),0) && alertOn)
              {
                Tab2D[x].col[y] = TimeCurrent();
                doAlert("SELL",index,ArraySB[y],StringToTF(ArrayTF[x]));
              }

              ObjectSetInteger(chart_id,"rec"+string(x)+string(y)+string(ChartWindowFind()),OBJPROP_BGCOLOR,DW);                   
              ObjectSetString(chart_id,"val"+string(x)+string(y)+string(ChartWindowFind()),OBJPROP_TEXT,string(index));
              ObjectSetInteger(chart_id,"val"+string(x)+string(y)+string(ChartWindowFind()),OBJPROP_COLOR,TextColor);
             }  
             ObjectSetInteger(chart_id,"val"+string(x)+string(y)+string(ChartWindowFind()),OBJPROP_FONTSIZE,TextSize);
             ObjectSetInteger(chart_id,"val"+string(x)+string(y)+string(ChartWindowFind()),OBJPROP_CORNER,corner);
             ObjectSetInteger(chart_id,"val"+string(x)+string(y)+string(ChartWindowFind()),OBJPROP_XDISTANCE,x*scaleX+offsetX+38); 
             ObjectSetInteger(chart_id,"val"+string(x)+string(y)+string(ChartWindowFind()),OBJPROP_YDISTANCE,y*scaleY+offsetY+42);            
          }
       }
    }
    
    ChartRedraw(0);
    RefreshRates();

    return(rates_total);               
//---
  }
//+------------------------------------------------------------------+

 
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
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Transform a string to TimeFrame                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES StringToTF(string in) 
{
   ENUM_TIMEFRAMES i=PERIOD_MN1;
   if(in=="M1") i = PERIOD_M1;
   if(in=="M5") i = PERIOD_M5;   
   if(in=="M15") i = PERIOD_M15;  
   if(in=="M30") i = PERIOD_M30;   
   if(in=="H1") i = PERIOD_H1;   
   if(in=="H4") i = PERIOD_H4;   
   if(in=="D1") i = PERIOD_D1;  
   if(in=="W1") i = PERIOD_W1;   
   if(in=="MN") i = PERIOD_MN1;   
   return(i);     
} 
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Transform a TimeFrame to String                                  |
//+------------------------------------------------------------------+
string TFToString(int in) 
{
   string signal;
      
   switch (in) {
   case 1: signal = "M1"; break;
   case 5: signal = "M5"; break;
   case 15: signal = "M15"; break;
   case 30: signal = "M30"; break;
   case 60: signal = "H1"; break;
   case 240: signal = "H4"; break;
   case 1440: signal = "D1"; break;
   case 10080: signal = "W1"; break;
   case 43200: signal = "MN1";
   }
   return(signal);     
} 
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Transform a string to Array                                      |
//+------------------------------------------------------------------+
void StringToArray(string in,string separator,string &strArray[]) 
{
   int i,j=0;
   string str = in;
   
   //StringToUpper(str);
   str = StringTrimLeft(str);
   str = StringTrimRight(str);
   
   if (StringSubstr(str,StringLen(str),1) != separator) str = StringConcatenate(str,separator);  

   do {
      i = StringFind(str,separator);
      if(i>0){
         ArrayResize(strArray,j+1);
         strArray[j] = StringSubstr(str,0,i); 
         Print(strArray[j]);
         j++;
      }
      if(StringLen(str)==i+1)  
         i=0;
      else
         str = StringSubstr(str,i+1);

   }while(i>0);
} 
//+------------------------------------------------------------------+

//------------------------------------------------------------------
// Alert Manager Function
//------------------------------------------------------------------
//
void doAlert(string doWhat,int i,string sb,int tf)
  {
   string msg="3 EMA FLOW "+sb+","+TFToString(tf)+", at "+TimeToString(iTime(sb,tf,i))+" ";

   if(doWhat=="BUY") msg=msg+doWhat;
   if(doWhat=="SELL") msg=msg+doWhat;

   if(alertsEmail) SendMail(sb+","+TFToString(tf),msg);
   if(alertsSound) PlaySound("alert2.wav");
   if(alertsMessage) Alert(msg);
   if(alertsNotification) SendNotification(msg);
  }

//+------------------------------------------------------------------+
