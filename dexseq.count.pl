#!/usr/bin/perl
use warnings;
use Data::Dumper;
unless ($#ARGV == 0) {print "Usage: tophat.fusion.pl <path>\n";exit;}

my $data_dir = $ARGV[0];
my $scripts_dir = "/home/strickt2/scripts/shell/";
my $main_out = $ARGV[0];
my $gff = "/data/strickt2/SEQreference/hg38ref/gtf/Homo_sapiens.GRCh38.87.gff";
my $dexseq = " /home/strickt2/SEQanalysis/python_scripts/dexseq_count.py";
my @files = `find $ARGV[0] -name '*bam' `;
print Dumper \@files;

my %fin;
foreach my $i (0..$#files){
    chomp $files[$i];
    my @temp = split('\/', $files[$i]);
    my @name = split(/\./, $temp[$#temp]);
    $fin{$name[0]}=$files[$i];
}

print Dumper \%fin;

foreach my $foo (keys %fin){
	my $out_file = $main_out.$foo.".count";
    	my $output_script = $scripts_dir.$foo.".tophat.refseq.sh";
	open (OUT, ">$output_script")||die "Can't open $output_script!";
	my $email = "thomas.stricker\@vanderbilt.edu";
	print OUT "\#\!\/bin\/bash\n\#SBATCH --mail-user=$email\n\#SBATCH --mail-type=ALL\n\#SBATCH --nodes=1\n\#SBATCH --ntasks=8\n\#SBATCH --mem=120000mb\n\#SBATCH --time=6:00:00\n\#SBATCH -o /home/strickt2/log/$foo.tophat.log\n";
	print OUT  "python $dexseq  -p yes -s yes -f bam -r pos $gff $fin{$foo} $out_file\n";
        print  "python $dexseq  -p yes -s yes -f bam -r pos $gff $fin{$foo} $out_file\n";
	`sbatch $output_script`;
}




