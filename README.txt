This is a bash version of SciVal author metrics API: https://dev.elsevier.com/scival.html#!/SciVal_Author_Lookup_API/authorMetrics
In this example we collect the researcher's publication data in the past 6 years. For instance, in 2023, we collect the data from 2017-2022. 
The publication data we collect in this example include: the total number of scholarly outputs, FWCI (Field-weighted Citation Impact), Publications In Top 10% Journal, and Outputs In Top 10% Citation. For the metrics guide, go to https://elsevier.widen.net/s/chpzk57rqk/acad_rl_elsevierresearchmetricsbook_web 

1. go to https://dev.elsevier.com/apikey/manage to get your API keys, and put in line 1. apikey=

2. go to https://service.elsevier.com/app/contact/supporthub/dataasaservice/ to request a token, and put in line 2. token=

3. prepare your input file to replace example.csv on line 22. 
   The 1st column is the person's university ID. You may use any ID easier for you to identify the person.
   The 2nd column is the person's Scopus ID. You may collect the IDs through another Repository Scopus-Author-Search-API, or manually search on Scopus web: https://www.scopus.com/freelookup/form/author.uri

4. run the code in a Linux/Unix terminal. command: bash elsevier.api.sh

5. output: researchdata.out.example.csv
   AUID: the researcher's university ID;
   ScopusID: the researcher's Scopus ID;
   Outputs: the total number of Scholarly outputs in the past 6 years
   FWCI: Field-weighted Citation Impact the past 6 years;
   ...
   
