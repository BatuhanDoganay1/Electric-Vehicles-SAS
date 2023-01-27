data IMPORT;
set IMPORT;
lnTopSpeed_KM_H=log(TopSpeed_KM_H);
lnEfficiency_WH_KM=log(Efficiency_WH_KM);
run;



proc means data = IMPORT;
var lnTopSpeed_KM_H lnEfficiency_WH_KM ;
run;



proc freq data = IMPORT;
table Drive;
run;



/*Tek yoklu manova*/
proc glm data = IMPORT;
class Drive;
model lnTopSpeed_KM_H lnEfficiency_WH_KM = Drive / SS3;
manova h = Drive;
run;



/*etkilesimli*/
proc glm data = IMPORT;
class Drive Acceleration_SEC;
model lnTopSpeed_KM_H lnEfficiency_WH_KM = Drive*Acceleration_SEC / SS3;
manova h = Drive*Acceleration_SEC ;
run;



proc factor data=WORK.IMPORT /*name of data file*/
out=skorlar
nobs=124 /*number of observations*/
corr /*print correlation matrix*/
method=principal /*method of extraction*/
nfactors=3 /*number of factors to retain*/
maxiter = 25 /*maximum number of iterations*/
rotate=varimax /*type of rotation */
msa
scree /*print of scree plot*/
res /*display residual correlation matrix*/
preplot
plot
heywood;/*sets to 1 any communality greater than 1, allowing iterations to proceed*/
var Acceleration_SEC TopSpeed_KM_H Range_H Efficiency_WH_KM effi FastChargeSpeed Drive NumberofSeats PriceinGermany_EURO; /*variables to be included*/
run;



/* yorum satiri eklenebilir */



proc freq data=IMPORT;
tables Drive;
run;



proc corr data=IMPORT spearman;
var Acceleration_SEC TopSpeed_KM_H Range_H Efficiency_WH_KM effi FastChargeSpeed Drive NumberofSeats PriceinGermany_EURO;
run;



proc discrim data=IMPORT can simple;
class Drive;
var Acceleration_SEC TopSpeed_KM_H Range_H Efficiency_WH_KM effi FastChargeSpeed NumberofSeats PriceinGermany_EURO;
priors proportional;
run;



proc stepdisc data=IMPORT;
class Drive;
var effi Acceleration_SEC NumberofSeats;
run;



proc logistic data=IMPORT ;
model NumberofSeats(ref="1") = TopSpeed_KM_H Efficiency_WH_KM /expb lackfit rsquare ;
output out=outdata p=pred_prob lower=low upper=up;
run;



data outdata;
set outdata;
if pred_prob > 0.5 then pred ='B' ;
else pred ='A';
run;



proc freq data=outdata;
table NumberofSeats*Drive;
run;



/* Stepwise Lojistik Regresyon*/
proc logistic data=IMPORT ;
model NumberofSeats(ref="1") = TopSpeed_KM_H Efficiency_WH_KM /expb lackfit rsquare selection=backward;
output out=outdata p=pred_prob lower=low upper=up;
run;



data outdata;
set outdata;
if pred_prob > 0.5 then pred ='B' ;
else pred ='A';
run;



proc freq data=outdata;
table NumberofSeats*Drive;
run;




/*Hiyerarşik Kümeleme Analizi*/
proc cluster data=IMPORT method=centroid outtree=centroid plots(maxpoints=1000) ;



ID Name; /*ID gözlemlerin isimlerini görüntülemek için*/
VAR TopSpeed_KM_H Range_H Efficiency_WH_KM PriceinGermany_EURO; /*Analize girecek değişkenlerin adları*/
run;



/*K-MEANS KÜMELEME ANALİZİ*/
proc fastclus data=WORK.IMPORT maxiter=10 maxclusters=5 list distance out=clust;
var TopSpeed_KM_H Range_H Efficiency_WH_KM PriceinGermany_EURO;
id Name;
run;



/*Değişkenlerin kümelemede anlamlı olup olmadığını görmek için glm komutu kullanılıyor */
proc glm data=clust;
class cluster;
model TopSpeed_KM_H=cluster;
run;



proc glm data=clust;
class cluster;
model Range_H=cluster;
run;



proc glm data=clust;
class cluster;
model Efficiency_WH_KM=cluster;
run;



proc glm data=clust;
class cluster;
model PriceinGermany_EURO=cluster;
run;
