rm(list = ls())
graphics.off()
source("GetResults.R")

#Lac Léman
#forc_file = "LacLeman/Forcing_H.dat3"
#forc_file_out = "LacLeman/Forcing_WFILT.dat3"
#morph_file = "LacLeman/Morphology.dat"
#results_dir = "LacLeman_Results/"
#Bodensee
#forc_file = "Bodensee/Forcing_Guettingen_1981-2012.dat2"
#forc_file_out = "Bodensee/Forcing_Guettingen_1981-2012_WFILT.dat2"
#morph_file = "Bodensee/Morphology.dat"
#results_dir = "Bodensee_Results/"
#Bielersee
#forc_file = "Bielersee/SimForceStationComb_1994_2014.dat3"
#forc_file_out = "Bielersee/SimForceStationComb_1994_2014_WFILT.dat3"
#morph_file = "Bielersee/Morph_Biel.dat"
#results_dir = "Bielersee_Results/"
#Lac de Neuchâtel
forc_file = "LacDeNeuchatel/SimForceStationComb_Neuchatel_1994_2014.dat3"
forc_file_out = "LacDeNeuchatel/SimForceStationComb_Neuchatel_1994_2014_WFILT.dat3"
morph_file = "LacDeNeuchatel/Morph_Neuchatel.dat"
results_dir = "LacDeNeuchatel_Results/"

density = function(T) {
  #Water density
  a0 = 999.842594
  a1 =   6.793952e-2
  a2 =  -9.095290e-3
  a3 =   1.001685e-4
  a4 =  -1.120083e-6
  a5 =   6.536332e-9
  T68 = T * 1.00024
  return(a0 + (a1 + (a2 + (a3 + (a4 + a5*T68)*T68)*T68)*T68)*T68)
}

#Extract results from SIMSTRAT
results = GetResults(results_dir,"T")
time_model = results$time
z_model = results$z
T_model = results$data[[1]]
nm = length(time_model)

#Read and store forcing data
forc = read.table(forc_file,header=T,sep="\t")
time = as.POSIXlt(forc[,1]*24*3600,origin="1904-01-01")
forc = forc[time>=time_model[1] & time<=time_model[nm],]
time = time[time>=time_model[1] & time<=time_model[nm]]

#Lake
Zmax = max(abs(z_model)) #Max depth of the basin [m]

#Stratification coefficient [s-2]
zm = (z_model[-1]+z_model[1:length(z_model)-1])/2
ddens = t(apply(density(T_model),1,diff))
N2m = 9.81/1000*ddens/-diff(z_model)
N2 = cbind(N2m[,1],t(matrix(unlist(apply(N2m,1,approx,x=zm,xout=z_model[2:(length(z_model)-1)])),ncol=nrow(N2m))[-(1:(length(z_model)-2)),]),N2m[,ncol(N2m)])

#Calculate averaged h1, h2, T1, T2 for every date
h1 = numeric(length=nm)
h2 = numeric(length=nm)
T1 = numeric(length=nm)
T2 = numeric(length=nm)
for (t in 1:nm) {
  im = which(N2[t,]==max(N2[t,],na.rm=T))
  if (N2[t,im[1]]>1E-4) { #Stratified basin
    T1[t] = mean(as.numeric(T_model[t,im[length(im)]:ncol(T_model)]),na.rm=T)
    T2[t] = mean(as.numeric(T_model[t,1:im[1]]),na.rm=T)
    h1[t] = -mean(z_model[im])
  } else { #Homogeneous basin
    T1[t] = mean(as.numeric(T_model[t,]),na.rm=T)
    T2[t] = as.numeric(T_model[t,1])
    h1[t] = Zmax
  }
}
h1[h1<=0] = min(h1[h1>0])
h2 = Zmax - h1

morph = read.table(morph_file,sep="\t",header=T)
area = approx(morph[,2],x=morph[,1],xout=-h1)
L = sqrt(4*area[[2]])

#Wave period [hr]
rho1 = density(T1)
rho2 = density(T2)
Twave = 1/3600*2*L*(9.81*(rho2-rho1)/rho1*h1*h2/(h1+h2))^-0.5
Twave[is.na(Twave)] = Inf
Twave[Twave<0] = 0
Twave[!is.finite(Twave)] = max(Twave[is.finite(Twave)])
#Cutting criterion for wind period
Tcut = Twave/4

#Reinterpolate on complete time series
T1 = approx(T1,x=as.numeric(time_model),xout=as.numeric(time))[[2]]
T2 = approx(T2,x=as.numeric(time_model),xout=as.numeric(time))[[2]]
h1 = approx(h1,x=as.numeric(time_model),xout=as.numeric(time))[[2]]
h2 = approx(h2,x=as.numeric(time_model),xout=as.numeric(time))[[2]]
L = approx(L,x=as.numeric(time_model),xout=as.numeric(time))[[2]]
Tcut = approx(Tcut,x=as.numeric(time_model),xout=as.numeric(time))[[2]]

#Wind
WD = atan2(forc[,2],forc[,3])+pi #Wind direction (origin, clockwise from North, 0-2pi) [rad]
WS = sqrt(forc[,2]^2+forc[,3]^2) #Wind speed [m/s]
WS[is.na(WS) | WS<0 | WS>20] = 0 #Corrections

#Calculate wind duration and direction
WS2 = WS
cr = mean(WS)
Tmin = 10

lng = length(WS2)
Wdur = numeric(length=lng)
Wdir = numeric(length=lng)
while (max(WS2)>cr) {
  im = which(WS2==max(WS2))[1]
  is = im
  ie = im
  #if (mean(WSrat[is:ie])>=1) {#(sum(WSlog[is:ie])>=0.75*(ie-is+1)) {
    #Mean wind larger than 1.5x criterion on each side#At least 75% above criterion on each side
    while (is>1 && mean(WS[is:im])>=1.5*cr) {#sum(WS[is:im]>cr)>=0.75*(im-is+1)) {
      is=is-1
    }
    while (ie<lng && mean(WS[im:ie])>=1.5*cr) {#sum(WS[im:ie]>cr)>=0.75*(ie-im+1)) {
      ie=ie+1
    }
    Wdur[is:ie] = ie-is+1 #Duration of wind events
    dir = atan2(mean(sin(WD[is:ie]-pi)),mean(cos(WD[is:ie]-pi)))+pi #Mean direction (0,2pi)
    if (dir>3*pi/2 || dir<pi/2) {
      Wdir[is:ie] = sum(WD[is:ie]>((dir-pi/2)%%(2*pi)) | WD[is:ie]<((dir+pi/2)%%(2*pi)))/(ie-is+1) #Percentage of directions on same side as average
    } else {
      Wdir[is:ie] = sum(WD[is:ie]>((dir-pi/2)%%(2*pi)) & WD[is:ie]<((dir+pi/2)%%(2*pi)))/(ie-is+1)
    }
  #}
  WS2[is:ie] = cr
}
Wdur[Wdur<min(Tcut)] = min(Tcut)
Wdir[Wdir<0.5] = 0.5

#Wedderburn number
rho1 = density(T1)
rho2 = density(T2)
C10 = -0.000000712*WS^2+0.00007387*WS+0.0006605
C10[WS<=3.85] = 0.0044*WS[WS<=3.85]^(-1.15)
C10[WS<=0.10] = 0.06215
rho_air = 1.2
rho_wat = density(approx(T_model[,ncol(T_model)],x=as.numeric(time_model),xout=as.numeric(time))[[2]])
Wb=(9.81*(rho2-rho1)/rho1*h1^2)/(rho_air/rho_wat*C10*WS^2*max(L))
Wb[Wb<=0] = min(Wb[Wb>0])
Wb[!is.finite(Wb)]=max(Wb[is.finite(Wb)])

#Build a new velocity time series
#Reduction factors
#Duration of wind events
f_dur = (Wdur/Tcut)^0.5
f_dur[f_dur>1] = 1
                                          #f_dur[f_dur>=0.95] = 1
                                          #f_dur[f_dur<0.95] = f_dur[f_dur<0.95]+0.05
#Homogeneity of wind direction
f_dir = (Wdir-0.5)*2+0.5
f_dir[f_dir>1] = 1
#Stability of lake vertical structure
#f_stab = 1./(1+1/9*Wb.^(1/2))
#crit = pmax(L/(4*h1),quantile(Wb,0.5))
crit = pmax(L,2*min(L[L>0]))/(4*h1)
crit[!is.finite(crit)] = max(crit[is.finite(crit)])
f_stab = 1/(1+Wb/crit)
#p1=3 p2=50
#f_stab = double(Wb<=p1)
#f_stab(Wb>p1 & Wb<=p2) = (p2-Wb(Wb>p1 & Wb<=p2))/(p2-p1)

f_dir = rep(1,length(f_dir))
f = f_dur*f_dir*f_stab
WS_filt = f*WS

plot(time,f_dur,type="l",col="blue",main="Reduction factors",ylim=c(0,1))
lines(time,f_dir,col="green")
lines(time,f_stab,col="red")
legend(time[1],1,c("Wind duration","Wind direction","Lake stability"))

month = as.POSIXlt(time)$mon+1
f_dur_avg = numeric(length=12)
f_dir_avg = numeric(length=12)
f_stab_avg = numeric(length=12)
f_avg = numeric(length=12)
#f_dur_std = numeric(length=12)
#f_dir_std = numeric(length=12)
#f_stab_std = numeric(length=12)
#f_std = numeric(length=12)
for (i in 1:12) {
  f_dur_avg[i]=mean(f_dur[month==i])
  f_dir_avg[i]=mean(f_dir[month==i])
  f_stab_avg[i]=mean(f_stab[month==i])
  f_avg[i]=mean(f[month==i])
  #f_dur_std[i]=sd(f_dur[month==i])
  #f_dir_std[i]=sd(f_dir[month==i])
  #f_stab_std[i]=sd(f_stab[month==i])
  #f_std[i]=sd(f[month==i])
}
plot(1:12,f_dur_avg,type="o",col="blue",main="Monthly-averaged reduction factors",ylim=c(0,1),xlab="Month",ylab="Value of reduction factor [-]",xaxt="n",cex.axis=1.1,cex.lab=1.3)
axis(1,at=1:12,labels=month.abb[1:12],cex.axis=1.1)
#lines(1:12,f_dir_avg,type="o",col="green")
lines(1:12,f_stab_avg,type="o",col="red")
lines(1:12,f_avg,type="o",col="black",lwd=2)
#lines(1:12,f_avg+f_std,type="l",col="black")
#lines(1:12,f_avg-f_std,type="l",col="black")
legend(1,1,c("Wind duration","Lake stability","Altogether"),lty=1,lwd=c(1,1,2),pch=1,col=c("blue","red","black"),cex=1.1)

stop()
doy = as.POSIXlt(time)$yday+1
f_dur_avg = numeric(length=365)
f_dir_avg = numeric(length=365)
f_stab_avg = numeric(length=365)
f_avg = numeric(length=365)
for (i in 1:365) {
  f_dur_avg[i]=mean(f_dur[doy==i])
  f_dir_avg[i]=mean(f_dir[doy==i])
  f_stab_avg[i]=mean(f_stab[doy==i])
  f_avg[i]=mean(f[doy==i])
}
plot(1:365,f_dur_avg,type="l",col="blue",main="Daily-averaged reduction factors",ylim=c(0,1),xlab="Day of year",ylab="Value of reduction factor")
lines(1:365,f_dir_avg,col="green")
lines(1:365,f_stab_avg,col="red")
lines(1:365,f_avg,col="black",lwd=2)
legend(1,1,c("Wind duration","Wind direction","Lake stability","All"),lty=1,col=c("blue","green","red","black"))

plot(time,WS,type="l",xlab="Year",ylab="Wind speed [m/s]")
lines(time,WS_filt,type="l",col="red")
legend(time[1],10.5,c("Raw","Filtered"),lty=1,col=c("black","red"))
#plot(time,WS_filt/WS,type="l",col="blue",xlab="Year",ylab="Filtering ratio")
stop()
#Rewrite forcing file including time series of filtered wind
fid = file(forc_file_out)
open(fid,"w")
type_out = substr(forc_file_out,nchar(forc_file_out),nchar(forc_file_out))
if (type_out=='3') {
  writeLines("t\tu (m/s)\tv (m/s)\tTair (oC)\tFsol (W/m2)\tvap (mbar)\tcloud coverage\tfiltered wind",fid)
} else if (type_out=='2') {
  writeLines("t\tu (m/s)\tv (m/s)\tTair (oC)\tFsol (W/m2)\tvap (mbar)\tfiltered wind",fid)
}
for (k in 1:nrow(forc)) {
  if (type_out=='3') {
    writeLines(sprintf("%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f",forc[k,1],forc[k,2],forc[k,3],forc[k,4],forc[k,5],forc[k,6],forc[k,7],WS_filt[k]),fid)
  } else if (type_out=='2') {
    writeLines(sprintf("%f\t%f\t%f\t%f\t%f\t%f\t%f",forc[k,1],forc[k,2],forc[k,3],forc[k,4],forc[k,5],as.numeric(as.character(forc[k,6])),WS_filt[k]),fid)
  }
}
close(fid)
