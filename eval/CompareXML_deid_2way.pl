#!/usr/bin/perl

#This code compares two XML files (one is the machine output, the other is the gold standard answer)
#This code evaluates XML based on 2 way classification: 
#"NONE",1,"PHI",2

#The XML tags that label PHIs should be in the format <PHI TYPE="DATE">WORD</PHI>, where there is no space between the <PHI> tags and 
#the words they identify.  <PHI TYPE="DATE"> WORD </PHI> is incorrect.
#The code evaluates the XML files word level evaluation (evaluating matches word-by-word) using f measures

#The output contains the word level confusion matrix and the precision, recall and f-measures for each phi
#The output was written to corresponding file to the input. e.g. if the input file to evaluate is a.xml, then output file is a.2wayresult
#works for both OVERALL VALUES FOR BOTH BINARY AND MULTI

use strict;
open(ACT, "$ARGV[0]"); #actual/gold standard 
open(IN, "$ARGV[1]"); #results/machine output

my $outfile = $ARGV[1];
$outfile =~ s/\.xml/\.2wayresult/g;
open(OUT, ">$outfile");

# VERBOSE MODES:
#  0 normal
#  1 show mismatches 
#  2 debug mode

my $verbosemode=$ARGV[2];

my @lines = <ACT>;
my $line_num = 0;

my @sens;

my $i;
my $j;
for($i = 1; $i <= 9; $i++)
{
    for ($j = 1; $j <= 9; $j++)
    {	
	$sens[$i][$j] =0;
    }
}


my $correct = 0;
my $total = 0;
my $line;
my $line_ac;
my $acc;
my $in;

my %phi = ("NONE",1,"PATIENT",2,"DOCTOR",3,"LOCATION",4,"HOSPITAL",5,"DATE",6,"ID",7,"PHONE",8,"AGE",9);
my @keys = ("","NONE","PHI");

#WORD LEVEL CONFUSION MATRIX
my $line_t;
my $resPhiType=1;
my $resPhiEnd="false";
my $actPhiType=1;
my $actPhiEnd="false";


while(<IN>)
{
    $line_t = $_; 
    $total++;
    chomp($line_t);
    $line_ac = $lines[$line_num];
    chomp($line_ac);
    
    my @act = split/ /,$line_ac;
    my @res = split/ /,$line_t;
    #print OUT "$line_ac\n";
    
    my $word_num=0;
    my $predix_res = "";
    my $predix_act = "";
    foreach my $word (@act)	{
     	while( $res[$word_num] =~ /(.*)<PHI/ )	{
     		$predix_res .= $1;
          	$word_num++;
     	}

    	
     	if( $word =~ /(.*)<PHI/ )	{

        }else	{

	       	if( defined $verbosemode and $verbosemode==2 )	{
	          	print OUT "COMPARE: $word to $res[$word_num]\n";
	       	}
	       	
	       	#GET THE CURRENT PHI TYPE FOR WORD IN ACTUAL, STRIP XML TAGS 
	       	if( $word =~ s/TYPE=\"(.*?)\">// ){
	          	$actPhiType=$phi{$1};
		    }
	      	if( $word =~ s/<\/PHI>.*// ){
	          	$actPhiEnd="true";
	      	}
	      	
	      	my $result = $predix_res . $res[$word_num];
	      	$result =~ s/TYPE=\"(.*?)\">//g;
	      	$result =~ s/<\/PHI>//g;
	    	my @token_ori = split /\/|-/, $result;
	    	
	       	#GET THE CURRENT PHI TYPE FOR WORD IN RESULT, STRIP XML TAGS
		    if( $res[$word_num] =~ s/TYPE=\"(.*?)\">// ){
		        $resPhiType = $phi{$1};
		
		    }
		    if($res[$word_num]=~s/<\/PHI>.*//){
		        $resPhiEnd="true";
		    }
		    
		    if( $actPhiType == 6 )	{
			    my $spurious = 0;
			    my $per = 0;
			    # deals with special case of date boundary mismatch in one word   
			    # assume there can't be two phi types in one word
			    my @token_ac = split /\/|-/, $word;
			    if( length($token_ac[0]) == 0 )	{
			    	shift @token_ac;
			    }
			    my $token_ac_num = scalar( @token_ac );
			    
			    my @token_t = split /\/|-/, $res[$word_num];
			   	if( length($token_t[0]) == 0 )	{
			    	shift @token_t;
			    }
			    my $token_t_num = scalar( @token_t );
			    

			       	
		       	my $match = 0;
		       	my $count = 0;
		       	# try to find the longest match
				for( my $i = 0; $i < $token_ac_num; $i++ )	{
					for( my $j = 0; $j < $token_t_num; $j++ )	{
						while( $i+$count < $token_ac_num and $j+$count < $token_t_num and $token_ac[$i+$count] eq $token_t[$j+$count] )	{
							$count++;
						}
						$match = ($match > $count) ? $match : $count;
					}
				}
		       	$per = $match;
		       	$spurious = $token_t_num - $match;
		
			       
			    $sens[$actPhiType][$resPhiType] += $per;
			    $sens[1][$resPhiType] += $spurious;
			    $sens[$actPhiType][1] += $token_ac_num - $per;
			    $sens[1][1] += scalar(@token_ori) - $token_ac_num - $spurious ;
		    }else {
		    	$sens[$actPhiType][$resPhiType] ++;
		    }
		      
		    #RESET PHI TYPE IF THE WORD IS THE LAST WORD ENCLOSED BY PHI TAGS
		    if($resPhiEnd eq "true"){
		        $resPhiType=1;
				$resPhiEnd="false";
		    }
		    if($actPhiEnd eq "true"){
		        $actPhiType=1;
			  	$actPhiEnd = "false";
		    }  
		       
		    $word_num++;
    	}
	}
    
  	$line_num++;
}

close(IN);

# recount to 2 way
my @sens_2way = ();

$sens_2way[1][1] = $sens[1][1];

for( my $i = 2; $i <= 9; $i++ ) {
	$sens_2way[1][2] += $sens[1][$i];
	$sens_2way[2][1] += $sens[$i][1]; 
}

for( my $i = 2; $i <= 9; $i++ )	{
	for( my $j = 2; $j <=9; $j++ )	{
		$sens_2way[2][2] += $sens[$i][$j];
	}
}

@sens = ();
@sens = @sens_2way;

print OUT "2 way Word Level Confusion Matrix\n";

print OUT "none phi\n";
print OUT "$sens[1][1]\t$sens[1][2]\tnone\n";
print OUT "$sens[2][1]\t$sens[2][2]\tphi\n";
print OUT "\n\n";
print OUT "X: MACHINE LABEL    Y: GOLD STANDARD LABEL\n\n";

print OUT "F-measures for all data\n";
&printFMeasure();   
print OUT "\n\n";

#USED TO EVALUATE WORD LEVEL CONFUSION MATRICES 
sub printFMeasure{
  	# I corrected the index bug here, it should started from 1 instead of 0 according to previous program setting
  	for($i=1; $i<=$#sens; $i++){
     	my $tot=0;
     	my $pred=0;
     
     	#Tot - total number of type $i in key
     	#Pred - total number of type $i in machine output result
     	for($j=1; $j<=$#sens; $j++){
        	$tot += $sens[$i][$j];
        	$pred += $sens[$j][$i];
     	}   
     
     	#Precision
     	my $prec;
     	if($pred==0){
        	$prec = 0;
     	}else{
        	$prec = $sens[$i][$i]/$pred;
     	}
     
     	#Recall
     	my $rec;
     	if($tot==0){
        	$rec=0;
     	}else{
        	$rec=$sens[$i][$i]/$tot;
     	}
     
     	#F-Measure
     	my $f;
     	if(($prec*$rec)==0){
        	$f = 0;
     	}else{
        	$f = (2*$prec*$rec)/($prec+$rec);
     	}
     
     	print OUT "$keys[$i]\t:\tprecision =\t$prec\trecall =\t$rec\tf-measure =\t$f\n";
  	}
}  




