#!/usr/bin/perl                                                                                                                                     
use strict;
use warnings;
use Data::Dumper;

unless ($#ARGV == 0) {print "Usage: star.pl <path>  \n";exit;}

my $data_dir = $ARGV[0];
my $scripts_dir = "/home/strickt2/scripts/shell/";
my $main_out = "/data/strickt2/3377/STAR/";
my $ref = " /data/strickt2/SEQreference/hg38ref/STAR_index/star_indices_overhang150/";
my $genome = "/data/strickt2/SEQreference/hg38ref/Homo_sapiens.GRCh38.dna.primary_assembly.fa";
my $gtf = "/data/strickt2/SEQreference/hg38ref/gtf/Homo_sapiens.GRCh38.87.gtf";
my @files = `find $ARGV[0] -name '*clip*' `;
#my @junctions  = `find $ARGV[0] -name "*SJ.out.tab"`;


my %fin;
foreach my $i (0..$#files){
    chomp $files[$i];
    my @name = split('\/', $files[$i]);
    my @name2 = split(/_/, $name[$#name]);
    if ($files[$i] =~ /CLA/ && $files[$i] =~ /\_1/){
        push @{$fin{$name2[0]}{READ1}},$files[$i];
    }
    elsif ($files[$i] =~ /CLA/ && $files[$i] =~ /\_2/){
        push @{$fin{$name2[0]}{READ2}},$files[$i];
    }

}
print Dumper \%fin;

#my $junctions = join(" ", @junctions);
#$junctions =~ s/\n//g;
#print "$junctions\n";

my $read1;
my $read2;
foreach my $foo (keys %fin){
    $read1=$fin{$foo}{READ1}[0];
    $read2=$fin{$foo}{READ2}[0];
    foreach my $i (1..$#{$fin{$foo}{READ1}}){
	$read1 = $read1.",".$fin{$foo}{READ1}[$i];
	$read2 = $read2.",".$fin{$foo}{READ2}[$i];
    }
}


foreach my $foo (keys %fin){
    #foreach my $i (0..$#{$fin{$foo}{READ1}}){
	
	my $output_script = $scripts_dir.$foo.".star.geno.sh";
	open (OUT, ">$output_script")||die "Can't open $output_script!";
	my $email = "thomas.stricker\@vanderbilt.edu";
	print OUT "\#\!\/bin\/bash\n\#SBATCH --mail-user=$email\n\#SBATCH --mail-type=ALL\n\#SBATCH --nodes=1\n\#SBATCH --ntasks=8\n\#SBATCH --mem=120000mb\n\#SBATCH --time=8:00:00\n\#SBATCH -o /home/strickt2/log/$foo.star.log\n";
        my $out_dir = $main_out.$foo."/";
	`mkdir $out_dir`;
	#print OUT "mkdir $out_dir\n";
       	print OUT "cd $out_dir\n";
        print OUT "setpkgs -a  gcc_compiler_4.9.3\n";
	print OUT "/home/strickt2/SEQanalysis/STAR/source/STAR --outSAMtype BAM SortedByCoordinate --genomeDir $ref --sjdbGTFfile $gtf --twopassMode Basic --outFileNamePrefix $out_dir --readFilesIn $read1 $read2  --readFilesCommand zcat --runThreadN 8\n";
	print "/home/strickt2/SEQanalysis/STAR/source/STAR --outSAMtype BAM SortedByCoordinate --genomeDir $ref --sjdbGTFfile $gtf --twopassMode Basic --outFileNamePrefix $out_dir --readFilesIn $read1 $read2  --readFilesCommand zcat --runThreadN 8\n";

	
        `sbatch $output_script`;
  #}   
}

   




