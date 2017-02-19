#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

unless ($#ARGV == 0) {print "Usage: clip.pl < path >\n";exit;}

my $data_dir = $ARGV[0];
my $scripts_dir = "/home/strickt2/scripts/shell/";

my @files = `find $ARGV[0] -name '*.gz'`;
print Dumper \@files; 

my %fin;
foreach my $i (0..$#files){
    chomp $files[$i];
    if ($files[$i] =~ /gz$/){
	my @temp = split(/\//,$files[$i]); 
       my @name = split('\_', $temp[$#temp]);

       if ($name[0] =~ /CLA/ && $files[$i] =~ /\_1/){
	   $fin{$name[0]}{READ1} = $files[$i];
       }
       elsif ($name[0] =~ /CLA/ && $files[$i] =~ /\_2/){
	   $fin{$name[0]}{READ2} = $files[$i];
       }
    }
}
print Dumper \%fin;


my $out_dir = $ARGV[0]."/clip/";
`mkdir $out_dir`;

foreach my $foo (keys %fin){    
	my $output_script = $scripts_dir.$foo.".clip.sh";
	open (OUT, ">$output_script")||die "Can't open $output_script!";
	my $email = "thomas.stricker\@vanderbilt.edu";	
	print OUT "\#\!\/bin\/bash\n\#SBATCH --mail-user=$email\n\#SBATCH --mail-type=ALL\n\#SBATCH --nodes=1\n\#SBATCH --ntasks=4\n\#SBATCH --mem=10000mb\n\#SBATCH --time=8:00:00\n\#SBATCH -o /home/strickt2/log/$foo.clip.log\n";
	my $PE_out1 = $data_dir."/clip/".$foo.".clip_1_sequence.txt.gz";
	my $PE_out2 = $data_dir."/clip/".$foo.".clip_2_sequence.txt.gz";
	print OUT "fastq-mcf  -q 7 -l 25 -o $PE_out1 -o $PE_out2 /home/strickt2/SEQanalysis/FastQC/Contaminants/illumina.primers.fa $fin{$foo}{READ1} $fin{$foo}{READ2}\n";
	print  "fastq-mcf  -q 7 -l 25 -o $PE_out1 -o $PE_out2 /home/strickt2/SEQanalysis/FastQC/Contaminants/illumina.primers.fa $fin{$foo}{READ1} $fin{$foo}{READ2}\n";
	
	`sbatch $output_script`;
  
}
  

