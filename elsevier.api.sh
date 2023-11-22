apikey= # go to https://dev.elsevier.com/apikey/manage to get your API keys
token= #go to https://service.elsevier.com/app/contact/supporthub/dataasaservice/ to requst a token

# parameters
thre='"threshold":10'  #top 1%,5%,10%,25%
#metric=ScholarlyOutput
# use: FieldWeightedCitationImpact, ScholarlyOutput, PublicationsInTopJournalPercentiles, OutputsInTopCitationPercentiles
# CitationCount, CitationsPerPublication, CitedPublications, FieldWeightedCitationImpact, HIndices, ScholarlyOutput (default), PublicationsInTopJournalPercentiles, OutputsInTopCitationPercentiles
yr=10yrs
# 3yrs, 3yrsAndCurrent, 3yrsAndCurrentAndFuture, 5yrs (default)..., 10yrs (no current or future for 10yrs)
selfcite=true
ptype=AllPublicationTypes
broke_year=true # whether to return results broken down by year
# use: ArticlesOnly, BooksAndBookChapters, ArticlesConferencePapers (- ArticlesOnly = conference), AllPublicationTypes (for cited metrics), AllPublicationTypes (- ArticlesReviewsConferencePapersBooksAndBookChapters)
# AllPublicationTypes, ArticlesOnly, ArticlesReviews, ArticlesReviewsConferencePapers, ArticlesConferencePapers, BooksAndBookChapters, ArticlesReviewsConferencePapersBooksAndBookChapters 
impacttype=SNIP
# CiteScore, SNIP, SJR
fieldweight=true
index=hIndex
# h5Index, gIndex, mIndex

for inpfile in example.csv # your input file
do

outfile=researchdata.out.${inpfile}
if [ -f $outfile ];then
	rm -f $outfile
fi
printf '%s\n' AUID ScopusID Outputs FWCI PublicationsInTopJournal OutputsInTopCitation | paste -sd "," >> $outfile

for id in `cat $inpfile | awk -F, 'NR>1 {print $2}'`
do
auid=`cat $inpfile | awk -F, '$2==o {print $1}' o=$id`
#echo $auid

#-------------------------scholarly output
metric=ScholarlyOutput
inp=`echo 'https://api.elsevier.com/analytics/scival/author/metrics?metricTypes=' $metric '&authors=' $id '&yearRange=' $yr '&includeSelfCitations=' $selfcite '&byYear=' $broke_year '&includedDocs=' $ptype '&journalImpactType=' $impacttype '&showAsFieldWeighted=' $fieldweight '&indexType=' $index '&apiKey=' $apikey '&insttoken=' $token | awk '{print $1$2$3$4$5$6$7$8$9$10$11$12$13$14$15$16$17$18$19$20$21$22}'`
echo $inp
out=`curl -X GET --header 'Accept: application/json' $inp`

#year1=`echo $out | awk -F'"valueByYear":{"' '{print $2}' | awk -F'"' '{print $1}'`
#num1=`echo $out | awk -F'"valueByYear":{"' '{print $2}' | awk -F$year1 '{print $2}' | awk -F',' '{print $1}' | awk -F: '{print $2}'`
year1=`echo $out | awk -F'"valueByYear":{"' '{print $2}' | awk -F'"' '{print $9}'`
year2=`echo $out | awk -F'"valueByYear":{"' '{print $2}' | awk -F'"' '{print $11}'`
year3=`echo $out | awk -F'"valueByYear":{"' '{print $2}' | awk -F'"' '{print $13}'`
year4=`echo $out | awk -F'"valueByYear":{"' '{print $2}' | awk -F'"' '{print $15}'`
year5=`echo $out | awk -F'"valueByYear":{"' '{print $2}' | awk -F'"' '{print $17}'`
year6=`echo $out | awk -F'"valueByYear":{"' '{print $2}' | awk -F'"' '{print $19}'`
j=0
num=(0 0 0 0 0 0)
echo $year1 $year2 $year3 $year4 $year5 $year6
for year in $year1 $year2 $year3 $year4 $year5 $year6
do
num[$j]=`echo $out | awk -F'"valueByYear":{"' '{print $2}' | awk -F$year '{print $2}' | awk -F',' '{print $1}' | awk -F: '{print $2}'`
j=`echo $j | awk '{print $1+1}'`
done
#year5=`echo $out | awk -F'"valueByYear":{"' '{print $2}' | awk -F'"' '{print $9}'`
#num5=`echo $out | awk -F'"valueByYear":{"' '{print $2}' | awk -F$year5 '{print $2}' | awk -F'}' '{print $1}' | awk -F: '{print $2}'`

output=`echo ${num[0]} ${num[1]} ${num[2]} ${num[3]} ${num[4]} ${num[5]} | awk '{print $1+$2+$3+$4+$5+$6}'`
if [ "$output" == "" ];then
	output=0
fi

#------------------------ FWCI
metric=FieldWeightedCitationImpact
num_fwc1=$num1;num_fwc2=$num2;num_fwc3=$num3;num_fwc4=$num4;num_fwc5=$num5;num_fwc6=$num6
inp=`echo 'https://api.elsevier.com/analytics/scival/author/metrics?metricTypes=' $metric '&authors=' $id '&yearRange=' $yr '&includeSelfCitations=' $selfcite '&byYear=' $broke_year '&includedDocs=' $ptype '&journalImpactType=' $impacttype '&showAsFieldWeighted=' $fieldweight '&indexType=' $index '&apiKey=' $apikey '&insttoken=bcd1557397d17c62b8531058aa55a8e9' | awk '{print $1$2$3$4$5$6$7$8$9$10$11$12$13$14$15$16$17$18$19$20$21}'`

out=`curl -X GET --header 'Accept: application/json' $inp`
FWCI1=0;FWCI=0;num_sum=0;j=0
for year in $year1 $year2 $year3 $year4 $year5 $year6
do
fwc=`echo $out | awk -F'"valueByYear":{"' '{print $2}' | awk -F$year '{print $2}' | awk -F',' '{print $1}' | awk -F: '{print $2}'`
if [ $fwc != null ];then
	FWCI1=`echo $FWCI1 $fwc ${num[$j]} | awk '{print $1+$2*$3}'`
	num_sum=`echo $num_sum ${num[$j]} | awk '{print $1+$2}'`
fi
j=`echo $j | awk '{print $1+1}'`
done
FWCI=`echo $FWCI1 $num_sum | awk '{print $1/$2}'`

#------------------------ PublicationsInTopJournal
metric=PublicationsInTopJournalPercentiles
inp=`echo 'https://api.elsevier.com/analytics/scival/author/metrics?metricTypes=' $metric '&authors=' $id '&yearRange=' $yr '&includeSelfCitations=' $selfcite '&byYear=' $broke_year '&includedDocs=' $ptype '&journalImpactType=' $impacttype '&showAsFieldWeighted=' $fieldweight '&indexType=' $index '&apiKey=' $apikey '&insttoken=bcd1557397d17c62b8531058aa55a8e9' | awk '{print $1$2$3$4$5$6$7$8$9$10$11$12$13$14$15$16$17$18$19$20$21}'`

out=`curl -X GET --header 'Accept: application/json' $inp`
TOPJ=0;j=0
for year in $year1 $year2 $year3 $year4 $year5 $year6
do
topj=`echo $out | awk -F$thre '{print $2}' | awk -F'"valueByYear":{"' '{print $2}' | awk -F$year '{print $2}' | awk -F',' '{print $1}' | awk -F: '{print $2}'`
if [ $topj != null ];then
	TOPJ=`echo $TOPJ $topj | awk '{print $1+$2}'`
fi
j=`echo $j | awk '{print $1+1}'`
done

#------------------------ OutputsInTopCitation
metric=OutputsInTopCitationPercentiles
inp=`echo 'https://api.elsevier.com/analytics/scival/author/metrics?metricTypes=' $metric '&authors=' $id '&yearRange=' $yr '&includeSelfCitations=' $selfcite '&byYear=' $broke_year '&includedDocs=' $ptype '&journalImpactType=' $impacttype '&showAsFieldWeighted=' $fieldweight '&indexType=' $index '&apiKey=' $apikey '&insttoken=bcd1557397d17c62b8531058aa55a8e9' | awk '{print $1$2$3$4$5$6$7$8$9$10$11$12$13$14$15$16$17$18$19$20$21}'`

out=`curl -X GET --header 'Accept: application/json' $inp`
TOPC=0;j=0
for year in $year1 $year2 $year3 $year4 $year5 $year6
do
topc=`echo $out | awk -F$thre '{print $2}' | awk -F'"valueByYear":{"' '{print $2}' | awk -F$year '{print $2}' | awk -F',' '{print $1}' | awk -F: '{print $2}'`
if [ $topc != null ];then
	TOPC=`echo $TOPC $topc | awk '{print $1+$2}'`
fi
j=`echo $j | awk '{print $1+1}'`
done

if [ "$FWCI" == "" ];then
	FWCI=0
fi
if [ "$TOPJ" == "" ];then
	TOPJ=0
fi
if [ "$TOPC" == "" ];then
	TOPC=0
fi
printf '%s\n' $auid $id $output $FWCI $TOPJ $TOPC | paste -sd "," >> $outfile

done #id
done #inpfile