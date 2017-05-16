#Get (and plot) the physical results from SIMSTRAT text files
#
#results = GetResults(path[,var][,period][,depths][,graph][,dateref])
# * path (string): Path to directory where results file are located
# * var (string vector): Variables to extract (set to 'all' to get everything)
# * period (string vector): Start and end time (strings in %Y-%m-%d format)
#   of period to extract (skip to get everything)
# * depths (numeric vector): Depths to extract (skip to get everything)
# * graph (boolean): Make the plots (contour plots if "depths" not provided,
#   curves otherwise) (default: 0)
# * dateref (string): Reference time that corresponds to time 0 in the
#   model run (default: 1904-01-01)
#
#Example usage:
#   results = GetResults('Results/')
#   results = GetResults('Results/',var=c('T','S'),depths=-50)
#   results = GetResults('Results/','all',depths=c(-50,-100),dateref='1981-01-01')
#
#Extract output:
#   results$time, results$z, results$label, results$data

GetResults = function(path,var,period,depths,graph,dateref) {

  if(missing(dateref)) {dateref="1904-01-01"}
  if(missing(graph)) {graph=FALSE}
  if(missing(depths)) {depths=numeric()}
  if(missing(period)) {period=numeric()}
  if(missing(var)) {var="all"}
  
  if (length(period)!=0) {
    period = sort(strftime(period))
    if ((length(period)!=2) || any(is.na(period))) {
      warning("Given period is not a vector with two dates. Extracting all times.")
      period = numeric()
    }
  }
  
  depths = depths[!is.na(depths)]
  depths = sort(-abs(depths),decreasing=T)
  path = gsub("\\\\","/",path)
  if (substr(path,nchar(path),nchar(path))!="/") {
    path = paste(path,"/",sep="")
  }
  var = tolower(var)
  
  leg = c("Velocity East [m/s]","Velocity North [m/s]","Temperature [°C]","Salinity [???]","Vertical Advection [m^3/s]","Turbulent kinetic energy [J/kg]","Dissipation rate of TKE [W/kg]","Turbulent diffusivity [J*s/kg]","Brunt-Väisälä frequency [1/s^2]","Production rate of buoyancy [W/kg]","Production rate of shear stress [W/kg]","Production rate of TKE [W/kg]","Seiche energy [J]")
  files = c("U","V","T","S","Qv","k","eps","nuh","N2","B","P","Ps","Es")
  files = paste(files,"_out.dat",sep="")
  
  j = 1
  data = list()
  label = list()
  for (i in 1:length(files)) {
    req = FALSE
    for (k in 1:length(var)) {
      req = req || any(substr(tolower(files[i]),1,length(var[k]))==substr(var[k],1,length(var[k])))
    }
    if (any(var=="all") || req) {
      data[[j]] = data.matrix(read.table(paste(path,files[i],sep="")))
      if (j==1) {
        time = as.POSIXct(data[[j]][2:nrow(data[[j]]),1]*24*3600,origin=dateref)
        z = as.numeric(as.matrix(data[[j]][1,2:(ncol(data[[j]])-1)]))
        if (length(period)!=0) {
          tok = (time>=as.POSIXlt(period[1]) & time<=as.POSIXlt(period[2]))
          time = time[tok]
        }
        if (length(depths)!=0) {
          if (min(depths)<min(z) || max(depths)>max(z)) {
            warning("Some required depths are out of results range.")
          }
        }
      }
      if (i!=length(files)) {
        data[[j]] = data[[j]][2:nrow(data[[j]]),2:(ncol(data[[j]])-1)]
      } else {
        data[[j]] = data[[j]][2:nrow(data[[j]]),2]
      }
      
      if (length(period)!=0) { #Select required period
        if (i!=length(files)) {
          data[[j]] = data[[j]][tok,]
        } else {
          data[[j]] = data[[j]][tok]
        }
      }
      if (length(depths)!=0 && i!=length(files)) { #Reinterpolate on required depths        
        data[[j]] = t(matrix(unlist(apply(data[[j]],1,approx,x=z,xout=depths)),ncol=nrow(data[[j]]))[-(1:length(depths)),])
      }
      
      label[[j]] = leg[i]
      
      if (graph) {
        if (length(depths)!=0 || i==length(files)) {
          matplot(time,t(data[[j]]),lty=1,type='l',xaxt='n',xlab='Time',ylab='',col=rainbow(length(depths)))
          timelabels=format(time,"%Y")
          axis(1,at=time,labels=timelabels)
          if (i!=length(files)) legend(time[1],20,paste(depths,'m'),lty=1,col=rainbow(length(depths)))
        } else {
          filled.contour(time,z,data[[j]],ylab='Depth [m]')
        }
        title(label[[j]])
      }
      j = j+1
    }
  }
  
  if (length(depths)!=0) {
    z = depths
  }
  if (j==1) {
    warning("No corresponding file found. Verify required variable(s).")
    time = numeric()
    z = numeric()
    data[[j]] = list()
    label[[j]] = list()
  } else if (any(var=="all") && length(var)>j-1) {
    warning("All corresponding files not found. Verify required variable(s).")
  }
  return(list(time=time,z=z,data=data,label=label))
}