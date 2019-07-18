me
[zxia@moon 16S_results2019711]$ conda activate qiime2-2019.4
#用完后关闭qiime
conda deactivate
#import data
(qiime2-2019.4) [zxia@moon qiime]$ qiime tools import \
   --type 'SampleData[PairedEndSequencesWithQuality]' \
   --input-path 16S_samplelist \
   --output-path ./paired-end-demux.qza  \

(qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime demux summarize \
  --i-data paired-end-demux.qza \
  --o-visualization paired-end-demux.qzv
#Quality Control
(qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime quality-filter q-score \
  --i-demux paired-end-demux.qza \
  --o-filtered-sequences paired-end-demux-filtered.qza \
  --o-filter-stats paired-end-demux-filter-stats.qza
 #制作metadata表，可视化后下载，手动添加分组信息
(qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime metadata tabulate \
  --m-input-file paired-end-demux-filter-stats.qza \
  --o-visualization paired-end-demux-filter-stats.qzv
#接着使用deblur用于质控及OTU去噪(OTU denoising)
使用质量分数图为数据选择适当的修剪长度。joined.qzv
 值得注意的是，denoising而不是clustering，这是为了明显地区分开传统的OTU与现在的ASV(amplicon sequence variant)。
 注意deblur只接受single-end的序列，如果你把没有jion的序列传递给deblur，它会只处理forward seqs。 
 deblur在denoising时需要输入整齐一样长度的序列，所以需要trim成相同的长度。
 这里需要用到前面join summary里我们记下来的join起来的质量有保障的序列大概有多长的数值。
 Deblur的开发者们建议设置一个质量分数开始迅速下降的长度
 （recommend setting this value to a length where the median quality score begins to drop too low）。
 于是本例中--p-trim-length为240。
另外这一步跑得时间可能稍微久一点，10多分钟。
(qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime deblur denoise-16S \
  --i-demultiplexed-seqs paired-end-demux-filtered.qza \
  --p-trim-length 240 \
  --o-representative-sequences rep-seqs.qza \
  --o-table table.qza \
  --p-sample-stats \
  --o-stats deblur-stats.qza
  
 (qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime deblur visualize-stats \
  --i-deblur-stats deblur-stats.qza \
  --o-visulization deblur-stats.qzv

(qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime feature-table summarize \
  --i-table table.qza \
  --o-visualization table.qzv \
  --m-sample-metadata-file metadata.tsv 

##Feature Table Creation  
(qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime feature-table tabulate-seqs \
  --i-data rep-seqs.qza \
  --o-visualization rep-seqs.qzv
#Phylogenetic Tree Creation
(qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime alignment mafft \
  --i-sequences rep-seqs.qza \
  --o-alignment aligned-rep-seqs.qza
 (qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime alignment mask \
  --i-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza
 (qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime phylogeny fasttree \
  --i-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza
(qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime phylogeny midpoint-root \
  --i-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza
 #The most commonly used phylogenetic index is Faith’s Phylogenetic Diversity (PD; Faith 1992). 
 PD is the phylogenetic analogue of taxon richness and is expressed as the number of tree units which are found in a sample.
 #Core Metrics: Calculated metric values depend on sampling depth
 Alpha diversity
§ Shannon’s diversity index (a quantitative measure of community richness)
§ Observed OTUs (a qualitative measure of community richness)
§ Faith’s Phylogenetic Diversity (a qualitiative measure of community richness that
incorporates phylogenetic relationships between the features)
§ Evenness (or Pielou’s Evenness; a measure of community evenness)
• Beta diversity
§ Jaccard distance (a qualitative measure of community dissimilarity)
§ Bray-Curtis distance (a quantitative measure of community dissimilarity)
§ unweighted UniFrac distance (a qualitative measure of community dissimilarity that
incorporates phylogenetic relationships between the features)
§ weighted UniFrac distance (a quantitative measure of community dissimilarity that
incorporates phylogenetic relationship
 
(qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table table.qza \
  --p-sampling-depth 4085 \
  --m-metadata-file metadata.tsv \
  --output-dir metrics
#Alpha Diversity Group Significance
§Faith’s Phylogenetic Diversity
(qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime diversity alpha-group-significance \
  --i-alpha-diversity metrics/faith_pd_vector.qza \
  --m-metadata-file metadata.tsv \
  --o-visualization metrics/faith_pd_group-significance.qzv
(qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime diversity alpha-group-significance \
  --i-alpha-diversity metrics/shannon_vector.qza \
  --m-metadata-file metadata.tsv \
  --o-visualization metrics/shannon_group-significance.qzv
 (qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime diversity alpha-group-significance \
  --i-alpha-diversity metrics/evenness_vector.qza \
  --m-metadata-file metadata.tsv \
  --o-visualization metrics/evenness_group-significance.qzv
 #Alpha Diversity Correlation
(qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime diversity alpha-correlation \
  --i-alpha-diversity metrics/evenness_vector.qza \
  --m-metadata-file metadata.tsv \
  --o-visualization metrics/evenness_alpha-correlation.qzv
  ##beta多样性的组间差异分析
 (qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime diversity beta-group-significance \
  --i-distance-matrix metrics/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file metadata.tsv \
  --m-metadata-column  group \
  --p-pairwise \
  --o-visualization metrics/unweighted_unifrac_group-significance.qzv
  
 (qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime diversity beta-group-significance \
  --i-distance-matrix metrics/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file metadata.tsv \
  --m-metadata-column group \
  --p-pairwise \
  --o-visualization metrics/weighted_unifrac_group_significance.qzv

  
##在这一节中，我们将开始探索样本的物种组成，并将其与样本元数据再次组合。这个过程的第一步是为FeatureData[Sequence]的序列进行物种注释。
我们将使用经过Naive Bayes分类器预训练的，并由q2-feature-classifier插件来完成这项工作。
这个分类器是在Greengenes 13_8 99% OTU上训练的，其中序列被修剪到仅包括来自16S区域的250个碱基，
该16S区域在该分析中采用V4区域的515F/806R引物扩增并测序。我们将把这个分类器应用到序列中，并且可以生成从序列到物种注释结果关联的可视化。
注意：物种分类器根据你特定的样品制备和测序参数进行训练时表现最好，包括用于扩增的引物和测序序列的长度。
因此，一般来说，你应该按照使用q2-feature-classifier的训练特征分类器的说明来训练自己的物种分类器。
我们在数据资源页面上提供了一些通用的分类器，包括基于Silva的16S分类器，不过将来我们可能会停止提供这些分类器，
而让用户训练他们自己的分类器，这将与他们的序列数据最相关。  
(qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime feature-classifier classify-sklearn \
  --i-classifier ../16S_results/gg     
  --i-classifier ../16S_results/gg-13-8-99-nb-classifier.qza \
  --i-reads rep-seqs.qza \
  --o-classification taxonomy.qza
(qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv
(qiime2-2019.4) [zxia@moon 16S_results2019711]$ qiime taxa barplot \
  --i-taxonomy taxonomy.qza \
  --i-table table.qza \
  --m-metadata-file metadata.tsv \
  --o-visualization taxa-bar-plots.qzv
