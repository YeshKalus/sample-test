// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © subhagghosh

//@version=4
strategy("My Strategy", overlay=true)

//////////////////////////////////////////////////////////////////////
// Testing Start dates
testStartYear = input(2020, "Backtest Start Year")
testStartMonth = input(1, "Backtest Start Month")
testStartDay = input(1, "Backtest Start Day")
testPeriodStart = timestamp(testStartYear,testStartMonth,testStartDay,0,0)
//Stop date if you want to use a specific range of dates
testStopYear = input(2030, "Backtest Stop Year")
testStopMonth = input(12, "Backtest Stop Month")
testStopDay = input(30, "Backtest Stop Day")
testPeriodStop = timestamp(testStopYear,testStopMonth,testStopDay,0,0)


testPeriod() =>
    time >= testPeriodStart and time <= testPeriodStop ? true : false
// Component Code Stop
//////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////
// Check Trend Strength
ha_t = syminfo.tickerid
col_red = #ff0000
col_green = #00ff00
fast_length = input(title="Fast Length",  defval=3)
slow_length = input(title="Slow Length",  defval=10)
src = input(title="Source", defval=close)

TSB = true
TSS = false


res_60 = input('60', title="Higher Time Frame 1 ")
trend_60 = security(ha_t, res_60, ((ema(src, fast_length) - ema(src, slow_length))/src)*100)
prev_trend_60 = security(ha_t, res_60, ((ema(src[5], fast_length) - ema(src[5], slow_length))/src[5])*100)

trend_status_60 = trend_60 > prev_trend_60
//trend_status_60 ? (TSB = true ):(TSS = true)


///////////////////////////////////////////////////////////////////
//End of checking stength

rsi_period = input(14, title="RSI period", minval = 1, step = 1) 
myrsi = rsi(close, rsi_period)
rsi1 = crossunder(myrsi,70)
rsi2 = myrsi > 75

// Regression Lines

source      = input(close)
length      = input(100, minval=1)
offset      = input(0, minval=0)
smoothing   = input(1, minval=1)
mtf_val     = input("", "Resolution", input.resolution)
p           = input("Lime", "Up Color", options=["Red", "Lime", "Orange", "Teal", "Yellow", "White", "Black"])
q           = input("Red", "Down Color", options=["Red", "Lime", "Orange", "Teal", "Yellow", "White", "Black"])


cc(x) => x=="Red"?color.red:x=="Lime"?color.lime:x=="Orange"?color.orange:x=="Teal"?
 color.teal:x=="Yellow"?color.yellow:x=="Black"?color.black:color.white
data(x) => ema(security(syminfo.tickerid, mtf_val!="" ? mtf_val : timeframe.period, x), smoothing)

linreg = data(linreg(source, length, offset))
linreg_p = data(linreg(source, length, offset+1))
//plot(linreg, "Regression Line", cc(linreg>linreg[1]?p:q),linewidth=2, editable=false)

// Regression End

//COLOR of Regression Line

switchColor = input(true, "Color Regression according to trend?")
candleCol = input(false,title="Color candles based on Hull's Trend?")
visualSwitch  = input(true, title="Show as a Band?")
thicknesSwitch = input(1, title="Line Thickness")
transpSwitch = input(40, title="Band Transparency",step=5)
hullColor = switchColor ? (linreg>linreg[1] ? #00ff00 : #ff0000) : #ff9800

//PLOT
///< Frame
Fi1 = plot(linreg, title="Regression Line", color=hullColor, linewidth=thicknesSwitch, transp=50)
Fi2 = plot(visualSwitch ? linreg[3] : na, title="RL", color=hullColor, linewidth=thicknesSwitch, transp=50)
///< Ending Filler
fill(Fi1, Fi2, title="Band Filler", color=hullColor, transp=transpSwitch)
///BARCOLOR
//barcolor(color = candleCol ? (switchColor ? hullColor : na) : na)


// Signal 

LRCOL = crossover(linreg,linreg[1])   //Linear Regression crossover long
LRCUS = crossunder(linreg,linreg[1])  //Linear Regression crossdown short
//PALR  = source > linreg ? true:false  // Price Above Linear Regression
//PBLR  = source < linreg ? true:false  // Price Below Linear Regression

PALR = true
PBLR = true


longCondition = ((LRCOL and testPeriod()) and PALR) //and trend_status_60 
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)
    
 //strategy.close("My Long Entry Id", when = rsi1, comment="crossunder RSI")
//strategy.close("My Long Entry Id", when = rsi2, comment ="RSI MAX")


shortCondition = ((LRCUS and testPeriod()) and PBLR) //and trend_status_60 
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)