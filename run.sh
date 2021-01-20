#!/bin/bash
#!/bin/bash                                                                                                                                                                                    
#SBATCH --job-name=perl_perl_all_shared0                                                                                                                                                       
#SBATCH --output=/u/mtaram/spec2017/joint_chkpoints_spec2017/run6/perl_perl/all_shared0/stdout.out                                                                                             
#SBATCH --error=/u/mtaram/spec2017/joint_chkpoints_spec2017/run6/perl_perl/all_shared0/stderr.err
#SBATCH --mem=85GB
#SBATCH --exclude=hermes4
#SBATCH --requeue

module load vscode
module load scons
module load git
module load gcc-6.3.0
module load python3.6.2

HOME=/u/xr5ry/
PROJ="$HOME/src"
bin1="$PROJ/wolfssl-4.5.0/wolfcrypt/benchmark/benchmark"
args1=$2
bin2="$PROJ/duktape-2.6.0/duk"
args2=$3
args2list="3d-raytrace.js controlflow-recursive.js math-cordic.js regexp-dna.js string-base64.js"

case "$1" in
  
  shared)
#    outdir=shared
    simpots=''
    ;;
  partitioned)
#    outdir=partitioned
    simopts='--smtROBPolicy=PartitionedSMTPolicy --smtIQPolicy=PartitionedSMTPolicy --smtTLBPolicy=PartitionedSMTPolicy --smtPhysRegPolicy=PartitionedSMTPolicy --smtSQPolicy=PartitionedSMTPolicy --smtLQPolicy=PartitionedSMTPolicy --smtIssuePolicy=MultiplexingFUs'
    ;;
  adaptive)
#    outdir=adaptive
    simopts='--smtROBPolicy=AdaptiveSMTPolicy --smtIQPolicy=AdaptiveSMTPolicy --smtTLBPolicy=AdaptiveSMTPolicy --smtPhysRegPolicy=AdaptiveSMTPolicy  --smtSQPolicy=AdaptiveSMTPolicy --smtLQPolicy=AdaptiveSMTPolicy --smtIssuePolicy=Adaptive --smtAdaptiveInterval=100000'
    ;;
  symmetric)
#    outdir=symmetric
    simopts='--smtROBPolicy=AdaptiveSMTPolicy --smtIQPolicy=AdaptiveSMTPolicy --smtTLBPolicy=AdaptiveSMTPolicy --smtPhysRegPolicy=DynamicSMTPolicy --smtSQPolicy=AdaptiveSMTPolicy --smtLQPolicy=AdaptiveSMTPolicy  --smtIssuePolicy=Asymmetric --smtAdaptiveInterval=100000'
    ;;
  *)
    echo "wrong scenario"
    exit
esac

outdir=$1__$2__$3

echo running scenario $1
echo running: $bin1 $args1 xx $bin2 $args2
echo 
echo with gem5 args:
echo $simopts

mkdir $outdir
mkdir $outdir/checkpoints
# simulate for some 6~8 hours and take 100 checkpoints over that time
$PROJ/gem5-smt/build/X86/gem5.opt  --outdir $outdir --stats-file=stat-file.txt $PROJ/gem5-smt/configs/example/se.py -c "$bin1;$bin2" --options="$args1;$args2" -I 100000000 --caches --cpu-type=Skylake_3 --l2cache --smt $simopts --maxinsts_threadID=1

echo done running: $bin1 $args1 XXX  $bin2 $args2
