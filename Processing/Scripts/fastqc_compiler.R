### Load library

library(tidyverse)

### Load variables with arguments

setwd("~/EMERSON/wetup/")
parsed_dir <- "Processing/Data/fastqc/parsed/"
output_dir <- "Processing/Data/fastqc/compiled/"
sets <- c("wub_raw1", "wub_raw2", "wub_raw3", "wub_raw4", "wub_cat_rmphix")
prefix <- "wub"

### Function for reading files

read_fastqc <- function(txt){
  read.table(txt, header = T, sep = "\t", fill = T, quote = "")
}

### Create the empty files

adapter.cnt <- data.frame()
basic.stats <- data.frame()
overrep.seq <- data.frame()
p.base.n.ct <- data.frame()
p.base.seq.ct <- data.frame()
p.base.seq.q <- data.frame()
p.seq.gc.ct <- data.frame()
p.seq.q.scr <- data.frame()
#p.tile.seq.q <- data.frame()
seq.dup <- data.frame()
seq.len.dist <- data.frame()

### Fill files

for (set in sets) {
  adapter.cnt <- rbind(adapter.cnt, read_fastqc(paste(parsed_dir, set, "_adapter_ctnt.txt",  sep = "")) %>% mutate(Type = set))
  basic.stats <- rbind(basic.stats, read_fastqc(paste(parsed_dir, set, "_basic_stats.txt", sep = "")) %>% mutate(Type = set))
  overrep.seq <- rbind(overrep.seq, read_fastqc(paste(parsed_dir, set, "_overrep_seqs.txt", sep = "")) %>% mutate(Type = set)) 
  p.base.n.ct <- rbind(p.base.n.ct, read_fastqc(paste(parsed_dir, set, "_per_base_n_ctnt.txt", sep = "")) %>% mutate(Type = set)) 
  p.base.seq.ct <- rbind(p.base.seq.ct, read_fastqc(paste(parsed_dir, set, "_per_base_seq_ctnt.txt", sep = "")) %>% mutate(Type = set)) 
  p.base.seq.q <- rbind(p.base.seq.q, read_fastqc(paste(parsed_dir, set, "_per_base_seq_qual.txt", sep = "")) %>% mutate(Type = set)) 
  p.seq.gc.ct <- rbind(p.seq.gc.ct, read_fastqc(paste(parsed_dir, set, "_per_seq_gc_ctnt.txt", sep = "")) %>% mutate(Type = set)) 
  p.seq.q.scr <- rbind(p.seq.q.scr, read_fastqc(paste(parsed_dir, set, "_per_seq_qual_scrs.txt", sep = "")) %>% mutate(Type = set)) 
  #p.tile.seq.q <- rbind(p.tile.seq.q, read_fastqc(paste(parsed_dir, set, "_per_tile_seq_qual.txt", sep = "")) %>% mutate(Type = set)) 
  seq.dup <- rbind(seq.dup, read_fastqc(paste(parsed_dir, set, "_seq_dup_lvls.txt", sep = "")) %>% mutate(Type = set))
  seq.len.dist <- rbind(seq.len.dist, read_fastqc(paste(parsed_dir, set, "_seq_len_dstr.txt", sep = "")) %>% mutate(Type = set)) 
}

### Reformat basic stats
basic.stats <- basic.stats %>% 
  filter(!Measure %in% c("Filename", "File type", "Encoding")) %>%
  mutate(Measure = fct_recode(Measure, 
                              "Total_Sequences" = "Total Sequences",
                              "Poor_Qual_Seqs" = "Sequences flagged as poor quality",
                              "Sequence_Length" = "Sequence length",
                              "GC" = "%GC")) %>% 
  spread(key = Measure, value = Value) %>% 
  separate(Sequence_Length, c("Short", "Long")) %>% 
  mutate(Long = ifelse(is.na(Long), Short, Long)) %>% 
  mutate(GC = as.numeric(as.character(GC)),
         Short = as.numeric(as.character(Short)),
         Long = as.numeric(as.character(Long)),
         Poor_Qual_Seqs = as.numeric(as.character(Poor_Qual_Seqs)),
         Total_Sequences = as.numeric(as.character(Total_Sequences)))

### Save RDS files

saveRDS(adapter.cnt, paste(output_dir, prefix, "_adapter_ctnt.RDS", sep = ""))
saveRDS(basic.stats, paste(output_dir, prefix, "_basic_stats.RDS", sep = ""))
saveRDS(overrep.seq, paste(output_dir, prefix, "_overrep_seqs.RDS", sep = ""))
saveRDS(p.base.n.ct, paste(output_dir, prefix, "_per_base_n_ctnt.RDS", sep = ""))
saveRDS(p.base.seq.ct, paste(output_dir, prefix, "_per_base_seq_ctnt.RDS", sep = ""))
saveRDS(p.base.seq.q, paste(output_dir, prefix, "_per_base_seq_qual.RDS", sep = ""))
saveRDS(p.seq.gc.ct, paste(output_dir, prefix, "_per_seq_gc_ctnt.RDS", sep = ""))
saveRDS(p.seq.q.scr, paste(output_dir, prefix, "_per_seq_qual_scrs.RDS", sep = ""))
#saveRDS(p.tile.seq.q, paste(output_dir, prefix, "_per_tile_seq_qual.RDS", sep = "")) 
saveRDS(seq.dup, paste(output_dir, prefix, "_seq_dup_lvls.RDS", sep = ""))
saveRDS(seq.len.dist, paste(output_dir, prefix, "_seq_len_dstr.RDS", sep = ""))