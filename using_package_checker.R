# function that checks if required R packages are installed 
# source is the following post: https://stackoverflow.com/a/44660688

using<-function(...) {
  libs<-unlist(list(...))
  req<-unlist(lapply(libs,require,character.only=TRUE))
  need<-libs[req==FALSE]
  if(length(need)>0){ 
    install.packages(need, repos='https://cloud.r-project.org/', dependencies=TRUE)
    lapply(need,require,character.only=TRUE)
    
  }
}

# how to use it
# using("AcousticNDLCodeR","acrt")

