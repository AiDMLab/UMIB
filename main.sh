#!/bin/bash
main_directory="/media/d102/ai1/guoman/example"
data_directory=${main_directory}/data
mkdir ${main_directory}/result
result_directory=${main_directory}/result

cd ${main_directory}
ls ${data_directory} > dataname.txt

for x in `cat ${main_directory}/dataname.txt`
do
y=${x%.*}
mkdir ${result_directory}/${y}
cd ${result_directory}/${y}
########unmapped reads whose mate are mapped
samtools view -u -f 4 -F 264 ${data_directory}/${x} -o ${y}_unmappedone.bam
samtools view ${y}_unmappedone.bam | cut -f1,10 | sed 's/^/>/' | sed 's/\t/\n/' > ${y}_unmappedone.fasta
########both reads of the pair are unmapped
samtools view -u -f 12 -F 256 ${data_directory}/${x} -o ${y}_unmappedtwo.bam
samtools view ${y}_unmappedtwo.bam | cut -f1,10,11 | sed 's/^/@/' | sed 's/\t/\n/' | sed 's/\t/\n+\n/' > ${y}_unmappedtwo.fastq
bash ${main_directory}/fastq_standard.sh ${y}_unmappedtwo.fastq ${y}_unmappedtwo_s.fastq
awk '0 == ((NR+4) % 8)*((NR+5) % 8)*((NR+6) % 8)*((NR+7) %8)' ${y}_unmappedtwo_s.fastq | awk '{ if(NR%4==1) { print $0 "/1" } else { print $0 } }' > ${y}_unmappedtwo_1.fastq
awk '0 == (NR % 8)*((NR+1) % 8)*((NR+2) % 8)*((NR+3) %8)' ${y}_unmappedtwo_s.fastq | awk '{ if(NR%4==1) { print $0 "/2" } else { print $0 } }' > ${y}_unmappedtwo_2.fastq
pandaseq -f ${y}_unmappedtwo_1.fastq -r ${y}_unmappedtwo_2.fastq -B -w ${y}_assemble.fasta
###################
cat ${y}_unmappedone.fasta >> ${y}_unmapped.fasta
cat ${y}_assemble.fasta >> ${y}_unmapped.fasta
#############bwa grammy
#############tar zxvf reference_bacteria.tar main_directory
cd ${main_directory}
cp ${result_directory}/${y}/${y}_unmapped.fasta .
grammy_rdt . . -s .fasta
bwa mem -a -S -t 15 reference.fna.1 ${y}_unmapped.fasta > ${y}_unmapped.sam.1
sh ${main_directory}/convert-to-sorted-bam.sh ${y}_unmapped.sam.1 ${y}_unmapped.bam.1
grammy_pre ${y}_unmapped reference -m bam -p ${y}_unmapped.bam
grammy_em ${y}_unmapped.bam.mtx
grammy_post ${y}_unmapped.bam.est reference ${y}_unmapped.bam.btp
cat ${y}_unmapped.bam.mtx | tail -n +2 | head -n 1 > mapped-number.txt
cp ${y}_unmapped.bam.gra ${y}_unmapped.bam.mtx ${y}_unmapped.bam mapped-number.txt ${result_directory}/${y}/.
rm ${y}_unmapped.bam.1 ${y}_unmapped.bam.1.bai ${y}_unmapped.bam.avl ${y}_unmapped.bam.btp ${y}_unmapped.bam.est ${y}_unmapped.bam.gra ${y}_unmapped.bam.lld ${y}_unmapped.bam.mtx ${y}_unmapped.fasta ${y}_unmapped.fasta.gz ${y}_unmapped.rdt ${y}_unmapped.sam.1 ${y}_unmapped.sam.1.bam mapped-number.txt
done


